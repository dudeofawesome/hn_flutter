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
        title: new Text(this.imageUrl),
      ),
      body: new SizedBox.expand(
        child: new Hero(
          tag: this.imageUrl,
          child: new Image.network(this.imageUrl),
        ),
      ),
    );
  }
}
