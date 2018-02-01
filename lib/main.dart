import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart' show
  debugPaintSizeEnabled,
  debugPaintBaselinesEnabled,
  debugPaintLayerBordersEnabled,
  debugPaintPointersEnabled,
  debugRepaintRainbowEnabled;

import 'package:hn_flutter/pages/settings.dart';
import 'package:hn_flutter/pages/stories.dart';
import 'package:hn_flutter/pages/story.dart';
import 'package:hn_flutter/pages/user.dart';

import 'package:hn_flutter/router.dart';

import 'package:hn_flutter/sdk/local_storage_service.dart';

Future<Null> main () async {
  await new LocalStorageService().init();

  runApp(new HNApp());
}

class HNApp extends StatefulWidget {
  @override
  HNAppState createState () => new HNAppState();
}

class HNAppState extends State<HNApp> {
  HNRouter router = new HNRouter();

  @override
  initState () {
    super.initState();

    registerDeepLinkChannel(context);
  }

  // This widget is the root of your application.
  @override
  Widget build (BuildContext context) {
    // assert(() {
    //   debugPaintSizeEnabled = _configuration.debugShowSizes;
    //   debugPaintBaselinesEnabled = _configuration.debugShowBaselines;
    //   debugPaintLayerBordersEnabled = _configuration.debugShowLayers;
    //   debugPaintPointersEnabled = _configuration.debugShowPointers;
    //   debugRepaintRainbowEnabled = _configuration.debugShowRainbow;
    //   return true;
    // }());

    return new MaterialApp(
      title: 'Butterfly Reader',
      theme: this.theme,
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
      initialRoute: null,
      onGenerateRoute: router.router.generator,
    );
  }

  ThemeData get theme {
    return new ThemeData(
      // This is the theme of your application.
      //
      // Try running your application with "flutter run". You'll see the
      // application has a blue toolbar. Then, without quitting the app, try
      // changing the primarySwatch below to Colors.green and then invoke
      // "hot reload" (press "r" in the console where you ran "flutter run",
      // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
      // counter didn't reset back to zero; the application is not restarted.
      primarySwatch: Colors.deepOrange,
      accentColor: Colors.orangeAccent,
      scaffoldBackgroundColor: Colors.grey[300],
    );
  }
}
