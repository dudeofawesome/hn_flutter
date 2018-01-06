import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/components/story_card.dart';
import 'package:hn_flutter/components/fab_bottom_padding.dart';

import 'package:hn_flutter/sdk/hn_story_service.dart';
import 'package:hn_flutter/sdk/actions/ui_actions.dart';
import 'package:hn_flutter/sdk/stores/ui_store.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';

import 'package:hn_flutter/router.dart';

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

  Future<Null> _refresh (SortModes sortMode) async {
    this._loadMore(0, sortMode);
  }

  Future<Null> _loadMore (int skip, SortModes sortMode) async {
    switch (sortMode) {
      case SortModes.TOP:
        await this._hnStoryService.getTopStories(skip: skip);
        break;
      case SortModes.NEW:
        await this._hnStoryService.getNewStories(skip: skip);
        break;
      case SortModes.BEST:
        await this._hnStoryService.getBestStories(skip: skip);
        break;
      case SortModes.ASK_HN:
        await this._hnStoryService.getAskStories(skip: skip);
        break;
      case SortModes.SHOW_HN:
        await this._hnStoryService.getShowStories(skip: skip);
        break;
      case SortModes.JOB:
        await this._hnStoryService.getJobStories(skip: skip);
        break;
      default:
    }
  }

  Future<Null> _changeSortMode (SortModes sortMode) async {
    setStorySortMode(sortMode);
    await this._refresh(sortMode);
  }

  _openStoryDialog (BuildContext ctx) async {
    String storyId;

    storyId = await showDialog(
      context: ctx,
      child: new SimpleDialog(
        title: const Text('Enter story ID'),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        children: <Widget>[
          new TextField(
            autofocus: true,
            decoration: new InputDecoration(
              labelText: 'Story ID',
            ),
            keyboardType: TextInputType.number,
            onChanged: (String val) => storyId = val,
          ),
          new ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'.toUpperCase()),
                  onPressed: () => Navigator.pop(ctx),
                ),
                new FlatButton(
                  child: new Text('View'.toUpperCase()),
                  onPressed: () => Navigator.pop(ctx, storyId),
                ),
              ],
            ),
          ),
        ],
      )
    );

    if (storyId != null) {
      print(storyId);
      Navigator.pushNamed(ctx, '/${Routes.STORIES}:$storyId');
    }
  }

  _openUserDialog (BuildContext ctx) async {
    String userId;

    userId = await showDialog(
      context: ctx,
      child: new SimpleDialog(
        title: const Text('Enter user ID'),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        children: <Widget>[
          new TextField(
            autofocus: true,
            autocorrect: false,
            keyboardType: TextInputType.text,
            decoration: new InputDecoration(
              labelText: 'User ID',
            ),
            onChanged: (String val) => userId = val,
          ),
          new Container(
            height: 8.0,
          ),
          new ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'.toUpperCase()),
                  onPressed: () => Navigator.pop(ctx),
                ),
                new FlatButton(
                  child: new Text('View'.toUpperCase()),
                  onPressed: () => Navigator.pop(ctx, userId),
                ),
              ],
            ),
          ),
        ],
      )
    );

    if (userId != null) {
      print(userId);
      Navigator.pushNamed(ctx, '/${Routes.USERS}:$userId');
    }
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final HNItemStore itemStore = stores[itemStoreToken];
    final UIStore uiStore = stores[uiStoreToken];

    var stories = itemStore.sortedStoryIds
      .map((itemId) => itemStore.items[itemId])
      .takeWhile((story) => story != null);

    final sortMode = uiStore.sortMode;

    final storyCards = new Scrollbar(
      child: new ListView(
        children: <Widget>[
          const Padding(
            padding: const EdgeInsets.only(top: 5.0),
          )
        ]..addAll(
          stories.map<Widget>((story) => new StoryCard(
            storyId: story.id,
          )).toList()..addAll([
            new Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: new FlatButton(
                child: new Column(
                  children: <Widget>[
                    const Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: const Icon(Icons.replay),
                    ),
                    const Text('Load more'),
                  ],
                ),
                onPressed: () => this._loadMore(stories.length, sortMode),
              ),
            ),
            // Bottom padding for FAB and home gesture bar
            const FABBottomPadding(),
          ]),
        ),
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
            onSelected: this._changeSortMode,
          ),
        ],
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountEmail: const Text('louis@orleans.io'),
              accountName: const Text('Louis Orleans'),
            ),
            new MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text('Open Story'),
                    onTap: () {
                      this._openStoryDialog(context);
                    },
                  ),
                  new ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: const Text('Open User'),
                    onTap: () {
                      this._openUserDialog(context);
                    },
                  ),
                  const Divider(),
                  new ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                    }
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: itemStore.items.length > 0 ?
        new RefreshIndicator(
          onRefresh: () => this._refresh(sortMode),
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
