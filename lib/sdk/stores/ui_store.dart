import 'dart:async';
import 'dart:io';

import 'package:flutter_flux/flutter_flux.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/sdk/actions/ui_actions.dart';
import 'package:hn_flutter/sdk/sqflite_vals.dart';
import 'package:hn_flutter/sdk/services/local_storage_service.dart';

class UIStore extends Store {
  static final UIStore _singleton = new UIStore._internal();

  final LocalStorageService _localStorage = new Injector().localStorageService;

  UIStore._internal () {
    new Future(() async {
      final storySortModeKeys = await this._localStorage.databases[KEYS_DB].query(
        KEYS_TABLE,
        columns: [KEYS_ID, KEYS_VALUE],
        where: '$KEYS_ID = ?',
        whereArgs: [KEY_STORY_SORT_MODE],
        limit: 1,
      );

      if (storySortModeKeys.length > 0) {
        setStorySortMode(SortModes.values[int.parse(storySortModeKeys.first[KEYS_VALUE])]);
      }
    }).then((a) {});

    triggerOnAction(selectItem, (int selection) {
      if (this._selectedItem != selection) {
        this._selectedItem = selection;
      } else {
        this._selectedItem = null;
      }
    });

    triggerOnAction(setStoryScrollPos, (Tuple2<int, double> storyScrollPos) {
      print('setting scroll pos: $storyScrollPos');
      this._storyScrollPos[storyScrollPos.item1] = storyScrollPos.item2;
    });

    triggerOnAction(setStorySortMode, (SortModes sortMode) async {
      _sortMode = sortMode;

      await this._localStorage.databases[KEYS_DB].rawInsert(
        '''
        INSERT OR REPLACE INTO $KEYS_TABLE ($KEYS_ID, $KEYS_VALUE)
          VALUES (?, ?);
        ''',
        [KEY_STORY_SORT_MODE, _sortMode.index]
      );
    });
  }

  factory UIStore () => _singleton;

  int _selectedItem;
  SortModes _sortMode = SortModes.TOP;
  Map<int, double> _storyScrollPos = new Map();

  int get item => this._selectedItem;
  SortModes get sortMode => this._sortMode;
  Map<int, double> get storyScrollPos => new Map.unmodifiable(this._storyScrollPos);
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
