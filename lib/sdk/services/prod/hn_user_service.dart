import 'dart:async';
import 'dart:isolate';
import 'dart:convert' show json, utf8;
import 'dart:io' show HttpClient, ContentType, Cookie;

import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import 'package:hn_flutter/sdk/services/abstract/hn_user_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/models/hn_user.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/actions/hn_user_actions.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

class HNUserServiceProd implements HNUserService {
  static final _config = new HNConfig();
  final _httpClient = new HttpClient();
  final _receivePort = new ReceivePort();
  SendPort _sendPort;

  Future<Null> init () async {
    assert(this._sendPort == null, 'HNUserServiceProd::init has already been called');

    await Isolate.spawn(_onMessage, this._receivePort.sendPort);
    this._sendPort = await _receivePort.first;
  }

  static Future<Null> _onMessage (SendPort sendPort) async {
    final port = new ReceivePort();
    sendPort.send(port.sendPort);

    // handle message passing
    await for (final msg in port) {
      final _IsolateMessage data = msg[0];
      final SendPort replyTo = msg[1];

      switch (data.type) {
        case _IsolateMessageType.GET_USER_BY_ID:
          new Future(() async {
            final user = await http.get('${_config.url}/user/${data.params}.json')
              .then((res) => json.decode(res.body))
              .then((body) async {
                if (body != null) return new HNUser.fromMap(body);
                else return _getUserByIdFromSite(data.params);
              });
            replyTo.send(user);
          });
          break;
        case _IsolateMessageType.DESTRUCT:
          port.close();
          break;
      }
    }
  }

  Future<HNUser> getUserByID (String id) async {
    addHNUser(new HNUser(id: id, computed: new HNUserComputed(loading: true)));

    final response = new ReceivePort();
    this._sendPort.send([new _IsolateMessage(
      type: _IsolateMessageType.GET_USER_BY_ID,
      params: id,
    ), response.sendPort]);

    final HNUser user = await response.first;
    addHNUser(user);
    return user;
  }

  static Future _getUserByIdFromSite (String id) {
    return http.get('${_config.apiHost}/user?id=$id')
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

  Future<List<int>> getSavedByUserID (String id, bool stories, Cookie accessCookie) async {
    final req = await ((await _httpClient.getUrl(Uri.parse(
        '${_config.apiHost}/favorites?id=$id&comments=${stories ? 'f' : 't'}'
      )))
      ..cookies.add(accessCookie)
      ..headers.contentType = new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8'))
      .close();

    print(req.headers);
    final body = await req.transform(utf8.decoder).toList().then((body) => body.join());
    print(body);
    if (body.contains('Bad login')) throw 'Bad login.';
    if (req.headers.value('location') != null) throw 'Unknown error';

    final items = (stories ? _storyIdRegExp : _commentIdRegExp)
      .allMatches(body)
        .map((match) => match?.group(1))
        .where((id) => id != null)
        .map((id) => int.parse(id))
        .toList();

    items.forEach((itemId) =>
      patchItemStatus(new HNItemStatus.patch(id: itemId, saved: true)));

    return items;
  }

  Future<List<int>> getVotedByUserID (String id, bool stories, Cookie accessCookie) async {
    final req = await ((await _httpClient.getUrl(Uri.parse(
        '${_config.apiHost}/upvoted?id=$id&comments=${stories ? 'f' : 't'}'
      )))
      ..cookies.add(accessCookie)
      ..headers.contentType = new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8'))
      .close();

    final body = await req.transform(utf8.decoder).toList().then((body) => body.join());
    if (body.contains('Bad login')) throw 'Bad login.';
    if (req.headers.value('location') != null) throw 'Unknown error';

    final items = (stories ? _storyIdRegExp : _commentIdRegExp)
      .allMatches(body)
        .map((match) => match?.group(1))
        .where((id) => id != null)
        .map((id) => int.parse(id))
        .toList();

    items.forEach((itemId) =>
      patchItemStatus(new HNItemStatus.patch(id: itemId, upvoted: true)));

    return items;
  }
}

final _storyIdRegExp = new RegExp(r'''<tr class=["']athing["'] id=["']([0-9]+)["']>''');
final _commentIdRegExp = new RegExp(r'''<tr class=["']athing["'] id=["']([0-9]+)["']>''');

final _createdRegExp = new RegExp(r'''created:.*?<td><a href="front\?day=([0-9\-]+)&birth=''');
final _karmaRegExp = new RegExp(r'''<td valign="top">karma:<\/td><td>\s*([0-9]+)\s*<\/td>''');
final _aboutRegExp = new RegExp(r'''<td valign="top">about:<\/td><td>\s*(.*)\s*<\/td>''');

class _IsolateMessage {
  _IsolateMessageType type;
  dynamic params;

  _IsolateMessage ({
    @required this.type,
    @required this.params,
  });
}

enum _IsolateMessageType {
  GET_USER_BY_ID,
  DESTRUCT,
}
