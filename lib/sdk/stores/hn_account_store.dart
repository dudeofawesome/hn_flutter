import 'dart:async';

import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/sdk/actions/hn_account_actions.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';
import 'package:hn_flutter/sdk/services/local_storage_service.dart';

class HNAccountStore extends Store {
  static final HNAccountStore _singleton = new HNAccountStore._internal();

  final LocalStorageService _localStorage = new Injector().localStorageService;

  String _primaryAccountId;
  final Map<String, HNAccount> _accounts = new Map();

  HNAccountStore._internal () {
    new Future(() async {
      final primaryUserId = await this._localStorage.primaryUserId;

      (await this._localStorage.accounts)
        .forEach((account) {
          print(account);
          // TODO: this causes the DB to get rewritten every launch
          addHNAccount(account);
        });

      if (primaryUserId != null) {
        print('primary account was $primaryUserId');
        setPrimaryHNAccount(primaryUserId);
      }
    }).then((a) {});

    triggerOnAction(addHNAccount, (HNAccount user) async {
      _accounts[user.id] = user;
      await this._localStorage.addHNAccount(user);
    });

    triggerOnAction(removeHNAccount, (String userId) async {
      _accounts.remove(userId);
      await this._localStorage.removeHNAccount(userId);

      if (this._accounts.length == 0) {
        await this._localStorage.unsetPrimaryHNAccount(userId);
        this._primaryAccountId = null;
      } else {
        final newPrimaryUserId = this._accounts.values.first.id;
        setPrimaryHNAccount(newPrimaryUserId);
      }
    });

    triggerOnAction(setPrimaryHNAccount, (String userId) async {
      this._primaryAccountId = userId;
      await this._localStorage.setPrimaryHNAccount(userId);
    });
  }

  factory HNAccountStore () {
    return _singleton;
  }

  String get primaryAccountId => this._primaryAccountId;
  HNAccount get primaryAccount => this._accounts[this._primaryAccountId];
  Map<String, HNAccount> get accounts => new Map.unmodifiable(this._accounts);
}

final StoreToken accountStoreToken = new StoreToken(new HNAccountStore());
