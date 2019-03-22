import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/components/story_header.dart';

class StoryCard extends StoryHeader {
  StoryCard({Key key, @required storyId}) : super(key: key, storyId: storyId);

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    final borderRadius = BorderRadius.all(Radius.circular(6.0));

    final storyHeader = super.build(context, stores);

    if (storyHeader is Container) {
      return storyHeader;
    }

    return Card(
      margin: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: InkWell(
        onTap: () => super.openStory(context),
        onLongPress: () => super.showOverflowMenu(context),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: storyHeader,
        ),
      ),
    );
  }
}
