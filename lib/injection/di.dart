import 'package:hn_flutter/sdk/services/hn_user_service.dart';


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

  Injector._internal ();

  HNUserService get hnUserService {
    if (_instances[_flavor]?.containsKey('HNUserService') == null) {
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
}
