import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hn_flutter/sdk/models/hn_user.dart';

import 'package:hn_flutter/components/story_card.dart';

class UserSubmittedTab extends StatelessWidget {
  final HNUser user;

  const UserSubmittedTab (
    this.user,
    {
      Key key,
    }
  ) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return new Scrollbar(
      child: new ListView(
        children: this.user.submitted.map((itemId) => new StoryCard(
          storyId: itemId,
        )).toList(),
      ),
    );
  }
}
