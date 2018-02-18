import 'package:hn_flutter/sdk/services/hn_user_service.dart';
import 'package:hn_flutter/sdk/services/hn_item_service.dart';
import 'package:hn_flutter/sdk/services/hn_story_service.dart';
import 'package:hn_flutter/sdk/services/hn_comment_service.dart';
import 'package:hn_flutter/sdk/services/hn_auth_service.dart';
import 'package:hn_flutter/sdk/services/local_storage_service.dart';

enum Flavor {
  PROD,
  MOCK,
}

/// Simple DI
class Injector {
  static final Injector _singleton = new Injector._internal();

  static Flavor _flavor;
  Map<Flavor, Map<_Injectables, dynamic>> _instances = new Map();

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
    if (!_instances[_flavor].containsKey(_Injectables.HN_USER_SERVICE)) {
      HNUserService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNUserServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNUserServiceMock();
          break;
      }
      _instances[_flavor][_Injectables.HN_USER_SERVICE] = instance;
    }
    return _instances[_flavor][_Injectables.HN_USER_SERVICE];
  }

  HNItemService get hnItemService {
    if (!_instances[_flavor].containsKey(_Injectables.HN_ITEM_SERVICE)) {
      HNItemService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNItemServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNItemServiceMock();
          break;
      }
      _instances[_flavor][_Injectables.HN_ITEM_SERVICE] = instance;
    }
    return _instances[_flavor][_Injectables.HN_ITEM_SERVICE];
  }

  HNStoryService get hnStoryService {
    if (!_instances[_flavor].containsKey(_Injectables.HN_STORY_SERVICE)) {
      HNStoryService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNStoryServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNStoryServiceMock();
          break;
      }
      _instances[_flavor][_Injectables.HN_STORY_SERVICE] = instance;
    }
    return _instances[_flavor][_Injectables.HN_STORY_SERVICE];
  }

  HNCommentService get hnCommentService {
    if (!_instances[_flavor].containsKey(_Injectables.HN_COMMENT_SERVICE)) {
      HNCommentService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNCommentServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNCommentServiceMock();
          break;
      }
      _instances[_flavor][_Injectables.HN_COMMENT_SERVICE] = instance;
    }
    return _instances[_flavor][_Injectables.HN_COMMENT_SERVICE];
  }

  HNAuthService get hnAuthService {
    if (!_instances[_flavor].containsKey(_Injectables.HN_AUTH_SERVICE)) {
      HNAuthService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new HNAuthServiceProd();
          break;
        case Flavor.MOCK:
          instance = new HNAuthServiceMock();
          break;
      }
      _instances[_flavor][_Injectables.HN_AUTH_SERVICE] = instance;
    }
    return _instances[_flavor][_Injectables.HN_AUTH_SERVICE];
  }

  LocalStorageService get localStorageService {
    if (!_instances[_flavor].containsKey(_Injectables.LOCAL_STORAGE_SERVICE)) {
      LocalStorageService instance;
      switch (_flavor) {
        case Flavor.PROD:
          instance = new LocalStorageServiceProd();
          break;
        case Flavor.MOCK:
          instance = new LocalStorageServiceMock();
          break;
      }
      _instances[_flavor][_Injectables.LOCAL_STORAGE_SERVICE] = instance;
    }
    return _instances[_flavor][_Injectables.LOCAL_STORAGE_SERVICE];
  }
}

enum _Injectables {
  HN_USER_SERVICE,
  HN_ITEM_SERVICE,
  HN_STORY_SERVICE,
  HN_COMMENT_SERVICE,
  HN_AUTH_SERVICE,
  LOCAL_STORAGE_SERVICE,
}
