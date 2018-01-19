import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String imageUrl;

  const ImagePreview (
    {
      Key key,
      @required this.imageUrl,
    }
  ) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: new Text(this.imageUrl),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      persistentFooterButtons: <Widget>[
        new IconButton(
          icon: const Icon(Icons.ac_unit),
          color: Colors.white,
        ),
      ],
      backgroundColor: new Color.fromRGBO(0, 0, 0, 0.8),
      body: new SizedBox.expand(
        child: new Hero(
          tag: this.imageUrl,
          child: new Image.network(
            this.imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

Future<T> showOverlay<T> ({
  @required BuildContext context,
  @required String imageUrl,
  bool barrierDismissible: true,
}) {
  return Navigator.of(context, rootNavigator: true).push(new _OverlayRoute<T>(
    child: new ImagePreview(
      imageUrl: imageUrl,
    ),
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}

class _OverlayRoute<T> extends PopupRoute<T> {
  _OverlayRoute ({
    @required this.theme,
    bool barrierDismissible: true,
    this.barrierLabel,
    @required this.child,
  }) : assert(barrierDismissible != null),
       _barrierDismissible = barrierDismissible;

  final Widget child;
  final ThemeData theme;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  Color get barrierColor => Colors.black45;

  @override
  final String barrierLabel;

  @override
  Widget buildPage (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: new Builder(
        builder: (BuildContext context) {
          return theme != null ? new Theme(data: theme, child: child) : child;
        }
      ),
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
