import 'dart:async';
import 'dart:io' show Cookie;

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/pages/submit_story.dart';

import 'package:hn_flutter/components/main_drawer.dart';
import 'package:hn_flutter/components/fab_bottom_padding.dart';
import 'package:hn_flutter/components/story_card.dart';

import 'package:hn_flutter/sdk/services/hn_story_service.dart';
import 'package:hn_flutter/sdk/actions/ui_actions.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/stores/ui_store.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage ({
    Key key,
  }) : super(key: key);

  @override
  _StoriesPageState createState () => new _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> with StoreWatcherMixin<StoriesPage> {
  final HNStoryService _hnStoryService = new HNStoryService();

  HNAccountStore _accountStore;
  HNItemStore _itemStore;
  UIStore _uiStore;

  ScrollController _scrollController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState () {
    super.initState();

    this._accountStore = listenToStore(accountStoreToken);
    this._itemStore = listenToStore(itemStoreToken);
    this._uiStore = listenToStore(uiStoreToken);

    this._scrollController = new ScrollController();
  }

  Future<Null> _refresh (SortModes sortMode, Cookie accessCookie) async {
    switch (sortMode) {
      case SortModes.TOP:
        await this._hnStoryService.getTopStories(accessCookie: accessCookie);
        break;
      case SortModes.NEW:
        await this._hnStoryService.getNewStories(accessCookie: accessCookie);
        break;
      case SortModes.BEST:
        await this._hnStoryService.getBestStories(accessCookie: accessCookie);
        break;
      case SortModes.ASK_HN:
        await this._hnStoryService.getAskStories(accessCookie: accessCookie);
        break;
      case SortModes.SHOW_HN:
        await this._hnStoryService.getShowStories(accessCookie: accessCookie);
        break;
      case SortModes.JOB:
        await this._hnStoryService.getJobStories(accessCookie: accessCookie);
        break;
    }

    this._scrollToTop();
  }

  Future<Null> _changeSortMode (SortModes sortMode, Cookie accessCookie) async {
    setStorySortMode(sortMode);
    await this._refresh(sortMode, accessCookie);
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

  Future<Null> _submitStoryModal (BuildContext ctx) async {
    return await showDialog(
      context: ctx,
      child: new SubmitStoryPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final account = this._accountStore?.primaryAccount;

    final stories = this._itemStore.sortedStoryIds;

    final sortMode = this._uiStore.sortMode;

    if (stories == null || stories.length == 0) {
      this._refresh(sortMode, account?.accessCookie);
    }

    final storyCards = new Scrollbar(
      child: new ListView.builder(
        controller: this._scrollController,
        itemCount: stories.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: const EdgeInsets.only(top: 5.0),
            );
          } else if (index == stories.length + 1) {
            return new Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: new Column(
                children: <Widget>[
                  // new FlatButton(
                  //   child: new Column(
                  //     children: <Widget>[
                  //       const Padding(
                  //         padding: const EdgeInsets.only(bottom: 6.0),
                  //         child: const Icon(Icons.replay),
                  //       ),
                  //       const Text('Load more'),
                  //     ],
                  //   ),
                  //   onPressed: () => this._loadMore(stories.length, sortMode, account?.accessCookie),
                  // ),
                  const Text('''You've reached the end.'''),
                  // Bottom padding for FAB and home gesture bar
                  const FABBottomPadding(),
                ],
              ),
            );
          } else {
            return new StoryCard(
              storyId: stories.elementAt(index - 1),
            );
          }
        },
      ),
    );

    final loadingStories = const Center(
      child: const CircularProgressIndicator(value: null),
    );

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new GestureDetector(
          onTap: () => this._scrollToTop(),
          child: const Text('Butterfly Reader'),
        ),
        flexibleSpace: new GestureDetector(
          onTap: () => this._scrollToTop(),
        ),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              this._refreshIndicatorKey.currentState.show();
              this._refresh(sortMode, account.accessCookie);
            },
          ),
          new PopupMenuButton<SortModes>(
            icon: const Icon(Icons.sort),
            initialValue: sortMode,
            itemBuilder: (BuildContext ctx) => <PopupMenuEntry<SortModes>>[
              const PopupMenuItem<SortModes>(
                value: SortModes.TOP,
                child: const Text('Top'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.NEW,
                child: const Text('New'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.BEST,
                child: const Text('Best'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.ASK_HN,
                child: const Text('Ask HN'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.SHOW_HN,
                child: const Text('Show HN'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.JOB,
                child: const Text('Jobs'),
              ),
            ],
            onSelected: (sort) => this._changeSortMode(sort, account?.accessCookie),
          ),
        ],
      ),
      drawer: new Drawer(
        child: new MainDrawer(),
      ),
      body: stories.length > 0 ?
        new RefreshIndicator(
          key: this._refreshIndicatorKey,
          onRefresh: () => this._refresh(sortMode, account?.accessCookie),
          child: storyCards,
        ) :
        loadingStories,
      floatingActionButton: account != null ?
        new FloatingActionButton(
          tooltip: 'Submit Story',
          child: new Icon(Icons.add),
          onPressed: () => this._submitStoryModal(context),
        ) :
        null,
    );
  }
}
