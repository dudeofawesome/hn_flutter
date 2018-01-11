import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

class HNItemStore extends Store {
  HNItemStore () {
    triggerOnAction(addHNItem, (HNItemAction action) {
      this._items[action.item.id] = action.item;
      if (action.status != null) {
        this._itemStatuses[action.item.id] = action.status;
      } else {
        this._itemStatuses[action.item.id] = new HNItemStatus(id: action.item.id);
      }
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

    triggerOnAction(setStorySort, (List<int> sortedItemIds) {
      this._sortedStoryIds = sortedItemIds;
    });

    triggerOnAction(showHideItem, (int itemId) {
      final HNItemStatus itemStatus = this._itemStatuses[itemId];

      // TODO: don't mutate the old state but rather make a clone
      itemStatus.hidden = !(itemStatus?.hidden ?? false);
    });
  }

  Map<int, HNItem> _items = new Map();
  Map<int, HNItemStatus> _itemStatuses = new Map();
  List<int> _sortedStoryIds = <int>[];

  Map<int, HNItem> get items => new Map.unmodifiable(_items);
  Map<int, HNItemStatus> get itemStatuses => new Map.unmodifiable(_itemStatuses);
  List<int> get sortedStoryIds => new List.unmodifiable(_sortedStoryIds);

  // bool get isComposing => _currentMessage.isNotEmpty;
}

final StoreToken itemStoreToken = new StoreToken(new HNItemStore());
