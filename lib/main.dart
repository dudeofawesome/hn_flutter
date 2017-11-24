import 'package:flutter/material.dart';

import 'package:hn_flutter/components/story_card.dart' show StoryCard;
import 'package:hn_flutter/sdk/hn_story_service.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      home: new MyHomePage(title: 'Hacker News'),
      // routes: <String, WidgetBuilder> {
      //   '/a': (BuildContext context) => new SomePage(),
      // },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HNStoryService _hnStoryService = new HNStoryService();

  List<HNItem> _stories = new List();

  _MyHomePageState () {
    this._hnStoryService.topStories.then((stories) {
      print(stories);
      setState(() {
        this._stories = stories;
      });
    });
  }

  Route<Null> _getRoute(RouteSettings settings) {
    // Routes, by convention, are split on slashes, like filesystem paths.
    final List<String> path = settings.name.split('/');
    // We only support paths that start with a slash, so bail if
    // the first component is not empty:
    if (path[0] != '')
      return null;
    // If the path is "/stock:..." then show a stock page for the
    // specified stock symbol.
    if (path[1].startsWith('stock:')) {
      // We don't yet support subpages of a stock, so bail if there's
      // any more path components.
      if (path.length != 2)
        return null;
      // Extract the symbol part of "stock:..." and return a route
      // for that symbol.
      final String symbol = path[1].substring(6);
      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new StockSymbolPage(symbol: symbol, stocks: stocks),
      );
    }
    // The other paths we support are in the routes table.
    return null;
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
        title: new Text(widget.title),
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
