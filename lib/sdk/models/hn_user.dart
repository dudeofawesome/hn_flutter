import 'package:hn_flutter/utils/simple_html_to_markdown.dart';

class HNUser {
  /// The user's unique username. Case-sensitive. Required.
  String id;

  /// Delay in minutes between a comment's creation and its visibility to other users.
  int delay;

  /// Creation date of the user, in seconds since the epoch.
  int created;

  /// The user's karma.
  int karma;

  /// The user's optional self-description. HTML.
  String about;

  /// List of the user's stories, polls and comments.
  List<int> submitted;

  HNUserComputed computed;

  HNUser({
    this.id,
    this.delay,
    this.created,
    this.karma,
    this.about,
    this.submitted,
    this.computed,
  }) {
    if (this.computed == null) {
      this.computed = new HNUserComputed();
    }
  }

  HNUser.fromMap(Map map) {
    this.id = map['id'];
    this.delay = map['delay'];
    this.created = map['created'];
    this.karma = map['karma'];
    this.about = map['about'];
    this.submitted = (map['submitted'] as List)?.cast<int>();

    this.computed = new HNUserComputed.fromUser(this);
  }
}

class HNUserComputed {
  bool loading;
  String aboutMarkdown;
  String imageUrl;

  HNUserComputed({
    this.loading = false,
    this.imageUrl =
        'https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg?sz=1000',
    this.aboutMarkdown = '',
  });

  HNUserComputed.fromUser(HNUser user) {
    this.imageUrl =
        'https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg?sz=1000';

    if (user.about != null) {
      this.aboutMarkdown = SimpleMarkdownConversion.htmlToMD(user.about);
    }

    this.loading = false;
  }
}
