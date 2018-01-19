import 'dart:async';
import 'dart:io';

import 'package:flutter_flux/flutter_flux.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hn_flutter/sdk/actions/ui_actions.dart';
import 'package:hn_flutter/sdk/sqflite_vals.dart';

class UIStore extends Store {
  static final UIStore _singleton = new UIStore._internal();

  Directory _documentsDirectory;
  Database _keysDb;

  UIStore._internal () {
    new Future(() async {
      this._documentsDirectory = await getApplicationDocumentsDirectory();

      String keysPath = join(this._documentsDirectory.path, KEYS_DB);
      this._keysDb = await openDatabase(keysPath, version: 1, onCreate: (Database db, int version) async {
        print('CREATING KEYS TABLE');
        await db.execute('CREATE TABLE $KEYS_TABLE ($KEYS_ID TEXT PRIMARY KEY, $KEYS_VALUE TEXT)');
      });

      final storySortModeKeys = await this._keysDb.query(
        KEYS_TABLE,
        columns: [KEYS_ID, KEYS_VALUE],
        where: '$KEYS_ID = ?',
        whereArgs: [KEY_STORY_SORT_MODE],
        limit: 1,
      );

      if (storySortModeKeys.length > 0) {
        print('primary account was ${storySortModeKeys.first[KEYS_VALUE]}');
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

    triggerOnAction(setStorySortMode, (SortModes sortMode) async {
      _sortMode = sortMode;

      await this._keysDb.rawInsert(
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
