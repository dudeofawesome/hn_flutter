import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_web_browser/flutter_web_browser.dart' show FlutterWebBrowser;
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownBody, MarkdownStyleSheet;

import 'package:hn_flutter/components/image_preview.dart';

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
      if (await this._isImage(url)) {
        print('''That's an image!!!''');
        this._showImage(ctx, url);
      } else {
        await FlutterWebBrowser.openWebPage(url: url, androidToolbarColor: Theme.of(ctx).primaryColor);
      }
    }
  }

  Future<bool> _isImage (String url) async {
    final head = await http.head(url);

    String contentType;
    if (head.headers['content-type'] != null) {
      contentType = head.headers['content-type'];
    }
    if (head.headers['Content-Type'] != null) {
      contentType = head.headers['Content-Type'];
    }

    return contentType != null && contentType.startsWith('image/');
  }

  void _showImage (BuildContext ctx, String url) {
    Navigator.push(ctx, new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new ImagePreview(imageUrl: url);
      }
    ));
  }

  @override
  Widget build (BuildContext context) {
    final theme = Theme.of(context);
    final styleSheet = new MarkdownStyleSheet.fromTheme(theme).copyWith(
      blockquoteDecoration: new BoxDecoration(
        color: Colors.grey[350],
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
