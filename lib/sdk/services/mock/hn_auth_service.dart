import 'dart:async';
import 'dart:io' show HttpClient, HttpStatus, ContentType, Cookie;
import 'dart:convert' show UTF8;

import 'package:http/http.dart' as http;

import 'package:hn_flutter/sdk/services/abstract/hn_auth_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/actions/hn_account_actions.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';

class HNAuthServiceMock implements HNAuthService {
  static final HNAuthServiceMock _singleton = new HNAuthServiceMock._internal();

  final _config = new HNConfig();
  final _httpClient = new HttpClient();

  HNAuthServiceMock._internal ();

  factory HNAuthServiceMock () {
    return _singleton;
  }

  Future<bool> addAccount (String userId, String userPassword) async {
    final req = await _httpClient.postUrl(Uri.parse('${this._config.apiHost}/login?goto=%2Fuser%3Fid%3D$userId'))
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
        String email;
        Cookie accessCookie = res.cookies.firstWhere((cookie) => cookie.name == 'user');

        final userReq = await (await _httpClient.getUrl(Uri.parse('${this._config.apiHost}/user?id=$userId'))
          ..cookies.add(accessCookie)).close();
        final body = await userReq.transform(UTF8.decoder).toList().then((body) => body.join());

        final emailMatch = new RegExp(r'<input.*?name="uemail".*?value="(.*?)".*?>').firstMatch(body);
        if (emailMatch != null) {
          email = emailMatch[1];
        }

        return new HNAccount(
          id: userId,
          email: email,
          password: userPassword,
          accessCookie: accessCookie,
        );
      })
      .then((account) {
        addHNAccount(account);
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
