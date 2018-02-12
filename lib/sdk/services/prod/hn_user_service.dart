import 'dart:async';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'dart:convert' show JSON;

import 'package:flutter/foundation.dart';

import 'package:hn_flutter/sdk/services/abstract/hn_user_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/models/hn_user.dart';
import 'package:hn_flutter/sdk/actions/hn_user_actions.dart';

class HNUserServiceProd implements HNUserService {
  static final _config = new HNConfig();
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
          final user = await http.get('${_config.url}/user/${data.params}.json')
            .then((res) => JSON.decode(res.body))
            .then((user) => new HNUser.fromMap(user));
          replyTo.send(user);
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
}

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
