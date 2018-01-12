import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_web_browser/flutter_web_browser.dart' show FlutterWebBrowser;
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' show timeAgo;

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/hn_story_service.dart';
import 'package:hn_flutter/sdk/hn_item_service.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

import 'package:hn_flutter/components/simple_markdown.dart';

class StoryCard extends StoreWatcher {
  final int storyId;

  StoryCard ({
    Key key,
    @required this.storyId
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(itemStoreToken);
  }

  _openStoryUrl (BuildContext ctx, String url) async {
    if (await UrlLauncher.canLaunch(url)) {
      await FlutterWebBrowser.openWebPage(url: url, androidToolbarColor: Theme.of(ctx).primaryColor);
    }
  }

  void _openStory (BuildContext ctx) {
    Navigator.pushNamed(ctx, '/${Routes.STORIES}:${this.storyId}');
  }

  void _upvoteStory () {
  }

  void _downvoteStory () {
  }

  void _saveStory () {
    toggleSaveItem(this.storyId);
  }

  Future<Null> _shareStory (String storyUrl) async {
    await share(storyUrl);
  }

  void _hideStory () {
    showHideItem(storyId);
  }

  void _viewProfile (BuildContext ctx, String by) {
    Navigator.pushNamed(ctx, '/${Routes.USERS}:$by');
  }

  @override
  Widget build (BuildContext context, Map<StoreToken, Store> stores) {
    final HNItemStore itemStore = stores[itemStoreToken];
    final story = itemStore.items[this.storyId];
    final storyStatus = itemStore.itemStatuses[this.storyId];

    final cardOuterPadding = const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 1.0);

    if (story == null || storyStatus.loading) {
      if (story == null) {
        final HNItemService _hnItemService = new HNItemService();
        _hnItemService.getItemByID(storyId);
      }

      return new Padding(
        padding: cardOuterPadding,
        child: new Card(
          child: new Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
            child: const Text('Loading…'),
          ),
        ),
      );
    }

    if (story.type != 'story' && story.type != 'job' && story.type != 'poll') {
      return new Container();
    }


    final linkOverlayText = Theme.of(context).textTheme.body1.copyWith(color: Colors.white);

    final titleColumn = new Padding(
      padding: new EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 0.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            story.title ?? 'NO story.title FOUND!',
            style: Theme.of(context).textTheme.title.copyWith(
              fontSize: 18.0,
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(story.by),
                new Text(' • '),
                new Text(timeAgo(new DateTime.fromMillisecondsSinceEpoch(story.time * 1000))),
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
                new Text('${story.score} points'),
                new Text('${story.descendants ?? '0'} comments'),
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
              color: (storyStatus?.upvoted ?? false) ? Colors.orange : Colors.black,
            ),
            // new IconButton(
            //   icon: const Icon(Icons.arrow_downward),
            //   tooltip: 'Downvote',
            //   onPressed: () => _downvoteStory(),
            //   color: this.storyStatus.downvoted ? Colors.blue : Colors.black,
            // ),
            new IconButton(
              icon: const Icon(Icons.star),
              tooltip: 'Save',
              iconSize: 20.0,
              onPressed: () => _saveStory(),
              color: (storyStatus?.saved ?? false) ? Colors.amber : Colors.black,
            ),
            // new IconButton(
            //   icon: const Icon(Icons.more_vert),
            // ),
            new PopupMenuButton<OverflowMenuItems>(
              icon: const Icon(
                Icons.more_horiz,
                size: 20.0
              ),
              itemBuilder: (BuildContext ctx) => <PopupMenuEntry<OverflowMenuItems>>[
                const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.SHARE,
                  child: const Text('Share'),
                ),
                const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.HIDE,
                  child: const Text('Hide'),
                ),
                const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.VIEW_PROFILE,
                  child: const Text('View Profile'),
                ),
              ],
              onSelected: (OverflowMenuItems selection) async {
                switch (selection) {
                  case OverflowMenuItems.HIDE:
                    return this._hideStory();
                  case OverflowMenuItems.SHARE:
                    return await this._shareStory('https://news.ycombinator.com/item?id=${story.id}');
                  case OverflowMenuItems.VIEW_PROFILE:
                    return this._viewProfile(context, story.by);
                }
              },
            ),
          ],
        ),
      ],
    );

    List<Widget> cardContent;
    if (story.url != null) {
      cardContent = <Widget>[
        new GestureDetector(
          onTap: () => this._openStoryUrl(context, story.url),
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
                        story.computed.urlHostname ?? 'NO story.computed.urlHostname FOUND!',
                        style: linkOverlayText,
                        overflow: TextOverflow.ellipsis,
                      ),
                      new Text(
                        story.url ?? 'NO story.url FOUND!',
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
    } else if (story.text != null) {
      cardContent = <Widget>[
        titleColumn,
        new Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: new SimpleMarkdown(story.computed.markdown),
        ),
        bottomRow,
      ];
    } else {
      cardContent = <Widget>[
        titleColumn,
        bottomRow,
      ];
    }

    return new Padding(
      padding: cardOuterPadding,
      child: new Card(
        child: new GestureDetector(
          onTap: () => this._openStory(context),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cardContent
          ),
        ),
      ),
    );
  }
}

enum OverflowMenuItems {
  HIDE,
  SHARE,
  VIEW_PROFILE,
}
