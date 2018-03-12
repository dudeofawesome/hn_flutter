import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:share/share.dart';

import 'package:hn_flutter/sdk/stores/hn_user_store.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';

import 'package:hn_flutter/components/upvoted_items_tab.dart';

class VotedStoriesPage extends StoreWatcher {
  VotedStoriesPage ({
    Key key,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(accountStoreToken);
    listenToStore(userStoreToken);
  }

  Future<Null> _shareUser (String userId) async {
    await share('https://news.ycombinator.com/upvoted?id=$userId');
  }

  @override
  Widget build (BuildContext context, Map<StoreToken, Store> stores) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final HNAccountStore accountStore = stores[accountStoreToken];

    return new DefaultTabController(
      length: _choices.length,
      child: new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          leading: (context.ancestorWidgetOfExactType(Scaffold) != null)
            ? new IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            )
            : null,
          title: new Text(
            (accountStore.primaryAccount?.permissions?.canDownvote ?? false)
              ? 'Upvoted'
              : 'Voted'
          ),
          actions: <Widget>[
            new PopupMenuButton<_OverflowMenuItems>(
              icon: const Icon(Icons.more_horiz),
              itemBuilder: (BuildContext ctx) => <PopupMenuEntry<_OverflowMenuItems>>[
                const PopupMenuItem<_OverflowMenuItems>(
                  value: _OverflowMenuItems.SHARE,
                  child: const Text('Share'),
                ),
              ],
              onSelected: (_OverflowMenuItems selection) async {
                switch (selection) {
                  case _OverflowMenuItems.SHARE:
                    return await this._shareUser(accountStore.primaryAccountId);
                }
              },
            ),

          ],
          bottom: (accountStore.primaryAccount?.permissions?.canDownvote ?? false)
            ? new TabBar(
              // isScrollable: true,
              tabs: _choices.map((choice) => new Tab(
                text: choice.title.toUpperCase(),
                icon: new Icon(choice.icon),
              )).toList(),
            )
            : null,
        ),
        body: (accountStore.primaryAccount?.permissions?.canDownvote ?? false)
          ? new TabBarView(
            children: <Widget>[
              new UpvotedItemsTab(
                userId: accountStore.primaryAccountId,
                showStories: true,
              ),
            ],
          )
          : new UpvotedItemsTab(
            userId: accountStore.primaryAccountId,
            showStories: true,
          ),
      ),
    );
  }
}

enum _OverflowMenuItems {
  SHARE,
}

class _Choice {
  const _Choice({ this.title, this.icon });
  final String title;
  final IconData icon;
}

const List<_Choice> _choices = const <_Choice>[
  const _Choice(title: 'Upvoted', icon: Icons.arrow_upward),
  const _Choice(title: 'Downvoted', icon: Icons.arrow_downward),
];
