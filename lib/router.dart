import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show MethodChannel;

import 'package:hn_flutter/pages/settings.dart';
import 'package:hn_flutter/pages/starred.dart';
import 'package:hn_flutter/pages/main.dart';
import 'package:hn_flutter/pages/story.dart';
import 'package:hn_flutter/pages/submit_comment.dart';
import 'package:hn_flutter/pages/submit_story.dart';
import 'package:hn_flutter/pages/user.dart';
import 'package:hn_flutter/pages/voted_stories.dart';
import 'package:hn_flutter/pages/voted_comments.dart';

import 'package:hn_flutter/utils/channels.dart';

class Routes {
  static const MAIN = 'main';
  static const STORIES = 'item';
  static const USERS = 'user';
  static const STARRED = 'starred';
  static const VOTED = 'voted';
  static const SUBMIT_STORY = 'submit_story';
  static const SUBMIT_COMMENT = 'submit_comment';
  static const SETTINGS = 'settings';
}

final staticRoutes = <String, WidgetBuilder>{
  '/': (BuildContext context) => new MainPage(MainPageSubPages.STORIES),
  '/${Routes.SETTINGS}': (BuildContext context) => new SettingsPage()
};

Route<Null> getRoute (RouteSettings settings) {
  // Routes, by convention, are split on slashes, like filesystem paths.
  final parsed = Uri.parse(settings.name);

  assert(parsed.path.startsWith('/'), 'Path must start with a /');

  switch (parsed.pathSegments[0]) {
    case Routes.MAIN:
      MainPageSubPages subPage;
      switch (parsed.pathSegments[1]) {
        case Routes.USERS:
          subPage = MainPageSubPages.PROFILE;
          break;
        case Routes.STARRED:
          subPage = MainPageSubPages.STARRED_STORIES;
          break;
        case Routes.VOTED:
          subPage = MainPageSubPages.VOTED_STORIES;
          break;
        case Routes.STORIES:
        default:
          subPage = MainPageSubPages.STORIES;
      }
      return new PageRouteBuilder<Null>(
        settings: settings,
        pageBuilder: (
          BuildContext context,
          Animation<double> animation, Animation<double> secondaryAnimation
        ) => new MainPage(subPage),
        transitionDuration: const Duration(),
        // transitionsBuilder: routeTransitionsBuilder,
      );
    case Routes.STORIES:
      if (parsed.pathSegments.length == 1) {
        return new CupertinoPageRoute<Null>(
          settings: settings,
          builder: (BuildContext context) => new MainPage(MainPageSubPages.STORIES),
        );
      } else {
        final itemId = int.parse(parsed.pathSegments[1]);
        return new CupertinoPageRoute<Null>(
          settings: settings,
          builder: (BuildContext context) => new StoryPage(itemId: itemId),
        );
      }
      break;
    case Routes.USERS:
      assert(parsed.pathSegments.length == 2, 'Path must be 2 segments');

      final userId = parsed.pathSegments[1];
      return new CupertinoPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new UserPage(userId: userId),
      );
    case Routes.STARRED:
      return new CupertinoPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new StarredPage(),
      );
    case Routes.VOTED:
      return new CupertinoPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new VotedStoriesPage(),
      );
    case Routes.SUBMIT_STORY:
      return new MaterialPageRoute<Null>(
        settings: settings,
        fullscreenDialog: true,
        builder: (BuildContext context) => new SubmitStoryPage(),
      );
    case Routes.SUBMIT_COMMENT:
      assert(parsed.queryParameters['parentId'] != null);
      assert(parsed.queryParameters['authToken'] != null);

      return new MaterialPageRoute<Null>(
        settings: settings,
        fullscreenDialog: true,
        builder: (BuildContext context) => new SubmitCommentPage(
          parentId: int.parse(parsed.queryParameters['parentId']),
          authToken: parsed.queryParameters['authToken'],
        ),
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

enum MainPageSubPages {
  STORIES,
  PROFILE,
  STARRED_STORIES,
  STARRED_COMMENTS,
  VOTED_STORIES,
  VOTED_COMMENTS,
}
