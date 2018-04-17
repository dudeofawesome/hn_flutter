import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';

import 'package:hn_flutter/components/main_drawer.dart';
import 'package:hn_flutter/pages/starred_comments.dart';
import 'package:hn_flutter/pages/starred_stories.dart';
import 'package:hn_flutter/pages/stories.dart';
import 'package:hn_flutter/pages/user.dart';
import 'package:hn_flutter/pages/voted_stories.dart';
import 'package:hn_flutter/pages/voted_comments.dart';

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
      case MainPageSubPages.STARRED_STORIES:
        pageWidget = new StarredStoriesPage();
        break;
      case MainPageSubPages.STARRED_COMMENTS:
        pageWidget = new StarredCommentsPage();
        break;
      case MainPageSubPages.VOTED_STORIES:
        pageWidget = new VotedStoriesPage();
        break;
      case MainPageSubPages.VOTED_COMMENTS:
        pageWidget = new VotedCommentsPage();
        break;
    }

    return new Scaffold(
      drawer: new MainDrawer(this.page),
      body: pageWidget,
    );
  }
}
