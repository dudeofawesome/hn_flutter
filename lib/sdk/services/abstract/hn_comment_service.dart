import 'dart:async';

import 'package:hn_flutter/sdk/models/hn_item.dart';

abstract class HNCommentService {
  Future<Null> getChildComments(HNItem item);
}
