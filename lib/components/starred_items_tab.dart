import 'dart:async';
import 'dart:io' show HandshakeException;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/sdk/services/abstract/hn_user_service.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

import 'package:hn_flutter/components/story_card.dart';
import 'package:hn_flutter/components/comment.dart';

class StarredItemsTab extends StatefulWidget {
  final String userId;
  final bool showStories;
  final bool showComments;

  const StarredItemsTab({
    this.userId,
    this.showStories = false,
    this.showComments = false,
    Key key,
  }) : super(key: key);

  @override
  createState() => new _StarredItemsTabState();
}

class _StarredItemsTabState extends State<StarredItemsTab>
    with StoreWatcherMixin<StarredItemsTab> {
  HNUserService _hnUserService = new Injector().hnUserService;
  HNItemStore _hnItemStore;
  HNAccountStore _hnAccountStore;

  @override
  initState() {
    super.initState();
    this._hnItemStore = listenToStore(itemStoreToken);
    this._hnAccountStore = listenToStore(accountStoreToken);

    this._refresh(context);
  }

  Future<Null> _refresh(BuildContext context) async {
    try {
      if (widget.showStories) {
        await this._hnUserService.getSavedByUserID(widget.userId, true,
            this._hnAccountStore.primaryAccount.accessCookie);
      }
      if (widget.showComments) {
        await this._hnUserService.getSavedByUserID(widget.userId, false,
            this._hnAccountStore.primaryAccount.accessCookie);
      }
    } on HandshakeException catch (err) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(err.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final upvotedItems = this
        ._hnItemStore
        .itemStatuses
        .values
        .where((itemStatus) => itemStatus.saved)
        .where((itemStatus) {
      if (widget.showStories && widget.showComments) {
        return true;
      } else if (this._hnItemStore.items[itemStatus.id] != null) {
        if (widget.showStories) {
          return this._hnItemStore.items[itemStatus.id]?.type ==
              HNItemType.STORY;
        } else if (widget.showComments) {
          return this._hnItemStore.items[itemStatus.id]?.type ==
              HNItemType.COMMENT;
        }
      }
      return true;
    }).toList();

    return new RefreshIndicator(
        onRefresh: () => this._refresh(context),
        child: new Scrollbar(
          child: (upvotedItems.length > 0)
              ? new ListView.builder(
                  itemCount: upvotedItems.length,
                  itemBuilder: (context, index) =>
                      (this._hnItemStore.items[upvotedItems[index].id]?.type ==
                              HNItemType.STORY)
                          ? new StoryCard(
                              storyId: upvotedItems[index].id,
                            )
                          : new Comment(
                              itemId: upvotedItems[index].id,
                              loadChildren: false,
                            ),
                )
              : new ListView(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  children: [new Center(child: new Text('No submissions'))],
                ),
        ));
  }
}
