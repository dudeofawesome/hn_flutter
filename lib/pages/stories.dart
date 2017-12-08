import 'package:flutter/material.dart';

import 'package:hn_flutter/components/story_card.dart' show StoryCard;
import 'package:hn_flutter/sdk/hn_story_service.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

import 'package:hn_flutter/router.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _StoriesPageState createState() => new _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  HNStoryService _hnStoryService = new HNStoryService();

  List<HNItem> _stories = new List();

  _StoriesPageState () {
    this._hnStoryService.getTopStories().then((stories) {
      print(stories);
      setState(() {
        this._stories = stories;
      });
    });
  }

  void _changeSortMode (SortModes sortModes) {
  }

  _openStoryDialog (BuildContext ctx) async {
    String storyId;

    storyId = await showDialog(
      context: ctx,
      child: new SimpleDialog(
        title: const Text('Enter story ID'),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        children: <Widget>[
          new TextField(
            autofocus: true,
            decoration: new InputDecoration(
              labelText: 'Story ID',
            ),
            onChanged: (String val) => storyId = val,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('CANCEL'),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.pop(ctx, storyId);
                },
                child: const Text('GO'),
              ),
            ],
          ),
        ],
      )
    );

    if (storyId != null) {
      print(storyId);
      Navigator.pushNamed(ctx, '/${Routes.STORIES}:$storyId');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final storyCards = new ListView(
      children: this._stories.map<Widget>((story) => new StoryCard(
        story: story,
      )).toList()..addAll([
        // Bottom padding for FAB and home gesture bar
        const SizedBox(
          height: 56.0 + 24.0,
        ),
      ]),
    );
    // children: <Widget>[
    //   new StoryCard(
    //     story: new HNItem(
    //       by: 'monsieurpng',
    //       descendants: 75,
    //       id: 8863,
    //       kids: [
    //         8952,
    //         9224,
    //         8917,
    //         8884,
    //         8887,
    //         8943,
    //         8869,
    //         8958,
    //         9005,
    //         9671,
    //         9067,
    //         8940,
    //         8908,
    //         9055,
    //         8865,
    //         8881,
    //         8872,
    //         8873,
    //         8955,
    //         10403,
    //         8903,
    //         8928,
    //         9125,
    //         8998,
    //         8901,
    //         8902,
    //         8907,
    //         8894,
    //         8878,
    //         8980,
    //         8870,
    //         8934,
    //         8876,
    //       ],
    //       score: 91,
    //       time: 1175714200,
    //       title: 'Why Amazon, Facebook and Google can all be beaten',
    //       type: 'story',
    //       url: 'https://medium.com/lightspeed-venture-partners/why-amazon-facebook-and-google-can-all-be-beaten-f2b3ee48feaf',
    //     ),
    //   ),
    //   new StoryCard(
    //     story: new HNItem(
    //       by: 'tel',
    //       descendants: 16,
    //       id: 121003,
    //       kids: [
    //         21016,
    //         121109,
    //         121168,
    //       ],
    //       score: 25,
    //       time: 1203647620,
    //       title: 'Ask HN: The Arc Effect',
    //       type: 'story',
    //       text: "<i>or</i> HN: the Next Iteration<p>I get the impression that with Arc being released a lot of people who never had "
    //         "time for HN before are suddenly dropping in more often. (PG: what are the numbers on this? I'm envisioning a spike.)<p>"
    //         "Not to say that isn't great, but I'm wary of Diggification. Between links comparing programming to sex and a flurry of "
    //         "gratuitous, ostentatious  adjectives in the headlines it's a bit concerning.<p>80% of the stuff that makes the front "
    //         "page is still pretty awesome, but what's in place to keep the signal/noise ratio high? Does the HN model still work as "
    //         "the community scales? What's in store for (++ HN)?",
    //     ),
    //   ),
    //   // Bottom padding for FAB and home gesture bar
    //   const SizedBox(
    //     height: 56.0 + 24.0,
    //   ),
    // ],

    final loadingStories = const Center(
      child: const CircularProgressIndicator(value: null),
    );

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Hacker News'),
        actions: <Widget>[
          // const IconButton(
          //   icon: const Icon(Icons.sort),
          //   tooltip: 'Sort',
          // ),


          new PopupMenuButton<SortModes>(
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext ctx) => <PopupMenuEntry<SortModes>>[
              const PopupMenuItem<SortModes>(
                value: SortModes.TOP,
                child: const Text('Top'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.NEW,
                child: const Text('New'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.BEST,
                child: const Text('Best'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.ASK_HN,
                child: const Text('Ask HN'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.SHOW_HN,
                child: const Text('Show HN'),
              ),
              const PopupMenuItem<SortModes>(
                value: SortModes.JOB,
                child: const Text('Jobs'),
              ),
            ],
            onSelected: (SortModes selection) => this._changeSortMode(selection),
          ),



        ],
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountEmail: const Text('louis@orleans.io'),
              accountName: const Text('Louis Orleans'),
            ),
            new MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: const Text('Open Story'),
                    onTap: () => this._openStoryDialog(context),
                  ),
                  const Divider(),
                  new ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: this._stories?.length > 0 ? storyCards : loadingStories,
      floatingActionButton: new FloatingActionButton(
        // onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

enum SortModes {
  TOP,
  NEW,
  BEST,
  ASK_HN,
  SHOW_HN,
  JOB,
}
