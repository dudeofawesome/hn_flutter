import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/sdk/services/abstract/hn_user_service.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';

import 'package:hn_flutter/components/story_card.dart';

class UpvotedItemsTab extends StatefulWidget {
  final String userId;

  const UpvotedItemsTab (
    this.userId, {
    Key key,
  }) : super(key: key);

  @override
  createState () => new _UpvotedItemsTabState();
}

class _UpvotedItemsTabState extends State<UpvotedItemsTab> with StoreWatcherMixin<UpvotedItemsTab> {
  HNUserService _hnUserService = new Injector().hnUserService;
  HNItemStore _hnItemStore;
  HNAccountStore _hnAccountStore;

  @override
  initState () {
    super.initState();
    this._hnItemStore = listenToStore(itemStoreToken);
    this._hnAccountStore = listenToStore(accountStoreToken);

    this._refresh();
  }

  Future<Null> _refresh () async {
    await this._hnUserService.getVotedByUserID(
      widget.userId, this._hnAccountStore.primaryAccount.accessCookie);
  }

  @override
  Widget build (BuildContext context) {
    final upvotedItems = this._hnItemStore.itemStatuses.values
      .where((itemStatus) => itemStatus.saved);

    return new RefreshIndicator(
      // key: this._refreshIndicatorKey,
      onRefresh: () => this._refresh(),
      child: new Scrollbar(
        child: (upvotedItems.length > 0)
          ? new ListView(
            children: upvotedItems.map((itemStatus) => new StoryCard(
              storyId: itemStatus.id,
            ))?.toList(),
          )
          : new ListView(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            children: [
              new Center(child: new Text('No submissions'))
            ],
          ),
      )
    );
  }
}
