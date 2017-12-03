import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show
  debugPaintSizeEnabled,
  debugPaintBaselinesEnabled,
  debugPaintLayerBordersEnabled,
  debugPaintPointersEnabled,
  debugRepaintRainbowEnabled;

import 'package:hn_flutter/pages/stories.dart';
import 'package:hn_flutter/pages/story.dart';
import 'package:hn_flutter/pages/user.dart';

void main() => runApp(new HNApp());

class HNApp extends StatefulWidget {
  @override
  HNAppState createState () => new HNAppState();
}

class HNAppState extends State<HNApp> {
  Route<Null> _getRoute (RouteSettings settings) {
    // Routes, by convention, are split on slashes, like filesystem paths.
    final List<String> path = settings.name.split('/');
    // We only support paths that start with a slash, so bail if
    // the first component is not empty:
    if (path[0] != '') {
      return null;
    }
    // If the path is "/stock:..." then show a stock page for the
    // specified stock symbol.
    if (path[1].startsWith('stories:')) {
      // We don't yet support subpages of a stock, so bail if there's
      // any more path components.
      if (path.length != 2) {
        return null;
      }
      // Extract the symbol part of "stock:..." and return a route
      // for that symbol.
      final int itemId = int.parse(path[1].substring(6));
      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new StoryPage(itemId: itemId),
      );
    }

    if (path[1].startsWith('users:')) {
      if (path.length != 2) {
        return null;
      }

      final int userId = int.parse(path[1].substring(6));
      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new UserPage(userId: userId),
      );
    }
    // The other paths we support are in the routes table.
    return null;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // assert(() {
    //   debugPaintSizeEnabled = _configuration.debugShowSizes;
    //   debugPaintBaselinesEnabled = _configuration.debugShowBaselines;
    //   debugPaintLayerBordersEnabled = _configuration.debugShowLayers;
    //   debugPaintPointersEnabled = _configuration.debugShowPointers;
    //   debugRepaintRainbowEnabled = _configuration.debugShowRainbow;
    //   return true;
    // }());

    return new MaterialApp(
      title: 'Hacker News',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      // localizationsDelegates: <LocalizationsDelegate<dynamic>>[
      //   new _StocksLocalizationsDelegate(),
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        // const Locale('es', 'ES'),
      ],
      // debugShowMaterialGrid: _configuration.debugShowGrid,
      // showPerformanceOverlay: _configuration.showPerformanceOverlay,
      // showSemanticsDebugger: _configuration.showSemanticsDebugger,
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new StoriesPage(),
        // '/story': (BuildContext context) => new StoriesPage()
      },
      onGenerateRoute: _getRoute,
    );
  }
}
