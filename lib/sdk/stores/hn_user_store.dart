import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/actions/hn_user_actions.dart';
import 'package:hn_flutter/sdk/models/hn_user.dart';

class HNUserStore extends Store {
  HNUserStore () {
    triggerOnAction(addHNUser, (HNUser user) {
      _users[user.id] = user;
    });
  }

  final Map<String, HNUser> _users = new Map();

  Map<String, HNUser> get users => new Map.unmodifiable(this._users);
}

final StoreToken userStoreToken = new StoreToken(new HNUserStore());
