import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:io';

import 'package:flutter_flux/flutter_flux.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hn_flutter/sdk/actions/hn_account_actions.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';
import 'package:hn_flutter/sdk/sqflite_vals.dart';

class HNAccountStore extends Store {
  Directory _documentsDirectory;
  Database _keysDb;
  Database _accountsDb;

  String _primaryAccountId;
  final Map<String, HNAccount> _accounts = new Map();

  HNAccountStore () {
    new Future(() async {
      this._documentsDirectory = await getApplicationDocumentsDirectory();

      String keysPath = join(this._documentsDirectory.path, KEYS_DB);
      this._keysDb = await openDatabase(keysPath, version: 1, onCreate: (Database db, int version) async {
        print('CREATING KEYS TABLE');
        await db.execute('CREATE TABLE $KEYS_TABLE ($KEYS_ID TEXT PRIMARY KEY, $KEYS_VALUE TEXT)');
      });

      final primaryUserIdKeys = await this._keysDb.query(
        KEYS_TABLE,
        columns: [KEYS_ID, KEYS_VALUE],
        where: '$KEYS_ID = ?',
        whereArgs: [KEY_PRIMARY_ACCOUNT_ID],
        limit: 1,
      );

      String accountsPath = join(this._documentsDirectory.path, ACCOUNTS_DB);
      this._accountsDb = await openDatabase(accountsPath, version: 1, onCreate: (Database db, int version) async {
        print('CREATING ACCOUNTS TABLE');
        await db.execute('''
          CREATE TABLE $ACCOUNTS_TABLE
            ($ACCOUNTS_ID TEXT PRIMARY KEY, $ACCOUNTS_EMAIL TEXT, $ACCOUNTS_PASSWORD TEXT, $ACCOUNTS_ACCESS_COOKIE TEXT)
        ''');
      });

      final accounts = await this._accountsDb.query(
        ACCOUNTS_TABLE,
        columns: [ACCOUNTS_ID, ACCOUNTS_EMAIL, ACCOUNTS_PASSWORD, ACCOUNTS_ACCESS_COOKIE],
      );

      accounts
        .map((accountMap) => new HNAccount.fromMap(accountMap))
        .forEach((account) {
          print(account);
          // this._accounts[account.id] = account;
          // TODO: this causes the DB to get rewritten every launch
          addHNAccount(account);
        });

      if (primaryUserIdKeys.length > 0) {
        print('primary account was ${primaryUserIdKeys.first[KEYS_VALUE]}');
        setPrimaryHNAccount(primaryUserIdKeys.first[KEYS_VALUE]);

        // final primaryUser = accounts.firstWhere((account) => account[''] == this._primaryAccountId);
        // this._primaryUserPassword = primaryUser[ACCOUNTS_PASSWORD];
      }
    }).then((a) {});

    triggerOnAction(addHNAccount, (HNAccount user) async {
      _accounts[user.id] = user;

      print('Adding ${user.id} to SQLite');

      final cookieJson = JSON.encode({
        'name': user.accessCookie.name,
        'value': user.accessCookie.value,
        'expires': user.accessCookie.expires.millisecondsSinceEpoch,
        'domain': user.accessCookie.domain,
        'httpOnly': user.accessCookie.httpOnly,
        'secure': user.accessCookie.secure,
      });

      await this._accountsDb.rawInsert(
        '''
        INSERT OR REPLACE INTO $ACCOUNTS_TABLE ($ACCOUNTS_ID, $ACCOUNTS_EMAIL, $ACCOUNTS_PASSWORD, $ACCOUNTS_ACCESS_COOKIE)
          VALUES (?, ?, ?, ?);
        ''',
        [user.id, user.email, user.password, cookieJson]
      );

      print('Added ${user.id} to SQLite');
    });

    triggerOnAction(removeHNAccount, (String userId) async {
      _accounts.remove(userId);

      print('Removing $userId from SQLite');

      await this._accountsDb.delete(
        ACCOUNTS_TABLE,
        where: '$ACCOUNTS_ID = ?',
        whereArgs: [userId],
      );

      print('Removed $userId from SQLite');

      if (this._accounts.length == 0) {
        await this._keysDb.delete(
          KEYS_TABLE,
          where: '$KEYS_ID = ?',
          whereArgs: [KEY_PRIMARY_ACCOUNT_ID],
        );
      } else {
        final newPrimaryUserId = this._accounts.values.first.id;
        setPrimaryHNAccount(newPrimaryUserId);
      }
    });

    triggerOnAction(setPrimaryHNAccount, (String userId) async {
      this._primaryAccountId = userId;

      this._keysDb.rawInsert(
        '''
        INSERT OR REPLACE INTO $KEYS_TABLE ($KEYS_ID, $KEYS_VALUE)
          VALUES (?, ?);
        ''',
        [KEY_PRIMARY_ACCOUNT_ID, userId],
      );
    });
  }

  String get primaryAccountId => this._primaryAccountId;
  HNAccount get primaryAccount => this._accounts[this._primaryAccountId];
  Map<String, HNAccount> get accounts => new Map.unmodifiable(this._accounts);
}

final StoreToken accountStoreToken = new StoreToken(new HNAccountStore());
