import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:hn_flutter/utils/simple_html_to_markdown.dart';
import 'package:hn_flutter/utils/dedent.dart';

part 'hn_item.g.dart';

@JsonSerializable()
class HNItem extends Object with _$HNItemSerializerMixin {
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
  @JsonKey(nullable: false)
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

  factory HNItem.fromJson(Map<String, dynamic> json) {
    final item = _$HNItemFromJson(json);
    return item
      ..computed = new HNItemComputed.fromItem(item);
  }

  @override
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

  HNItemAuthTokens authTokens;

  HNItemStatus ({
    @required this.id,
    this.loading = false,
    this.upvoted = false,
    this.downvoted = false,
    this.saved = false,
    this.hidden = false,
    this.seen = false,
    this.authTokens,
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
    this.authTokens,
  });

  @override
  String toString() => dedent('''
    HNItemStatus:
      id: $id
      loading: $loading
      upvoted: $upvoted
      downvoted: $downvoted
      saved: $saved
      hidden: $hidden
      seen: $seen
      authTokens: ${authTokens == null ? 'null' : ''}
        upvote: ${authTokens?.upvote}
        downvote: ${authTokens?.downvote}
        save: ${authTokens?.save}
        hide: ${authTokens?.hide}
        reply: ${authTokens?.reply}
  ''');
}

class HNItemAuthTokens {
  String upvote;
  String downvote;
  String save;
  String hide;
  String see;
  String reply;

  HNItemAuthTokens ({
    this.upvote,
    this.downvote,
    this.save,
    this.hide,
    this.see,
    this.reply,
  });

  HNItemAuthTokens.fromMap (Map<String, dynamic> map) {
    upvote = map['upvote'];
    downvote = map['downvote'];
    save = map['save'];
    hide = map['hide'];
    see = map['see'];
    reply = map['reply'];
  }
}

@JsonSerializable(includeIfNull: false)
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

  factory HNItemComputed.fromJson(Map<String, dynamic> json) =>
    _$HNItemComputedFromJson(json);
}
