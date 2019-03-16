import 'dart:convert' show json;
import 'dart:io' show Cookie;
import 'dart:ui' show Color;

import 'package:intl/intl.dart' show DateFormat;

import 'package:hn_flutter/utils/dedent.dart';

class HNAccount {
  /// The user's unique username. Case-sensitive. Required.
  String id;
  String email;
  String password;
  Cookie accessCookie;
  HNAccountPermissions permissions;
  HNAccountPreferences preferences;

  HNAccount({
    this.id,
    this.email,
    this.password,
    this.accessCookie,
    this.permissions,
    this.preferences,
  });

  HNAccount.fromMap(Map map) {
    this.id = map['id'];
    this.email = map['email'];
    this.password = map['password'];
    if (map['accessCookie'] is Cookie) {
      this.accessCookie = map['accessCookie'];
    } else if (map['accessCookie'] is String) {
      final jsonCookie = json.decode(map['accessCookie']);

      // TODO: figure out how to format the actual TZ
      final rfc2616 = new DateFormat("E, d MMM yyyy HH:mm:ss 'GMT'");
      final formattedExpiration = jsonCookie['expires'] != null
          ? rfc2616.format(
              new DateTime.fromMillisecondsSinceEpoch(jsonCookie['expires']))
          : null;

      this.accessCookie = new Cookie.fromSetCookieValue(
          '${jsonCookie['name']}=${jsonCookie['value']}'
          '${(formattedExpiration != null) ? '; Expires=' + formattedExpiration : ''}'
          '${(jsonCookie['httpOnly'] ?? false) ? '; HttpOnly' : ''}'
          '${(jsonCookie['secure'] ?? false) ? '; Secure' : ''}');
    }
    this.permissions =
        new HNAccountPermissions.fromMap(json.decode(map['permissions']));
    this.preferences =
        new HNAccountPreferences.fromMap(json.decode(map['preferences']));
  }

  @override
  String toString() {
    return dedent('''
      HNAccount:
        id: $id
        email: $email
        password: ${password[0]}***
        accessCookie.value: ${accessCookie.value}
        permissions:
      ${permissions?.toString(indent: 4)}
        preferences:
      ${preferences?.toString(indent: 4)}
    ''');
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'email': this.email,
        'password': this.password,
        'accessCookie': {
          'name': this.accessCookie?.name,
          'value': this.accessCookie?.value,
          'expires': this.accessCookie?.expires?.millisecondsSinceEpoch,
          'domain': this.accessCookie?.domain,
          'httpOnly': this.accessCookie?.httpOnly,
          'secure': this.accessCookie?.secure,
        },
        'permissions': this.permissions.toJson(),
        'preferences': this.preferences.toJson(),
      };

  Map<String, dynamic> cookieToJson() => {
        'name': this.accessCookie?.name,
        'value': this.accessCookie?.value,
        'expires': this.accessCookie?.expires?.millisecondsSinceEpoch,
        'domain': this.accessCookie?.domain,
        'httpOnly': this.accessCookie?.httpOnly,
        'secure': this.accessCookie?.secure,
      };
}

class HNAccountPermissions {
  /// Currently, you need 500 Karma to downvote
  bool canDownvote;

  /// flags act as a "super" downvote and enough flags will strongly reduce the
  /// rank of the submission, or kill it entirely. Currently, you need 30 Karma
  bool canFlag;

  /// A vouched submission/comment has its rank restored, but it can be flagged
  /// again at which point it can't be re-vouched.
  bool canVouch;

  /// you need over 200 Karma to create a poll
  bool canPoll;

  HNAccountPermissions({
    this.canDownvote = false,
    this.canFlag = false,
    this.canVouch = false,
    this.canPoll = false,
  });

  HNAccountPermissions.fromMap(Map map) {
    this.canDownvote = map['canDownvote'];
    this.canFlag = map['canFlag'];
    this.canVouch = map['canVouch'];
    this.canPoll = map['canPoll'];
  }

  @override
  String toString({
    int indent = 0,
  }) {
    return dedent('''
        canDownvote: $canDownvote
        canFlag: $canFlag
        canVouch: $canVouch
        canPoll: $canPoll
      ''').replaceAll('\n', '\n'.padLeft(indent));
  }

  Map<String, dynamic> toJson() => {
        'canDownvote': this.canDownvote,
        'canFlag': this.canFlag,
        'canVouch': this.canVouch,
        'canPoll': this.canPoll,
      };
}

class HNAccountPreferences {
  /// Enable to see all stories and comments that have been killed by software,
  /// moderators, or user flags.
  bool showDead;

  /// Help you prevent yourself from spending too much time on HN. If enabled,
  /// you'll only be allowed to visit the site for `maxVisit` minutes at a
  /// time, with gaps of `minAway` minutes in between. You can override
  /// `noProcrastinate` if you want, in which case your visit clock starts over
  /// at zero.
  bool noProcrastinate;

  /// Max visit duration. Defaults to 20 minutes
  Duration maxVisit;

  /// Minimum time spent away from site after procrastinate timeout.
  /// Defaults to 180 minutes
  Duration minAway;

  /// The color of the top bar in their profile settings.
  /// Currently requires 250 Karma. Defaults is #ff6600.
  Color topColor;

  /// Delay gives you time to edit your comments before they appear to others.
  /// Set it to the number of minutes you'd like. The maximum is 10 minutes.
  Duration delay;

  HNAccountPreferences({
    this.showDead = _defaultShowDead,
    this.noProcrastinate = _defaultNoProcrastinate,
    this.maxVisit = const Duration(minutes: _defaultMaxVisit),
    this.minAway = const Duration(minutes: _defaultMinAway),
    this.topColor = const Color(_defaultTopColor),
    this.delay = const Duration(minutes: _defaultDelay),
  });

  HNAccountPreferences.fromMap(Map map) {
    this.showDead = map['showDead'] ?? _defaultShowDead;
    this.noProcrastinate = map['noProcrastinate'] ?? _defaultNoProcrastinate;
    this.maxVisit = new Duration(minutes: map['maxVisit'] ?? _defaultMaxVisit);
    this.minAway = new Duration(minutes: map['minAway'] ?? _defaultMinAway);
    this.topColor = new Color(map['topColor'] ?? _defaultTopColor);
    this.delay = new Duration(minutes: map['delay'] ?? _defaultDelay);
  }

  @override
  String toString({
    int indent = 0,
  }) {
    return dedent('''
        showDead: $showDead
        noProcrastinate: $noProcrastinate
        maxVisit: $maxVisit
        minAway: $minAway
        topColor: $topColor
        delay: $delay
      ''').replaceAll('\n', '\n'.padLeft(indent));
  }

  Map<String, dynamic> toJson() => {
        'showDead': this.showDead,
        'noProcrastinate': this.noProcrastinate,
        'maxVisit': this.maxVisit?.inMinutes,
        'minAway': this.minAway?.inMinutes,
        'topColor': this.topColor?.value,
        'delay': this.delay?.inMinutes,
      };
}

const _defaultShowDead = false;
const _defaultNoProcrastinate = false;
const _defaultMaxVisit = 20;
const _defaultMinAway = 180;
const _defaultTopColor = 4294927872;
const _defaultDelay = 0;
