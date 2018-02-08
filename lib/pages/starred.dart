import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:share/share.dart';

import 'package:hn_flutter/sdk/stores/hn_user_store.dart';
import 'package:hn_flutter/sdk/services/hn_user_service.dart';

class StarredPage extends StatefulWidget {
  @override
  _StarredPageState createState () => new _StarredPageState();
}

class _StarredPageState extends State<StarredPage> with StoreWatcherMixin<StarredPage> {
  @override
  void initState () {
    super.initState();
    listenToStore(userStoreToken);
  }

  @override
  Widget build (BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    // final HNUserStore userStore = stores[userStoreToken];
    // final user = userStore.users[this.userId];

    // if (user == null) {
    //   print('getting user $userId');
    //   final HNUserService _hnStoryService = new HNUserService();
    //   _hnStoryService.getUserByID(this.userId);
    // }

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Starred'),
        actions: <Widget>[],
      ),
      body: const Center(
        child: const Text('Starred'),
      ),
    );
  }
}
