import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/components/story_card.dart' show StoryCard;
// import 'package:hn_flutter/sdk/hn_story_service.dart';
// import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';

import 'package:hn_flutter/router.dart';

class StoriesPage extends StoreWatcher { // State<StoriesPage> {
  // final HNStoryService _hnStoryService = new HNStoryService();

  StoriesPage () {
    // this._hnStoryService.getTopStories().then((stories) {
    //   print(stories);
    //   setState(() {
    //     this._stories = stories;
    //   });
    // });
  }

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(itemStoreToken);
  }

  void _changeSortMode (SortModes sortModes) {
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
            onChanged: (String val) => storyId = val,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: new Text('Cancel'.toUpperCase()),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.pop(ctx, storyId);
                },
                child: new Text('Go'.toUpperCase()),
              ),
            ],
          ),
        ],
      )
    );

    if (storyId != null) {
      print(storyId);
      Navigator.pushNamed(ctx, '/${Routes.STORIES}:$storyId');
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

    final storyCards = new ListView(
      children: itemStore.items.map<Widget>((story) => new StoryCard(
        story: story,
      )).toList()..addAll([
        // Bottom padding for FAB and home gesture bar
        const SizedBox(
          height: 56.0 + 24.0,
        ),
      ]),
    );

    final loadingStories = const Center(
      child: const CircularProgressIndicator(value: null),
    );

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Hacker News'),
        actions: <Widget>[
          // const IconButton(
          //   icon: const Icon(Icons.sort),
          //   tooltip: 'Sort',
          // ),


          new PopupMenuButton<SortModes>(
            icon: const Icon(Icons.sort),
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
            onSelected: (SortModes selection) => this._changeSortMode(selection),
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
                    leading: const Icon(Icons.open_in_new),
                    title: const Text('Open Story'),
                    onTap: () {
                      this._openStoryDialog(context);
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
      body: itemStore.items.length > 0 ? storyCards : loadingStories,
      floatingActionButton: new FloatingActionButton(
        tooltip: 'New Story',
        child: new Icon(Icons.add),
        // onPressed: _incrementCounter,
      ),
    );
  }
}

enum SortModes {
  TOP,
  NEW,
  BEST,
  ASK_HN,
  SHOW_HN,
  JOB,
}
