import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/actions/ui_actions.dart';

class UIStore extends Store {
  UIStore () {
    triggerOnAction(selectItem, (int selection) {
      if (this._selectedItem != selection) {
        this._selectedItem = selection;
      } else {
        this._selectedItem = null;
      }
    });

    triggerOnAction(setStorySortMode, (SortModes sortMode) {
      _sortMode = sortMode;
    });
  }

  int _selectedItem;
  SortModes _sortMode = SortModes.TOP;

  int get item => this._selectedItem;
  SortModes get sortMode => this._sortMode;
}

final StoreToken uiStoreToken = new StoreToken(new UIStore());

enum SortModes {
  TOP,
  NEW,
  BEST,
  ASK_HN,
  SHOW_HN,
  JOB,
}
