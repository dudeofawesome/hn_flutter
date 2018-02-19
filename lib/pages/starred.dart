import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:share/share.dart';

import 'package:hn_flutter/sdk/stores/hn_user_store.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';

import 'package:hn_flutter/components/stared_submissions_tab.dart';
import 'package:hn_flutter/components/stared_comments_tab.dart';

class StarredPage extends StoreWatcher {
  StarredPage ({
    Key key,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(accountStoreToken);
    listenToStore(userStoreToken);
  }

  Future<Null> _shareUser (String userId) async {
    await share('https://news.ycombinator.com/favorites?id=$userId');
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
          title: new Text('Favorites'),
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
          bottom: new TabBar(
            // isScrollable: true,
            tabs: _choices.map((choice) => new Tab(
              text: choice.title.toUpperCase(),
              icon: new Icon(choice.icon),
            )).toList(),
          ),
        ),
        body: new TabBarView(
          children: <Widget>[
            new StaredSubmissionsTab(accountStore.primaryAccountId),
            new StaredCommentsTab(accountStore.primaryAccountId),
          ],
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
  const _Choice(title: 'Submissions', icon: Icons.forum),
  const _Choice(title: 'Comments', icon: Icons.chat),
];
