import 'dart:async';
import 'dart:convert' show UTF8, JSON;
import 'dart:io' show HttpClient, HttpStatus, ContentType;

import 'package:http/http.dart' as http;

import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/actions/hn_account_actions.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';

class HNAuthService {
  static final HNAuthService _singleton = new HNAuthService._internal();

  final _httpClient = new HttpClient();

  HNConfig _config = new HNConfig();

  HNAuthService._internal ();

  factory HNAuthService () {
    return _singleton;
  }

  Future<bool> addAccount (String userId, String userPassword) async {
    final req = await _httpClient.postUrl(Uri.parse('${this._config.apiHost}/login'))
      ..headers.contentType = new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8')
      ..write('acct=$userId&pw=$userPassword');

    return req.close()
      .then((res) {
        if (
          (res.statusCode == HttpStatus.OK || res.statusCode == HttpStatus.MOVED_TEMPORARILY) &&
          res.cookies.firstWhere((cookie) => cookie.name == 'user') != null
        ) {
          return res;
        } else {
          throw res;
        }
      })
      .then((res) async {
        addHNAccount(new HNAccount(
          id: userId,
          password: userPassword,
          accessToken: res.cookies.firstWhere((cookie) => cookie.name == 'user').value.split('&')[1],
        ));
        return true;
      })
      .catchError((err) {
        print(err);
        return false;
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
