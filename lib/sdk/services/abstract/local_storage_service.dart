import 'dart:async';

import 'package:sqflite/sqflite.dart';

abstract class LocalStorageService {
  Future<Null> init ();

  Map<String, Database> get databases;
}
