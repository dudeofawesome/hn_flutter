import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, MethodCall;

import 'package:hn_flutter/pages/settings.dart';
import 'package:hn_flutter/pages/stories.dart';
import 'package:hn_flutter/utils/channels.dart';

class Routes {
  static const STORIES = 'stories';
  static const USERS = 'users';
  static const SETTINGS = 'settings';
}

final staticRoutes = <String, WidgetBuilder>{
  '/': (BuildContext context) => new StoriesPage(),
  '/${Routes.SETTINGS}': (BuildContext context) => new SettingsPage()
};

registerDeepLinkChannel () {
  const MethodChannel(Channels.DEEP_LINK_RECEIVED)
    ..setMethodCallHandler((call) async {
      print('RECEIVED DEEP LINK');
      print(call);

      if (call.method == "linkReceived") {
        Map<String, dynamic> passedObjs = call.arguments;
        if (passedObjs != null) {
          var path = passedObjs["path"];
          // Application.router.navigateTo(context, path);
        }
      }
    });
}
