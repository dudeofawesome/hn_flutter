import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/components/story_header.dart';

class StoryCard extends StoryHeader {
  StoryCard({Key key, @required storyId}) : super(key: key, storyId: storyId);

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    return new Padding(
      padding: EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 1.0),
      child: new Card(
        child: new InkWell(
          onTap: () => super.openStory(context),
          onLongPress: () => super.showOverflowMenu(context),
          child: super.build(context, stores),
        ),
      ),
    );
  }
}
