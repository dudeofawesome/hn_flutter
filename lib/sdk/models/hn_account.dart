class HNAccount {
  /// The user's unique username. Case-sensitive. Required.
  String id;
  String email;
  String password;
  String accessToken;

  HNAccount ({
    this.id,
    this.email,
    this.password,
    this.accessToken,
  });

  HNAccount.fromMap (Map map) {
    this.id = map['id'];
    this.email = map['email'];
    this.password = map['password'];
    this.accessToken = map['accessToken'];
  }
}
