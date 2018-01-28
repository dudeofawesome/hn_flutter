import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_web_browser/flutter_web_browser.dart' show FlutterWebBrowser;

class ImagePreview extends StatelessWidget {
  final String imageUrl;

  const ImagePreview (
    {
      Key key,
      @required this.imageUrl,
    }
  ) : super(key: key);

  _openInBrowser (BuildContext ctx) async {
    if (await UrlLauncher.canLaunch(this.imageUrl)) {
      await FlutterWebBrowser.openWebPage(url: this.imageUrl, androidToolbarColor: Theme.of(ctx).primaryColor);
    }
  }

  Future<Null> _copyUrl () async {
    await Clipboard.setData(new ClipboardData(text: this.imageUrl));
  }

  Future<Null> _shareImage () async {
    await share(this.imageUrl);
  }

  Future<Null> _download () async {}

  @override
  Widget build (BuildContext context) {
    return new Scaffold(
      // appBar: new AppBar(
      //   leading: new IconButton(
      //     icon: const Icon(Icons.close),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: new Text(this.imageUrl),
      //   elevation: 0.0,
      //   backgroundColor: Colors.transparent,
      // ),
      backgroundColor: new Color.fromRGBO(0, 0, 0, 0.8),
      body: new Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          // new Container(
          //   decoration: new BoxDecoration(
          //     color: Colors.white,
          //   ),
          // ),
          new GestureDetector(
            onTap: () => Navigator.pop(context),
            child: new SizedBox.expand(
              child: new Hero(
                tag: this.imageUrl,
                child: new Image.network(
                  this.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          new IconTheme(
            data: new IconThemeData(
              color: Colors.white,
            ),
            child: new DefaultTextStyle(
              style: new TextStyle(
                color: Colors.white,
              ),
              child: new DecoratedBox(
                decoration: new BoxDecoration(
                  color: Colors.grey[850],
                ),
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          // child: new Text(
                          //   this.imageUrl,
                          //   // softWrap: true,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                        ),
                        new IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                    new DecoratedBox(
                      decoration: new BoxDecoration(
                        color: Colors.grey[800],
                      ),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          new IconButton(
                            icon: const Icon(Icons.open_in_browser),
                            tooltip: 'Open in Browser',
                            onPressed: () => this._openInBrowser(context),
                          ),
                          new IconButton(
                            icon: const Icon(Icons.content_copy),
                            tooltip: 'Copy URL',
                            onPressed: this._copyUrl,
                          ),
                          new IconButton(
                            icon: const Icon(Icons.share),
                            tooltip: 'Share',
                            onPressed: this._shareImage,
                          ),
                          new IconButton(
                            icon: const Icon(Icons.file_download),
                            tooltip: 'Download',
                            onPressed: this._download,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<T> showOverlay<T> ({
  @required BuildContext context,
  @required String imageUrl,
}) {
  return Navigator.of(context, rootNavigator: true).push(new _OverlayRoute<T>(
    child: new ImagePreview(
      imageUrl: imageUrl,
    ),
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}

class _OverlayRoute<T> extends PopupRoute<T> {
  _OverlayRoute ({
    @required this.theme,
    this.barrierLabel,
    @required this.child,
  });

  final Widget child;
  final ThemeData theme;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black45;

  @override
  final String barrierLabel;

  @override
  Widget buildPage (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return new Builder(
      builder: (BuildContext context) {
        return theme != null ? new Theme(data: theme, child: child) : child;
      }
    );
  }

  @override
  Widget buildTransitions (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
      opacity: new CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut
      ),
      child: child
    );
  }
}
