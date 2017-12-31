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
    final theme = Theme.of(context);
    final styleSheet = new MarkdownStyleSheet.fromTheme(theme).copyWith(
      blockquote: new TextStyle(
        color: Colors.white,
      ),
      blockquoteDecoration: new BoxDecoration(
        color: theme.accentColor,
        borderRadius: new BorderRadius.circular(3.0),
      ),
    );

    return new MarkdownBody(
      data: this.data,
      styleSheet: styleSheet,
      onTapLink: this._openLink,
    );
  }
}
