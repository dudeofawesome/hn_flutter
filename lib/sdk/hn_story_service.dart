import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' show JSON;

import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

class HNStoryService {
  HNConfig _config = new HNConfig();

  Future<List<HNItem>> _getStories (
    String sort,
    {
      int skip = 0,
    }
  ) {
    return http.get('${this._config.url}/$sort.json')
      .then((res) => JSON.decode(res.body))
      .then((List<int> itemIds) => [itemIds, itemIds.sublist(skip, skip + 10)])
      .then((List<List<int>> body) => [body[0], Future.wait(body[1].map((itemId) => this.getItemByID(itemId)).toList())])
      .then((stories) {
        setStorySort(stories[0]);
      });
  }

  Future<List<HNItem>> getTopStories ({
    int skip = 0,
  }) => this._getStories('topstories', skip: skip);

  Future<List<HNItem>> getNewStories ({
    int skip = 0,
  }) => this._getStories('newstories', skip: skip);

  Future<List<HNItem>> getBestStories ({
    int skip = 0,
  }) => this._getStories('beststories', skip: skip);

  Future<List<HNItem>> getAskStories ({
    int skip = 0,
  }) => this._getStories('askstories', skip: skip);

  Future<List<HNItem>> getShowStories ({
    int skip = 0,
  }) => this._getStories('showstories', skip: skip);

  Future<List<HNItem>> getJobStories ({
    int skip = 0,
  }) => this._getStories('jobstories', skip: skip);

  Future<HNItem> getItemByID (int id) {
    addHNItem(new HNItemAction(new HNItem(id: id), new HNItemStatus()));

    return http.get('${this._config.url}/item/$id.json')
      .then((res) => JSON.decode(res.body))
      .then((item) => new HNItem.fromMap(item))
      .then((item) {
        addHNItem(new HNItemAction(item, new HNItemStatus()));
        return item;
      });
  }
}
