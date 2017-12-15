import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/actions/selected_item_actions.dart';

class SelectedItemStore extends Store {
  SelectedItemStore () {
    triggerOnAction(selectItem, (int selection) {
      if (this._selectedItem != selection) {
        this._selectedItem = selection;
      } else {
        this._selectedItem = null;
      }
    });
  }

  int _selectedItem;

  int get item => this._selectedItem;
}

final StoreToken selectedItemStoreToken = new StoreToken(new SelectedItemStore());
