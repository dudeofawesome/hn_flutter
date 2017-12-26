import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/actions/hn_user_actions.dart';
import 'package:hn_flutter/sdk/models/hn_user.dart';

class HNUserStore extends Store {
  HNUserStore () {
    triggerOnAction(addHNUser, (HNUser user) {
      final HNUser found = this._users.firstWhere((el) => el.id == user.id, orElse: () {
        this._users.add(user);
      });
      if (found != null) {
        this._users[this._users.indexOf(found)] = user;
      }
    });
  }

  final List<HNUser> _users = <HNUser>[];

  List<HNUser> get users => new List.unmodifiable(this._users);
}

final StoreToken userStoreToken = new StoreToken(new HNUserStore());
