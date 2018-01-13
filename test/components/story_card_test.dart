// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hn_flutter/components/story_card.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

void main() {
  testWidgets('[StoryCard] widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(new Builder(
      builder: (BuildContext context) {
        return new MaterialApp(
          home: new Material(
            child: new StoryCard(
              storyId: 1,
            ),
          ),
        );
      },
    ));

    // Verify that our counter starts at 0.
    // expect(find.text('Load more'), findsOneWidget);

    // Insert loading HN item with ID 1
    await addHNItem(new HNItemAction(
      new HNItem(
        id: 1,
      ),
      new HNItemStatus(
        id: 1,
        loading: true,
      )
    ));
    // Trigger a frame.
    await tester.pump();

    // Verify that our counter has incremented.
    // expect(find.byType(SimpleMarkdown), findsNothing);
    // expect(find.text('Loading…'), findsOneWidget);
    // expect(find.text('Load more'), findsNothing);

    // update HN item with ID 1
    await addHNItem(new HNItemAction(
      new HNItem(
        id: 1,
        by: 'sama',
        kids: [17, 454424],
        parent: 1,
        text: '&#34;the rising star of venture capital&#34; -unknown VC eating lunch on SHR',
        time: 1160423461,
        type: 'comment',
      ),
      new HNItemStatus(
        id: 1,
        loading: false,
      )
    ));
    // Trigger a frame.
    await tester.pump();
    await tester.pump();

    // Verify that our counter has incremented.
    // expect(find.byType(SimpleMarkdown), findsNothing);
    // expect(find.byType(Container), findsOneWidget);

    // update HN item with ID 1
    await addHNItem(new HNItemAction(
      new HNItem(
        id: 1,
        by: 'pg',
        descendants: 15,
        kids: [487171, 15, 234509, 454410, 82729],
        score: 61,
        time: 1160418111,
        title: 'Y Combinator',
        type: 'story',
        url: 'http://ycombinator.com',
      ),
      new HNItemStatus(
        id: 1,
        loading: false,
      )
    ));
    // Trigger a frame.
    await tester.pump();
    await tester.pump();

    // Verify that our counter has incremented.
    // expect(find.byType(SimpleMarkdown), findsOneWidget);
    // expect(find.text('Loading…'), findsNothing);
    // expect(find.text('Load more'), findsNothing);
  });
}
