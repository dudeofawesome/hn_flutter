import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_web_browser/flutter_web_browser.dart' show FlutterWebBrowser;
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' show timeAgo;

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/hn_story_service.dart';

import 'package:hn_flutter/components/comment.dart';
import 'package:hn_flutter/components/fab_bottom_padding.dart';
import 'package:hn_flutter/components/simple_markdown.dart';

class StoryPage extends StoreWatcher {
  final int id;
  final int itemId;

  StoryPage ({
    Key key,
    this.id,
    @required this.itemId,
  }) : super(key: key) {
    // final HNCommentService hnCommentService = new HNCommentService();
    // hnCommentService.getItemByID(id)
  }

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(itemStoreToken);
  }

  void _upvoteStory () {
  }

  void _downvoteStory () {
  }

  void _saveStory () {
  }

  Future<Null> _shareStory (String storyUrl) async {
    await share(storyUrl);
  }

  _reply (int itemId) {}

  Future<Null> refreshStory () async {
    final HNStoryService hnStoryService = new HNStoryService();
    await hnStoryService.getItemByID(this.itemId);
  }

  _openStoryUrl (BuildContext ctx, String url) async {
    if (await UrlLauncher.canLaunch(url)) {
      await FlutterWebBrowser.openWebPage(url: url, androidToolbarColor: Theme.of(ctx).primaryColor);
    }
  }

  void _viewProfile (BuildContext ctx, String author) {
    Navigator.pushNamed(ctx, '/${Routes.USERS}:$author');
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
    final item = itemStore.items[this.itemId];

    final linkOverlayText = Theme.of(context).textTheme.body1.copyWith(color: Colors.white);

    final titleColumn = new Padding(
      padding: new EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            item.title,
            style: Theme.of(context).textTheme.title.copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(item.by),
                new Text(' • '),
                new Text(timeAgo(new DateTime.fromMillisecondsSinceEpoch(item.time * 1000))),
              ],
            ),
          ),
        ],
      ),
    );

    final bottomRow = new Row(
      children: <Widget>[
        new Expanded(
          child: new Padding(
            padding: new EdgeInsets.all(8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('${item.score} points'),
                new Text('${item.descendants} comments'),
              ],
            ),
          ),
        ),
        new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Upvote',
              iconSize: 20.0,
              onPressed: () => _upvoteStory(),
              color: item.computed.upvoted ? Colors.orange : Colors.black,
            ),
            // new IconButton(
            //   icon: const Icon(Icons.arrow_downward),
            //   tooltip: 'Downvote',
            //   onPressed: () => _downvoteStory(),
            //   color: this.story.computed.downvoted ? Colors.blue : Colors.black,
            // ),
            new IconButton(
              icon: const Icon(Icons.star),
              tooltip: 'Save',
              iconSize: 20.0,
              onPressed: () => _saveStory(),
              color: item.computed.saved ? Colors.amber : Colors.black,
            ),
            // new IconButton(
            //   icon: const Icon(Icons.more_vert),
            // ),
            new PopupMenuButton<OverflowMenuItems>(
              icon: const Icon(
                Icons.more_horiz,
                size: 20.0
              ),
              itemBuilder: (BuildContext ctx) {
                const share = const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.SHARE,
                  child: const Text('Share'),
                );
                const copyText = const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.COPY_TEXT,
                  child: const Text('Copy Text'),
                );
                const viewProfile = const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.VIEW_PROFILE,
                  child: const Text('View Profile'),
                );

                final menu = <PopupMenuEntry<OverflowMenuItems>>[];

                menu.add(share);
                if (item.text != null) {
                  menu.add(copyText);
                }
                menu.add(viewProfile);

                return menu;
              },
              onSelected: (OverflowMenuItems selection) async {
                switch (selection) {
                  case OverflowMenuItems.SHARE:
                    return await this._shareStory('https://news.ycombinator.com/item?id=${item.id}');
                  case OverflowMenuItems.COPY_TEXT:
                    return await Clipboard.setData(new ClipboardData(text: item.computed.simpleText));
                  case OverflowMenuItems.VIEW_PROFILE:
                    return this._viewProfile(context, item.by);
                }
              },
            ),
          ],
        ),
      ],
    );

    List<Widget> cardContent;
    if (item.url != null) {
      cardContent = <Widget>[
        new GestureDetector(
          onTap: () => this._openStoryUrl(context, item.url),
          child: new Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[
              // new Image.network(
              //   this.story.computed.imageUrl,
              //   fit: BoxFit.cover,
              // ),
              new Container(
                decoration: new BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 0, 0.5),
                ),
                width: double.INFINITY,
                child: new Padding(
                  padding: new EdgeInsets.all(8.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        item.computed.urlHostname ?? 'NO story.computed.urlHostname FOUND!',
                        style: linkOverlayText,
                        overflow: TextOverflow.ellipsis,
                      ),
                      new Text(
                        item.url ?? 'NO story.url FOUND!',
                        style: linkOverlayText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        titleColumn,
        bottomRow,
      ];
    } else if (item.text != null) {
      cardContent = <Widget>[
        titleColumn,
        new Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: new SimpleMarkdown(item.computed.markdown),
        ),
        bottomRow,
      ];
    } else {
      cardContent = <Widget>[
        titleColumn,
        bottomRow,
      ];
    }


    final storyCard = new Container(
      width: double.INFINITY,
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          const BoxShadow(
            color: Colors.black,
            blurRadius: 5.0,
          ),
        ],
      ),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cardContent,
      ),
    );

    // final comments = item.kids != null ?
    //   new Column(
    //     // children: new Iterable.generate(5, (i) => new Comment(
    //     //     itemId: i,
    //     //   ))
    //     //   .toList(),
    //     children: item.kids.map((kid) => new Comment(
    //       itemId: kid,
    //     )).toList(),
    //   ) :
    //   const Padding(
    //     padding: const EdgeInsets.only(top: 8.0),
    //     child: const Center(
    //       child: const Text('No comments'),
    //     ),
    //   );

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(item?.title),
        actions: <Widget>[],
      ),
      body: new RefreshIndicator(
        onRefresh: this.refreshStory,
        child: new Scrollbar(
          child: new ListView(
            children: <Widget>[
              storyCard,
              comments,
              const FABBottomPadding(),
            ],
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => this._reply(item.id),
        tooltip: 'Reply',
        child: const Icon(Icons.reply),
      ),
    );
  }
}

enum OverflowMenuItems {
  SHARE,
  COPY_TEXT,
  VIEW_PROFILE,
}
