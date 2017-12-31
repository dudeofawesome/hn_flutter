import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:hn_flutter/sdk/models/hn_user.dart';

import 'package:hn_flutter/components/icon_text.dart';
import 'package:hn_flutter/components/simple_markdown.dart';

class UserAboutTab extends StatelessWidget {
  final HNUser user;

  const UserAboutTab (
    this.user,
    {
      Key key,
    }
  ) : super(key: key);

  @override
  Widget build (BuildContext context) {
    final aboutCard = new Card(
      child: new Padding(
        padding: new EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: const Text(
                'About',
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
            user != null ?
              user.computed.aboutMarkdown != null ?
                new SimpleMarkdown(user.computed.aboutMarkdown) :
                new Container() :
              const Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
                child: const Center(
                  child: const SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: const CircularProgressIndicator(value: null),
                  ),
                ),
              ),
          ],
        )
      ),
    );

    final userCreated = new DateTime.fromMillisecondsSinceEpoch(user?.created * 1000);
    final String accountAge =
      '${new DateTime.now().difference(userCreated).inDays} days' ??
      '? years';
    final String accountCakeDay = new DateFormat.yMMMMd("en_US").format(userCreated);

    final summaryCard = new Card(
      child: new Padding(
        padding: new EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new IconText(
                  icon: const Icon(Icons.thumb_up),
                  text: new Text('${user?.karma ?? '?'} karma'),
                ),
                new IconText(
                  icon: const Icon(Icons.comment),
                  text: new Text('${user?.submitted?.length ?? '?'} posts'),
                ),
              ],
            ),
            new Padding(
              padding: const EdgeInsets.only(left: 16.0),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new IconText(
                  icon: const Icon(Icons.timer),
                  text: new Text('$accountAge old'),
                ),
                new IconText(
                  icon: const Icon(Icons.cake),
                  text: new Text(accountCakeDay),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return new Padding(
      padding: const EdgeInsets.all(4.0),
      child: new Column(
        children: <Widget>[
          summaryCard,
          aboutCard,
        ],
      ),
    );
  }
}
