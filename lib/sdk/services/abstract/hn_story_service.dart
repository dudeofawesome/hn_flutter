import 'dart:async';
import 'dart:io' show Cookie;

abstract class HNStoryService {
  Future<List<int>> getTopStories({
    int skip = 0,
    Cookie accessCookie,
  });

  Future<List<int>> getNewStories({
    int skip = 0,
    Cookie accessCookie,
  });

  Future<List<int>> getBestStories({
    int skip = 0,
    Cookie accessCookie,
  });

  Future<List<int>> getAskStories({
    int skip = 0,
    Cookie accessCookie,
  });

  Future<List<int>> getShowStories({
    int skip = 0,
    Cookie accessCookie,
  });

  Future<List<int>> getJobStories({
    int skip = 0,
    Cookie accessCookie,
  });
}
