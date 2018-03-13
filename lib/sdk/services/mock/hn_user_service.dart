import 'dart:async';
import 'dart:convert' show json;
import 'dart:io' show Cookie;

import 'package:http/http.dart' as http;

import 'package:hn_flutter/sdk/services/abstract/hn_user_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/models/hn_user.dart';
import 'package:hn_flutter/sdk/actions/hn_user_actions.dart';

class HNUserServiceMock implements HNUserService {
  HNConfig _config = new HNConfig();

  Future<HNUser> getUserByID (String id) {
    addHNUser(new HNUser(id: id, computed: new HNUserComputed(loading: true)));

    return http.get('${this._config.url}/user/$id.json')
      .then((res) => json.decode(res.body))
      .then((user) => new HNUser.fromMap(user))
      .then((user) {
        addHNUser(user);
      });
  }

  Future<List<int>> getSavedByUserID (String id, bool stories, Cookie accessCookie) async {
    return new List();
  }

  Future<List<int>> getVotedByUserID (String id, bool stories, Cookie accessCookie) async {
    return new List();
  }
}
