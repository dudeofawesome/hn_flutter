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

  Future<HNItem> getItemByID (int id, [Cookie accessCookie]) {
    addHNItem(new HNItem(id: id));
    patchItemStatus(new HNItemStatus.patch(id: id, loading: true));

    if (accessCookie != null) {
      this._getItemPageById(id, accessCookie).then((page) async {
        final status = this._parseItemStatus(id, page);
        status.authTokens = this._parseItemAuthTokens(id, page);
        patchItemStatus(status);
      });
    }

    return http.get('${this._config.url}/item/$id.json')
      .then((res) => JSON.decode(res.body))
      .then((item) => new HNItem.fromMap(item))
      .then((item) {
        addHNItem(item);
        patchItemStatus(new HNItemStatus.patch(id: id, loading: false));

        return item;
      });
  }

  Future<String> _getItemPageById (int itemId, Cookie accessCookie) async {
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

    return body;
  }

  HNItemAuthTokens _parseItemAuthTokens (int itemId, String itemPage) {
    return new HNItemAuthTokens(
      // logout: new RegExp(r'''<a.*?id=(?:"|')logout(?:"|').*?href=(?:"|')logout\?.*?auth=(.*?)(?:&.*?)?(?:"|').*?>''')
      //   .firstMatch(itemPage)[1],
      upvote: new RegExp(r'''<a.*?id=(?:"|')up_''' '$itemId' r'''(?:"|').*?href=(?:"|')vote\?.*?auth=(.*?)(?:&.*?)?(?:"|').*?>''')
        .firstMatch(itemPage)?.group(1),
      downvote: new RegExp(r'''<a.*?id=(?:"|')down_''' '$itemId' r'''(?:"|').*?href=(?:"|')vote\?.*?auth=(.*?)(?:&.*?)?(?:"|').*?>''')
        .firstMatch(itemPage)?.group(1),
      hide: new RegExp(r'''href=(?:"|')hide\?.*?id=''' '$itemId' '''&.*?auth=(.*?)(?:"|').*?>(?:un-)?hide''').firstMatch(itemPage)?.group(1),
      save: new RegExp(r'''href=(?:"|')fave\?.*?id=''' '$itemId' '''&.*?auth=(.*?)(?:"|').*?>''').firstMatch(itemPage)?.group(1),
    );
  }

  HNItemStatus _parseItemStatus (int itemId, String itemPage) {
    return new HNItemStatus.patch(
      id: itemId,
      upvoted: new RegExp(r'''<a.*?id=(?:"|')up_''' '$itemId' r'''(?:"|').*?class=(?:"|').*?nosee.*?(?:"|').*?>''')
        .firstMatch(itemPage) != null,
      downvoted: new RegExp(r'''<a.*?id=(?:"|')down_''' '$itemId' r'''(?:"|').*?class=(?:"|').*?nosee.*?(?:"|').*?>''')
        .firstMatch(itemPage) != null,
      hidden: new RegExp(r'''href=(?:"|')hide\?.*?id=''' '$itemId' '''(?:&.*?)?(?:"|').*?>un-hide''').firstMatch(itemPage) != null,
      saved: new RegExp(r'''href=(?:"|')fave\?.*?id=''' '$itemId' '''(?:&.*?)?(?:"|').*?>un-favorite''').firstMatch(itemPage) != null,
      // seen: new RegExp(r'''href=(?:"|')fave\?.*?id=''' '$itemId' '''(?:&.*?)?(?:"|').*?>un-favorite''').firstMatch(itemPage)[1],
    );
  }

  Future<Null> faveItem (HNItemStatus status, HNAccount account) async {
    final bool save = !(status?.saved ?? false);
    toggleSaveItem(status.id);
    bool autoUpvoted = false;
    if (!(status?.upvoted ?? false)) {
      toggleUpvoteItem(status.id);
      autoUpvoted = true;
    }

    try {
      final req = await (await _httpClient.getUrl(Uri.parse(
          '${this._config.apiHost}/fave'
          '?id=${status.id}'
          '&un=${save ? 'f' : 't'}'
          '${status?.authTokens?.save != null ? '&auth=' + status.authTokens.save : ''}'
        ))
        ..cookies.add(account.accessCookie))
        .close();

      final body = await req.transform(UTF8.decoder).toList().then((body) => body.join());
      var a = new RegExp(r'''href=(?:"|')fave\?.*?id=''' '${status.id}' '''(?:&.*?)?(?:"|').*?>un-favorite''').firstMatch(body);
      print(a);
      if (a != null) {
        return;
      } else {
        throw 'Bad login.';
      }
    } catch (err) {
      // undo action
      toggleSaveItem(status.id);
      if (autoUpvoted) {
        toggleUpvoteItem(status.id);
      }
      throw err;
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
