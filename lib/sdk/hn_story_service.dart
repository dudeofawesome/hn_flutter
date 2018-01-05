import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' show JSON;

import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

class HNStoryService {
  HNConfig _config = new HNConfig();

  Future<List<HNItem>> getTopStories ({
    int skip = 0,
  }) {
    return http.get('${this._config.url}/topstories.json')
      .then((res) => JSON.decode(res.body))
      .then((List<int> itemIds) => [itemIds, itemIds.sublist(skip, skip + 10)])
      .then((List<List<int>> body) => [body[0], Future.wait(body[1].map((itemId) => this.getItemByID(itemId)).toList())])
      .then((stories) {
        setStorySort(stories[0]);
      });
  }

  Future<HNItem> getItemByID (int id) {
    addHNItem(new HNItem(id: id, computed: new HNItemComputed(loading: true)));

    return http.get('${this._config.url}/item/$id.json')
      .then((res) => JSON.decode(res.body))
      .then((item) => new HNItem.fromMap(item))
      .then((item) {
        addHNItem(item);
        return item;
      });
  }
}
