import 'dart:async';
import 'dart:convert' show JSON;
import 'package:http/http.dart' as http;
import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

class HNStoryService {
  HNConfig _config = new HNConfig();

  Future<List<HNItem>> getTopStories () {
    return http.get('${this._config.url}/topstories.json')
      .then((res) => JSON.decode(res.body))
      .then((List<int> body) => body.sublist(0, 5))
      .then((List<int> body) {
        return Future.wait(body.map((itemId) => this.getItemByID(itemId)).toList());
      })
      .then((List<HNItem> items) {
        items.forEach((item) => addHNItem(item));
      });
  }

  Future<HNItem> getItemByID (int id) => http.get('${this._config.url}/item/$id.json')
    .then((res) => JSON.decode(res.body))
    .then((item) => new HNItem.fromMap(item));
}
