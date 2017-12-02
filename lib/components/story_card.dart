import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'package:hn_flutter/components/simple_html.dart';
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

  _openStory (BuildContext ctx) async {
    Navigator.pushNamed(ctx, '/story:${this.story.id}');
  }

  void _incrementCounter () {
  }

  void _upvoteStory () {
  }

  void _downvoteStory () {
  }

  void _saveStory () {
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
                new Text('4 hours ago'),
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
          child: new SimpleHTML(this.story.text),
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
              color: this.story.computed.upvoted ? Colors.orange : Colors.grey,
            ),
            // new IconButton(
            //   icon: const Icon(Icons.arrow_downward),
            //   tooltip: 'Downvote',
            //   onPressed: () => _downvoteStory(),
            //   color: this.story.computed.downvoted ? Colors.blue : Colors.grey,
            // ),
            new IconButton(
              icon: const Icon(Icons.star),
              tooltip: 'Save',
              onPressed: () => _saveStory(),
              color: this.story.computed.saved ? Colors.amber : Colors.grey,
            ),
            // new IconButton(
            //   icon: const Icon(Icons.more_vert),
            // ),
            new PopupMenuButton<OverflowMenuItems>(
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
