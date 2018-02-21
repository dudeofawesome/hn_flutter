import 'dart:convert' show JSON;
import 'dart:io' show Cookie;

import 'package:intl/intl.dart' show DateFormat;

import 'package:hn_flutter/utils/dedent.dart';

class HNAccount {
  /// The user's unique username. Case-sensitive. Required.
  String id;
  String email;
  String password;
  Cookie accessCookie;
  bool canDownvote;

  HNAccount ({
    this.id,
    this.email,
    this.password,
    this.accessCookie,
    this.canDownvote,
  });

  HNAccount.fromMap (Map map) {
    this.id = map['id'];
    this.email = map['email'];
    this.password = map['password'];
    if (map['accessCookie'] is Cookie) {
      this.accessCookie = map['accessCookie'];
    } else if (map['accessCookie'] is String) {
      final jsonCookie = JSON.decode(map['accessCookie']);

      // TODO: figure out how to format the actual TZ
      final rfc2616 = new DateFormat("E, d MMM yyyy HH:mm:ss 'GMT'");
      final formattedExpiration = jsonCookie['expires'] != null ?
        rfc2616.format(new DateTime.fromMillisecondsSinceEpoch(jsonCookie['expires'])) :
        null;

      this.accessCookie = new Cookie.fromSetCookieValue(
        '${jsonCookie['name']}=${jsonCookie['value']}'
        '${(formattedExpiration != null) ? '; Expires=' + formattedExpiration : ''}'
        '${(jsonCookie['httpOnly'] ?? false) ? '; HttpOnly' : ''}'
        '${(jsonCookie['secure'] ?? false) ? '; Secure' : ''}'
      );
    }
    this.canDownvote = map['canDownvote'] ?? false;
  }

  String toString () {
    return dedent('''
      HNAccount
        id: $id
        email: $email
        password: ${password[0]}***
        accessCookie.value: ${accessCookie.value}
        canDownvote: $canDownvote
    ''');
  }
}
