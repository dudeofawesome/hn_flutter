import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io' show HttpClient, HttpStatus, ContentType, Cookie;
import 'dart:ui' show Color;

// import 'package:html/dom.dart' show ;
import 'package:html/parser.dart' show parse;

import 'package:hn_flutter/sdk/services/abstract/hn_auth_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/actions/hn_account_actions.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';

class HNAuthServiceProd implements HNAuthService {
  static final HNAuthServiceProd _singleton = new HNAuthServiceProd._internal();

  final _config = new HNConfig();
  final _httpClient = new HttpClient();

  HNAuthServiceProd._internal ();

  factory HNAuthServiceProd () {
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
        final accessCookie = res.cookies.firstWhere((cookie) => cookie.name == 'user');

        final userReq = await (await _httpClient.getUrl(Uri.parse('${this._config.apiHost}/user?id=$userId'))
          ..cookies.add(accessCookie)).close();
        final body = await userReq.transform(utf8.decoder).toList().then((body) => body.join());

        final doc = parse(body);

        final email = doc.querySelector('input[name=uemail]')
          ?.attributes['value'];

        final canDownvote = doc.querySelector('a[href*=downvoted]') != null;

        final topColorEl = doc.querySelector('input[name=topcolor]');
        final topColor = topColorEl != null
          ? new Color(int.parse('0xFF${topColorEl.attributes['value']}'))
          : null;
        final showDeadEl = doc.querySelector('select[name=showd]')
          ?.querySelector('option[selected]');
        final showDead = showDeadEl != null
          ? (showDeadEl.attributes['value'] == 'yes')
          : null;
        final noProcrastinateEl = doc.querySelector('select[name=nopro]')
          ?.querySelector('option[selected]');
        final noProcrastinate = noProcrastinateEl != null
          ? (noProcrastinateEl.attributes['value'] == 'yes')
          : null;
        final maxVisitEl = doc.querySelector('input[name=maxv]');
        final maxVisit = maxVisitEl != null
          ? new Duration(minutes: int.parse(maxVisitEl.attributes['value']))
          : null;
        final minAwayEl = doc.querySelector('input[name=mina]');
        final minAway = minAwayEl != null
          ? new Duration(minutes: int.parse(minAwayEl.attributes['value']))
          : null;
        final delayEl = doc.querySelector('input[name=delay]');
        final delay = delayEl != null
          ? new Duration(minutes: int.parse(delayEl.attributes['value']))
          : null;

        return new HNAccount(
          id: userId,
          email: email,
          password: userPassword,
          accessCookie: accessCookie,
          permissions: new HNAccountPermissions(
            canDownvote: canDownvote,
          ),
          preferences: new HNAccountPreferences(
            topColor: topColor,
            showDead: showDead,
            noProcrastinate: noProcrastinate,
            maxVisit: maxVisit,
            minAway: minAway,
            delay: delay,
          )
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
