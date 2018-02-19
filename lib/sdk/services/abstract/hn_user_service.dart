import 'dart:async';
import 'dart:io' show Cookie;

import 'package:hn_flutter/sdk/models/hn_user.dart';

abstract class HNUserService {
  Future<HNUser> getUserByID (String id);
  Future<List<int>> getSavedByUserID (String id, bool stories, Cookie accessCookie);
  Future<List<int>> getVotedByUserID (String id, Cookie accessCookie);
}
