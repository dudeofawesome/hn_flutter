import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:hn_flutter/router.dart';

import 'package:hn_flutter/injection/di.dart';

Future<Null> main () async {
  Injector.configure(Flavor.PROD);

  await new Injector().localStorageService.init();

  runApp(new HNApp());
}

class HNApp extends StatefulWidget {
  @override
  HNAppState createState () => new HNAppState();
}

class HNAppState extends State<HNApp> {
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
      routes: staticRoutes,
      onGenerateRoute: getRoute,
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
