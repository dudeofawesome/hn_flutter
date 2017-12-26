import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:timeago/timeago.dart' show timeAgo;
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownBody;

import 'package:hn_flutter/router.dart';
import 'package:hn_flutter/sdk/stores/hn_user_store.dart';
import 'package:hn_flutter/sdk/hn_comment_service.dart';
import 'package:hn_flutter/sdk/hn_user_service.dart';

import 'package:hn_flutter/components/comment.dart';

class UserPage extends StoreWatcher {
  final String userId;

  UserPage ({
    Key key,
    @required this.userId,
  }) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(userStoreToken);
  }

  void _saveStory () {
  }

  void _shareStory () {
  }

  _openStoryUrl (String url) async {
    if (await UrlLauncher.canLaunch(url)) {
      await UrlLauncher.launch(url, forceWebView: true);
    }
  }

  @override
  Widget build (BuildContext context, Map<StoreToken, Store> stores) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final HNUserStore userStore = stores[userStoreToken];
    final user = userStore?.users?.firstWhere((user) => user.id == this.userId, orElse: () {});

    if (user == null) {
      print('getting user $userId');
      final HNUserService _hnStoryService = new HNUserService();
      _hnStoryService.getUserByID(this.userId);
    }

    final aboutPreview = new Padding(
      padding: new EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: user != null ?
        user.computed.aboutMarkdown != null ?
          new MarkdownBody(data: user.computed.aboutMarkdown) :
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
    );

    final bottomRow = new Row(
      children: <Widget>[
        new Expanded(
          child: new Padding(
            padding: new EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('${user?.karma ?? 0} karma points'),
                new Text('${user?.submitted?.length ?? 0} comments'),
              ],
            ),
          ),
        ),
        new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new IconButton(
              icon: const Icon(Icons.star),
              tooltip: 'Save',
              onPressed: () => _saveStory(),
              // color: user.computed.saved ? Colors.amber : Colors.black,
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
              ],
              onSelected: (OverflowMenuItems selection) {
                switch (selection) {
                  case OverflowMenuItems.SHARE:
                    return this._shareStory();
                }
              },
            ),
          ],
        ),
      ],
    );

    final headerCard = new Container(
      width: double.INFINITY,
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          const BoxShadow(
            color: Colors.black,
            blurRadius: 5.0,
          ),
        ],
      ),
      // child: new Column(
      //   children: [
      //     new Padding(
      //       padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 8.0),
      //       child: new Column(
      //         mainAxisSize: MainAxisSize.min,
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: <Widget>[
      //           const Text('test'),
      //           new Text('ID: ${item.id}'),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          aboutPreview,
          bottomRow,
        ],
      ),
    );

    final comments = user?.submitted != null ?
      new Column(
        children: user.submitted
          .sublist(0, 15)
          .map((kid) => new Comment(
            itemId: kid,
            loadChildren: false,
          )).toList(),
      ) :
      new Container();

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(user?.id ?? this.userId),
        actions: <Widget>[],
      ),
      body: new ListView(
        children: <Widget>[
          headerCard,
          comments,
        ],
      ),
    );
  }
}

enum OverflowMenuItems {
  SHARE,
}

enum SortModes {
  TOP,
  NEW,
  BEST,
}
