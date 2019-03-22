import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links/uni_links.dart';

import 'package:hn_flutter/pages/settings.dart';
import 'package:hn_flutter/pages/licenses.dart';
import 'package:hn_flutter/pages/starred_comments.dart';
import 'package:hn_flutter/pages/starred_stories.dart';
import 'package:hn_flutter/pages/story.dart';
import 'package:hn_flutter/pages/stories.dart';
import 'package:hn_flutter/pages/submit_comment.dart';
import 'package:hn_flutter/pages/submit_story.dart';
import 'package:hn_flutter/pages/user.dart';
import 'package:hn_flutter/pages/voted_comments.dart';
import 'package:hn_flutter/pages/voted_stories.dart';

import 'package:hn_flutter/sdk/stores/ui_store.dart' as UIStore;
import 'package:hn_flutter/sdk/actions/ui_actions.dart';

class Routes {
  static const MAIN = 'main';
  static const STORIES = 'item';
  static const TOP = 'top';
  static const NEW = 'new';
  static const ASK = 'ask';
  static const SHOW = 'show';
  static const JOBS = 'jobs';
  static const USERS = 'user';
  static const STARRED = 'starred';
  static const VOTED = 'voted';
  static const SUBPAGE_STORIES = 'stories';
  static const SUBPAGE_COMMENTS = 'comments';
  static const SUBMIT_STORY = 'submit_story';
  static const SUBMIT_COMMENT = 'submit_comment';
  static const SETTINGS = 'settings';
  static const LICENSES = 'licenses';
}

final staticRoutes = <String, WidgetBuilder>{
  '/': (BuildContext context) => new StoriesPage(),
  '/stories': (BuildContext context) => new StoriesPage(),
  '/stories/top': (BuildContext context) {
    setStorySortMode(UIStore.SortModes.TOP);
    return new StoriesPage();
  },
  '/stories/new': (BuildContext context) {
    setStorySortMode(UIStore.SortModes.NEW);
    return new StoriesPage();
  },
  '/stories/ask': (BuildContext context) {
    setStorySortMode(UIStore.SortModes.ASK_HN);
    return new StoriesPage();
  },
  '/stories/show': (BuildContext context) {
    setStorySortMode(UIStore.SortModes.SHOW_HN);
    return new StoriesPage();
  },
  '/stories/jobs': (BuildContext context) {
    setStorySortMode(UIStore.SortModes.JOB);
    return new StoriesPage();
  },
  '/${Routes.SETTINGS}': (BuildContext context) => new SettingsPage(),
  '/${Routes.LICENSES}': (BuildContext context) => new LicensesPage(),
};

Route<Null> getRoute(RouteSettings settings) {
  // Routes, by convention, are split on slashes, like filesystem paths.
  final parsed = Uri.parse(settings.name);

  assert(parsed.path.startsWith('/'), 'Path must start with a /');

  switch (parsed.pathSegments[0]) {
    case Routes.MAIN:
      Widget subPage;
      switch (parsed.pathSegments[1]) {
        case Routes.USERS:
          subPage = new UserPage(userId: null, showDrawer: true);
          break;
        case Routes.STARRED:
          switch (parsed.pathSegments[2]) {
            case Routes.SUBPAGE_STORIES:
              subPage = new StarredStoriesPage(showDrawer: true);
              break;
            case Routes.SUBPAGE_COMMENTS:
            default:
              subPage = new StarredCommentsPage(showDrawer: true);
          }
          break;
        case Routes.VOTED:
          switch (parsed.pathSegments[2]) {
            case Routes.SUBPAGE_STORIES:
              subPage = new VotedStoriesPage(showDrawer: true);
              break;
            case Routes.SUBPAGE_COMMENTS:
            default:
              subPage = new VotedCommentsPage(showDrawer: true);
          }
          break;
        case Routes.STORIES:
        default:
          switch (parsed.pathSegments[2]) {
            case Routes.TOP:
              setStorySortMode(UIStore.SortModes.TOP);
              break;
            case Routes.NEW:
              setStorySortMode(UIStore.SortModes.NEW);
              break;
            case Routes.ASK:
              setStorySortMode(UIStore.SortModes.ASK_HN);
              break;
            case Routes.SHOW:
              setStorySortMode(UIStore.SortModes.SHOW_HN);
              break;
            case Routes.JOBS:
              setStorySortMode(UIStore.SortModes.JOB);
              break;
          }
          subPage = new StoriesPage(showDrawer: true);
      }
      return new PageRouteBuilder<Null>(
        settings: settings,
        pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            subPage,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return new FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      );
    case Routes.STORIES:
      if (parsed.pathSegments.length == 1) {
        return new CupertinoPageRoute<Null>(
          settings: settings,
          builder: (BuildContext context) => new StoriesPage(showDrawer: true),
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
        builder: (BuildContext context) =>
            new UserPage(userId: userId, showDrawer: false),
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

Future<StreamSubscription> initDeepLinks(
    GlobalKey<NavigatorState> navKey) async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    var initialLink = await getInitialLink();
    if (initialLink != null) {
      _setRoute(navKey.currentState, initialLink);
    }
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }

  final linkSub = getLinksStream().listen((String link) {
    print(link);
    _setRoute(navKey.currentState, link);
  }, onError: (err) {
    // Handle exception by warning the user their action did not succeed
  });

  return linkSub;
}

void _setRoute(NavigatorState navState, String link) {
  final route = _convertLink(link);
  final routeUri = Uri.parse(route);
  if (routeUri.pathSegments[0] == Routes.MAIN) {
    navState.pushReplacementNamed(route);
  } else {
    navState.pushNamed(route);
  }
}

String _convertLink(String hnLink) {
  final uri = Uri.parse(hnLink);
  switch (uri.pathSegments[0]) {
    case '':
      return '/stories';
    case 'news':
    case 'top':
      return '/${Routes.MAIN}/${Routes.STORIES}/${Routes.TOP}';
    case 'newest':
      return '/${Routes.MAIN}/${Routes.STORIES}/${Routes.NEW}';
    case 'ask':
      return '/${Routes.MAIN}/${Routes.STORIES}/${Routes.ASK}';
    case 'show':
      return '/${Routes.MAIN}/${Routes.STORIES}/${Routes.SHOW}';
    case 'jobs':
      return '/${Routes.MAIN}/${Routes.STORIES}/${Routes.JOBS}';
    case 'item':
      if (uri.queryParameters['id'] != null) {
        return "/${Routes.STORIES}/${uri.queryParameters['id']}";
      }
      return '/';
    case 'user':
      if (uri.queryParameters['id'] != null) {
        return "/${Routes.USERS}/${uri.queryParameters['id']}";
      }
      return '/';
    default:
      return '/';
  }
}

enum MainPageSubPages {
  STORIES,
  PROFILE,
  STARRED_STORIES,
  STARRED_COMMENTS,
  VOTED_STORIES,
  VOTED_COMMENTS,
}
