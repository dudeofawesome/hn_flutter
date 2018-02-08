import 'dart:async';

abstract class HNAuthService {
  Future<bool> addAccount (String userId, String userPassword);

  Future<bool> removeAccount (String userId);
}
