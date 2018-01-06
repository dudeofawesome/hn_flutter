import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:share/share.dart';

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_user_store.dart';
import 'package:hn_flutter/sdk/hn_user_service.dart';

import 'package:hn_flutter/components/user_about_tab.dart';
import 'package:hn_flutter/components/user_comments_tab.dart';
import 'package:hn_flutter/components/user_submitted_tab.dart';

class UserPage extends StoreWatcher {
  final String userId;

  UserPage ({
    Key key,
    @required this.userId,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(userStoreToken);
  }

  Future<Null> _shareUser (String userId) async {
    await share('https://news.ycombinator.com/user?id=$userId');
  }

  void _saveUser () {}

  @override
  Widget build (BuildContext context, Map<StoreToken, Store> stores) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final HNUserStore userStore = stores[userStoreToken];
    final user = userStore.users[this.userId];

    if (user == null) {
      print('getting user $userId');
      final HNUserService _hnStoryService = new HNUserService();
      _hnStoryService.getUserByID(this.userId);
    }

    return new DefaultTabController(
      length: choices.length,
      child: new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(user?.id ?? this.userId),
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.star_border),
              tooltip: 'Save',
              onPressed: () => _saveUser(),
              // color: user.computed.saved ? Colors.amber : Colors.black,
            ),
            new PopupMenuButton<OverflowMenuItems>(
              icon: const Icon(Icons.more_horiz),
              itemBuilder: (BuildContext ctx) => <PopupMenuEntry<OverflowMenuItems>>[
                const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.SHARE,
                  child: const Text('Share'),
                ),
              ],
              onSelected: (OverflowMenuItems selection) async {
                switch (selection) {
                  case OverflowMenuItems.SHARE:
                    return await this._shareUser(user.id);
                }
              },
            ),

          ],
          bottom: new TabBar(
            // isScrollable: true,
            tabs: choices.map((choice) => new Tab(
              text: choice.title.toUpperCase(),
              icon: new Icon(choice.icon),
            )).toList(),
          ),
        ),
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

enum OverflowMenuItems {
  SHARE,
}

enum SortModes {
  TOP,
  NEW,
  BEST,
}

class Choice {
  const Choice({ this.title, this.icon });
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'User', icon: Icons.account_box),
  const Choice(title: 'Submitted', icon: Icons.forum),
  const Choice(title: 'Comments', icon: Icons.chat),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({ Key key, this.choice }) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return new Card(
      color: Colors.white,
      child: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Icon(choice.icon, size: 128.0, color: textStyle.color),
            new Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
