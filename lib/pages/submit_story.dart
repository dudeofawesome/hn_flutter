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
  final _storyTextKey = new GlobalKey<HackerNewsEditorState>();

  @override
  void initState () {
    super.initState();
    // listenToStore(userStoreToken);
  }

  Future<bool> _onWillPop (BuildContext context) async {
    if (this._storyTextKey.currentState.value == '') return true;

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
    return new WillPopScope(
      onWillPop: () => this._onWillPop(context),
      child: new Scaffold(
        appBar: new AppBar(
          title: const Text('Submit Story'),
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.send),
              onPressed: this._submit,
            )
          ],
        ),
        body: new SafeArea(
          bottom: true,
          child: new Form(
            key: this._formKey,
            child: new Column(
              children: <Widget>[
                new FormField<String>(
                  builder: (builder) => new Expanded(
                    child: new HackerNewsEditor(
                      key: _storyTextKey,
                    ),
                  ),
                ),
              ],
            ),
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
