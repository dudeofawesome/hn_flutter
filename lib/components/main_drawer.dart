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
  final MainPageSubPages page;
  final ScaffoldState scaffold;

  MainDrawer(
    this.page,
    this.scaffold, {
    Key key,
  }) : super(key: key);

  @override
  _MainDrawerState createState() => new _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer>
    with SingleTickerProviderStateMixin, StoreWatcherMixin<MainDrawer> {
  Animation<double> _animation;
  AnimationController _controller;

  final HNAuthService _hnAuthService = new Injector().hnAuthService;
  HNAccountStore _accountStore;

  void initState() {
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
    )..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    // controller.forward();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: new ListView(
          children: <Widget>[
            this._buildAccountHeader(context),
            this._buildAccountManager(context),
            new MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: new Column(
                children: this._buildMenuItems(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountHeader(BuildContext context) {
    return new UserAccountsDrawerHeader(
      accountEmail: (this._accountStore.primaryAccount != null &&
              this._accountStore.primaryAccount.email != null)
          ? new Text(this._accountStore.primaryAccount.email)
          : null,
      accountName:
          new Text(this._accountStore.primaryAccountId ?? 'Not logged in'),
      onDetailsPressed: this._toggleAccounts,
    );
  }

  Widget _buildAccountManager(BuildContext context) {
    return new ClipRect(
      child: new Align(
        heightFactor: _animation.value,
        child: new Container(
          // color: Colors.grey[700],
          child: new Column(
            children: this
                ._accountStore
                .accounts
                .values
                // .where((account) => account.id != this._accountStore.primaryAccountId)
                .map<Widget>((account) => new ListTile(
                      title: new Text(account.id),
                      trailing: new IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            _showRemoveAccountDialog(context, account.id),
                      ),
                      onTap: () async {
                        this._switchAccount(context, account.id);
                        this._toggleAccounts();
                      },
                    ))
                .toList()
                  ..addAll([
                    new ListTile(
                      title: new Text('Add account'),
                      trailing: new Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: const Icon(Icons.add, color: Colors.black45),
                      ),
                      onTap: () {
                        this
                            ._showAddAccountDialog(widget.scaffold.context)
                            .then((res) {
                          if (res ?? false) {
                            this._closeDrawer(context);
                          }
                        });
                      },
                    ),
                    const Divider(),
                  ]),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = <Widget>[];

    menuItems.add(new ListTile(
      leading: const Icon(Icons.dashboard),
      title: const Text('Stories'),
      selected: widget.page == MainPageSubPages.STORIES,
      onTap: () async {
        this._closeDrawer(context);
        await Navigator.pushReplacementNamed(
            context, '/${Routes.MAIN}/${Routes.STORIES}');
      },
    ));

    if (this._accountStore.primaryAccountId != null) {
      menuItems.add(new ListTile(
        leading: const Icon(Icons.account_circle),
        title: const Text('Profile'),
        selected: widget.page == MainPageSubPages.PROFILE,
        onTap: () async {
          this._closeDrawer(context);
          await Navigator.pushReplacementNamed(
              context, '/${Routes.MAIN}/${Routes.USERS}');
        },
      ));
      menuItems.add(new ExpansionTile(
        leading: const Icon(Icons.star),
        title: const Text('Favorites'),
        initiallyExpanded: widget.page == MainPageSubPages.STARRED_STORIES ||
            widget.page == MainPageSubPages.STARRED_COMMENTS,
        children: <Widget>[
          new ListTile(
            leading: new Container(),
            title: const Text('Stories'),
            selected: widget.page == MainPageSubPages.STARRED_STORIES,
            onTap: () async {
              this._closeDrawer(context);
              await Navigator.pushReplacementNamed(context,
                  '/${Routes.MAIN}/${Routes.STARRED}/${Routes.SUBPAGE_STORIES}');
            },
          ),
          new ListTile(
            leading: new Container(),
            title: const Text('Comments'),
            selected: widget.page == MainPageSubPages.STARRED_COMMENTS,
            onTap: () async {
              this._closeDrawer(context);
              await Navigator.pushReplacementNamed(context,
                  '/${Routes.MAIN}/${Routes.STARRED}/${Routes.SUBPAGE_COMMENTS}');
            },
          ),
        ],
      ));
      menuItems.add(new ExpansionTile(
        leading: new Transform.rotate(
          angle: math.pi,
          child: const Icon(Icons.arrow_drop_down_circle),
        ),
        title: const Text('Voted'),
        initiallyExpanded: widget.page == MainPageSubPages.VOTED_STORIES ||
            widget.page == MainPageSubPages.VOTED_COMMENTS,
        children: <Widget>[
          new ListTile(
            leading: new Container(),
            title: const Text('Stories'),
            selected: widget.page == MainPageSubPages.VOTED_STORIES,
            onTap: () async {
              this._closeDrawer(context);
              await Navigator.pushReplacementNamed(context,
                  '/${Routes.MAIN}/${Routes.VOTED}/${Routes.SUBPAGE_STORIES}');
            },
          ),
          new ListTile(
            leading: new Container(),
            title: const Text('Comments'),
            selected: widget.page == MainPageSubPages.VOTED_COMMENTS,
            onTap: () async {
              this._closeDrawer(context);
              await Navigator.pushReplacementNamed(context,
                  '/${Routes.MAIN}/${Routes.VOTED}/${Routes.SUBPAGE_COMMENTS}');
            },
          ),
        ],
      ));
    }

    menuItems.add(const Divider());

    menuItems.add(new ListTile(
      leading: const Icon(Icons.book),
      title: const Text('View Story'),
      onTap: () async {
        final storyId = await this._showStoryDialog(context);
        if (storyId != null) {
          print(storyId);
          await Navigator.pushNamed(context, '/${Routes.STORIES}/$storyId');
        }
        this._closeDrawer(context);
      },
    ));
    menuItems.add(new ListTile(
      leading: const Icon(Icons.account_circle),
      title: const Text('View User'),
      onTap: () async {
        final userId = await this._showUserDialog(context);
        if (userId != null) {
          print(userId);
          await Navigator.pushNamed(context, '/${Routes.USERS}/$userId');
        }
        this._closeDrawer(context);
      },
    ));

    menuItems.add(const Divider());

    menuItems.add(new ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () async {
          this._closeDrawer(context);
          this._openSettings(context);
        }));

    return menuItems;
  }

  void _closeDrawer(BuildContext ctx) {
    if (widget.scaffold.hasDrawer) {
      // DrawerControllerState drawerController = widget.scaffold.context
      //       .ancestorStateOfType(new TypeMatcher<DrawerControllerState>());
      // drawerController.close();
      Navigator.of(ctx).pop();
    }
  }

  void _toggleAccounts() {
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

  Future<int> _showStoryDialog(BuildContext context) async {
    String storyId;

    return await showDialog<int>(
        context: context,
        builder: (BuildContext ctx) => new SimpleDialog(
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
                new ButtonTheme.bar(
                  // make buttons use the appropriate styles for cards
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
                          Navigator.pop(
                              ctx, int.parse(storyId, onError: (err) => null));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }

  Future<String> _showUserDialog(BuildContext context) async {
    String userId;

    return await showDialog<String>(
        context: context,
        builder: (BuildContext ctx) => new SimpleDialog(
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
                new ButtonTheme.bar(
                  // make buttons use the appropriate styles for cards
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
            ));
  }

  Future<bool> _showAddAccountDialog(BuildContext context) async {
    String userId = '';
    String userPassword = '';

    return await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return new SimpleDialog(
            title: const Text('Login'),
            contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            children: <Widget>[
              new TextField(
                autofocus: true,
                autocorrect: false,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                ),
                onChanged: (String val) => userId = val,
              ),
              new TextField(
                autocorrect: false,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                onChanged: (String val) => userPassword = val,
              ),
              const Padding(
                padding: const EdgeInsets.only(top: 8.0),
              ),
              new ButtonTheme.bar(
                // make buttons use the appropriate styles for cards
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
          );
        });
  }

  Future<void> _showRemoveAccountDialog(BuildContext ctx, String userId) async {
    return await showDialog<void>(
      context: ctx,
      builder: (BuildContext ctx) => new SimpleDialog(
            title: new Text('Remove $userId?'),
            contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            children: <Widget>[
              new ButtonTheme.bar(
                // make buttons use the appropriate styles for cards
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

  _addAccount(BuildContext ctx, String userId, String userPassword) async {
    if (await this._hnAuthService.addAccount(userId, userPassword)) {
      setPrimaryHNAccount(userId);
      widget.scaffold.showSnackBar(new SnackBar(
        content: new Text('Logged in'),
      ));
    } else {
      widget.scaffold.showSnackBar(new SnackBar(
        content: new Text('Failed to login'),
      ));
    }
  }

  _removeAccount(BuildContext ctx, String userId) async {
    if (await this._hnAuthService.removeAccount(userId)) {
    } else {
      widget.scaffold.showSnackBar(new SnackBar(
        content: new Text('Failed to remove account'),
      ));
    }
  }

  _switchAccount(BuildContext ctx, String userId) async {
    setPrimaryHNAccount(userId);
  }

  _openSettings(BuildContext ctx) async {
    Navigator.pushNamed(ctx, '/${Routes.SETTINGS}');
  }
}
