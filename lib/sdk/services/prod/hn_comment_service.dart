import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

import 'package:hn_flutter/injection/di.dart';
import 'package:hn_flutter/sdk/services/abstract/hn_comment_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/services/hn_item_service.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

class HNCommentServiceProd implements HNCommentService {
  HNConfig _config = new HNConfig();
  HNItemService _itemService = new Injector().hnItemService;

  getChildComments (HNItem item) async {
    item.kids.forEach((child) => http.get('${this._config.url}/item/$child')
      .then((res) => (json.decode(res.body) as List).cast<int>())
      .then((List<int> body) => body.sublist(0, 5))
      .then((List<int> body) => Future.wait(body.map((itemId) => this._itemService.getItemByID(itemId)).toList()))
      .then((List<HNItem> children) {
        children.forEach((child) => addHNItem(child));
      })
    );
  }
}
