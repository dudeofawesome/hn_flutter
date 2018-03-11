import 'dart:async';
import 'dart:io' show Cookie;

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';

import 'package:hn_flutter/components/main_drawer.dart';
import 'package:hn_flutter/pages/stories.dart';
import 'package:hn_flutter/pages/user.dart';

class MainPage extends StoreWatcher {
  final MainPageSubPages page;

  MainPage (
    this.page, {
    Key key,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(accountStoreToken);
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    final HNAccountStore accountStore = stores[accountStoreToken];

    Widget pageWidget;

    switch (this.page) {
      case MainPageSubPages.STORIES:
        pageWidget = new StoriesPage();
        break;
      case MainPageSubPages.PROFILE:
        pageWidget = new UserPage(userId: accountStore.primaryAccountId);
        break;
    }

    return new Scaffold(
      drawer: new MainDrawer(this.page),
      body: pageWidget,
    );
  }
}
