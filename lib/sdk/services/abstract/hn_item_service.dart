import 'dart:async';
import 'dart:io' show Cookie;

import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/models/hn_account.dart';

abstract class HNItemService {
  Future<HNItem> getItemByID (int id, [Cookie accessCookie]);

  Future<List<HNItemStatus>> getStoryItemAuthById (int id, Cookie accessCookie);

  Future<List<HNItemStatus>> getCommentItemAuthById (int id, Cookie accessCookie);

  Future<Null> faveItem (HNItemStatus status, HNAccount account);

  Future<Null> voteItem (bool up, HNItemStatus status, HNAccount account);

  Future<Null> replyToItemById (
    int parentId,
    String comment,
    HNItemAuthTokens authTokens,
    Cookie accessCookie,
  );

  Future<Null> postItem (
    String authToken, Cookie accessCookie,
    String title,
    {
      String text, String url,
    }
  );
}
