import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final Icon icon;
  final Text text;

  const IconText({
    Key key,
    @required this.icon,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Padding(
          padding: Directionality.of(context) == TextDirection.ltr
              ? const EdgeInsets.only(right: 5.0)
              : const EdgeInsets.only(left: 5.0),
          child: this.icon,
        ),
        this.text,
      ],
    );
  }
}
