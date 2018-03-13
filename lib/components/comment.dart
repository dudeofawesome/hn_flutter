import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flux/flutter_flux.dart';
// import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' show timeAgo;

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_item_store.dart';
import 'package:hn_flutter/sdk/stores/ui_store.dart';
import 'package:hn_flutter/sdk/stores/hn_account_store.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';
import 'package:hn_flutter/sdk/actions/ui_actions.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';

import 'package:hn_flutter/components/simple_markdown.dart';

class Comment extends StatefulWidget {
  final int itemId;
  final int depth;
  final bool loadChildren;
  final String op;
  final bool indicateSelf;
  final List<BarButtons> buttons;
  final List<BarButtons> overflowButtons;

  Comment ({
    Key key,
    @required this.itemId,
    this.depth = 0,
    this.loadChildren = true,
    this.buttons = const [
      BarButtons.UPVOTE,
      BarButtons.REPLY,
      BarButtons.SAVE,
      BarButtons.VIEW_PROFILE,
    ],
    this.overflowButtons = const [
      BarButtons.SHARE,
      BarButtons.COPY_TEXT,
    ],
    this.op,
    this.indicateSelf = true,
  }) : super(key: key);

  @override
  _CommentState createState () => new _CommentState();
}

class _CommentState extends State<Comment>
  with StoreWatcherMixin<Comment>, SingleTickerProviderStateMixin<Comment> {

  final _hnItemService = new Injector().hnItemService;
  HNItemStore _itemStore;
  UIStore _selectedItemStore;
  HNAccountStore _accountStore;

  AnimationController _controller;
  Animation<double> _btnHeightAnimation;
  ColorTween _backgroundColorTween;

  @override
  void initState () {
    super.initState();

    this._itemStore = listenToStore(itemStoreToken);
    this._selectedItemStore = listenToStore(uiStoreToken);
    this._accountStore = listenToStore(accountStoreToken);

    this._controller = new AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    this._btnHeightAnimation = new CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      )..addListener(() => setState(() {
        // the state that has changed here is the animation object’s value
      }));
    this._backgroundColorTween = new ColorTween(
      begin: Colors.transparent,
      end: Colors.red,
    )..animate(this._btnHeightAnimation);
  }

  void _upvoteComment (BuildContext ctx, HNItemStatus status, HNAccount account) {
    this._hnItemService.voteItem(true, status, account)
      .catchError((err) {
        Scaffold.of(ctx).showSnackBar(new SnackBar(
          content: new Text(err.toString()),
        ));
      });
  }

  void _downvoteComment (BuildContext ctx, HNItemStatus status, HNAccount account) {
    this._hnItemService.voteItem(false, status, account)
      .catchError((err) {
        Scaffold.of(ctx).showSnackBar(new SnackBar(
          content: new Text(err.toString()),
        ));
      });
  }

  Future<Null> _saveComment (BuildContext ctx, HNItemStatus status, HNAccount account) {
    return new Future<Null>(() async {
      if (status.authTokens?.save == null) {
        status = (await _hnItemService.getStoryItemAuthById(status.id, account.accessCookie))
          .firstWhere((patch) => patch.id == status.id);

        if (status?.authTokens?.save == null) {
          throw '''Couldn't favorite item''';
        }
      }

      return this._hnItemService.faveItem(status, account);
    }).catchError((err) {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text(err.toString()),
      ));
    });
  }

  Future<Null> _shareComment (final HNItem comment, final Map<int, HNItem> items) async {
    HNItem parentStory = items[comment.parent];
    while (parentStory.type == 'comment') {
      print(parentStory.id);
      parentStory = items[parentStory.parent];
    }
    await share('https://news.ycombinator.com/item?id=${parentStory.id}#${comment.id}');
  }

  Future<Null> _reply (BuildContext ctx, HNItemStatus status, HNAccount account) async {
    Navigator.pushNamed(
      ctx,
      '/${Routes.SUBMIT_COMMENT}?parentId=${widget.itemId}&authToken=${status.authTokens.reply}'
    );
  }

  void _viewProfile (BuildContext ctx, String author) {
    Navigator.pushNamed(ctx, '/${Routes.USERS}/$author');
  }

  void _viewContext (BuildContext ctx, int parent) {
    // Navigator.pushNamed(ctx, '/${Routes.USERS}/$author');
  }

  Future<Null> _copyText (String text) async {
    await Clipboard.setData(new ClipboardData(text: text));
  }

  void _toggleButtonBar (int commentId) => selectItem(commentId);

  @override
  Widget build (BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final comment = _itemStore.items[widget.itemId];
    final commentStatus = _itemStore.itemStatuses[widget.itemId];
    final account = _accountStore.primaryAccount;

    if (_selectedItemStore.item != null && _selectedItemStore.item == comment?.id) {
      this._controller.forward();
    } else if (
      _selectedItemStore.item != comment?.id &&
      (this._controller.isAnimating || this._controller.isCompleted)
    ) {
      this._controller.reverse();
    }

    if (comment != null) {
      if (comment.type != null && comment.type != 'comment') {
        return new Container();
      }

      Widget topRow;

      final bylineStyle = new TextStyle(
        fontWeight: FontWeight.w500,
      );

      Widget byline;

      if (comment.by != null && comment.by == widget.op) {
        byline = new Container(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
            color: Colors.blue,
          ),
          child: new Text(
            comment.by,
            style: bylineStyle.copyWith(
              color: Colors.white,
            ),
          ),
        );
      } else if (
        comment.by != null && widget.indicateSelf &&
        comment.by == account.id
      ) {
        byline = new Container(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
            color: Colors.amber[600],
          ),
          child: new Text(
            comment.by,
            style: bylineStyle.copyWith(
              color: Colors.white,
            ),
          ),
        );
      } else {
        byline = new Text(
          comment.by ?? (comment.computed.markdown != null ? '…' : '[deleted]'),
          style: bylineStyle,
        );
      }

      if (!commentStatus.loading) {
        topRow = new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 2.0, 0.0),
              child: byline,
            ),
            comment.score != null ? new Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
              child: new Text(
                '${comment.score} points',
                style: new TextStyle(
                  color: (commentStatus?.upvoted ?? false) ? Colors.orange :
                    (commentStatus?.downvoted ?? false) ? Colors.blue :
                      Theme.of(context).textTheme.display1.color,
                ),
              ),
            ) : new Container(),
            new Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
              child: new Text(
                '${timeAgo(new DateTime.fromMillisecondsSinceEpoch(comment.time * 1000))}',
                style: new TextStyle(
                  color: (commentStatus?.upvoted ?? false) ? Colors.orange :
                    (commentStatus?.downvoted ?? false) ? Colors.blue :
                      Theme.of(context).textTheme.display1.color,
                ),
              ),
            ),
          ],
        );
      } else {
        topRow = new Container();
      }

      final content = new Padding(
        padding: new EdgeInsets.only(top: comment.computed.markdown == null ? 0.0 : 4.0),
        child: comment.computed.markdown != null ?
          new SimpleMarkdown(comment.computed.markdown) :
          commentStatus.loading ? const Text('Loading…') : const Text('[deleted]'),
      );

      final List<Widget> buttons = widget.buttons.map<Widget>((button) {
        switch (button) {
          case BarButtons.UPVOTE:
            return new IconButton(
              icon: const Icon(Icons.arrow_upward),
              color: (commentStatus.upvoted ?? false) ? Colors.orange : Colors.white,
              tooltip: 'Upvote',
              onPressed: commentStatus?.authTokens?.upvote != null ?
                () {
                  this._toggleButtonBar(comment.id);
                  this._upvoteComment(context, commentStatus, account);
                } :
                null,
            );
          case BarButtons.DOWNVOTE:
            return new IconButton(
              icon: const Icon(Icons.arrow_downward),
              color: (commentStatus.downvoted ?? false) ? Colors.blue : Colors.black,
              tooltip: 'Downvote',
              onPressed: commentStatus?.authTokens?.downvote != null ?
                () {
                  this._toggleButtonBar(comment.id);
                  // this._downvoteStory()
                } :
                null,
            );
          case BarButtons.REPLY:
            return new IconButton(
              icon: const Icon(Icons.reply),
              color: Colors.white,
              tooltip: 'Reply',
              onPressed: commentStatus?.authTokens?.reply != null ?
                () {
                  this._toggleButtonBar(comment.id);
                  this._reply(context, commentStatus, account);
                } :
                null,
            );
          case BarButtons.SAVE:
            return new IconButton(
              icon: const Icon(Icons.star),
              color: (commentStatus?.saved ?? false) ? Colors.amber : Colors.white,
              tooltip: 'Save',
              onPressed: account != null ?
                () {
                  this._toggleButtonBar(comment.id);
                  this._saveComment(context, commentStatus, account);
                } :
                null,
            );
          case BarButtons.VIEW_PROFILE:
            return new IconButton(
              icon: const Icon(Icons.person),
              color: Colors.white,
              tooltip: 'View Profile',
              onPressed: () {
                this._toggleButtonBar(comment.id);
                this._viewProfile(context, comment.by);
              },
            );
          case BarButtons.VIEW_CONTEXT:
            return new IconButton(
              icon: const Icon(Icons.comment),
              color: Colors.white,
              tooltip: 'View Profile',
              onPressed: () {
                this._toggleButtonBar(comment.id);
                this._viewContext(context, comment.parent);
              },
            );
          case BarButtons.COPY_TEXT:
            return new IconButton(
              icon: const Icon(Icons.content_copy),
              color: Colors.white,
              tooltip: 'Copy Text',
              onPressed: () {
                this._toggleButtonBar(comment.id);
                this._copyText(comment.computed.simpleText);
              },
            );
          case BarButtons.SHARE:
            return new IconButton(
              icon: const Icon(Icons.share),
              color: Colors.white,
              tooltip: 'Share',
              onPressed: () {
                this._toggleButtonBar(comment.id);
                this._shareComment(comment, _itemStore.items);
              },
            );
        }
      }).toList();

      if (widget.overflowButtons != null && widget.overflowButtons.length > 0) {
        buttons.add(
          new PopupMenuButton<BarButtons>(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white,
            ),
            itemBuilder: (BuildContext ctx) => widget.overflowButtons.map((button) {
              switch (button) {
                case BarButtons.UPVOTE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.UPVOTE,
                    child: const Text('Upvote'),
                  );
                case BarButtons.DOWNVOTE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.DOWNVOTE,
                    child: const Text('Downvote'),
                  );
                case BarButtons.REPLY:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.REPLY,
                    child: const Text('Reply'),
                  );
                case BarButtons.SAVE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.SAVE,
                    child: const Text('Save'),
                  );
                case BarButtons.VIEW_PROFILE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.VIEW_PROFILE,
                    child: const Text('View Profile'),
                  );
                case BarButtons.VIEW_CONTEXT:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.VIEW_CONTEXT,
                    child: const Text('View Context'),
                  );
                case BarButtons.COPY_TEXT:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.COPY_TEXT,
                    child: const Text('Copy Text'),
                  );
                case BarButtons.SHARE:
                  return const PopupMenuItem<BarButtons>(
                    value: BarButtons.SHARE,
                    child: const Text('Share'),
                  );
              }
            }).toList(),
            onSelected: (BarButtons selection) async {
              this._toggleButtonBar(comment.id);
              switch (selection) {
                case BarButtons.UPVOTE:
                  return this._upvoteComment(context, commentStatus, account);
                case BarButtons.DOWNVOTE:
                  return this._downvoteComment(context, commentStatus, account);
                case BarButtons.REPLY:
                  return this._reply(context, commentStatus, account);
                case BarButtons.SAVE:
                  return this._saveComment(context, commentStatus, account);
                case BarButtons.VIEW_PROFILE:
                  return this._viewProfile(context, comment.by);
                case BarButtons.VIEW_CONTEXT:
                  return this._viewContext(context, comment.parent);
                case BarButtons.COPY_TEXT:
                  return this._copyText(comment.computed.simpleText);
                case BarButtons.SHARE:
                  return await this._shareComment(comment, _itemStore.items);
              }
            },
          )
        );
      }

      final buttonRow = new ClipRect(
        child: new Align(
          heightFactor: this._btnHeightAnimation.value,
          child: new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: new Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: buttons,
              ),
            ),
          ),
        ),
      );

      final childComments = (
          comment.kids != null && widget.loadChildren && !(commentStatus?.hidden ?? false)
        )
        ? new Column(
          children: comment.kids.map((kid) => new Comment(
            itemId: kid,
            depth: widget.depth + 1,
            op: widget.op,
          )).toList(),
        )
        : new Container();

      Color commentColor;
      if (widget.depth > 0) {
        int index = widget.depth - 1;
        while (index >= commentColors.length) {
          index -= commentColors.length;
        }
        commentColor = commentColors[index];
      }

      this._backgroundColorTween.end = Theme.of(context).primaryColor.withOpacity(0.3);

      return new Column(
        children: <Widget>[
          new Material(
            color: Theme.of(context).cardColor,
            child: new InkWell(
              splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
              onTap: () {
                if (
                  _selectedItemStore.item != comment.id &&
                  commentStatus.authTokens?.reply == null && account?.accessCookie != null
                ) {
                  _hnItemService.getCommentItemAuthById(comment.id, account.accessCookie);
                }

                this._toggleButtonBar(comment.id);
              },
              onLongPress: () {
                SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
                showHideItem(comment.id);
              },
              child: new Padding(
                padding: new EdgeInsets.only(left: widget.depth > 0 ? (widget.depth - 1) * 4.0 : 0.0),
                child: new Container(
                  width: double.infinity,
                  decoration: new BoxDecoration(
                    border: new Border(
                      left: widget.depth > 0 ? new BorderSide(
                        width: 4.0,
                        color: commentColor,
                      ) : const BorderSide(
                        width: 0.0,
                      ),
                      bottom: const BorderSide(
                        width: 1.0,
                        color: Colors.black12,
                      ),
                    ),
                    color: this._backgroundColorTween.lerp(this._btnHeightAnimation.value),
                  ),
                  child: new Column(
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            topRow,
                            !(commentStatus?.hidden ?? false) ? content : new Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          this._btnHeightAnimation.value > 0 ? buttonRow : new Container(),
          !(commentStatus?.hidden ?? false) ?
            childComments :
            new Container(),
        ],
      );
    } else {
      _hnItemService.getItemByID(widget.itemId);

      return new Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: new Text('Loading…'),
      );
    }
  }
}

const List<Color> commentColors = const [
  Colors.red,
  Colors.blue,
  Colors.purple,
  Colors.green,
  Colors.yellow,
];

enum OverflowMenuItems {
  SHARE,
  COPY_TEXT,
}

enum SortModes {
  TOP,
  NEW,
  BEST,
  ASK_HN,
  SHOW_HN,
  JOB,
}

enum BarButtons {
  UPVOTE,
  DOWNVOTE,
  REPLY,
  SAVE,
  VIEW_PROFILE,
  VIEW_CONTEXT,
  COPY_TEXT,
  SHARE,
}
