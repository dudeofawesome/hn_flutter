import 'dart:async';
import 'dart:io' show Directory;
import 'dart:convert' show json;

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hn_flutter/sdk/services/abstract/local_storage_service.dart';
import 'package:hn_flutter/sdk/sqflite_vals.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';

class LocalStorageServiceProd implements LocalStorageService {
  static final LocalStorageServiceProd _singleton = new LocalStorageServiceProd._internal();

  Directory _documentsDirectory;
  Map<String, Database> _databases = new Map();

  LocalStorageServiceProd._internal ();

  factory LocalStorageServiceProd () {
    return _singleton;
  }

  Future<Null> init () async {
    this._documentsDirectory = await getApplicationDocumentsDirectory();

    await Future.wait([
      this._initTableKeys(),
      this._initTableAccounts(),
    ]);
  }

  Future<Null> _initTableKeys () async {
    final path = join(this._documentsDirectory.path, KEYS_DB);
    this._databases[KEYS_DB] = await openDatabase(
      path, version: KEYS_TABLE_VERSION,
      onCreate: (Database db, int version) async {
        print('CREATING KEYS TABLE');
        await db.execute('''
          CREATE TABLE $KEYS_TABLE
            ($KEYS_ID TEXT PRIMARY KEY, $KEYS_VALUE TEXT)
        ''');
      }
    );
  }

  Future<Null> _initTableAccounts () async {
    final path = join(this._documentsDirectory.path, ACCOUNTS_DB);

    this._databases[ACCOUNTS_DB] = await openDatabase(
      path, version: ACCOUNTS_TABLE_VERSION,
      onCreate: (Database db, int version) async {
        print('CREATING ACCOUNTS TABLE');
        await db.execute('''
          CREATE TABLE $ACCOUNTS_TABLE
            (
              $ACCOUNTS_ID TEXT PRIMARY KEY, $ACCOUNTS_EMAIL TEXT,
              $ACCOUNTS_PASSWORD TEXT, $ACCOUNTS_ACCESS_COOKIE TEXT,
              $ACCOUNTS_PERMISSIONS TEXT, $ACCOUNTS_PREFERENCES TEXT
            )
        ''');
      },
      onUpgrade: (db, old, curr) async {
        if (old <= 1) {
          await Future.wait([
            db.execute('''
              ALTER TABLE $ACCOUNTS_TABLE ADD COLUMN $ACCOUNTS_PERMISSIONS TEXT
            '''),
            db.execute('''
              ALTER TABLE $ACCOUNTS_TABLE ADD COLUMN $ACCOUNTS_PREFERENCES TEXT
            '''),
          ]);
        }
      }
    );
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
    print('Adding ${account.id} to SQLite');

    final cookieJson = json.encode(account.cookieToJson());

    final permissionsJson = json.encode(account.permissions?.toJson());

    final preferencesJson = json.encode(account.preferences?.toJson());

    await this._databases[ACCOUNTS_DB].rawInsert(
      '''
      INSERT OR REPLACE INTO $ACCOUNTS_TABLE
        (
          $ACCOUNTS_ID, $ACCOUNTS_EMAIL, $ACCOUNTS_PASSWORD,
          $ACCOUNTS_ACCESS_COOKIE, $ACCOUNTS_PERMISSIONS, $ACCOUNTS_PREFERENCES
        )
        VALUES (?, ?, ?, ?, ?, ?);
      ''',
      [
        account.id, account.email, account.password, cookieJson,
        permissionsJson, preferencesJson
      ]
    );

    print('Added ${account.id} to SQLite');
  }

  Future<Null> removeHNAccount (String userId) async {
    print('Removing $userId from SQLite');

    await this._databases[ACCOUNTS_DB].delete(
      ACCOUNTS_TABLE,
      where: '$ACCOUNTS_ID = ?',
      whereArgs: [userId],
    );

    print('Removed $userId from SQLite');
  }

  Future<Null> setPrimaryHNAccount (String userId) {
    return this._databases[KEYS_DB].rawInsert(
      '''
      INSERT OR REPLACE INTO $KEYS_TABLE ($KEYS_ID, $KEYS_VALUE)
        VALUES (?, ?);
      ''',
      [KEY_PRIMARY_ACCOUNT_ID, userId],
    );
  }

  Future<Null> unsetPrimaryHNAccount (String userId) {
    return this._databases[KEYS_DB].delete(
      KEYS_TABLE,
      where: '$KEYS_ID = ?',
      whereArgs: [KEY_PRIMARY_ACCOUNT_ID],
    );
  }
}
