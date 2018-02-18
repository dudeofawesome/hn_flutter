import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' show JSON;

import 'package:hn_flutter/sdk/services/abstract/hn_user_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/models/hn_user.dart';
import 'package:hn_flutter/sdk/actions/hn_user_actions.dart';

class HNUserServiceProd implements HNUserService {
  HNConfig _config = new HNConfig();

  Future<HNUser> getUserByID (String id) {
    addHNUser(new HNUser(id: id, computed: new HNUserComputed(loading: true)));

    return http.get('${this._config.url}/user/$id.json')
      .then((res) => JSON.decode(res.body))
      .then((body) async {
        if (body != null) return new HNUser.fromMap(body);
        else return this._getUserByIdFromSite(id);
      })
      .then((user) {
        addHNUser(user);
      });
  }

  Future _getUserByIdFromSite (String id) {
    return http.get('${this._config.apiHost}/user?id=$id')
      .then((res) {
        if (res.statusCode != 200) throw 'User "$id" not found';
        return res.body;
      })
      .then((body) {
        if (body == 'No such user.') throw 'User "$id" not found';
        else {
          final created = (DateTime.parse(_createdRegExp.firstMatch(body)?.group(1)).millisecondsSinceEpoch / 1000).round();
          final karma = int.parse(_karmaRegExp.firstMatch(body)?.group(1) ?? '1');
          final about = _aboutRegExp.firstMatch(body)?.group(1);

          return new HNUser(
            id: id,
            created: created,
            karma: karma,
            about: about,
            submitted: [],
          );
        }
      });
  }
}

final _createdRegExp = new RegExp(r'''created:.*?<td><a href="front\?day=([0-9\-]+)&birth=''');
final _karmaRegExp = new RegExp(r'''<td valign="top">karma:<\/td><td>\s*([0-9]+)\s*<\/td>''');
final _aboutRegExp = new RegExp(r'''<td valign="top">about:<\/td><td>\s*(.*)\s*<\/td>''');
