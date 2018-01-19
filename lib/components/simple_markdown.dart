import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_web_browser/flutter_web_browser.dart' show FlutterWebBrowser;
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownBody, MarkdownStyleSheet;

class SimpleMarkdown extends StatelessWidget {
  final String data;

  SimpleMarkdown (
    this.data,
    {
      Key key,
    }
  ) : super(key: key);

  _openLink (BuildContext ctx, String url) async {
    if (await UrlLauncher.canLaunch(url)) {
      await FlutterWebBrowser.openWebPage(url: url, androidToolbarColor: Theme.of(ctx).primaryColor);
    }
  }

  @override
  Widget build (BuildContext context) {
    final theme = Theme.of(context);
    final styleSheet = new MarkdownStyleSheet.fromTheme(theme).copyWith(
      blockquoteDecoration: new BoxDecoration(
        color: Colors.grey.withOpacity(0.5),
        borderRadius: new BorderRadius.circular(3.0),
      ),
    );

    return new MarkdownBody(
      data: this.data,
      styleSheet: styleSheet,
      onTapLink: (url) {
        this._openLink(context, url);
      },
    );
  }
}
