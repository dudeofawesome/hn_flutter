import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownBody, MarkdownStyleSheet;

class SimpleMarkdown extends StatelessWidget {
  final String data;

  SimpleMarkdown (
    this.data,
    {
      Key key,
    }
  ) : super(key: key);

  _openLink (String url) async {
    if (await UrlLauncher.canLaunch(url)) {
      await UrlLauncher.launch(url, forceWebView: true);
    }
  }

  @override
  Widget build (BuildContext context) {
    final styleSheet = new MarkdownStyleSheet.fromTheme(Theme.of(context));

    return new MarkdownBody(
      data: this.data,
      styleSheet: styleSheet,
      onTapLink: this._openLink,
    );
  }
}
