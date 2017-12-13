import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/components/simple_html.dart';

class Comment extends StoreWatcher {
  final int id;
  final int itemId;

  Comment ({
    Key key,
    this.id,
    @required this.itemId,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(itemStoreToken);
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
    // final item = itemStore.items.firstWhere((item) => item.id == this.itemId);
    final item = new HNItem(
      id: itemId,
      by: 'dudeofawesome',
      text: 'Comment $itemId',
    );

    final content = new GestureDetector(
      onTap: () => this._highlightComment(),
      child: new SimpleHTML(item.text),
    );

    final topRow = new Row(
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
        new Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
          child: new Text('${item.score} points'),
        ),
        new Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
          child: new Text('${'2 hours ago'}${'*'}'),
        ),
      ],
    );

    final buttonRow = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Upvote',
              onPressed: () => this._upvoteComment(),
              color: item.computed.upvoted ? Colors.orange : Colors.black,
            ),
            // new IconButton(
            //   icon: const Icon(Icons.arrow_downward),
            //   tooltip: 'Downvote',
            //   onPressed: () => _downvoteStory(),
            //   color: this.story.computed.downvoted ? Colors.blue : Colors.black,
            // ),
            new IconButton(
              icon: const Icon(Icons.reply),
              tooltip: 'Reply',
              onPressed: () => this._reply(item.id),
            ),
            new IconButton(
              icon: const Icon(Icons.star),
              tooltip: 'Save',
              onPressed: () => this._saveComment(),
              color: item.computed.saved ? Colors.amber : Colors.black,
            ),
            new IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'View Profile',
              onPressed: () => this._viewProfile(context, item.by),
            ),
            new PopupMenuButton<OverflowMenuItems>(
              icon: const Icon(Icons.more_horiz),
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
      ],
    );

    return new Container(
      width: double.INFINITY,
      decoration: new BoxDecoration(
        border: new Border(
          left: const BorderSide(
            width: 4.0,
            color: Colors.red,
          ),
          bottom: const BorderSide(
            width: 1.0,
            color: Colors.black12,
          ),
        ),
      ),
      child: new Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            topRow,
            content,
            false ? buttonRow : new Container(),
          ],
        ),
      ),
    );
  }
}

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
