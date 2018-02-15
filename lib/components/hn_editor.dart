import 'package:flutter/material.dart';

class HackerNewsEditor extends StatefulWidget {
  @override
  createState () => new _HackerNewsEditorState();
}

class _HackerNewsEditorState extends State<HackerNewsEditor> {
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build (BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Column(
        children: <Widget>[
          new TabBarView(
            children: <Widget>[
              // this._buildEditor(context),
              new Text('Render'),
            ],
          ),
          new TabBar(
            tabs: <Tab>[
              new Tab(
                icon: const Icon(Icons.edit),
              ),
              new Tab(
                icon: const Icon(Icons.panorama_fish_eye),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEditor (BuildContext context) {
    return new Column(
      children: <Widget>[
        new TextField(
          controller: this._controller,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: new InputDecoration(hintText: 'Story text'),
        ),
        new SizedBox(
          height: 44.0,
          child: new ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              new IconButton(
                icon: const Icon(Icons.format_bold),
              ),
              new IconButton(
                icon: const Icon(Icons.format_italic),
              ),
              new IconButton(
                icon: const Icon(Icons.format_quote),
              ),
              new IconButton(
                icon: const Icon(Icons.format_strikethrough),
              ),
              new IconButton(
                icon: const Icon(Icons.format_underlined),
              ),
              new IconButton(
                icon: const Icon(Icons.format_list_bulleted),
              ),
              new IconButton(
                icon: const Icon(Icons.format_list_numbered),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
