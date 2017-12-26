import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
// import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:timeago/timeago.dart' show timeAgo;
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownBody;

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/stores/selected_item_store.dart';
import 'package:hn_flutter/sdk/actions/selected_item_actions.dart';
import 'package:hn_flutter/sdk/hn_comment_service.dart';

class Comment extends StoreWatcher {
  final int itemId;
  final int depth;
  final bool loadChildren;

  Comment ({
    Key key,
    @required this.itemId,
    this.depth = 0,
    this.loadChildren = true,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(itemStoreToken);
    listenToStore(selectedItemStoreToken);
  }

  void _upvoteComment () {
  }

  void _downvoteComment () {
  }

  void _saveComment () {
  }

  void _shareComment () {
  }

  void _highlightComment () {
  }

  void _reply (int itemId) {
  }

  void _viewProfile (BuildContext ctx, String author) {
    Navigator.pushNamed(ctx, '/${Routes.USERS}:$author');
  }

  void _copyText (String text) {
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
    final SelectedItemStore selectedItemStore = stores[selectedItemStoreToken];

    final item = itemStore.items.firstWhere((item) => item.id == this.itemId, orElse: () {});
    // final item = new HNItem(
    //   id: itemId,
    //   by: 'dudeofawesome',
    //   text: 'Comment $itemId',
    // );

    if (item != null) {
      final content = new MarkdownBody(data: item.computed.markdown ?? (item.computed.loading ? 'Loading…' : 'Error'));

      Widget topRow;

      if (!item.computed.loading) {
        topRow = new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 2.0, 0.0),
              child: new Text(
                item.by,
                style: new TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            item.score != null ? new Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
              child: new Text('${item.score} points'),
            ) : new Container(),
            new Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
              child: new Text('${timeAgo(new DateTime.fromMillisecondsSinceEpoch(item.time * 1000))} ${'*'}'),
            ),
          ],
        );
      } else {
        topRow = new Container();
      }

      final buttonRow = new Container(
        decoration: new BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: new Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new IconButton(
                icon: const Icon(Icons.arrow_upward),
                color: item.computed.upvoted ? Colors.orange : Colors.white,
                tooltip: 'Upvote',
                onPressed: () {
                  selectItem(item.id);
                  this._upvoteComment();
                },
              ),
              // new IconButton(
              //   icon: const Icon(Icons.arrow_downward),
              //   color: this.story.computed.downvoted ? Colors.blue : Colors.black,
              //   tooltip: 'Downvote',
              //   onPressed: () => _downvoteStory(),
              // ),
              new IconButton(
                icon: const Icon(Icons.reply),
                color: Colors.white,
                tooltip: 'Reply',
                onPressed: () {
                  selectItem(item.id);
                  this._reply(item.id);
                },
              ),
              new IconButton(
                icon: const Icon(Icons.star),
                color: item.computed.saved ? Colors.amber : Colors.white,
                tooltip: 'Save',
                onPressed: () {
                  selectItem(item.id);
                  this._saveComment();
                },
              ),
              new IconButton(
                icon: const Icon(Icons.person),
                color: Colors.white,
                tooltip: 'View Profile',
                onPressed: () {
                  selectItem(item.id);
                  this._viewProfile(context, item.by);
                },
              ),
              new PopupMenuButton<OverflowMenuItems>(
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                ),
                itemBuilder: (BuildContext ctx) => <PopupMenuEntry<OverflowMenuItems>>[
                  const PopupMenuItem<OverflowMenuItems>(
                    value: OverflowMenuItems.SHARE,
                    child: const Text('Share'),
                  ),
                  const PopupMenuItem<OverflowMenuItems>(
                    value: OverflowMenuItems.COPY_TEXT,
                    child: const Text('Copy Text'),
                  ),
                ],
                onSelected: (OverflowMenuItems selection) {
                  selectItem(item.id);
                  switch (selection) {
                    case OverflowMenuItems.SHARE:
                      return this._shareComment();
                    case OverflowMenuItems.COPY_TEXT:
                      return this._copyText(item.text);
                  }
                },
              ),
            ],
          ),
        ),
      );

      final childComments = item.kids != null && this.loadChildren ?
        new Column(
          children: item.kids.map((kid) => new Comment(
            itemId: kid,
            depth: depth + 1,
          )).toList(),
        ) :
        new Container();

      Color commentColor;
      if (this.depth > 0) {
        int index = this.depth - 1;
        while (index > commentColors.length) {
          index -= commentColors.length;
        }
        commentColor = commentColors[index];
      }

      return new Column(
        children: <Widget>[
          new GestureDetector(
            onTap: () {
              print('comment ${item.id} touched');
              selectItem(item.id);
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
                  color: selectedItemStore.item == item.id ?
                    Theme.of(context).primaryColor.withOpacity(0.3) :
                    Theme.of(context).cardColor,
                ),
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          topRow,
                          content,
                        ],
                      ),
                    ),
                    selectedItemStore.item == item.id ? buttonRow : new Container(),
                  ],
                ),
              ),
            ),
          ),
          childComments,
        ],
      );
    } else {
      // TODO: I need to find a better place to retrieve the item. This gets called on every repaint
      print('getting item $itemId');
      final HNCommentService _hnStoryService = new HNCommentService();
      _hnStoryService.getItemByID(itemId);

      return new Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: new Text('$itemId Load more'),
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
