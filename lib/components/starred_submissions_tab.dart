import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/sdk/services/abstract/hn_user_service.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';

import 'package:hn_flutter/components/story_card.dart';

class StarredSubmissionsTab extends StatefulWidget {
  final String userId;

  const StarredSubmissionsTab (
    this.userId, {
    Key key,
  }) : super(key: key);

  @override
  createState () => new _StarredSubmissionsTabState();
}

class _StarredSubmissionsTabState extends State<StarredSubmissionsTab> with StoreWatcherMixin<StarredSubmissionsTab> {
  HNUserService _hnUserService = new Injector().hnUserService;
  HNItemStore _hnItemStore;
  HNAccountStore _hnAccountStore;

  bool _loading = false;

  @override
  initState () {
    super.initState();
    this._hnItemStore = listenToStore(itemStoreToken);
    this._hnAccountStore = listenToStore(accountStoreToken);

    this._loading = true;
    this._refresh();
  }

  Future<Null> _refresh () async {
    await this._hnUserService.getSavedByUserID(widget.userId, true, this._hnAccountStore.primaryAccount.accessCookie);
    setState(() => this._loading = false);
  }

  @override
  Widget build (BuildContext context) {
    final starredStories = this._hnItemStore.itemStatuses.values
      .where((itemStatus) => itemStatus.saved);

    return (!this._loading)
      ? new Scrollbar(
        child: starredStories.length > 0
          ? new ListView(
            children: starredStories.map((itemStatus) => new StoryCard(
              storyId: itemStatus.id,
            ))?.toList(),
          )
          : new Center(
            child: new Text('No submissions'),
          ),
      )
      : new Center(
        child: new CircularProgressIndicator(),
      );
  }
}
