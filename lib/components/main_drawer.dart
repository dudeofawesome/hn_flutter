import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/services/hn_auth_service.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/actions/hn_account_actions.dart';

class MainDrawer extends StatefulWidget {
  MainDrawer ({Key key}) : super(key: key);

  @override
  _MainDrawerState createState () => new _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer>
  with SingleTickerProviderStateMixin, StoreWatcherMixin<MainDrawer> {

  Animation<double> _animation;
  AnimationController _controller;

  final HNAuthService _hnAuthService = new Injector().hnAuthService;
  HNAccountStore _accountStore;

  void initState () {
    super.initState();

    this._accountStore = listenToStore(accountStoreToken);

    _controller = new AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = new CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      )
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    // controller.forward();
  }

  void dispose () {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    return new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountEmail: (this._accountStore.primaryAccount != null && this._accountStore.primaryAccount.email != null) ?
              new Text(this._accountStore.primaryAccount.email) : null,
            accountName: new Text(this._accountStore.primaryAccountId ?? 'Not logged in'),
            onDetailsPressed: this._toggleAccounts,
          ),
          new ClipRect(
            child: new Align(
              heightFactor: _animation.value,
              child: new Container(
                // color: Colors.grey[700],
                child: new Column(
                  children: this._accountStore.accounts.values
                    // .where((account) => account.id != this._accountStore.primaryAccountId)
                    .map<Widget>((account) =>
                      new ListTile(
                        title: new Text(account.id),
                        trailing: new IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _showRemoveAccountDialog(context, account.id),
                        ),
                        onTap: () async {
                          this._switchAccount(context, account.id);
                          this._toggleAccounts();
                        },
                      )).toList()
                      ..addAll([
                        new ListTile(
                          title: new Text('Add account'),
                          trailing: new Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.black45
                            ),
                          ),
                          onTap: () async {
                            if (await this._showAddAccountDialog(context) ?? false) {
                              this._closeDrawer(context);
                            }
                          },
                        ),
                        const Divider(),
                      ]),
                ),
              ),
            ),
          ),
          new MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: new Column(
              children: <Widget>[
                this._accountStore.primaryAccountId != null
                  ? new Column(
                    children: <Widget>[
                      new ListTile(
                        leading: const Icon(Icons.account_circle),
                        title: const Text('Profile'),
                        onTap: () async {
                          this._closeDrawer(context);
                          await Navigator.pushNamed(context, '/${Routes.USERS}:${_accountStore.primaryAccountId}');
                        },
                      ),
                      new ListTile(
                        leading: const Icon(Icons.star),
                        title: const Text('Favorites'),
                        onTap: () async {
                          this._closeDrawer(context);
                          await Navigator.pushNamed(context, '/${Routes.STARRED}');
                        },
                      ),
                      new ListTile(
                        leading: new Transform.rotate(
                          angle: math.PI,
                          child: const Icon(Icons.arrow_drop_down_circle),
                        ),
                        title: const Text('Voted'),
                        onTap: () async {
                          this._closeDrawer(context);
                          await Navigator.pushNamed(context, '/${Routes.VOTED}');
                        },
                      ),
                      const Divider(),
                    ],
                  )
                  : new Container(),
                new Column(
                  children: <Widget>[
                    new ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('View Story'),
                      onTap: () async {
                        final storyId = await this._showStoryDialog(context);
                        if (storyId != null) {
                          print(storyId);
                          await Navigator.pushNamed(context, '/${Routes.STORIES}:$storyId');
                        }
                        this._closeDrawer(context);
                      },
                    ),
                    new ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: const Text('View User'),
                      onTap: () async {
                        final userId = await this._showUserDialog(context);
                        if (userId != null) {
                          print(userId);
                          await Navigator.pushNamed(context, '/${Routes.USERS}:$userId');
                        }
                        this._closeDrawer(context);
                      },
                    ),
                    const Divider(),
                    new ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () async {
                        this._closeDrawer(context);
                        this._openSettings(context);
                      }
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _closeDrawer (BuildContext ctx) {
    final scaffold = Scaffold.of(ctx);
    if (scaffold.hasDrawer) {
      final DrawerControllerState drawer = ctx.ancestorStateOfType(new TypeMatcher<DrawerControllerState>());
      drawer?.close();
    }
  }

  void _toggleAccounts () {
    if (_controller.isAnimating) {
      if (_controller.velocity > 0) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    } else if (_controller.value == 0) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Future<int> _showStoryDialog (BuildContext ctx) async {
    String storyId;

    return await showDialog(
      context: ctx,
      child: new SimpleDialog(
        title: const Text('Enter story ID'),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        children: <Widget>[
          new TextField(
            autofocus: true,
            decoration: new InputDecoration(
              labelText: 'Story ID',
            ),
            keyboardType: TextInputType.number,
            onChanged: (String val) => storyId = val,
          ),
          new ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'.toUpperCase()),
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                ),
                new FlatButton(
                  child: new Text('View'.toUpperCase()),
                  onPressed: () {
                    Navigator.pop(ctx, int.parse(storyId, onError: (err) => null));
                  },
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Future<String> _showUserDialog (BuildContext ctx) async {
    String userId;

    return await showDialog(
      context: ctx,
      child: new SimpleDialog(
        title: const Text('Enter user ID'),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        children: <Widget>[
          new TextField(
            autofocus: true,
            autocorrect: false,
            keyboardType: TextInputType.text,
            decoration: new InputDecoration(
              labelText: 'User ID',
            ),
            onChanged: (String val) => userId = val,
          ),
          new Container(
            height: 8.0,
          ),
          new ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'.toUpperCase()),
                  onPressed: () => Navigator.pop(ctx),
                ),
                new FlatButton(
                  child: new Text('View'.toUpperCase()),
                  onPressed: () => Navigator.pop(ctx, userId),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  _showAddAccountDialog (BuildContext ctx) async {
    String userId = '';
    String userPassword = '';

    return await showDialog(
      context: ctx,
      child: new SimpleDialog(
        title: const Text('Login'),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        children: <Widget>[
          new TextField(
            autofocus: true,
            autocorrect: false,
            keyboardType: TextInputType.text,
            decoration: new InputDecoration(
              labelText: 'User ID',
            ),
            onChanged: (String val) => userId = val,
          ),
          new TextField(
            autocorrect: false,
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: new InputDecoration(
              labelText: 'Password',
            ),
            onChanged: (String val) => userPassword = val,
          ),
          const Padding(
            padding: const EdgeInsets.only(top: 8.0),
          ),
          new ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'.toUpperCase()),
                  onPressed: () {
                    Navigator.pop(ctx, false);
                  },
                ),
                new FlatButton(
                  child: new Text('Login'.toUpperCase()),
                  onPressed: () async {
                    print(userId);
                    await this._addAccount(ctx, userId, userPassword);
                    Navigator.pop(ctx, true);
                  },
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  _showRemoveAccountDialog (BuildContext ctx, String userId) async {
    return await showDialog(
      context: ctx,
      child: new SimpleDialog(
        title: new Text('Remove $userId?'),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        children: <Widget>[
          new ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'.toUpperCase()),
                  onPressed: () {
                    Navigator.pop(ctx, false);
                  },
                ),
                new FlatButton(
                  child: new Text('Remove'.toUpperCase()),
                  onPressed: () async {
                    await this._removeAccount(context, userId);
                    Navigator.pop(ctx, true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _addAccount (BuildContext ctx, String userId, String userPassword) async {
    if (await this._hnAuthService.addAccount(userId, userPassword)) {
      setPrimaryHNAccount(userId);
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text('Logged in'),
      ));
    } else {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text('Failed to login'),
      ));
    }
  }

  _removeAccount (BuildContext ctx, String userId) async {
    if (await this._hnAuthService.removeAccount(userId)) {
    } else {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text('Failed to remove account'),
      ));
    }
  }

  _switchAccount (BuildContext ctx, String userId) async {
    setPrimaryHNAccount(userId);
  }

  _openSettings (BuildContext ctx) async {
    Navigator.pushNamed(ctx, '/${Routes.SETTINGS}');
  }
}
