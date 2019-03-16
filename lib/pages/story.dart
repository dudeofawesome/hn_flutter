import 'dart:async';
import 'dart:io' show Cookie;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:rxdart/rxdart.dart';
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
import 'package:hn_flutter/components/story_header.dart';
import 'package:hn_flutter/components/story_header.dart' as story_header;

class StoryPage extends StatefulWidget {
  final int itemId;

  StoryPage({
    Key key,
    @required this.itemId,
  }) : super(key: key);

  @override
  _StoryPageState createState() => new _StoryPageState();
}

class _StoryPageState extends State<StoryPage>
    with StoreWatcherMixin<StoryPage> {
  final _hnItemService = new Injector().hnItemService;

  HNAccountStore _accountStore;
  HNItemStore _itemStore;

  ScrollController _scrollController;
  BehaviorSubject<Tuple2<int, double>> _scrollPosSubject;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final _popupMenuButtonKey = new GlobalKey();

  @override
  void initState() {
    super.initState();

    this._itemStore = listenToStore(itemStoreToken);
    this._accountStore = listenToStore(accountStoreToken);

    this._scrollController = new ScrollController(
      initialScrollOffset: new UIStore().storyScrollPos[widget.itemId] ?? 0.0,
    );

    this._scrollPosSubject = BehaviorSubject<Tuple2<int, double>>()
      ..debounce(Duration(milliseconds: 250))
          .listen((pos) => setStoryScrollPos(pos));

    this._scrollController.addListener(() {
      this._scrollPosSubject.add(new Tuple2<int, double>(
          widget.itemId, this._scrollController.offset));
    });

    this._refreshStory(cookie: _accountStore.primaryAccount?.accessCookie);
  }

  @override
  void dispose() {
    super.dispose();
    this._scrollPosSubject.close();
  }

  Future<Null> _scrollToTop() async {
    if (this._scrollController.hasClients) {
      await this._scrollController.animateTo(0.0,
          duration: new Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  Future<bool> _onPopScope() async {
    setStoryScrollPos(
        new Tuple2<int, double>(widget.itemId, this._scrollController.offset));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final item = this._itemStore.items[widget.itemId];
    final itemStatus = this._itemStore.itemStatuses[widget.itemId];

    final account = this._accountStore.primaryAccount;

    if (!(itemStatus?.seen ?? true)) {
      markAsSeen(widget.itemId);
    }

    final comments = this._buildCommentTree(widget.itemId);

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
      child: StoryHeader(
        storyId: widget.itemId,
        fadeIfSeen: false,
        overflowMenuItems: [
          story_header.OverflowMenuItems.SHARE,
          story_header.OverflowMenuItems.COPY_TEXT,
          story_header.OverflowMenuItems.VIEW_PROFILE,
        ],
      ),
    );

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
                }),
          ),
        ],
      ),
      body: new Builder(
        builder: (context) => new RefreshIndicator(
              key: this._refreshIndicatorKey,
              onRefresh: () => this._refreshStory(
                  context: context, cookie: account?.accessCookie),
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
      floatingActionButton: account != null
          ? new FloatingActionButton(
              tooltip: 'Reply',
              child: const Icon(Icons.reply),
              onPressed: itemStatus?.authTokens?.reply != null
                  ? () => this._reply(context, itemStatus, account)
                  : null,
            )
          : null,
    );
  }

  List<_CommentInfo> _buildCommentTree(int storyId,
      [bool hideCollapsed = true]) {
    final story = this._itemStore.items[storyId];
    if (story == null || story.kids == null) return new List();

    final commentTree = story.kids
        .map((kid) => this._itemToCommentTreeNode(kid, hideCollapsed))
        .where((comment) => comment != null);
    return this._flattenCommentTree(commentTree).toList();
  }

  _CommentTreeNode _itemToCommentTreeNode(int itemId, bool hideCollapsed) {
    final item = this._itemStore.items[itemId];
    final itemStatus = this._itemStore.itemStatuses[itemId];

    return new _CommentTreeNode(
      commentId: itemId,
      children: !hideCollapsed || !(itemStatus?.hidden ?? false)
          ? item?.kids
              ?.map((kid) => this._itemToCommentTreeNode(kid, hideCollapsed))
          : null,
    );
  }

  Iterable<_CommentInfo> _flattenCommentTree(
      Iterable<_CommentTreeNode> commentTree,
      [int depth = 0,
      List<_CommentInfo> list]) {
    return commentTree.fold<List<_CommentInfo>>(list ?? new List(), (val, el) {
      if (el == null) return val;

      val.add(new _CommentInfo(commentId: el.commentId, depth: depth));
      if (el.children != null && el.children.length > 0)
        this._flattenCommentTree(el.children, depth + 1, val);
      return val;
    });
  }

  Future<Null> _reply(
      BuildContext ctx, HNItemStatus status, HNAccount account) async {
    Navigator.pushNamed(ctx,
        '/${Routes.SUBMIT_COMMENT}?parentId=${widget.itemId}&authToken=${status.authTokens.reply}');
  }

  Future<Null> _refreshStory({BuildContext context, Cookie cookie}) async {
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
}

class _CommentTreeNode {
  Iterable<_CommentTreeNode> children;
  int commentId;

  _CommentTreeNode({
    @required this.commentId,
    this.children,
  });
}

class _CommentInfo {
  int commentId;
  int depth;

  _CommentInfo({
    @required this.commentId,
    @required this.depth,
  });
}
