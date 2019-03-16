import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/sdk/services/abstract/hn_user_service.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';

import 'package:hn_flutter/components/comment.dart';

class StarredCommentsTab extends StatefulWidget {
  final String userId;

  const StarredCommentsTab(
    this.userId, {
    Key key,
  }) : super(key: key);

  @override
  createState() => new _StarredCommentsTabState();
}

class _StarredCommentsTabState extends State<StarredCommentsTab>
    with StoreWatcherMixin<StarredCommentsTab> {
  HNUserService _hnUserService = new Injector().hnUserService;
  HNItemStore _hnItemStore;
  HNAccountStore _hnAccountStore;

  bool _loading = false;

  @override
  initState() {
    super.initState();
    this._hnItemStore = listenToStore(itemStoreToken);
    this._hnAccountStore = listenToStore(accountStoreToken);

    this._loading = true;
    this._refresh();
  }

  Future<Null> _refresh() async {
    await this._hnUserService.getSavedByUserID(
        widget.userId, false, this._hnAccountStore.primaryAccount.accessCookie);
    setState(() => this._loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final starredStories = this
        ._hnItemStore
        .itemStatuses
        .values
        .where((itemStatus) => itemStatus.saved);

    return (!this._loading)
        ? new Scrollbar(
            child: starredStories.length > 0
                ? new ListView(
                    children: starredStories
                        .map((itemStatus) => new Comment(
                              itemId: itemStatus.id,
                              loadChildren: false,
                              buttons: <BarButtons>[
                                BarButtons.VIEW_CONTEXT,
                                BarButtons.SAVE,
                                BarButtons.SHARE,
                                BarButtons.COPY_TEXT,
                              ],
                              overflowButtons: <BarButtons>[],
                            ))
                        ?.toList(),
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
