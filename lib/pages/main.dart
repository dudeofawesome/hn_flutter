import 'dart:async';
import 'dart:io' show Cookie;

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/router.dart';

import 'package:hn_flutter/pages/stories.dart';
import 'package:hn_flutter/components/main_drawer.dart';

class MainPage extends StatelessWidget {
  final MainPageSubPages page;

  MainPage (
    this.page, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget pageWidget;

    switch (this.page) {
      case MainPageSubPages.STORIES:
        pageWidget = new StoriesPage();
        break;
    }

    return new Scaffold(
      drawer: new MainDrawer(this.page),
      body: pageWidget,
    );
  }
}
