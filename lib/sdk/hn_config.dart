class HNConfig {
  static final HNConfig _singleton = new HNConfig._internal();

  factory HNConfig() {
    return _singleton;
  }

  HNConfig._internal();

  final String path = 'https://hacker-news.firebaseio.com';
  final String version = 'v0';
  String get url => '$path/$version';
}
