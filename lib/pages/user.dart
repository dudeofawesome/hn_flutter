import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:share/share.dart';

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/sdk/stores/hn_user_store.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/services/hn_user_service.dart';

import 'package:hn_flutter/components/main_drawer.dart';
import 'package:hn_flutter/components/user_about_tab.dart';
import 'package:hn_flutter/components/user_comments_tab.dart';
import 'package:hn_flutter/components/user_submitted_tab.dart';

class UserPage extends StoreWatcher {
  final HNUserService _hnUserService = new Injector().hnUserService;

  /// the HN user id to view. `null` will show the logged in user's page
  final String userId;
  final bool showDrawer;

  UserPage({
    Key key,
    @required this.userId,
    this.showDrawer = false,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(accountStoreToken);
    listenToStore(userStoreToken);
  }

  Future<Null> _shareUser(String userId) async {
    await Share.share('https://news.ycombinator.com/user?id=$userId');
  }

  void _saveUser() {}

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final HNUserStore userStore = stores[userStoreToken];
    final HNAccountStore accountStore = stores[accountStoreToken];

    final userId = this.userId ?? accountStore.primaryAccountId;

    final user = userStore.users[userId];

    if (user == null) {
      print('getting user $userId');
      this._hnUserService.getUserByID(userId);
    }

    return new DefaultTabController(
      length: _choices.length,
      child: new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(userId),
          actions: <Widget>[
            // new IconButton(
            //   icon: const Icon(Icons.star_border),
            //   tooltip: 'Save',
            //   onPressed: () => _saveUser(),
            //   // color: user.computed.saved ? Colors.amber : Colors.black,
            // ),
            new PopupMenuButton<_OverflowMenuItems>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (BuildContext ctx) =>
                  <PopupMenuEntry<_OverflowMenuItems>>[
                    const PopupMenuItem<_OverflowMenuItems>(
                      value: _OverflowMenuItems.SHARE,
                      child: const Text('Share'),
                    ),
                  ],
              onSelected: (_OverflowMenuItems selection) async {
                switch (selection) {
                  case _OverflowMenuItems.SHARE:
                    return await this._shareUser(userId);
                }
              },
            ),
          ],
          bottom: new TabBar(
            // isScrollable: true,
            tabs: _choices
                .map((choice) => new Tab(
                      text: choice.title.toUpperCase(),
                      icon: new Icon(choice.icon),
                    ))
                .toList(),
          ),
        ),
        drawer: this.showDrawer
            ? new Builder(builder: (context) {
                return new MainDrawer(
                    MainPageSubPages.PROFILE, Scaffold.of(context));
              })
            : null,
        body: new TabBarView(
          children: <Widget>[
            new UserAboutTab(user),
            new UserSubmittedTab(user),
            new UserCommentsTab(user),
          ],
        ),
      ),
    );
  }
}

enum _OverflowMenuItems {
  SHARE,
}

enum SortModes {
  TOP,
  NEW,
  BEST,
}

class _Choice {
  const _Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<_Choice> _choices = const <_Choice>[
  const _Choice(title: 'User', icon: Icons.account_box),
  const _Choice(title: 'Submitted', icon: Icons.forum),
  const _Choice(title: 'Comments', icon: Icons.chat),
];
