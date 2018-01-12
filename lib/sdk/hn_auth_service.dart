import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hn_flutter/sdk/sqlite_vals.dart';
import 'package:hn_flutter/sdk/hn_config.dart';

class HNAuthService {
  static final HNAuthService _singleton = new HNAuthService._internal();

  HNConfig _config = new HNConfig();

  Directory _documentsDirectory;
  Database _keysDb;
  Database _accountsDb;

  String _primaryUserId = '';
  String _primaryUserPassword = '';

  HNAuthService._internal () {
    new Future(() async {
      this._documentsDirectory = await getApplicationDocumentsDirectory();

      String keysPath = join(this._documentsDirectory.path, 'keys.db');
      this._keysDb = await openDatabase(keysPath, version: 1, onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE $KEYS_TABLE ($KEYS_ID TEXT PRIMARY KEY, $KEYS_VALUE TEXT)');
      });

      final primaryUserIdKeys = await this._keysDb.query(
        KEYS_TABLE,
        columns: [KEYS_ID, KEYS_VALUE],
        where: '$KEYS_ID = ?',
        whereArgs: [KEY_PRIMARY_ACCOUNT_ID],
        limit: 1,
      );

      if (primaryUserIdKeys.length == 0) {
        this._primaryUserId = '';
      } else {
        print(primaryUserIdKeys.first);
        print(primaryUserIdKeys.first[KEYS_VALUE]);
        // this._primaryUserId = primaryUserIdKeys.first;

        String accountsPath = join(this._documentsDirectory.path, ACCOUNTS_DB);
        this._accountsDb = await openDatabase(accountsPath, version: 1, onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE $ACCOUNTS_TABLE ($ACCOUNTS_ID TEXT PRIMARY KEY, $ACCOUNTS_PASSWORD TEXT, $ACCOUNTS_ACCESS_TOKEN TEXT)');
        });

        final accounts = await this._keysDb.query(
          ACCOUNTS_TABLE,
          columns: [ACCOUNTS_ID, ACCOUNTS_PASSWORD, ACCOUNTS_ACCESS_TOKEN],
          where: '$ACCOUNTS_ID = ?',
          whereArgs: [this._primaryUserId],
        );

        print(accounts);

        final primaryUser = accounts.firstWhere((account) => account[''] == this._primaryUserId);
        this._primaryUserPassword = primaryUser[ACCOUNTS_PASSWORD];
      }
    });
  }

  factory HNAuthService () {
    return _singleton;
  }

  get primaryUserId => this._primaryUserId;
  get primaryUserPassword => this._primaryUserPassword;

  Future<bool> addAccount (String userId, String userPassword) async {
    return http.post(
        '${this._config.apiHost}/login',
        body: {
          'acct': userId,
          'pw': userPassword,
        },
      )
      .then((res) {
        if (res.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      });
  }
}
