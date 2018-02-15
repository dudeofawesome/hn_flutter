import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/services/hn_item_service.dart';

import 'package:hn_flutter/components/hn_editor.dart';

class SubmitStoryPage extends StatefulWidget {
  final _formKey = new GlobalKey<FormState>();
  final _storyTextKey = new GlobalKey<HackerNewsEditorState>();

  SubmitStoryPage ({
    Key key,
  }) : super(key: key);

  @override
  createState () => new _SubmitStoryPageState();
}

class _SubmitStoryPageState extends State<SubmitStoryPage> with StoreWatcherMixin<SubmitStoryPage> {
  final _formKey = new GlobalKey<FormState>();
  final _storyTitleKey = new GlobalKey<FormFieldState>();
  final _storyURLKey = new GlobalKey<FormFieldState>();
  final _storyTextKey = new GlobalKey<HackerNewsEditorState>();

  StoryTypes _storyType = StoryTypes.URL;

  @override
  void initState () {
    super.initState();
    // listenToStore(userStoreToken);
  }

  Future<bool> _onWillPop (BuildContext context) async {
    if (
      this._storyTitleKey.currentState.value == '' &&
      ((storyType) {
        switch (storyType) {
          case StoryTypes.TEXT: return this._storyTextKey.currentState.value == '';
          case StoryTypes.URL: return this._storyURLKey.currentState.value == '';
        }
      })(this._storyType)
    ) return true;

    return await showDialog(
      context: context,
      child: this._buildPopConfirmDialog(context),
    );
  }

  void _submit () async {
    print(this._storyTextKey.currentState.value);
  }

  @override
  Widget build (BuildContext context) {
    return new Form(
      key: this._formKey,
      onWillPop: () => this._onWillPop(context),
      child: new Scaffold(
        appBar: new AppBar(
          title: const Text('Submit Story'),
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.send),
              onPressed: this._submit,
            ),
          ],
        ),
        body: new SafeArea(
          bottom: true,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                child: new Column(
                  children: <Widget>[
                    new TextFormField(
                      key: this._storyTitleKey,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(labelText: 'Title'),
                    ),
                    new FormField<StoryTypes>(
                      builder: (builder) => new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: StoryTypes.values.map((val) =>
                          new SizedBox(
                            width: 130.0,
                            child: new RadioListTile<StoryTypes>(
                              groupValue: _storyType,
                              value: val,
                              onChanged: (val) => setState(() => this._storyType = val),
                              title: new Text(
                                ((val) {
                                  switch (val) {
                                    case StoryTypes.TEXT: return 'Text';
                                    case StoryTypes.URL: return 'URL';
                                  }
                                })(val),
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                    const Divider()
                  ],
                ),
              ),
              ((storyType) {
                switch (this._storyType) {
                  case StoryTypes.TEXT:
                    return new FormField<String>(
                      builder: (builder) => new Expanded(
                        child: new HackerNewsEditor(
                          key: _storyTextKey,
                        ),
                      ),
                    );
                  case StoryTypes.URL:
                    return new Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      child: new TextFormField(
                        key: this._storyURLKey,
                        keyboardType: TextInputType.url,
                        decoration: new InputDecoration(labelText: 'URL'),
                      ),
                    );
                }
              })(this._storyType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopConfirmDialog (BuildContext context) {
    return new AlertDialog(
      title: const Text('Discard submission?'),
      actions: <Widget>[
        new FlatButton(
          child: const Text('Keep'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        new FlatButton(
          child: const Text('Discard'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

enum StoryTypes {
  URL,
  TEXT,
}
