import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

import 'package:hn_flutter/components/hn_editor.dart';
import 'package:hn_flutter/components/html_text.dart';

class SubmitCommentPage extends StatefulWidget {
  final _formKey = new GlobalKey<FormState>();
  final _storyTextKey = new GlobalKey<HackerNewsEditorState>();

  final int parentId;
  final String authToken;

  SubmitCommentPage({
    Key key,
    @required this.parentId,
    @required this.authToken,
  }) : super(key: key);

  @override
  createState() => new _SubmitCommentPageState();
}

class _SubmitCommentPageState extends State<SubmitCommentPage>
    with StoreWatcherMixin<SubmitCommentPage> {
  final _hnItemService = new Injector().hnItemService;

  final _formKey = new GlobalKey<FormState>();
  final _commentTextKey = new GlobalKey<HackerNewsEditorState>();

  HNAccountStore _accountStore;
  HNItemStore _itemStore;

  @override
  void initState() {
    super.initState();
    this._accountStore = listenToStore(accountStoreToken);
    this._itemStore = listenToStore(itemStoreToken);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (this._commentTextKey.currentState.value == '') return true;

    return await showDialog(
      context: context,
      builder: (BuildContext ctx) => this._buildPopConfirmDialog(context),
    );
  }

  void _submit(BuildContext context) async {
    print(this._commentTextKey.currentState.value);

    try {
      await this._hnItemService.replyToItemById(
            widget.parentId,
            this._commentTextKey.currentState.value,
            widget.authToken,
            this._accountStore.primaryAccount.accessCookie,
          );

      Navigator.pop(context);
    } catch (err) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(err.toString() ?? 'Unknown error'),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final parent = this._itemStore.items[widget.parentId];

    return new Form(
      key: this._formKey,
      onWillPop: () => this._onWillPop(context),
      child: new Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: new AppBar(
          title: new Text('Reply to ${parent.by}'),
          actions: <Widget>[
            new Builder(
              builder: (context) => new IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: widget.authToken != null
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
              parent.type == HNItemType.COMMENT
                  ? new Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: new Column(
                        children: <Widget>[
                          new Container(
                            padding: const EdgeInsets.only(left: 8.0),
                            decoration: new BoxDecoration(
                                border: new Border(
                                    left: new BorderSide(
                                        color: Theme.of(context).accentColor,
                                        width: 3.0))),
                            child: new Container(
                              constraints: new BoxConstraints(
                                maxHeight: 200.0,
                              ),
                              child: new ListView(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                shrinkWrap: true,
                                children: <Widget>[
                                  new Text(
                                    parent.by,
                                    style: new TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  new HTMLText(parent.text),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    )
                  : const Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                    ),
              // new TextFormField(
              //   key: this._commentTextKey,
              //   autofocus: true,
              //   keyboardType: TextInputType.text,
              //   // maxLength: 80,
              //   decoration: new InputDecoration(labelText: 'Title'),
              // ),
              new FormField<String>(
                builder: (builder) => new Expanded(
                      child: new HackerNewsEditor(
                        key: this._commentTextKey,
                        labelText: 'Comment',
                      ),
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopConfirmDialog(BuildContext context) {
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
