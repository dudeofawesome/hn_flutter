import 'dart:async';
import 'dart:convert' show JSON, UTF8;
import 'dart:io' show HttpClient, HttpStatus, ContentType, Cookie;

import 'package:http/http.dart' as http;

import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';

class HNItemService {
  final _config = new HNConfig();
  final _httpClient = new HttpClient();

  Future<HNItem> getItemByID (int id) {
    addHNItem(new HNItem(id: id));
    patchItemStatus(new HNItemStatus.patch(id: id, loading: true));

    return http.get('${this._config.url}/item/$id.json')
      .then((res) => JSON.decode(res.body))
      .then((item) => new HNItem.fromMap(item))
      .then((item) {
        addHNItem(item);
        patchItemStatus(new HNItemStatus.patch(id: id, loading: false));

        return item;
      });
  }

  Future<String> _getItemAuthTokens (int itemId, String token, Cookie accessCookie) async {
    final req = await (await _httpClient.getUrl(Uri.parse(
        '${this._config.apiHost}/item'
        '?id=$itemId'
      ))
      ..cookies.add(accessCookie))
      .close();

    // req.transform(UTF8.decoder).listen((data) {
    //   print(data);
    // });

    // final body = '';

    final body = await req.transform(UTF8.decoder).toList().then((body) => body.join());

    if (body.contains(new RegExp(r'''<a.*?href=(?:"|')login.*?(?:"|').*?>'''))) {
      throw 'Invalid or expired auth cookie';
    }

    switch (token) {
      case 'logout':
        return new RegExp(r'''<a.*?id='logout'.*?href="logout\?.*?auth=(.*?)&?.*?".*?>''').firstMatch(body)[1];
      case 'upvote':
        return new RegExp(r'''<a.*?id='up_''' + '$itemId' + r''''.*?href='vote\?.*?auth=(.*?)&?.*?'.*?>''').firstMatch(body)[1];
      case 'downvote':
        return new RegExp(r'''<a.*?id='down_''' + '$itemId' + r''''.*?href='vote\?.*?auth=(.*?)&?.*?'.*?>''').firstMatch(body)[1];
      case 'hide':
        return new RegExp(r'''<a.*?href=(?:"|')hide\?.*?auth=(.*?)(?:&.*?"|"|').*?>''').firstMatch(body)[1];
      case 'fave':
        return new RegExp(r'''<a.*?href=(?:"|')fave\?.*?auth=(.*?)(?:&.*?"|"|').*?>''').firstMatch(body)[1];
      default:
        throw 'Invalid token request';
    }
  }

  Future<Null> faveItem (HNItemStatus item, HNAccount account) async {
    final bool save = !(item?.saved ?? false);
    toggleSaveItem(item.id);
    bool autoUpvoted = false;
    if (!(item?.upvoted ?? false)) {
      toggleUpvoteItem(item.id);
      autoUpvoted = true;
    }

    final authToken = await this._getItemAuthTokens(item.id, 'fave', account.accessCookie);

    final req = await (await _httpClient.getUrl(Uri.parse(
        '${this._config.apiHost}/fave'
        '?id=${item.id}'
        '&un=${save ? 'f' : 't'}'
        '&auth=$authToken'
      ))
      ..cookies.add(account.accessCookie))
      .close();

    final body = await req.transform(UTF8.decoder).toList().then((body) => body.join());
    if (body.contains('un-favorite')) {
      // undo action
      return;
    } else {
      toggleSaveItem(item.id);
      if (autoUpvoted) {
        toggleUpvoteItem(item.id);
      }
      throw 'Bad login.';
    }
  }

  Future<Null> voteItem (bool up, HNItemStatus status, HNAccount account) {
    if (up) {
      toggleUpvoteItem(status.id);
    } else {
      toggleDownvoteItem(status.id);
    }

    String how;
    if (up && !(status.upvoted ?? false)) {
      how = 'up';
    } else if (!up && !(status.downvoted ?? false)) {
      how = 'down';
    } else if (
      (up && (status.upvoted ?? false)) ||
      (!up && (status.downvoted ?? false))
    ) {
      how = 'un';
    }

    return http.post(
        '${this._config.apiHost}/vote',
        body: {
          'id': '${status.id}',
          'how': how,
          'acct': account.id,
          'pw': account.password,
        },
      )
      .then((res) {
        print('VOTE RES:');
        print(res);
        print(res.body);
        if (res.body.contains('Bad login.')) {
          // undo action
          if (up) {
            toggleUpvoteItem(status.id);
          } else {
            toggleDownvoteItem(status.id);
          }
          throw 'Bad login.';
        } else {
          return;
        }
      });
  }
}
