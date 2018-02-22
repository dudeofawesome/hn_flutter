import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'package:hn_flutter/sdk/models/hn_account.dart';

abstract class LocalStorageService {
  Future<Null> init ();

  Map<String, Database> get databases;
  Future<String> get primaryUserId;
  Future<List<HNAccount>> get accounts;

  Future<Null> addHNAccount (HNAccount account);
  Future<Null> removeHNAccount (String userId);
  Future<Null> setPrimaryHNAccount (String userId);
  Future<Null> unsetPrimaryHNAccount (String userId);
}
