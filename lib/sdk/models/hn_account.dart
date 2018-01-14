import 'dart:convert' show JSON;
import 'dart:io' show Cookie;

import 'package:hn_flutter/utils/dedent.dart';

class HNAccount {
  /// The user's unique username. Case-sensitive. Required.
  String id;
  String email;
  String password;
  Cookie accessCookie;

  HNAccount ({
    this.id,
    this.email,
    this.password,
    this.accessCookie,
  });

  HNAccount.fromMap (Map map) {
    this.id = map['id'];
    this.email = map['email'];
    this.password = map['password'];
    if (map['accessCookie'] is Cookie) {
      this.accessCookie = map['accessCookie'];
    } else if (map['accessCookie'] is String) {
      final jsonCookie = JSON.decode(map['accessCookie']);
      this.accessCookie = new Cookie(jsonCookie['name'], jsonCookie['value']);
    }
  }

  String toString () {
    return dedent('''
      HNAccount
        id: $id
        email: $email
        password: ${password[0]}***
        accessCookie.value: ${accessCookie.value}
    ''');
  }
}
