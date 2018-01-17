import 'dart:async';
import 'dart:io' show Cookie;

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/components/main_drawer.dart';
import 'package:hn_flutter/components/fab_bottom_padding.dart';
import 'package:hn_flutter/components/story_card.dart';

import 'package:hn_flutter/sdk/hn_story_service.dart';
import 'package:hn_flutter/sdk/actions/ui_actions.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/stores/ui_store.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';

class StoriesPage extends StoreWatcher {
  final HNStoryService _hnStoryService = new HNStoryService();

  StoriesPage ({
    Key key
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(itemStoreToken);
    listenToStore(uiStoreToken);
  }

  Future<Null> _refresh (SortModes sortMode, Cookie accessCookie) async {
    this._loadMore(0, sortMode, accessCookie);
  }

  Future<Null> _loadMore (int skip, SortModes sortMode, Cookie accessCookie) async {
    switch (sortMode) {
      case SortModes.TOP:
        await this._hnStoryService.getTopStories(skip: skip, accessCookie: accessCookie);
        break;
      case SortModes.NEW:
        await this._hnStoryService.getNewStories(skip: skip, accessCookie: accessCookie);
        break;
      case SortModes.BEST:
        await this._hnStoryService.getBestStories(skip: skip, accessCookie: accessCookie);
        break;
      case SortModes.ASK_HN:
        await this._hnStoryService.getAskStories(skip: skip, accessCookie: accessCookie);
        break;
      case SortModes.SHOW_HN:
        await this._hnStoryService.getShowStories(skip: skip, accessCookie: accessCookie);
        break;
      case SortModes.JOB:
        await this._hnStoryService.getJobStories(skip: skip, accessCookie: accessCookie);
        break;
      default:
    }
  }

  Future<Null> _changeSortMode (SortModes sortMode, Cookie accessCookie) async {
    setStorySortMode(sortMode);
    await this._refresh(sortMode, accessCookie);
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final HNAccountStore accountStore = stores[accountStoreToken];
    final HNItemStore itemStore = stores[itemStoreToken];
    final UIStore uiStore = stores[uiStoreToken];

    final account = accountStore?.primaryAccount;

    final stories = itemStore.sortedStoryIds
      .where((itemId) => !(itemStore.itemStatuses[itemId]?.hidden ?? false))
      .map((itemId) => itemStore.items[itemId])
      .takeWhile((story) => story != null);

    final sortMode = uiStore.sortMode;

    if (stories == null || stories.length == 0) {
      this._refresh(sortMode, account?.accessCookie);
    }

    final storyCards = new Scrollbar(
      child: new ListView.builder(
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
                  new FlatButton(
                    child: new Column(
                      children: <Widget>[
                        const Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: const Icon(Icons.replay),
                        ),
                        const Text('Load more'),
                      ],
                    ),
                    onPressed: () => this._loadMore(stories.length, sortMode, account?.accessCookie),
                  ),
                  // Bottom padding for FAB and home gesture bar
                  const FABBottomPadding(),
                ],
              ),
            );
          } else {
            return new StoryCard(
              storyId: stories.elementAt(index - 1).id,
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
        title: const Text('Butterfly Reader'),
        actions: <Widget>[
          // const IconButton(
          //   icon: const Icon(Icons.sort),
          //   tooltip: 'Sort',
          // ),
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
      body: itemStore.items.length > 0 ?
        new RefreshIndicator(
          onRefresh: () => this._refresh(sortMode, account?.accessCookie),
          child: storyCards,
        ) :
        loadingStories,
      floatingActionButton: new FloatingActionButton(
        tooltip: 'New Story',
        child: new Icon(Icons.add),
        // onPressed: _incrementCounter,
      ),
    );
  }
}
