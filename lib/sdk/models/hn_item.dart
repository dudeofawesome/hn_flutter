import 'package:flutter/foundation.dart';

import 'package:hn_flutter/utils/simple_html_to_markdown.dart';
import 'package:hn_flutter/utils/dedent.dart';

class HNItem {
  /// The item's unique id.
  int id;
  /// `true` if the item is deleted.
  bool deleted;
  /// `true` if the item is dead.
  bool dead;
  /// The type of item. One of `"job"`, `"story"`, `"comment"`, `"poll"`, or `"pollopt"`.
  String type;
  /// The title of the story, poll or job.
  String title;
  /// The URL of the story.
  String url;
  /// The comment, story or poll text. HTML.
  String text;
  /// Creation date of the item, in [Unix Time](http://en.wikipedia.org/wiki/Unix_time).
  int time;
  /// The username of the item's author.
  String by;
  /// The story's score, or the votes for a pollopt.
  int score;
  /// In the case of stories or polls, the total comment count.
  int descendants;
  /// The ids of the item's comments, in ranked display order.
  List<int> kids;
  /// The comment's parent: either another comment or the relevant story.
  int parent;
  /// The pollopt's associated poll.
  dynamic poll;
  /// A list of related pollopts, in display order.
  List<dynamic> parts;

  HNItemComputed computed;

  HNItem ({
    this.id,
    this.deleted,
    this.dead,
    this.type,
    this.title,
    this.url,
    this.text,
    this.time,
    this.by,
    this.score,
    this.descendants,
    this.kids,
    this.parent,
    this.poll,
    this.parts,
    this.computed,
  }) {
    if (this.computed == null) {
      this.computed = new HNItemComputed.fromItem(this);
    }
  }

  HNItem.fromMap (Map map) {
    this.id = map['id'];
    this.deleted = map['deleted'];
    this.dead = map['dead'];
    this.type = map['type'];
    this.title = map['title'];
    this.url = map['url'];
    this.text = map['text'];
    this.time = map['time'];
    this.by = map['by'];
    this.score = map['score'];
    this.descendants = map['descendants'];
    this.kids = map['kids'];
    this.parent = map['parent'];
    this.poll = map['poll'];
    this.parts = map['parts'];

    this.computed = new HNItemComputed.fromItem(this);
  }

  String toString() => dedent('''
    HNItem:
      id: $id
      type: $type
      title: $title
      text: $text
      by: $by
      score: $score
      time: $time
      descendants: $descendants
      computed:
        markdown: ${computed.markdown}
        urlHostname: ${computed.urlHostname}
  ''');
}

class HNItemStatus {
  int id;
  bool loading;
  bool upvoted;
  bool downvoted;
  bool saved;
  bool hidden;
  bool seen;

  HNItemStatus ({
    @required this.id,
    this.loading = false,
    this.upvoted = false,
    this.downvoted = false,
    this.saved = false,
    this.hidden = false,
    this.seen = false,
  });

  HNItemStatus.fromItem (HNItem item) {
    this.id = item.id;
    this.loading = false;
    this.upvoted = false;
    this.downvoted = false;
    this.saved = false;
    this.hidden = false;
    this.seen = false;
  }

  HNItemStatus.patch ({
    @required this.id,
    this.loading,
    this.upvoted,
    this.downvoted,
    this.saved,
    this.hidden,
    this.seen,
  });
}

class HNItemComputed {
  String markdown;
  String simpleText;
  String urlHostname;
  String imageUrl;

  HNItemComputed ({
    this.markdown,
    this.simpleText,
    this.urlHostname,
    this.imageUrl,
  });

  HNItemComputed.fromItem (HNItem item) {
    if (item.url != null) {
      this.urlHostname = Uri.parse(item.url).host;
      this.imageUrl;
    }

    if (item.text != null) {
      this.markdown = SimpleMarkdownConversion.htmlToMD(item.text);
      this.simpleText = this.markdown;
    }
  }
}
