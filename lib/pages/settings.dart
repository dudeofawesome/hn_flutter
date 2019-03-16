import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'package:hn_flutter/router.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  String _packageVersion = '';

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((info) {
      setState(() {
        this._packageVersion = info.version;
      });
    }).catchError((err) {
      setState(() {
        this._packageVersion = 'Unknown version';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text('Settings'),
          actions: <Widget>[],
        ),
        body: new ListView(
          children: <Widget>[
            new AboutListTile(
              applicationName: 'Butterfly Reader',
              applicationVersion: this._packageVersion,
            ),
            new ListTile(
              title: const Text('Version'),
              subtitle: new Text(this._packageVersion),
            ),
            new ListTile(
              title: const Text('Licenses'),
              onTap: () => Navigator.pushNamed(context, '/${Routes.LICENSES}'),
            ),
          ],
        ));
  }
}
