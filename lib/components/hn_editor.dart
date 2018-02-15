import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownBody;

class HackerNewsEditor extends StatefulWidget {
  @override
  createState () => new _HackerNewsEditorState();
}

class _HackerNewsEditorState extends State<HackerNewsEditor> {
  final TextEditingController _controller = new TextEditingController();

  void _padSelection (String padding) {
    final selection = this._controller.selection.textInside(this._controller.text);
    final modified = '$padding$selection$padding';
    this._controller.text =
      this._controller.selection.textBefore(this._controller.text) +
      modified +
      this._controller.selection.textAfter(this._controller.text);
    // this._controller.selection = this._controller.selection.copyWith(
    //   baseOffset: 0,
    // );
  }

  void _createBlock (String blockString) {
    final selection = this._controller.selection.textInside(this._controller.text);
    final modified = selection.replaceAll('\n', '\n$blockString');
    this._controller.text =
      this._controller.selection.textBefore(this._controller.text) +
      '\n$blockString$modified\n' +
      this._controller.selection.textAfter(this._controller.text);
  }

  void _insertQuote () => this._createBlock('> ');

  void _insertListBullet () => this._createBlock('- ');

  void _insertListNumber () => this._createBlock('1. ');

  void _makeSelectionBold () => this._padSelection('**');

  void _makeSelectionItalic () => this._padSelection('*');

  void _makeSelectionUnderlined () => this._padSelection('__');

  void _makeSelectionStruckThrough ()  => this._padSelection('~~');

  @override
  Widget build (BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Column(
        children: <Widget>[
          new Expanded(
            child: new TabBarView(
              children: <Widget>[
                this._buildEditor(context),
                new MarkdownBody(data: this._controller.text),
              ],
            ),
          ),
          new TabBar(
            tabs: <Tab>[
              new Tab(
                icon: const Icon(Icons.edit),
              ),
              new Tab(
                icon: const Icon(Icons.remove_red_eye),
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
        new Expanded(
          child: new TextField(
            controller: this._controller,
            autofocus: true,
            keyboardType: TextInputType.text,
            decoration: new InputDecoration(hintText: 'Story text'),
          ),
        ),
        new SizedBox(
          height: 44.0,
          child: new ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              new IconButton(
                icon: const Icon(Icons.format_bold),
                onPressed: _makeSelectionBold,
              ),
              new IconButton(
                icon: const Icon(Icons.format_italic),
                onPressed: _makeSelectionItalic,
              ),
              new IconButton(
                icon: const Icon(Icons.format_quote),
                onPressed: this._insertQuote,
              ),
              new IconButton(
                icon: const Icon(Icons.format_strikethrough),
                onPressed: this._makeSelectionStruckThrough,
              ),
              new IconButton(
                icon: const Icon(Icons.format_underlined),
                onPressed: this._makeSelectionUnderlined,
              ),
              new IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: this._insertListBullet,
              ),
              new IconButton(
                icon: const Icon(Icons.format_list_numbered),
                onPressed: this._insertListNumber,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
