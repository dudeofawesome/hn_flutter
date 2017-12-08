class HNItem {
  int id;
  String type;
  String title;
  String url;
  String text;
  int time;
  String by;
  int score;
  int descendants;
  List<int> kids;
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
  String urlHostname;
  String imageUrl;
  bool upvoted;
  bool downvoted;
  bool saved;
  bool hidden;
  bool seen;

  HNItemComputed ({
    this.urlHostname,
    this.imageUrl,
    this.upvoted,
    this.downvoted,
    this.saved,
    this.hidden,
    this.seen,
  }) {
    this.urlHostname = 'medium.com';
    this.imageUrl = 'https://cdn-images-1.medium.com/max/1600/1*jhDkbyL5Z31Ev7imhuOCgw.jpeg';
    this.upvoted = false;
    this.downvoted = false;
    this.saved = false;
    this.hidden = false;
    this.seen = false;
  }

  HNItemComputed.fromItem (HNItem item) {
    if (item.url != null) {
      this.urlHostname = Uri.parse(item.url).host;
      this.imageUrl = 'https://cdn-images-1.medium.com/max/1600/1*jhDkbyL5Z31Ev7imhuOCgw.jpeg';
    }

    this.upvoted = false;
    this.downvoted = false;
    this.saved = false;
    this.hidden = false;
    this.seen = false;
  }
}
