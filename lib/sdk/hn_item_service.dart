import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' show JSON;

import 'package:hn_flutter/sdk/hn_config.dart';
import 'package:hn_flutter/sdk/hn_auth_service.dart';
import 'package:hn_flutter/sdk/models/hn_item.dart';
import 'package:hn_flutter/sdk/actions/hn_item_actions.dart';

class HNItemService {
  HNConfig _config = new HNConfig();
  HNAuthService _hnAuthService = new HNAuthService();

  Future<HNItem> getItemByID (int id) {
    addHNItem(new HNItemAction(new HNItem(id: id), new HNItemStatus.patch(id: id, loading: true)));

    return http.get('${this._config.url}/item/$id.json')
      .then((res) => JSON.decode(res.body))
      .then((item) => new HNItem.fromMap(item))
      .then((item) {
        addHNItem(new HNItemAction(item, new HNItemStatus.patch(id: id, loading: false)));
        return item;
      });
  }

  Future<HNItem> faveItem (HNItemStatus item) {
    item.saved = true;
    setItemStatus(item);

    return http.post(
        '${this._config.apiHost}/fave',
        body: {
          'id': item.id,
          'acct': this._hnAuthService.primaryUserId,
          'pw': this._hnAuthService.primaryUserPassword,
        },
      )
      .then((res) => JSON.decode(res.body))
      .then((item) => new HNItem.fromMap(item))
      .then((item) {
        addHNItem(new HNItemAction(item));
      });
  }
}
