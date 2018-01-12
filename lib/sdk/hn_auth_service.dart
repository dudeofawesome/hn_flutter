import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hn_flutter/sdk/sqlite_vals.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/actions/hn_account_actions.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';

class HNAuthService {
  static final HNAuthService _singleton = new HNAuthService._internal();

  HNConfig _config = new HNConfig();

  HNAuthService._internal ();

  factory HNAuthService () {
    return _singleton;
  }

  Future<bool> addAccount (String userId, String userPassword) async {
    return http.post(
        '${this._config.apiHost}/login',
        body: {
          'acct': userId,
          'pw': userPassword,
        },
      )
      .then((res) {
        print(res);
        print(res.body);
        if (!res.body.contains('Bad login.')) {
          addHNAccount(new HNAccount(
            id: userId,
            password: userPassword,
          ));
          return true;
        } else {
          return false;
        }
      });
  }

  Future<bool> removeAccount (String userId) async {
    // return http.post(
    //     '${this._config.apiHost}/login',
    //     body: {
    //       'acct': userId,
    //       'pw': userPassword,
    //     },
    //   )
    //   .then((res) {
    //     print(res);
    //     print(res.body);
    //     if (!res.body.contains('Bad login.')) {
    //       addHNAccount(new HNAccount(
    //         id: userId,
    //         password: userPassword,
    //       ));
    //       return true;
    //     } else {
    //       return false;
    //     }
    //   });
    removeHNAccount(userId);
    return true;
  }
}
