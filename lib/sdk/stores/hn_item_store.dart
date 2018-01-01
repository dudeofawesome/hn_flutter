import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

class HNItemStore extends Store {
  HNItemStore () {
    triggerOnAction(addHNItem, (HNItem item) {
      final HNItem found = this._items.firstWhere((el) => el.id == item.id, orElse: () {
        this._items.add(item);
      });
      if (found != null) {
        this._items[this._items.indexOf(found)] = item;
      }
    });

    triggerOnAction(showHideItem, (int itemId) {
      final HNItem item = this._items.firstWhere((el) => el.id == itemId);

      // TODO: don't mutate the old state but rather make a clone
      item.computed.hidden = !item.computed.hidden;
    });

    triggerOnAction(sortItems, (List<int> sortedItemIds) {
      this._items.setAll(0, sortedItemIds.map((itemId) => this._items.firstWhere((item) => item.id == itemId)));
    });
  }

  List<HNItem> _items = <HNItem>[];

  List<HNItem> get items => new List.unmodifiable(_items);
  // String get currentMessage => _currentMessage;

  // bool get isComposing => _currentMessage.isNotEmpty;
}

final StoreToken itemStoreToken = new StoreToken(new HNItemStore());
