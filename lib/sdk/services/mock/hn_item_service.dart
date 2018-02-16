import 'dart:async';
import 'dart:convert' show JSON, UTF8;
import 'dart:io' show HttpClient, ContentType, Cookie;

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import 'package:hn_flutter/sdk/services/abstract/hn_item_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';

class HNItemServiceMock implements HNItemService {
  final _config = new HNConfig();
  final _httpClient = new HttpClient();
  final _itemStore = new HNItemStore();

  Future<HNItem> getItemByID (int id, [Cookie accessCookie]) {
    if (_itemStore.items[id] == null) {
      addHNItem(new HNItem(id: id));
      patchItemStatus(new HNItemStatus.patch(id: id, loading: true));
    }

    if (accessCookie != null) {
      this._getItemPageById(id, accessCookie).then((page) async {
        this._parseAllItems(page).forEach((patch) {
          patchItemStatus(patch);
        });
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

  Future<List<HNItemStatus>> getStoryItemAuthById (int id, Cookie accessCookie) async {
    if (_itemStore.items[id] == null) {
      addHNItem(new HNItem(id: id));
      patchItemStatus(new HNItemStatus.patch(id: id, loading: true));
    }

    final page = await this._getItemPageById(id, accessCookie);
    return this._parseAllItems(page)
      ..forEach((patch) {
        patchItemStatus(patch);
      });
  }

  Future<List<HNItemStatus>> getCommentItemAuthById (int id, Cookie accessCookie) async {
    if (_itemStore.items[id] == null) {
      addHNItem(new HNItem(id: id));
      patchItemStatus(new HNItemStatus.patch(id: id, loading: true));
    }

    final replyPage = await this._getItemReplyPageById(id, accessCookie);
    return this._parseAllItems(replyPage)
      ..forEach((patch) {
        patchItemStatus(patch);
      });
  }

  Future<String> _getItemPageById (int itemId, Cookie accessCookie) async {
    final req = await (await _httpClient.getUrl(Uri.parse(
        '${this._config.apiHost}/item'
        '?id=$itemId'
      ))
      ..cookies.add(accessCookie))
      .close();

    final body = await req.transform(UTF8.decoder).toList().then((body) => body.join());

    if (body.contains(new RegExp(r'''<a.*?href=(?:"|')login.*?(?:"|').*?>'''))) {
      throw 'Invalid or expired auth cookie';
    }

    return body;
  }

  Future<String> _getItemReplyPageById (int itemId, Cookie accessCookie) async {
    final req = await (await _httpClient.getUrl(Uri.parse(
        '${this._config.apiHost}/reply'
        '?id=$itemId'
      ))
      ..cookies.add(accessCookie))
      .close();

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

  List<HNItemStatus> _parseAllItems (String itemPage) {
    final document = parse(itemPage);

    final upvoteLinks = document.querySelectorAll('''a[id^='up_']''');
    final downvoteLinks = document.querySelectorAll('''a[id^='down_']''');
    final hideLinks = document.querySelectorAll('''a[href^='hide']''');
    final faveLinks = document.querySelectorAll('''a[href^='fave']''');
    final replyLinks = document.querySelectorAll('''input[name='hmac']''');

    final itemIds = upvoteLinks.map((match) => int.parse(match.id.substring(3)));

    final patches = itemIds.map((id) => new HNItemStatus.patch(id: id, authTokens: new HNItemAuthTokens())).toList();
    patches.forEach((patch) {
      final upvote = upvoteLinks.firstWhere((a) => a.id == 'up_${patch.id}', orElse: () {});
      final downvote = downvoteLinks.firstWhere((a) => a.id == 'down_${patch.id}', orElse: () {});
      final hide = hideLinks.firstWhere((a) => a.attributes['href'].startsWith('hide?id=${patch.id}'), orElse: () {});
      final fave = faveLinks.firstWhere((a) => a.attributes['href'].startsWith('fave?id=${patch.id}'), orElse: () {});
      final reply = replyLinks.firstWhere((input) =>
        input.parent.children.firstWhere(
          (i) => i.attributes['name'] == 'parent' && i.attributes['value'] == '${patch.id}', orElse: () {}
        ) != null,
        orElse: () {}
      );

      if (upvote != null) {
        patch.upvoted = upvote.classes.contains('nosee');
        patch.authTokens.upvote =
          new RegExp(r'vote\?id=' '${patch.id}' '(?:&.*?)?auth=(.+?)&').firstMatch(upvote.attributes['href'])?.group(1);
      }
      if (downvote != null) {
        patch.downvoted = downvote.classes.contains('nosee');
        patch.authTokens.downvote =
          new RegExp(r'vote\?id=' '${patch.id}' '(?:&.*?)?auth=(.+?)&').firstMatch(downvote.attributes['href'])?.group(1);
      }
      if (hide != null) {
        patch.hidden = hide.innerHtml.contains('un-hide');
        patch.authTokens.hide =
          new RegExp(r'auth=(.+)').firstMatch(hide.attributes['href'])?.group(1);
      }
      if (fave != null) {
        patch.saved = fave.innerHtml.contains('un-fave');
        patch.authTokens.save =
          new RegExp(r'auth=(.+)').firstMatch(fave.attributes['href'])?.group(1);
      }
      if (reply != null) {
        patch.authTokens.reply = reply.attributes['value'];
      }
    });

    return patches;
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
      var faved = new RegExp(r'''href=(?:"|')fave\?.*?id=''' '${status.id}' '''(?:&.*?)?(?:"|').*?>un-favorite''').firstMatch(body) != null;
      if (save == faved) {
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

  Future<Null> replyToItemById (int parentId, String comment, String authToken, Cookie accessCookie) async {
    final req = await (await _httpClient.postUrl(Uri.parse('${this._config.apiHost}/comment'))
      ..cookies.add(accessCookie)
      // ..headers.add('cookie', '${accessCookie.name}=${accessCookie.value}')
      ..headers.contentType = new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8')
      // ..headers.add('content-type', 'application/x-www-form-urlencoded')
      ..write(
        'parent=$parentId'
        '&goto=${Uri.encodeQueryComponent('item?id=$parentId')}'
        '&hmac=${authTokens.reply}'
        '&text=${Uri.encodeQueryComponent(comment)}'
      ))
      // ..write({
      //   'parent': '$parentId',
      //   'goto': Uri.encodeQueryComponent('item?id=$parentId'),
      //   'hmac': authTokens.reply,
      //   'text': Uri.encodeQueryComponent(comment),
      // }))
      .close();

    print(req.headers);
    final body = await req.transform(UTF8.decoder).toList().then((body) => body.join());
    print(body);
    if (body.contains('Bad login')) {
      throw 'Bad login.';
    // } else if (
    //   body.contains('<title>Add Comment | Hacker News</title>') &&
    //   body.contains('Please confirm that this is your comment')
    // ) {
    //   // Looks like we need to submit the comment again
    //   return await replyToItemById(parentId, comment, authTokens, accessCookie);
    }

    return null;
  }

  Future<int> postItem (
    String authToken, Cookie accessCookie,
    String title,
    {
      String text, String url,
    }
  ) async {
    final req = await (await _httpClient.postUrl(Uri.parse('${this._config.apiHost}/r'))
      ..cookies.add(accessCookie)
      // ..headers.add('cookie', '${accessCookie.name}=${accessCookie.value}')
      ..headers.contentType = new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8')
      // ..headers.add('content-type', 'application/x-www-form-urlencoded')
      ..write(
        'fnop=submit-page'
        '&fnid=$authToken'
        '&title=$title'
        '&url=$url'
        '&text=$text'
      ))
      .close();

    print(req.headers);
    final body = await req.transform(UTF8.decoder).toList().then((body) => body.join());
    print(body);

    if (body.contains('Bad login')) {
      throw 'Bad login.';
    // } else if (
    //   body.contains('<title>Add Comment | Hacker News</title>') &&
    //   body.contains('Please confirm that this is your comment')
    // ) {
    //   // Looks like we need to submit the comment again
    //   return await replyToItemById(parentId, comment, authTokens, accessCookie);
    } else if (body.contains('''You're posting too fast. Please slow down. Thanks.''')) {
      throw '''You're posting too fast. Please slow down. Thanks.''';
    }

    return null;
  }

  Future<String> getSubmissionAuthToken (Cookie accessCookie) async {
    final req = await (await _httpClient.getUrl(Uri.parse(
        '${this._config.apiHost}/submit'
      ))
      ..cookies.add(accessCookie))
      .close();

    final body = await req.transform(UTF8.decoder).toList().then((body) => body.join());

    final fnid = new RegExp(r'''<input .*?value="([a-zA-Z0-9])*?".*?>''').allMatches(body);

    if (fnid.first == null) throw 'New submission FNID not found';

    return fnid.first[1];
  }
}
