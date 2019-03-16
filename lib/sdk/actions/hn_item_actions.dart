import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/models/hn_item.dart';

final Action<HNItem> addHNItem = new Action();
final Action<int> markAsSeen = new Action();
final Action<int> toggleSaveItem = new Action();
final Action<int> toggleUpvoteItem = new Action();
final Action<int> toggleDownvoteItem = new Action();
final Action<HNItemStatus> patchItemStatus = new Action();
final Action<List<int>> setStorySort = new Action();
final Action<int> showHideItem = new Action();

class HNItemAction {
  HNItem item;
  HNItemStatus status;

  HNItemAction([
    this.item,
    this.status,
  ]);
}
