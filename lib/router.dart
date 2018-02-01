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
    router.define("/item", handler: storiesHandler);
    router.define("/item/:id", handler: storyHandler);
    router.define("/user/:id", handler: usersHandler);
    router.define("/voted", handler: storiesHandler);
    router.define("/starred", handler: storiesHandler);
    router.define("/settings", handler: storiesHandler);
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

class Routes {
  static const STORIES = 'item';
  static const USERS = 'user';
  static const STARRED = 'starred';
  static const VOTED = 'voted';
  static const SETTINGS = 'settings';
}

final staticRoutes = <String, WidgetBuilder>{
  '/': (BuildContext context) => new StoriesPage(),
  '/${Routes.SETTINGS}': (BuildContext context) => new SettingsPage()
};

Route<Null> getRoute (RouteSettings settings) {
  // Routes, by convention, are split on slashes, like filesystem paths.
  final List<String> path = settings.name.split('/');
  print('PATH UPDATED!');
  print(path);
  // We only support paths that start with a slash, so bail if
  // the first component is not empty:
  if (path[0] != '') {
    return null;
  }
  // If the path is "/stock:..." then show a stock page for the
  // specified stock symbol.
  if (path[1].startsWith('${Routes.STORIES}:')) {
    // We don't yet support subpages of a stock, so bail if there's
    // any more path components.
    if (path.length != 2) {
      return null;
    }
    // Extract the symbol part of "stock:..." and return a route
    // for that symbol.
    final int itemId = int.parse(path[1].substring(Routes.STORIES.length + 1));
    return new CupertinoPageRoute<Null>(
      settings: settings,
      builder: (BuildContext context) => new StoryPage(itemId: itemId),
    );
  } else if (path[1].startsWith('${Routes.USERS}:')) {
    if (path.length != 2) {
      return null;
    }

    final String userId = path[1].substring(Routes.USERS.length + 1);
    return new CupertinoPageRoute<Null>(
      settings: settings,
      builder: (BuildContext context) => new UserPage(userId: userId),
    );
  } else if (path[1].startsWith('${Routes.STARRED}')) {
    if (path.length != 2) {
      return null;
    }

    return new CupertinoPageRoute<Null>(
      settings: settings,
      builder: (BuildContext context) => new StarredPage(),
    );
  } else if (path[1].startsWith('${Routes.VOTED}')) {
    if (path.length != 2) {
      return null;
    }

    return new CupertinoPageRoute<Null>(
      settings: settings,
      builder: (BuildContext context) => new VotedPage(),
    );
  }
  // The other paths we support are in the routes table.
  return null;
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
