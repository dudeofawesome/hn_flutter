import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:timeago/timeago.dart' show timeAgo;
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownBody;

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

class StoryCard extends StatelessWidget {
  final HNItem story;

  StoryCard ({
    Key key,
    @required this.story
  }) : super(key: key);

  _openStoryUrl () async {
    if (await UrlLauncher.canLaunch(this.story.url)) {
      await UrlLauncher.launch(this.story.url, forceWebView: true);
    }
  }

  void _openStory (BuildContext ctx) {
    Navigator.pushNamed(ctx, '/${Routes.STORIES}:${this.story.id}');
  }

  void _upvoteStory () {
  }

  void _downvoteStory () {
  }

  void _saveStory () {
  }

  void _shareStory () {
  }

  void _hideStory () {
  }

  void _viewProfile (BuildContext ctx) {
    Navigator.pushNamed(ctx, '/${Routes.USERS}:${this.story.by}');
  }

  @override
  Widget build (BuildContext context) {
    final linkOverlayText = Theme.of(context).textTheme.body1.copyWith(color: Colors.white);

    final titleColumn = new GestureDetector(
      onTap: () => this._openStory(context),
      child: new Padding(
        padding: new EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              this.story.title,
              style: Theme.of(context).textTheme.title.copyWith(
                fontSize: 18.0,
              ),
            ),
            new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(this.story.by),
                new Text(' • '),
                new Text(timeAgo(new DateTime.fromMillisecondsSinceEpoch(this.story.time * 1000))),
              ],
            ),
          ],
        ),
      ),
    );

    final preview = this.story.text == null ?
      new GestureDetector(
        onTap: this._openStoryUrl,
        child: new Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            // new Image.network(
            //   this.story.computed.imageUrl,
            //   fit: BoxFit.cover,
            // ),
            new Container(
              decoration: new BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
              ),
              width: double.INFINITY,
              child: new Padding(
                padding: new EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      this.story.computed.urlHostname,
                      style: linkOverlayText,
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Text(
                      this.story.url,
                      style: linkOverlayText,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ) :
      new GestureDetector(
        onTap: () => this._openStory(context),
        child: new Padding(
          padding: new EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          child: new MarkdownBody(data: this.story.computed.markdown),
        ),
      );

    final bottomRow = new Row(
      children: <Widget>[
        new Expanded(
          child: new GestureDetector(
            onTap: () => this._openStory(context),
            child: new Padding(
              padding: new EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text('${this.story.score} points'),
                  new Text('${this.story.descendants} comments'),
                ],
              ),
            ),
          ),
        ),
        new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Upvote',
              onPressed: () => _upvoteStory(),
              color: this.story.computed.upvoted ? Colors.orange : Colors.black,
            ),
            // new IconButton(
            //   icon: const Icon(Icons.arrow_downward),
            //   tooltip: 'Downvote',
            //   onPressed: () => _downvoteStory(),
            //   color: this.story.computed.downvoted ? Colors.blue : Colors.black,
            // ),
            new IconButton(
              icon: const Icon(Icons.star),
              tooltip: 'Save',
              onPressed: () => _saveStory(),
              color: this.story.computed.saved ? Colors.amber : Colors.black,
            ),
            // new IconButton(
            //   icon: const Icon(Icons.more_vert),
            // ),
            new PopupMenuButton<OverflowMenuItems>(
              icon: const Icon(Icons.more_horiz),
              itemBuilder: (BuildContext ctx) => <PopupMenuEntry<OverflowMenuItems>>[
                const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.SHARE,
                  child: const Text('Share'),
                ),
                const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.HIDE,
                  child: const Text('Hide'),
                ),
                const PopupMenuItem<OverflowMenuItems>(
                  value: OverflowMenuItems.VIEW_PROFILE,
                  child: const Text('View Profile'),
                ),
              ],
              onSelected: (OverflowMenuItems selection) {
                switch (selection) {
                  case OverflowMenuItems.HIDE:
                    return this._hideStory();
                  case OverflowMenuItems.SHARE:
                    return this._shareStory();
                  case OverflowMenuItems.VIEW_PROFILE:
                    return this._viewProfile(context);
                }
              },
            ),
          ],
        ),
      ],
    );

    return new Card(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.story.text == null ?
          <Widget>[
            preview,
            titleColumn,
            bottomRow,
          ] :
          <Widget>[
            titleColumn,
            preview,
            bottomRow,
          ],
      ),
    );
  }
}

enum OverflowMenuItems {
  HIDE,
  SHARE,
  VIEW_PROFILE,
}
