import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class LicensesPage extends StatelessWidget {
  LicensesPage ({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Licenses'),
        actions: <Widget>[],
      ),
      body: new ListView(
        children: <Widget>[
          new ListTile(
            title: const Text('Butterfly Reader'),
          ),
          new ListTile(
            title: const Text('Licenses'),
            onTap: () => UrlLauncher.launch('https://github.com'),
          ),
        ],
      )
    );
  }
}
