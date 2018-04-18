import 'dart:async';
import 'dart:isolate';
import 'dart:convert' show json, utf8;
import 'dart:io' show HttpClient, ContentType, Cookie;

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import 'package:hn_flutter/sdk/services/abstract/hn_item_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';

class HNItemServiceProd implements HNItemService {
  static final _config = new HNConfig();
  final _receivePort = new ReceivePort();
  SendPort _sendPort;

  static final _httpClient = new HttpClient();
  final _itemStore = new HNItemStore();

  Future<Null> init () async {
    assert(this._sendPort == null, 'HNItemServiceProd::init has already been called');

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
        case _IsolateMessageType.GET_ITEM_BY_ID:
          new Future(() async {
            final int id = data.params['id'];
            final Cookie accessCookie = data.params['accessCookie'];

            List<HNItemStatus> statusUpdates;

            if (accessCookie != null) {
              statusUpdates = _parseAllItems(await _getItemPageById(id, accessCookie));
            }

            final item = await http.get('${_config.url}/item/$id.json')
              .then((res) => json.decode(res.body))
              .then((item) => new HNItem.fromMap(item));

            replyTo.send([item, statusUpdates]);
          });
          break;
        case _IsolateMessageType.DESTRUCT:
          port.close();
          break;
      }
    }
  }

  Future<HNItem> getItemByID (int id, [Cookie accessCookie]) async {
    if (_itemStore.items[id] == null) {
      addHNItem(new HNItem(id: id));
      patchItemStatus(new HNItemStatus.patch(id: id, loading: true));
    }

    final response = new ReceivePort();
    this._sendPort.send([new _IsolateMessage(
      type: _IsolateMessageType.GET_ITEM_BY_ID,
      params: {'id': id, 'accessCookie': accessCookie},
    ), response.sendPort]);

    final List<dynamic> res = await response.first;
    final HNItem item = res[0];
    final List<HNItemStatus> statusUpdates = res[1];

    statusUpdates?.forEach((patch) => patchItemStatus(patch));
    addHNItem(item);
    patchItemStatus(new HNItemStatus.patch(id: id, loading: false));

    return item;
  }

  Future<List<HNItemStatus>> getStoryItemAuthById (int id, Cookie accessCookie) async {
    if (_itemStore.items[id] == null) {
      addHNItem(new HNItem(id: id));
      patchItemStatus(new HNItemStatus.patch(id: id, loading: true));
    }

    final page = await _getItemPageById(id, accessCookie);
    return _parseAllItems(page)
      ..forEach((patch) {
        patchItemStatus(patch);
      });
  }

  Future<List<HNItemStatus>> getCommentItemAuthById (int id, Cookie accessCookie) async {
    if (_itemStore.items[id] == null) {
      addHNItem(new HNItem(id: id));
      patchItemStatus(new HNItemStatus.patch(id: id, loading: true));
    }

    final replyPage = await _getItemReplyPageById(id, accessCookie);
    return _parseAllItems(replyPage)
      ..forEach((patch) {
        patchItemStatus(patch);
      });
  }

  static Future<String> _getItemPageById (int itemId, Cookie accessCookie) async {
    final req = await (await _httpClient.getUrl(Uri.parse(
        '${_config.apiHost}/item'
        '?id=$itemId'
      ))
      ..cookies.add(accessCookie))
      .close();

    final body = await req.transform(utf8.decoder).toList().then((body) => body.join());

    if (body.contains(_loginLink)) {
      throw 'Invalid or expired auth cookie';
    }

    return body;
  }

  static Future<String> _getItemReplyPageById (int itemId, Cookie accessCookie) async {
    final req = await (await _httpClient.getUrl(Uri.parse(
        '${_config.apiHost}/reply'
        '?id=$itemId'
      ))
      ..cookies.add(accessCookie))
      .close();

    final body = await req.transform(utf8.decoder).toList().then((body) => body.join());

    if (body.contains(_loginLink)) {
      throw 'Invalid or expired auth cookie';
    }

    return body;
  }

  static HNItemAuthTokens _parseItemAuthTokens (int itemId, String itemPage) {
    return new HNItemAuthTokens(
      // logout: new RegExp(r'''<a.*?id=["']logout["'].*?href=["']logout\?.*?auth=(.*?)(?:&.*?)?["'].*?>''')
      //   .firstMatch(itemPage)[1],
      upvote: new RegExp(r'''<a.*?id=["']up_''' '$itemId' r'''["'].*?href=["']vote\?.*?auth=(.*?)(?:&.*?)?["'].*?>''')
        .firstMatch(itemPage)?.group(1),
      downvote: new RegExp(r'''<a.*?id=["']down_''' '$itemId' r'''["'].*?href=["']vote\?.*?auth=(.*?)(?:&.*?)?["'].*?>''')
        .firstMatch(itemPage)?.group(1),
      hide: new RegExp(r'''href=["']hide\?.*?id=''' '$itemId' '''&.*?auth=(.*?)["'].*?>(?:un-)?hide''').firstMatch(itemPage)?.group(1),
      save: new RegExp(r'''href=["']fave\?.*?id=''' '$itemId' '''&.*?auth=(.*?)["'].*?>''').firstMatch(itemPage)?.group(1),
    );
  }

  static HNItemStatus _parseItemStatus (int itemId, String itemPage) {
    return new HNItemStatus.patch(
      id: itemId,
      upvoted: new RegExp(r'''<a.*?id=["']up_''' '$itemId' r'''["'].*?class=["'].*?nosee.*?["'].*?>''')
        .firstMatch(itemPage) != null,
      downvoted: new RegExp(r'''<a.*?id=["']down_''' '$itemId' r'''["'].*?class=["'].*?nosee.*?["'].*?>''')
        .firstMatch(itemPage) != null,
      hidden: new RegExp(r'''href=["']hide\?.*?id=''' '$itemId' '''(?:&.*?)?["'].*?>un-hide''').firstMatch(itemPage) != null,
      saved: new RegExp(r'''href=["']fave\?.*?id=''' '$itemId' '''(?:&.*?)?["'].*?>un-favorite''').firstMatch(itemPage) != null,
      // seen: new RegExp(r'''href=["']fave\?.*?id=''' '$itemId' '''(?:&.*?)?["'].*?>un-favorite''').firstMatch(itemPage)[1],
    );
  }

  static List<HNItemStatus> _parseAllItems (String itemPage) {
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
          _authTokenQueryParam.firstMatch(hide.attributes['href'])?.group(1);
      }
      if (fave != null) {
        patch.saved = fave.innerHtml.contains('un-fave');
        patch.authTokens.save =
          _authTokenQueryParam.firstMatch(fave.attributes['href'])?.group(1);
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
          '${_config.apiHost}/fave'
          '?id=${status.id}'
          '&un=${save ? 'f' : 't'}'
          '${status?.authTokens?.save != null ? '&auth=' + status.authTokens.save : ''}'
        ))
        ..cookies.add(account.accessCookie))
        .close();

      final body = await req.transform(utf8.decoder).toList().then((body) => body.join());
      var faved = new RegExp(r'''href=["']fave\?.*?id=''' '${status.id}' '''(?:&.*?)?["'].*?>un-favorite''').firstMatch(body) != null;
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
        '${_config.apiHost}/vote',
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

  Future<int> replyToItemById (int parentId, String comment, String authToken, Cookie accessCookie) async {
    final req = await ((await _httpClient.postUrl(Uri.parse('${_config.apiHost}/comment')))
      ..cookies.add(accessCookie)
      ..headers.contentType = new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8')
      ..write(
        'parent=$parentId'
        '&goto=${Uri.encodeQueryComponent('item?id=$parentId')}'
        '&hmac=$authToken'
        '&text=${Uri.encodeQueryComponent(comment)}'
      ))
      .close();

    print(req.headers);
    final body = await req.transform(utf8.decoder).toList().then((body) => body.join());
    print(body);
    if (body.contains('Bad login')) throw 'Bad login.';
    if (req.headers.value('location') == null) throw 'Unknown error';
    if (req.headers.value('location') == 'deadlink') throw 'Outdated hmac (I think)';
    if (req.headers.value('location').contains('fnop=story-toofast')) throw 'Submitting too fast';
    if (!req.headers.value('location').startsWith('item?id=')) {
      if (req.headers.value('location').contains('fnop=commconfirm')) throw 'Submission failed';
      else throw 'Unknown error';
    }

    this.getItemByID(parentId);

    return int.parse(req.headers.value('location').replaceFirst('item?id=', ''));
  }

  Future<int> postItem (
    String authToken, Cookie accessCookie,
    String title,
    {
      String text, String url,
    }
  ) async {
    final req = await ((await _httpClient.postUrl(Uri.parse('${_config.apiHost}/r')))
      ..cookies.add(accessCookie)
      ..headers.contentType = new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8')
      ..write(
        'fnid=$authToken'
        '&fnop=submit-page'
        '&title=$title'
        '&url=${url != null ? Uri.encodeQueryComponent(url) : ''}'
        '&text=${text != null ? Uri.encodeQueryComponent(text) : ''}'
      ))
      .close();

    print(req.headers);
    final body = await req.transform(utf8.decoder).toList().then((body) => body.join());
    print(body);

    if (body.contains('Bad login'))
      throw 'Bad login.';
    else if (body.contains('''You're posting too fast. Please slow down. Thanks.'''))
      throw '''You're posting too fast. Please slow down. Thanks.''';
    else if (req.statusCode != 302) throw 'Unknown error';
    else if (req.headers.value('location') == null) throw 'Unknown error';
    else if (req.headers.value('location') == 'deadlink') throw 'Outdated fnid (I think)';
    else if (req.headers.value('location').contains('fnop=story-toofast')) throw 'Submitting too fast';

    print('''req.headers->location''');
    print(req.headers.value('location'));

    final newestReq = await ((await _httpClient.getUrl(Uri.parse(
        '${_config.apiHost}/${req.headers.value('location')}'
      )))
      ..cookies.add(accessCookie))
      .close();
    final newestBody = await newestReq.transform(utf8.decoder).toList().then((body) => body.join());

    if (!newestBody.contains('<font color="#ff6600">*</font>'))
      throw 'Submission not created';

    final itemId = int.parse(_postedItemId.firstMatch(newestBody)?.group(1));

    // TODO: add new itemId to top of new stories list

    return itemId;
  }

  Future<String> getSubmissionAuthToken (Cookie accessCookie) async {
    final req = await (await _httpClient.getUrl(Uri.parse(
        '${_config.apiHost}/submit'
      ))
      ..cookies.add(accessCookie))
      .close();

    final body = await req.transform(utf8.decoder).toList()
      .then((body) => body.join());

    final fnid = _submissionAuthToken.allMatches(body);

    if (fnid.first == null) throw 'New submission FNID not found';

    return fnid.first[1];
  }
}

final _loginLink = new RegExp(r'''<a.*?href=["']login.*?["'].*?>''');
final _authTokenQueryParam = new RegExp(r'auth=(.+)');
final _postedItemId =
  new RegExp(r'''<tr class="athing" id="([0-9]*?)">.*?<font color="#ff6600">*</font>''');
final _submissionAuthToken =
  new RegExp(r'''<input .*?name="fnid" .*?value="([a-zA-Z0-9]*?)".*?>''');

class _IsolateMessage {
  _IsolateMessageType type;
  dynamic params;

  _IsolateMessage ({
    @required this.type,
    @required this.params,
  });
}

enum _IsolateMessageType {
  GET_ITEM_BY_ID,
  GET_STORY_ITEM_AUTH_BY_ID,
  GET_COMMENT_ITEM_AUTH_BY_ID,
  // GET_ITEM_PAGE_BY_ID,
  // GET_ITEM_REPLY_PAGE_BY_ID,
  FAVE_ITEM,
  VOTE_ITEM,
  REPLY_TO_ITEM_BY_ID,
  POST_ITEM,
  DESTRUCT,
}
