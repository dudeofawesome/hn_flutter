import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hn_flutter/sdk/models/hn_user.dart';

import 'package:hn_flutter/components/comment.dart';

class UserCommentsTab extends StatelessWidget {
  final HNUser user;

  const UserCommentsTab (
    this.user,
    {
      Key key,
    }
  ) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return new Scrollbar(
      child: new ListView(
        children: this.user.submitted.map((itemId) => new Comment(
          itemId: itemId,
          loadChildren: false,
          buttons: <BarButtons>[
            BarButtons.VIEW_CONTEXT,
            BarButtons.SAVE,
            BarButtons.SHARE,
            BarButtons.COPY_TEXT,
          ],
          overflowButtons: <BarButtons>[],
        )).toList(),
      ),
    );
  }
}
