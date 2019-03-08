import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'package:hn_flutter/components/simple_markdown.dart';
import 'package:hn_flutter/utils/dedent.dart';

class LicensesPage extends StatefulWidget {
  LicensesPage({Key key}) : super(key: key);

  @override
  LicensePageState createState() => new LicensePageState();
}

class LicensePageState extends State<LicensesPage> {
  Map<String, String> licenses = new Map<String, String>();

  @override
  void initState() {
    super.initState();
    rootBundle
        .loadString('assets/strings/licenses.json')
        .then((input) => Map<String, String>.from(json.decode(input)))
        .then((licenses) {
      setState(() {
        this.licenses = licenses;
      });
    }).catchError((err) {
      print(err);
      throw err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keys = this.licenses.keys.toList()..sort((a, b) => a.compareTo(b));
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Licenses'),
        actions: <Widget>[],
      ),
      body: new ListView.builder(
        itemCount: this.licenses.length + 1,
        itemBuilder: (context, index) {
          if (index == 0)
            return new Text('Butterfly Reader',
                style: Theme.of(context).textTheme.headline,
                textAlign: TextAlign.center);
          final name = keys[index - 1];
          return new SimpleMarkdown('### $name\n'
              '```\n' +
              this.licenses[name] +
              '\n```');
        },
      ),
    );
  }
}
