import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';

import 'package:hn_flutter/components/hn_editor.dart';

class SubmitStoryPage extends StatefulWidget {
  SubmitStoryPage ({
    Key key,
  }) : super(key: key);

  @override
  createState () => new _SubmitStoryPageState();
}

class _SubmitStoryPageState extends State<SubmitStoryPage> with StoreWatcherMixin<SubmitStoryPage> {
  final _hnItemService = new Injector().hnItemService;

  final _formKey = new GlobalKey<FormState>();

  TextEditingController _storyTitleController = new TextEditingController();
  TextEditingController _storyURLController = new TextEditingController();

  String _storyTextVal = '';

  _StoryTypes _storyType = _StoryTypes.URL;

  HNAccountStore _accountStore;
  String _submissionAuthToken;

  @override
  void initState () {
    super.initState();
    this._accountStore = listenToStore(accountStoreToken);
    this._getFNID();
  }

  void _getFNID () async {
    this._submissionAuthToken = null;
    this._submissionAuthToken =
      await this._hnItemService.getSubmissionAuthToken(this._accountStore.primaryAccount.accessCookie);
  }

  Future<bool> _onWillPop (BuildContext context) async {
    if (
      this._storyTitleController.text == '' &&
      ((storyType) {
        switch (storyType) {
          case _StoryTypes.TEXT: return this._storyTextVal == '';
          case _StoryTypes.URL: return this._storyURLController.text == '';
        }
      })(this._storyType)
    ) return true;

    return await showDialog(
      context: context,
      child: this._buildPopConfirmDialog(context),
    );
  }

  void _submit (BuildContext context) async {
    print(this._storyTextVal);

    try {
      final itemId = await this._hnItemService.postItem(
        this._submissionAuthToken, this._accountStore.primaryAccount.accessCookie,
        this._storyTitleController.text,
        url: this._storyURLController.text,
        text: this._storyTextVal,
      );

      Navigator.pushReplacementNamed(context, '/${Routes.STORIES}:$itemId');
    } catch (err) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(err.toString() ?? 'Unknown error'),
        duration: const Duration(seconds: 3),
      ));

      this._getFNID();
    }
  }

  @override
  Widget build (BuildContext context) {
    return new Form(
      key: this._formKey,
      onWillPop: () => this._onWillPop(context),
      child: new Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: new AppBar(
          title: const Text('Submit Story'),
          actions: <Widget>[
            new Builder(
              builder: (context) => new IconButton(
                icon: const Icon(Icons.send),
                onPressed: this._submissionAuthToken != null
                  ? () => this._submit(context)
                  : null,
              ),
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
                    new TextField(
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      maxLength: 80,
                      decoration: new InputDecoration(labelText: 'Title'),
                      controller: this._storyTitleController,
                    ),
                    const Divider(),
                    new FormField<_StoryTypes>(
                      builder: (builder) => new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _StoryTypes.values.map((val) =>
                          new SizedBox(
                            width: 130.0,
                            child: new RadioListTile<_StoryTypes>(
                              groupValue: _storyType,
                              value: val,
                              onChanged: (val) => setState(() => this._storyType = val),
                              title: new Text(
                                ((val) {
                                  switch (val) {
                                    case _StoryTypes.TEXT: return 'Text';
                                    case _StoryTypes.URL: return 'URL';
                                  }
                                })(val),
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              ((storyType) {
                switch (this._storyType) {
                  case _StoryTypes.TEXT:
                    return new FormField<String>(
                      builder: (builder) => new Expanded(
                        child: new HackerNewsEditor(
                          initialValue: this._storyTextVal,
                          onChanged: (val) => setState(() => this._storyTextVal = val),
                        ),
                      ),
                    );
                  case _StoryTypes.URL:
                    return new Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      child: new TextField(
                        keyboardType: TextInputType.url,
                        decoration: new InputDecoration(labelText: 'URL'),
                        controller: this._storyURLController,
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

enum _StoryTypes {
  URL,
  TEXT,
}
