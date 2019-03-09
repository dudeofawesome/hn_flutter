import 'dart:async';
import 'dart:io' show Directory;

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hn_flutter/sdk/services/abstract/local_storage_service.dart';
import 'package:hn_flutter/sdk/sqflite_vals.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';

class LocalStorageServiceMock implements LocalStorageService {
  static final LocalStorageServiceMock _singleton = new LocalStorageServiceMock._internal();

  Directory _documentsDirectory;
  Map<String, Database> _databases = new Map();

  LocalStorageServiceMock._internal ();

  factory LocalStorageServiceMock () {
    return _singleton;
  }

  Future<Null> init () async {
    this._documentsDirectory = await getApplicationDocumentsDirectory();

    String keysPath = join(this._documentsDirectory.path, KEYS_DB);
    this._databases[KEYS_DB] = await openDatabase(keysPath, version: 1, onCreate: (Database db, int version) async {
      print('CREATING KEYS TABLE');
      await db.execute('CREATE TABLE $KEYS_TABLE ($KEYS_ID TEXT PRIMARY KEY, $KEYS_VALUE TEXT)');
    });

    String accountsPath = join(this._documentsDirectory.path, ACCOUNTS_DB);
    this._databases[ACCOUNTS_DB] = await openDatabase(accountsPath, version: 1, onCreate: (Database db, int version) async {
      print('CREATING ACCOUNTS TABLE');
      await db.execute('''
        CREATE TABLE $ACCOUNTS_TABLE
          ($ACCOUNTS_ID TEXT PRIMARY KEY, $ACCOUNTS_EMAIL TEXT, $ACCOUNTS_PASSWORD TEXT, $ACCOUNTS_ACCESS_COOKIE TEXT)
      ''');
    });
  }

  Map<String, Database> get databases => new Map.unmodifiable(this._databases);

  Future<String> get primaryUserId {
    return this._databases[KEYS_DB].query(
        KEYS_TABLE,
        columns: [KEYS_ID, KEYS_VALUE],
        where: '$KEYS_ID = ?',
        whereArgs: [KEY_PRIMARY_ACCOUNT_ID],
        limit: 1,
      )
      .then((res) => (res.length > 0 && res.first.containsKey(KEYS_VALUE))
        ? res.first[KEYS_VALUE]
        : null
      );
  }

  Future<List<HNAccount>> get accounts {
    return this._databases[ACCOUNTS_DB].query(
        ACCOUNTS_TABLE,
        columns: [
          ACCOUNTS_ID, ACCOUNTS_EMAIL, ACCOUNTS_PASSWORD,
          ACCOUNTS_ACCESS_COOKIE, ACCOUNTS_PERMISSIONS, ACCOUNTS_PREFERENCES,
        ],
      )
      .then((accounts) => accounts
        .map((accountMap) => new HNAccount.fromMap(accountMap))
        .toList())
      .then((accounts) => new List.unmodifiable(accounts));
  }

  Future<Null> addHNAccount (HNAccount account) async {
    print('Added ${account.id} to SQLite');
  }

  Future<Null> removeHNAccount (String userId) async {
    print('Removed $userId from SQLite');
  }

  Future<Null> setPrimaryHNAccount (String userId) async {
    print('Set primary HN account to $userId');
  }

  Future<Null> unsetPrimaryHNAccount (String userId) async {
    print('Unset primary HN account to $userId');
  }
}
