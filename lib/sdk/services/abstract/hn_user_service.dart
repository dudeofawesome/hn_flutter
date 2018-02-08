import 'dart:async';

import 'package:hn_flutter/sdk/models/hn_user.dart';

abstract class HNUserService {
  Future<HNUser> getUserByID (String id);
}
