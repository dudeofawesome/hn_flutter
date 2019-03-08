import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:share/share.dart';

import 'package:hn_flutter/router.dart';

import 'package:hn_flutter/sdk/stores/hn_user_store.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';

import 'package:hn_flutter/components/main_drawer.dart';
import 'package:hn_flutter/components/starred_items_tab.dart';

class StarredCommentsPage extends StoreWatcher {
  final bool showDrawer;

  StarredCommentsPage ({
    Key key,
    this.showDrawer = true,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(accountStoreToken);
    listenToStore(userStoreToken);
  }

  Future<Null> _share (String userId) async {
    await Share.share('https://news.ycombinator.com/favorites?id=$userId&comments=t');
  }

  @override
  Widget build (BuildContext context, Map<StoreToken, Store> stores) {
    final HNAccountStore accountStore = stores[accountStoreToken];

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text('Favorite Comments'),
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
                  return await this._share(accountStore.primaryAccountId);
              }
            },
          ),

        ],
      ),
      drawer: this.showDrawer
        ? new Builder(builder: (context) {
          return new MainDrawer(MainPageSubPages.STARRED_COMMENTS, Scaffold.of(context));
        })
        : null,
      body: new StarredItemsTab(
        userId: accountStore.primaryAccountId,
        showComments: true,
      ),
    );
  }
}

enum _OverflowMenuItems {
  SHARE,
}
