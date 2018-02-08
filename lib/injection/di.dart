import 'package:hn_flutter/sdk/services/hn_user_service.dart';
import 'package:hn_flutter/sdk/services/hn_item_service.dart';
import 'package:hn_flutter/sdk/services/hn_story_service.dart';
import 'package:hn_flutter/sdk/services/hn_comment_service.dart';
import 'package:hn_flutter/sdk/services/hn_auth_service.dart';

enum Flavor {
  PROD,
  MOCK,
}

/// Simple DI
class Injector {
  static final Injector _singleton = new Injector._internal();

  static Flavor _flavor;
  Map<Flavor, Map<String, dynamic>> _instances = new Map();

  static void configure (Flavor flavor) {
    _flavor = flavor;
  }

  factory Injector () => _singleton;

  Injector._internal () {
    for (final flavor in Flavor.values) {
      this._instances[flavor] = new Map();
    }
  }

  HNUserService get hnUserService {
    if (!_instances[_flavor].containsKey('HNUserService')) {
      HNUserService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNUserServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNUserServiceMock();
          break;
      }
      _instances[_flavor]['HNUserService'] = instance;
    }
    return _instances[_flavor]['HNUserService'];
  }

  HNItemService get hnItemService {
    if (!_instances[_flavor].containsKey('HNItemService')) {
      HNItemService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNItemServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNItemServiceMock();
          break;
      }
      _instances[_flavor]['HNItemService'] = instance;
    }
    return _instances[_flavor]['HNItemService'];
  }

  HNStoryService get hnStoryService {
    if (!_instances[_flavor].containsKey('HNStoryService')) {
      HNStoryService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNStoryServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNStoryServiceMock();
          break;
      }
      _instances[_flavor]['HNStoryService'] = instance;
    }
    return _instances[_flavor]['HNStoryService'];
  }

  HNCommentService get hnCommentService {
    if (!_instances[_flavor].containsKey('HNCommentService')) {
      HNCommentService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNCommentServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNCommentServiceMock();
          break;
      }
      _instances[_flavor]['HNCommentService'] = instance;
    }
    return _instances[_flavor]['HNCommentService'];
  }

  HNAuthService get hnAuthService {
    if (!_instances[_flavor].containsKey('HNAuthService')) {
      HNAuthService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNAuthServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNAuthServiceMock();
          break;
      }
      _instances[_flavor]['HNAuthService'] = instance;
    }
    return _instances[_flavor]['HNAuthService'];
  }
}
