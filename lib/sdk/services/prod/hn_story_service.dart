import 'dart:async';
import 'dart:io' show Cookie;
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

import 'package:hn_flutter/sdk/services/abstract/hn_story_service.dart';
import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

class HNStoryServiceProd implements HNStoryService {
  HNConfig _config = new HNConfig();

  Future<List<int>> _getStories (
    String sort,
    {
      int skip = 0,
      Cookie accessCookie,
    }
  ) {
    return http.get('${this._config.url}/$sort.json')
      .then((res) => (json.decode(res.body) as List).cast<int>())
      .then((itemIds) {
        setStorySort(itemIds);
        return itemIds;
      });
  }

  Future<List<int>> getTopStories ({
    int skip = 0,
    Cookie accessCookie,
  }) => this._getStories('topstories', skip: skip, accessCookie: accessCookie);

  Future<List<int>> getNewStories ({
    int skip = 0,
    Cookie accessCookie,
  }) => this._getStories('newstories', skip: skip, accessCookie: accessCookie);

  Future<List<int>> getBestStories ({
    int skip = 0,
    Cookie accessCookie,
  }) => this._getStories('beststories', skip: skip, accessCookie: accessCookie);

  Future<List<int>> getAskStories ({
    int skip = 0,
    Cookie accessCookie,
  }) => this._getStories('askstories', skip: skip, accessCookie: accessCookie);

  Future<List<int>> getShowStories ({
    int skip = 0,
    Cookie accessCookie,
  }) => this._getStories('showstories', skip: skip, accessCookie: accessCookie);

  Future<List<int>> getJobStories ({
    int skip = 0,
    Cookie accessCookie,
  }) => this._getStories('jobstories', skip: skip, accessCookie: accessCookie);
}
