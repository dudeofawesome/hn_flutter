import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flux/flutter_flux.dart';
// import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' show timeAgo;

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/stores/ui_store.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/actions/ui_actions.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';
import 'package:hn_flutter/sdk/hn_comment_service.dart';
import 'package:hn_flutter/sdk/hn_item_service.dart';

import 'package:hn_flutter/components/simple_markdown.dart';

class Comment extends StoreWatcher {
  final _hnItemService = new HNItemService();

  final int itemId;
  final int depth;
  final bool loadChildren;
  final String op;
  final List<BarButtons> buttons;
  final List<BarButtons> overflowButtons;

  Comment ({
    Key key,
    @required this.itemId,
    this.depth = 0,
    this.loadChildren = true,
    this.buttons = const [
      BarButtons.UPVOTE,
      BarButtons.REPLY,
      BarButtons.SAVE,
      BarButtons.VIEW_PROFILE,
    ],
    this.overflowButtons = const [
      BarButtons.SHARE,
      BarButtons.COPY_TEXT,
    ],
    this.op,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(itemStoreToken);
    listenToStore(uiStoreToken);
    listenToStore(accountStoreToken);
  }

  void _upvoteComment (BuildContext ctx, HNItemStatus status, HNAccount account) {
    this._hnItemService.voteItem(true, status, account)
      .catchError((err) {
        Scaffold.of(ctx).showSnackBar(new SnackBar(
          content: new Text(err.toString()),
        ));
      });
  }

  void _downvoteComment (BuildContext ctx, HNItemStatus status, HNAccount account) {
    this._hnItemService.voteItem(false, status, account)
      .catchError((err) {
        Scaffold.of(ctx).showSnackBar(new SnackBar(
          content: new Text(err.toString()),
        ));
      });
  }

  void _saveComment (BuildContext ctx, HNItemStatus status, HNAccount account) {
    this._hnItemService.faveItem(status, account)
      .catchError((err) {
        Scaffold.of(ctx).showSnackBar(new SnackBar(
          content: new Text(err.toString()),
        ));
      });
  }

  Future<Null> _shareComment (final HNItem comment, final Map<int, HNItem> items) async {
    HNItem parentStory = items[comment.parent];
    while (parentStory.type == 'comment') {
      print(parentStory.id);
      parentStory = items[parentStory.parent];
    }
    await share('https://news.ycombinator.com/item?id=${parentStory.id}#${comment.id}');
  }

  void _reply (int itemId) {
  }

  void _viewProfile (BuildContext ctx, String author) {
    Navigator.pushNamed(ctx, '/${Routes.USERS}:$author');
  }

  void _viewContext (BuildContext ctx, int parent) {
    // Navigator.pushNamed(ctx, '/${Routes.USERS}:$author');
  }

  Future<Null> _copyText (String text) async {
    await Clipboard.setData(new ClipboardData(text: text));
  }

  @override
  Widget build (BuildContext context, Map<StoreToken, Store> stores) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final HNItemStore itemStore = stores[itemStoreToken];
    final UIStore selectedItemStore = stores[uiStoreToken];
    final HNAccountStore accountStore = stores[accountStoreToken];

    final comment = itemStore.items[this.itemId];
    final commentStatus = itemStore.itemStatuses[this.itemId];
    final account = accountStore.primaryAccount;

    if (comment != null) {
      if (comment.type != null && comment.type != 'comment') {
        return new Container();
      }

      Widget topRow;

      final bylineStyle = new TextStyle(
        fontWeight: FontWeight.w500,
      );

      if (!commentStatus.loading) {
        topRow = new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 2.0, 0.0),
              child: (comment.by != null && comment.by == this.op) ?
                new Container(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
                    color: Theme.of(context).accentColor,
                  ),
                  child: new Text(
                    comment.by,
                    style: bylineStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ) :
                new Text(
                  comment.by ?? (comment.computed.markdown != null ? '…' : '[deleted]'),
                  style: bylineStyle,
                ),
            ),
            comment.score != null ? new Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
              child: new Text('${comment.score} points'),
            ) : new Container(),
            new Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
              child: new Text('${timeAgo(new DateTime.fromMillisecondsSinceEpoch(comment.time * 1000))}'),
            ),
          ],
        );
      } else {
        topRow = new Container();
      }

      final content = new Padding(
        padding: new EdgeInsets.only(top: comment.computed.markdown == null ? 0.0 : 4.0),
        child: comment.computed.markdown != null ?
          new SimpleMarkdown(comment.computed.markdown) :
          commentStatus.loading ? const Text('Loading…') : const Text('[deleted]'),
      );

      final List<Widget> buttons = this.buttons.map<Widget>((button) {
        switch (button) {
          case BarButtons.UPVOTE:
            return new IconButton(
              icon: const Icon(Icons.arrow_upward),
              color: commentStatus.upvoted ? Colors.orange : Colors.white,
              tooltip: 'Upvote',
              onPressed: () {
                selectItem(comment.id);
                this._upvoteComment(context, commentStatus, account);
              },
            );
          case BarButtons.DOWNVOTE:
            return new IconButton(
              icon: const Icon(Icons.arrow_downward),
              color: commentStatus.downvoted ? Colors.blue : Colors.black,
              tooltip: 'Downvote',
              onPressed: () {
                selectItem(comment.id);
                // this._downvoteStory()
              },
            );
          case BarButtons.REPLY:
            return new IconButton(
              icon: const Icon(Icons.reply),
              color: Colors.white,
              tooltip: 'Reply',
              onPressed: () {
                selectItem(comment.id);
                this._reply(comment.id);
              },
            );
          case BarButtons.SAVE:
            return new IconButton(
              icon: const Icon(Icons.star),
              color: (commentStatus?.saved ?? false) ? Colors.amber : Colors.white,
              tooltip: 'Save',
              onPressed: () {
                selectItem(comment.id);
                this._saveComment(context, commentStatus, account);
              },
            );
          case BarButtons.VIEW_PROFILE:
            return new IconButton(
              icon: const Icon(Icons.person),
              color: Colors.white,
              tooltip: 'View Profile',
              onPressed: () {
                selectItem(comment.id);
                this._viewProfile(context, comment.by);
              },
            );
          case BarButtons.VIEW_CONTEXT:
            return new IconButton(
              icon: const Icon(Icons.comment),
              color: Colors.white,
              tooltip: 'View Profile',
              onPressed: () {
                selectItem(comment.id);
                this._viewContext(context, comment.parent);
              },
            );
          case BarButtons.COPY_TEXT:
            return new IconButton(
              icon: const Icon(Icons.content_copy),
              color: Colors.white,
              tooltip: 'Copy Text',
              onPressed: () {
                selectItem(comment.id);
                this._copyText(comment.computed.simpleText);
              },
            );
          case BarButtons.SHARE:
            return new IconButton(
              icon: const Icon(Icons.share),
              color: Colors.white,
              tooltip: 'Share',
              onPressed: () {
                selectItem(comment.id);
                this._shareComment(comment, itemStore.items);
              },
            );
        }
      }).toList();

      if (this.overflowButtons?.length > 0) {
        buttons.add(
          new PopupMenuButton<BarButtons>(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white,
            ),
            itemBuilder: (BuildContext ctx) => this.overflowButtons.map((button) {
              switch (button) {
                case BarButtons.UPVOTE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.UPVOTE,
                    child: const Text('Upvote'),
                  );
                case BarButtons.DOWNVOTE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.DOWNVOTE,
                    child: const Text('Downvote'),
                  );
                case BarButtons.REPLY:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.REPLY,
                    child: const Text('Reply'),
                  );
                case BarButtons.SAVE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.SAVE,
                    child: const Text('Save'),
                  );
                case BarButtons.VIEW_PROFILE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.VIEW_PROFILE,
                    child: const Text('View Profile'),
                  );
                case BarButtons.VIEW_CONTEXT:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.VIEW_CONTEXT,
                    child: const Text('View Context'),
                  );
                case BarButtons.COPY_TEXT:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.COPY_TEXT,
                    child: const Text('Copy Text'),
                  );
                case BarButtons.SHARE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.SHARE,
                    child: const Text('Share'),
                  );
              }
            }).toList(),
            onSelected: (BarButtons selection) async {
              selectItem(comment.id);
              switch (selection) {
                case BarButtons.UPVOTE:
                  return this._upvoteComment(context, commentStatus, account);
                case BarButtons.DOWNVOTE:
                  return this._downvoteComment(context, commentStatus, account);
                case BarButtons.REPLY:
                  return this._reply(comment.id);
                case BarButtons.SAVE:
                  return this._saveComment(context, commentStatus, account);
                case BarButtons.VIEW_PROFILE:
                  return this._viewProfile(context, comment.by);
                case BarButtons.VIEW_CONTEXT:
                  return this._viewContext(context, comment.parent);
                case BarButtons.COPY_TEXT:
                  return this._copyText(comment.computed.simpleText);
                case BarButtons.SHARE:
                  return await this._shareComment(comment, itemStore.items);
              }
            },
          )
        );
      }

      final buttonRow = new Container(
        decoration: new BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: new Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: buttons,
          ),
        ),
      );

      final childComments = comment.kids != null && this.loadChildren && !commentStatus.hidden ?
        new Column(
          children: comment.kids.map((kid) => new Comment(
            itemId: kid,
            depth: depth + 1,
            op: this.op,
          )).toList(),
        ) :
        new Container();

      Color commentColor;
      if (this.depth > 0) {
        int index = this.depth - 1;
        while (index >= commentColors.length) {
          index -= commentColors.length;
        }
        commentColor = commentColors[index];
      }

      return new Column(
        children: <Widget>[
          new GestureDetector(
            onTap: () {
              print('comment ${comment.id} touched');
              selectItem(comment.id);
            },
            onLongPress: () async {
              print('comment ${comment.id} pressed');
              await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
              showHideItem(comment.id);
            },
            child: new Padding(
              padding: new EdgeInsets.only(left: this.depth > 0 ? (this.depth - 1) * 4.0 : 0.0),
              child: new Container(
                width: double.INFINITY,
                decoration: new BoxDecoration(
                  border: new Border(
                    left: this.depth > 0 ? new BorderSide(
                      width: 4.0,
                      color: commentColor,
                    ) : const BorderSide(),
                    bottom: const BorderSide(
                      width: 1.0,
                      color: Colors.black12,
                    ),
                  ),
                  color: selectedItemStore.item == comment.id ?
                    Theme.of(context).primaryColor.withOpacity(0.3) :
                    Theme.of(context).cardColor,
                ),
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          topRow,
                          !commentStatus.hidden ? content : new Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          selectedItemStore.item == comment.id ? buttonRow : new Container(),
          !commentStatus.hidden ?
            childComments :
            new Container(),
        ],
      );
    } else {
      final HNCommentService _hnStoryService = new HNCommentService();
      _hnStoryService.getItemByID(itemId);

      return new Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: new Text('Load more'),
      );
    }
  }
}

const List<Color> commentColors = const [
  Colors.red,
  Colors.blue,
  Colors.purple,
  Colors.green,
  Colors.yellow,
];

enum OverflowMenuItems {
  SHARE,
  COPY_TEXT,
}

enum SortModes {
  TOP,
  NEW,
  BEST,
  ASK_HN,
  SHOW_HN,
  JOB,
}

enum BarButtons {
  UPVOTE,
  DOWNVOTE,
  REPLY,
  SAVE,
  VIEW_PROFILE,
  VIEW_CONTEXT,
  COPY_TEXT,
  SHARE,
}
