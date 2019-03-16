import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FABBottomPadding extends StatelessWidget {
  final bool mini;

  const FABBottomPadding({
    this.mini = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: new EdgeInsets.only(top: this.mini ? 40.0 : 56.0),
    );
  }
}
