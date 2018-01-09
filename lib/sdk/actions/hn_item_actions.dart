import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/models/hn_item.dart';

final Action<HNItemAction> addHNItem = new Action();
final Action<int> markAsSeen = new Action();
final Action<List<int>> setStorySort = new Action();
final Action<int> showHideItem = new Action();

class HNItemAction {
  HNItem item;
  HNItemStatus status;

  HNItemAction ([
    this.item, this.status,
  ]);
}
