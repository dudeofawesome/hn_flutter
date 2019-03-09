import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_web_browser/flutter_web_browser.dart' show FlutterWebBrowser;
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' show timeAgo;

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';
import 'package:hn_flutter/sdk/services/hn_item_service.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

import 'package:hn_flutter/components/icon_button_toggle.dart';
import 'package:hn_flutter/components/simple_markdown.dart';

class StoryCard extends StoreWatcher {
  final _hnItemService = new Injector().hnItemService;

  final int storyId;
  final _popupMenuButtonKey = new GlobalKey();

  StoryCard ({
    Key key,
    @required this.storyId
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(itemStoreToken);
    listenToStore(accountStoreToken);
  }

  _openStoryUrl (BuildContext ctx, String url) async {
    if (await UrlLauncher.canLaunch(url)) {
      await FlutterWebBrowser.openWebPage(url: url, androidToolbarColor: Theme.of(ctx).primaryColor);
    }
  }

  void _openStory (BuildContext ctx) {
    Navigator.pushNamed(ctx, '/${Routes.STORIES}/${this.storyId}');
  }

  Future<Null> _upvoteStory (BuildContext ctx, HNItemStatus status, HNAccount account) async {
    return new Future<Null>(() async {
      if (status.authTokens?.upvote == null) {
        status = (await _hnItemService.getStoryItemAuthById(status.id, account.accessCookie))
          .firstWhere((patch) => patch.id == status.id);

        if (status?.authTokens?.upvote == null) {
          throw '''Couldn't send upvote''';
        }
      }

      return this._hnItemService.voteItem(true, status, account);
    }).catchError((err) {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text(err.toString()),
      ));
    });
  }

  Future<Null> _downvoteStory (BuildContext ctx, HNItemStatus status, HNAccount account) {
    return new Future<Null>(() async {
      if (status.authTokens?.downvote == null) {
        status = (await _hnItemService.getStoryItemAuthById(status.id, account.accessCookie))
          .firstWhere((patch) => patch.id == status.id);

        if (status?.authTokens?.downvote == null) {
          throw '''Couldn't send downvote''';
        }
      }

      return this._hnItemService.voteItem(false, status, account);
    }).catchError((err) {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text(err.toString()),
      ));
    });
  }

  Future<Null> _saveStory (BuildContext ctx, HNItemStatus status, HNAccount account) {
    return new Future<Null>(() async {
      if (status.authTokens?.save == null) {
        status = (await _hnItemService.getStoryItemAuthById(status.id, account.accessCookie))
          .firstWhere((patch) => patch.id == status.id);

        if (status?.authTokens?.save == null) {
          throw '''Couldn't favorite item''';
        }
      }

      return this._hnItemService.faveItem(status, account);
    }).catchError((err) {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text(err.toString()),
      ));
    });
  }

  Future<Null> _shareStory (String storyUrl) async {
    await Share.share(storyUrl);
  }

  void _hideStory () {
    showHideItem(storyId);
  }

  void _viewProfile (BuildContext context, String by) {
    Navigator.pushNamed(context, '/${Routes.USERS}/$by');
  }

  void _showOverflowMenu (BuildContext context) {
    (this._popupMenuButtonKey.currentState as dynamic).showButtonMenu();
  }

  @override
  Widget build (BuildContext context, Map<StoreToken, Store> stores) {
    final HNItemStore itemStore = stores[itemStoreToken];
    final HNAccountStore accountStore = stores[accountStoreToken];
    final story = itemStore.items[this.storyId];
    final storyStatus = itemStore.itemStatuses[this.storyId];
    final account = accountStore.primaryAccount;

    final cardOuterPadding = const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 1.0);

    final storyTextOpacity = !(storyStatus?.seen ?? false) ? 1.0 : 0.5;

    if (story == null || (storyStatus?.loading ?? true)) {
      if (story == null) {
        final HNItemService _hnItemService = new Injector().hnItemService;
        _hnItemService.getItemByID(storyId, account?.accessCookie)
          .catchError((err) {
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text(err?.toString() ?? 'Unknown Error'),
            ));
          });
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

    List<Widget> cardContent;
    if (story.url != null) {
      cardContent = <Widget>[
        new InkWell(
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
                width: double.infinity,
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
        story.type != 'job' ?
          _buildTitleColumn(context, story, storyStatus) :
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(child:_buildTitleColumn(context, story, storyStatus)), this._buildOverflowButton(context, story, storyStatus)
            ],
          ),
        story.type != 'job' ?
          _buildBottomRow(context, story, storyStatus, account) :
          Container(),
      ];
    } else if (story.text != null) {
      cardContent = <Widget>[
        _buildTitleColumn(context, story, storyStatus),
        new Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: new SimpleMarkdown(story.computed.markdown),
        ),
        _buildBottomRow(context, story, storyStatus, account),
      ];
    } else {
      cardContent = <Widget>[
        _buildTitleColumn(context, story, storyStatus),
        _buildBottomRow(context, story, storyStatus, account),
      ];
    }

    return new Padding(
      padding: cardOuterPadding,
      child: new Card(
        child: new InkWell(
          onTap: () => this._openStory(context),
          onLongPress: () => this._showOverflowMenu(context),
          child: new DefaultTextStyle(
            style: Theme.of(context).textTheme.body1.copyWith(
              color: Theme.of(context).textTheme.body1.color.withOpacity(storyTextOpacity),
            ),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cardContent
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverflowButton (BuildContext context, HNItem story, HNItemStatus storyStatus) {
    return new PopupMenuButton<OverflowMenuItems>(
      key: this._popupMenuButtonKey,
      icon: const Icon(
        Icons.more_horiz,
        size: 20.0
      ),
      itemBuilder: (BuildContext ctx) => <PopupMenuEntry<OverflowMenuItems>>[
        const PopupMenuItem<OverflowMenuItems>(
          value: OverflowMenuItems.SHARE,
          child: const Text('Share'),
        ),
        new PopupMenuItem<OverflowMenuItems>(
          value: OverflowMenuItems.HIDE,
          child: const Text('Hide'),
          enabled: storyStatus?.authTokens?.hide != null,
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
    );
  }

  Widget _buildTitleColumn (BuildContext context, HNItem story, HNItemStatus storyStatus) {
    final storyTextOpacity = !(storyStatus?.seen ?? false) ? 1.0 : 0.5;

    return Padding(
      padding: new EdgeInsets.fromLTRB(8.0, 6.0, 8.0, story.type != 'job' ? 0.0 : 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            story.title ?? '[deleted]',
            style: Theme.of(context).textTheme.title.copyWith(
              color: Theme.of(context).textTheme.title.color.withOpacity(storyTextOpacity),
              fontSize: 18.0,
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(story?.by ?? ((story?.deleted ?? false) ? '[deleted]' : '…')),
                new Text(' • '),
                new Text(timeAgo(story.time)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow (BuildContext context, HNItem story, HNItemStatus storyStatus, HNAccount account) {
    return Row(
      children: <Widget>[
        new Expanded(
          child: new Padding(
            padding: new EdgeInsets.all(8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('${story.score ?? '0'} points'),
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
            new IconButtonToggle(
              value: storyStatus?.upvoted,
              activeIcon: const Icon(Icons.arrow_upward),
              activeColor: Colors.orange,
              inactiveColor: Colors.black,
              activeTooltip: 'Upvote',
              iconSize: 20.0,
              onChanged: (value) {
                this._upvoteStory(context, storyStatus, account);
              },
            ),
            // new IconButtonToggle(
            //   value: storyStatus?.downvoted,
            //   activeIcon: const Icon(Icons.arrow_downward),
            //   activeColor: Colors.blue,
            //   inactiveColor: Colors.black,
            //   activeTooltip: 'Downvote',
            //   iconSize: 20.0,
            //   onChanged: (value) {
            //     this._downvoteStory(context, storyStatus, account);
            //   },
            // ),
            new IconButtonToggle(
              value: storyStatus?.saved,
              activeIcon: const Icon(Icons.star),
              activeColor: Colors.amber,
              inactiveColor: Colors.black,
              activeTooltip: 'Save',
              iconSize: 20.0,
              onChanged: (value) {
                this._saveStory(context, storyStatus, account);
              },
            ),
            _buildOverflowButton(context, story, storyStatus),
          ],
        ),
      ],
    );
  }
}

enum OverflowMenuItems {
  HIDE,
  SHARE,
  VIEW_PROFILE,
}
