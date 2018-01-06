import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

class HNItemStore extends Store {
  HNItemStore () {
    triggerOnAction(addHNItem, (HNItem item) {
      this._items[item.id] = item;
    });

    triggerOnAction(showHideItem, (int itemId) {
      final HNItem item = this._items[itemId];

      // TODO: don't mutate the old state but rather make a clone
      item.computed.hidden = !item.computed.hidden;
    });

    triggerOnAction(setStorySort, (List<int> sortedItemIds) {
      this._sortedStoryIds = sortedItemIds;
    });
  }

  Map<int, HNItem> _items = new Map();
  List<int> _sortedStoryIds = <int>[];

  Map<int, HNItem> get items => new Map.unmodifiable(_items);
  List<int> get sortedStoryIds => new List.unmodifiable(_sortedStoryIds);

  // bool get isComposing => _currentMessage.isNotEmpty;
}

final StoreToken itemStoreToken = new StoreToken(new HNItemStore());
