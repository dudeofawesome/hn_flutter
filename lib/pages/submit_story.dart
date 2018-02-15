import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/services/hn_item_service.dart';

import 'package:hn_flutter/components/hn_editor.dart';

class SubmitStoryPage extends StoreWatcher {
  SubmitStoryPage ({
    Key key,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    // listenToStore(userStoreToken);
  }

  @override
  Widget build (BuildContext context, Map<StoreToken, Store> stores) {
    // final HNUserStore userStore = stores[userStoreToken];

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Submit Story'),
        actions: <Widget>[],
      ),
      body: new Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: /* new Column(
          children: <Widget>[
            new Text('test'), */
            new HackerNewsEditor(),
        //   ],
        // ),
      )
    );
  }
}
