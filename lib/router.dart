import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show MethodChannel, MethodCall;
import 'package:fluro/fluro.dart';

import 'package:hn_flutter/pages/settings.dart';
import 'package:hn_flutter/pages/starred.dart';
import 'package:hn_flutter/pages/stories.dart';
import 'package:hn_flutter/pages/story.dart';
import 'package:hn_flutter/pages/user.dart';
import 'package:hn_flutter/pages/voted.dart';
import 'package:hn_flutter/utils/channels.dart';

class HNRouter {
  static final HNRouter _singleton = new HNRouter._internal();
  final router = new Router();

  HNRouter._internal () {
    defineRoutes(this.router);
  }

  factory HNRouter () => _singleton;

  static void defineRoutes (Router router) {
    router.define('/', handler: storiesHandler);
    router.define("/${Routes.STORIES}", handler: storiesHandler);
    router.define("/${Routes.STORIES}/:id", handler: storyHandler);
    router.define("/${Routes.USERS}/:id", handler: usersHandler);
    router.define("/${Routes.VOTED}", handler: storiesHandler);
    router.define("/${Routes.STARRED}", handler: storiesHandler);
    router.define("/${Routes.SETTINGS}", handler: storiesHandler);
  }

  static final storiesHandler = new Handler(handlerFunc: (context, params) =>
    new StoriesPage());
  static final storyHandler = new Handler(handlerFunc: (context, params) =>
    new StoryPage(itemId: int.parse(params['id'])));
  static final usersHandler = new Handler(handlerFunc: (context, params) =>
    new UserPage(userId: params['id']));
  static final votedHandler = new Handler(handlerFunc: (context, params) =>
    new VotedPage());
  static final starredHandler = new Handler(handlerFunc: (context, params) =>
    new StarredPage());
  static final settingsHandler = new Handler(handlerFunc: (context, params) =>
    new SettingsPage());
}

enum Routes {
  STORIES,
  USERS,
  STARRED,
  VOTED,
  SETTINGS,
}

registerDeepLinkChannel (BuildContext ctx) {
  const MethodChannel(Channels.DEEP_LINK_RECEIVED)
    ..setMethodCallHandler((call) async {
      print('RECEIVED DEEP LINK');
      print(call);

      switch (call.method) {
        case 'linkReceived':
          Map<String, dynamic> passedObjs = call.arguments;
          if (passedObjs != null) {
            final route = passedObjs["route"] as String;
            // final a = await Navigator.pushNamed(ctx, route);
            final a = await Navigator.of(ctx).pushNamed(route).catchError((err) {
              print(err);
              throw err;
            });
            print('PUSHED ROUTE');
            print(a);
          }
          break;
      }
    });
}
