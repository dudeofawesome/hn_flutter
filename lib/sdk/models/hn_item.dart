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
    this.type,
    this.title,
    this.url,
    this.text,
    this.time,
    this.by,
    this.score,
    this.descendants,
    this.kids,
    this.computed,
  }) {
    if (this.computed == null) {
      this.computed = new HNItemComputed();
    }
  }

  HNItem.fromMap (Map map) {
    this.id = map['id'];
    this.type = map['type'];
    this.title = map['title'];
    this.url = map['url'];
    this.text = map['text'];
    this.time = map['time'];
    this.by = map['by'];
    this.score = map['score'];
    this.descendants = map['descendants'];
    this.kids = map['kids'];

    this.computed = new HNItemComputed.fromItem(this);
  }
}

class HNItemComputed {
  bool loading;
  String urlHostname;
  String imageUrl;
  bool upvoted;
  bool downvoted;
  bool saved;
  bool hidden;
  bool seen;

  HNItemComputed ({
    this.loading = false,
    this.urlHostname = 'medium.com',
    this.imageUrl = 'https://cdn-images-1.medium.com/max/1600/1*jhDkbyL5Z31Ev7imhuOCgw.jpeg',
    this.upvoted = false,
    this.downvoted = false,
    this.saved = false,
    this.hidden = false,
    this.seen = false,
  });

  HNItemComputed.fromItem (HNItem item) {
    if (item.url != null) {
      this.urlHostname = Uri.parse(item.url).host;
      this.imageUrl = 'https://cdn-images-1.medium.com/max/1600/1*jhDkbyL5Z31Ev7imhuOCgw.jpeg';
    }

    this.loading = false;
    this.upvoted = false;
    this.downvoted = false;
    this.saved = false;
    this.hidden = false;
    this.seen = false;
  }
}
