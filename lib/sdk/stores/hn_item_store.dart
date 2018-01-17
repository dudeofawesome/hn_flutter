import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

class HNItemStore extends Store {
  static final HNItemStore _singleton = new HNItemStore._internal();

  HNItemStore._internal () {
    triggerOnAction(addHNItem, (HNItem item) {
      this._items[item.id] = item;
    });

    triggerOnAction(markAsSeen, (int itemId) {
      // TODO: don't mutate the old state but rather make a clone
      this._itemStatuses[itemId].seen = true;
    });

    triggerOnAction(toggleSaveItem, (int itemId) {
      final HNItemStatus itemStatus = this._itemStatuses[itemId];

      // TODO: don't mutate the old state but rather make a clone
      itemStatus.saved = !(itemStatus?.saved ?? false);
    });

    triggerOnAction(toggleUpvoteItem, (int itemId) {
      final HNItemStatus itemStatus = this._itemStatuses[itemId];

      // TODO: don't mutate the old state but rather make a clone
      itemStatus.upvoted = !(itemStatus?.upvoted ?? false);
    });

    triggerOnAction(toggleDownvoteItem, (int itemId) {
      final itemStatus = this._itemStatuses[itemId];

      // TODO: don't mutate the old state but rather make a clone
      itemStatus.downvoted = !(itemStatus?.downvoted ?? false);
    });

    triggerOnAction(setStorySort, (List<int> sortedItemIds) {
      this._sortedStoryIds = sortedItemIds;
    });

    triggerOnAction(showHideItem, (int itemId) {
      final itemStatus = this._itemStatuses[itemId];

      // TODO: don't mutate the old state but rather make a clone
      itemStatus.hidden = !(itemStatus?.hidden ?? false);
    });

    triggerOnAction(patchItemStatus, (HNItemStatus status) {
      var itemStatus = this._itemStatuses[status.id];

      if (itemStatus == null) {
        this._itemStatuses[status.id] = new HNItemStatus(id: status.id);
        itemStatus = this._itemStatuses[status.id];
      }

      // TODO: don't mutate the old state but rather make a clone
      itemStatus.loading = status.loading ?? itemStatus.loading;
      itemStatus.upvoted = status.upvoted ?? itemStatus.upvoted;
      itemStatus.downvoted = status.downvoted ?? itemStatus.downvoted;
      itemStatus.saved = status.saved ?? itemStatus.saved;
      itemStatus.hidden = status.hidden ?? itemStatus.hidden;
      itemStatus.seen = status.seen ?? itemStatus.seen;

      if (itemStatus.authTokens != null && status.authTokens != null) {
        itemStatus.authTokens.upvote = status.authTokens.upvote ?? itemStatus.authTokens.upvote;
        itemStatus.authTokens.downvote = status.authTokens.downvote ?? itemStatus.authTokens.downvote;
        itemStatus.authTokens.hide = status.authTokens.hide ?? itemStatus.authTokens.hide;
        itemStatus.authTokens.save = status.authTokens.save ?? itemStatus.authTokens.save;
        itemStatus.authTokens.see = status.authTokens.see ?? itemStatus.authTokens.see;
        itemStatus.authTokens.reply = status.authTokens.reply ?? itemStatus.authTokens.reply;
      } else if (status.authTokens != null) {
        itemStatus.authTokens = status.authTokens;
      }
    });
  }

  factory HNItemStore () {
    return _singleton;
  }

  Map<int, HNItem> _items = new Map();
  Map<int, HNItemStatus> _itemStatuses = new Map();
  List<int> _sortedStoryIds = <int>[];

  Map<int, HNItem> get items => new Map.unmodifiable(_items);
  Map<int, HNItemStatus> get itemStatuses => new Map.unmodifiable(_itemStatuses);
  List<int> get sortedStoryIds => new List.unmodifiable(_sortedStoryIds);

  _setStatusDefaults (HNItemStatus status) {
    if (status.downvoted == null) {
      status.downvoted = false;
    }
    if (status.hidden == null) {
      status.hidden = false;
    }
    if (status.loading == null) {
      status.loading = false;
    }
    if (status.saved == null) {
      status.saved = false;
    }
    if (status.seen == null) {
      status.seen = false;
    }
    if (status.upvoted == null) {
      status.upvoted = false;
    }
  }
}

final StoreToken itemStoreToken = new StoreToken(new HNItemStore());
