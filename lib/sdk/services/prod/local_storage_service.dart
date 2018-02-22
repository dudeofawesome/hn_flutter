import 'dart:async';
import 'dart:io' show Directory;
import 'dart:convert' show JSON;

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
    String keysPath = join(this._documentsDirectory.path, KEYS_DB);
    this._databases[KEYS_DB] = await openDatabase(keysPath, version: 1, onCreate: (Database db, int version) async {
      print('CREATING KEYS TABLE');
      await db.execute('CREATE TABLE $KEYS_TABLE ($KEYS_ID TEXT PRIMARY KEY, $KEYS_VALUE TEXT)');
    });
  }

  Future<Null> _initTableAccounts () async {
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
      .then((res) => res.first[KEYS_VALUE]);
  }

  Future<List<HNAccount>> get accounts {
    return this._databases[ACCOUNTS_DB].query(
        ACCOUNTS_TABLE,
        columns: [ACCOUNTS_ID, ACCOUNTS_EMAIL, ACCOUNTS_PASSWORD, ACCOUNTS_ACCESS_COOKIE],
      )
      .then((accounts) => accounts.map((accountMap) => new HNAccount.fromMap(accountMap))
        .toList())
      .then((accounts) => new List.unmodifiable(accounts));
  }

  Future<Null> addHNAccount (HNAccount account) async {
    print('Adding ${account.id} to SQLite');

    final cookieJson = JSON.encode({
      'name': account.accessCookie.name,
      'value': account.accessCookie.value,
      'expires': account.accessCookie.expires.millisecondsSinceEpoch,
      'domain': account.accessCookie.domain,
      'httpOnly': account.accessCookie.httpOnly,
      'secure': account.accessCookie.secure,
    });

    await this._databases[ACCOUNTS_DB].rawInsert(
      '''
      INSERT OR REPLACE INTO $ACCOUNTS_TABLE ($ACCOUNTS_ID, $ACCOUNTS_EMAIL, $ACCOUNTS_PASSWORD, $ACCOUNTS_ACCESS_COOKIE)
        VALUES (?, ?, ?, ?);
      ''',
      [account.id, account.email, account.password, cookieJson]
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
