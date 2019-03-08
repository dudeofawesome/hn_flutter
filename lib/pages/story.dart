import 'dart:async';
import 'dart:io' show Cookie;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_web_browser/flutter_web_browser.dart' show FlutterWebBrowser;
import 'package:share/share.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' show timeAgo;
import 'package:tuple/tuple.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/stores/ui_store.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/actions/ui_actions.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

import 'package:hn_flutter/components/comment.dart';
import 'package:hn_flutter/components/fab_bottom_padding.dart';
import 'package:hn_flutter/components/simple_markdown.dart';
import 'package:hn_flutter/components/icon_button_toggle.dart';

class StoryPage extends StatefulWidget {
  final int itemId;

  StoryPage ({
    Key key,
    @required this.itemId,
  }) : super(key: key);

  @override
  _StoryPageState createState () => new _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with StoreWatcherMixin<StoryPage> {
  final _hnItemService = new Injector().hnItemService;

  HNAccountStore _accountStore;
  HNItemStore _itemStore;

  ScrollController _scrollController;
  BehaviorSubject<Tuple2<int, double>> _scrollPosSubject;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
    new GlobalKey<RefreshIndicatorState>();
  final _popupMenuButtonKey = new GlobalKey();

  @override
  void initState () {
    super.initState();

    this._itemStore = listenToStore(itemStoreToken);
    this._accountStore = listenToStore(accountStoreToken);

    this._scrollController = new ScrollController(
      initialScrollOffset: new UIStore().storyScrollPos[widget.itemId] ?? 0.0,
    );

    this._scrollPosSubject = BehaviorSubject<Tuple2<int, double>>()
      ..debounce(Duration(milliseconds: 250)).listen((pos) => setStoryScrollPos(pos));

    this._scrollController.addListener(() {
      this._scrollPosSubject.add(new Tuple2<int, double>(widget.itemId, this._scrollController.offset));
    });

    this._refreshStory(cookie: _accountStore.primaryAccount?.accessCookie);
  }

  @override
  void dispose () {
    super.dispose();
    this._scrollPosSubject.close();
  }

  Future<Null> _scrollToTop () async {
    if (this._scrollController.hasClients) {
      await this._scrollController.animateTo(
        0.0,
        duration: new Duration(milliseconds: 500),
        curve: Curves.easeInOut
      );
    }
  }

  void _showOverflowMenu (BuildContext context) {
    (this._popupMenuButtonKey.currentState as dynamic).showButtonMenu();
  }

  Future<bool> _onPopScope () async {
    setStoryScrollPos(new Tuple2<int, double>(widget.itemId, this._scrollController.offset));
    return true;
  }

  @override
  Widget build (BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final item = this._itemStore.items[widget.itemId];
    final itemStatus = this._itemStore.itemStatuses[widget.itemId];

    final account = this._accountStore.primaryAccount;

    final linkOverlayText = Theme.of(context).textTheme.body1.copyWith(color: Colors.white);

    if (!(itemStatus?.seen ?? true)) {
      markAsSeen(widget.itemId);
    }

    final comments = this._buildCommentTree(widget.itemId);

    final titleColumn = new Padding(
      padding: new EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            item?.title ?? '…',
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
                new Text(item?.by ?? '…'),
                new Text(' • '),
                new Text((item?.time != null) ? timeAgo(item.time) : '…'),
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
                new Text('${item?.score ?? '…'} points'),
                new Text('${item?.descendants ?? '…'} comments'),
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
              value: itemStatus?.upvoted,
              activeIcon: const Icon(Icons.arrow_upward),
              activeColor: Colors.orange,
              inactiveColor: Colors.black,
              activeTooltip: 'Upvote',
              iconSize: 20.0,
              disabled: itemStatus?.authTokens?.upvote == null,
              onChanged: (value) {
                this._upvoteStory(context, itemStatus, account);
              },
            ),
            // new IconButtonToggle(
            //   value: itemStatus?.downvoted,
            //   activeIcon: const Icon(Icons.arrow_downward),
            //   activeColor: Colors.blue,
            //   inactiveColor: Colors.black,
            //   activeTooltip: 'Downvote',
            //   iconSize: 20.0,
            //   disabled: itemStatus?.authTokens?.downvote == null,
            //   onChanged: (value) {
            //     this._downvoteStory(context, itemStatus, account);
            //   },
            // ),
            new IconButtonToggle(
              value: itemStatus?.saved,
              activeIcon: const Icon(Icons.star),
              activeColor: Colors.amber,
              inactiveColor: Colors.black,
              activeTooltip: 'Save',
              iconSize: 20.0,
              disabled: itemStatus?.authTokens?.save == null,
              onChanged: (value) {
                this._saveStory(context, itemStatus, account);
              },
            ),
            new PopupMenuButton<OverflowMenuItems>(
              key: this._popupMenuButtonKey,
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
                if (item?.text != null) {
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

    Widget cardContent;
    if (item?.url != null) {
      cardContent = new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Material(
            child: new InkWell(
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
                    width: double.infinity,
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
          ),
          new Material(
            child: new InkWell(
              onLongPress: () => this._showOverflowMenu(context),
              child: new Column(
                children: <Widget>[
                  titleColumn,
                  bottomRow,
                ],
              ),
            ),
          ),
        ],
      );
    } else if (item?.text != null) {
      cardContent = new Material(
        child: new InkWell(
          onLongPress: () => this._showOverflowMenu(context),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleColumn,
              new Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: new SimpleMarkdown(item.computed.markdown),
              ),
              bottomRow,
            ],
          ),
        ),
      );
    } else {
      cardContent = new Material(
        child: new InkWell(
          onLongPress: () => this._showOverflowMenu(context),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleColumn,
              bottomRow,
            ],
          ),
        ),
      );
    }

    final storyCard = new Container(
      width: double.infinity,
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
      child: cardContent,
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
        title: new GestureDetector(
          onTap: () => this._scrollToTop(),
          child: new Text(item?.title ?? '…'),
        ),
        flexibleSpace: new GestureDetector(
          onTap: () => this._scrollToTop(),
        ),
        actions: <Widget>[
          new Builder(
            builder: (context) => new IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                this._refreshIndicatorKey.currentState.show();
                this._refreshStory(context: context);
              }
            ),
          ),
        ],
      ),
      body: new Builder(
        builder: (context) => new RefreshIndicator(
          key: this._refreshIndicatorKey,
          onRefresh: () => this._refreshStory(context: context, cookie: account?.accessCookie),
          child: new Scrollbar(
            child: new ListView.builder(
              controller: this._scrollController,
              itemCount: (comments.length ?? 1) + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return storyCard;
                } else if (index == comments.length + 1) {
                  return const FABBottomPadding();
                } else {
                  if (comments.length > 0) {
                    return new Comment(
                      itemId: comments[index - 1].commentId,
                      op: item.by,
                      depth: comments[index - 1].depth,
                      loadChildren: false,
                    );
                  } else {
                    return const Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: const Center(
                        child: const Text('No comments'),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: account != null ?
        new FloatingActionButton(
          tooltip: 'Reply',
          child: const Icon(Icons.reply),
          onPressed: itemStatus?.authTokens?.reply != null ?
            () => this._reply(context, itemStatus, account) :
            null,
        ) :
        null,
    );
  }

  List<_CommentInfo> _buildCommentTree (int storyId, [bool hideCollapsed = true]) {
    final story = this._itemStore.items[storyId];
    if (story == null || story.kids == null) return new List();

    final commentTree = story.kids
      .map((kid) => this._itemToCommentTreeNode(kid, hideCollapsed))
      .where((comment) => comment != null);
    return this._flattenCommentTree(commentTree).toList();
  }

  _CommentTreeNode _itemToCommentTreeNode (int itemId, bool hideCollapsed) {
    final item = this._itemStore.items[itemId];
    final itemStatus = this._itemStore.itemStatuses[itemId];

    return new _CommentTreeNode(
      commentId: itemId,
      children: !hideCollapsed || !(itemStatus?.hidden ?? false)
        ? item?.kids?.map((kid) => this._itemToCommentTreeNode(kid, hideCollapsed))
        : null,
    );
  }

  Iterable<_CommentInfo> _flattenCommentTree (
    Iterable<_CommentTreeNode> commentTree, [int depth = 0, List<_CommentInfo> list]
  ) {
    return commentTree.fold<List<_CommentInfo>>(list ?? new List(), (val, el) {
      if (el == null) return val;

      val.add(new _CommentInfo(commentId: el.commentId, depth: depth));
      if (el.children != null && el.children.length > 0)
        this._flattenCommentTree(el.children, depth + 1, val);
      return val;
    });
  }

  void _upvoteStory (BuildContext ctx, HNItemStatus status, HNAccount account) {
    this._hnItemService.voteItem(true, status, account)
      .catchError((err) {
        Scaffold.of(ctx).showSnackBar(new SnackBar(
          content: new Text(err.toString()),
        ));
      });
  }

  void _downvoteStory (BuildContext ctx, HNItemStatus status, HNAccount account) {
    this._hnItemService.voteItem(false, status, account)
      .catchError((err) {
        Scaffold.of(ctx).showSnackBar(new SnackBar(
          content: new Text(err.toString()),
        ));
      });
  }

  void _saveStory (BuildContext ctx, HNItemStatus storyStatus, HNAccount account) async {
    try {
      await this._hnItemService.faveItem(storyStatus, account);
    } catch (err) {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text(err.toString()),
      ));
    }
    // toggleSaveItem(this.storyId);
  }

  Future<Null> _shareStory (String storyUrl) async {
    await Share.share(storyUrl);
  }

  Future<Null> _reply (BuildContext ctx, HNItemStatus status, HNAccount account) async {
    Navigator.pushNamed(
      ctx,
      '/${Routes.SUBMIT_COMMENT}?parentId=${widget.itemId}&authToken=${status.authTokens.reply}'
    );
  }

  Future<Null> _refreshStory ({BuildContext context, Cookie cookie}) async {
    try {
      await this._hnItemService.getItemByID(widget.itemId, cookie);
    } catch (err) {
      if (context != null) {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(err.toString()),
        ));
      } else {
        print(err);
      }
    }
  }

  _openStoryUrl (BuildContext ctx, String url) async {
    if (await UrlLauncher.canLaunch(url)) {
      await FlutterWebBrowser.openWebPage(url: url, androidToolbarColor: Theme.of(ctx).primaryColor);
    }
  }

  void _viewProfile (BuildContext ctx, String author) {
    Navigator.pushNamed(ctx, '/${Routes.USERS}/$author');
  }
}

enum OverflowMenuItems {
  SHARE,
  COPY_TEXT,
  VIEW_PROFILE,
}

class _CommentTreeNode {
  Iterable<_CommentTreeNode> children;
  int commentId;

  _CommentTreeNode ({
    @required this.commentId,
    this.children,
  });
}

class _CommentInfo {
  int commentId;
  int depth;

  _CommentInfo ({
    @required this.commentId,
    @required this.depth,
  });
}
