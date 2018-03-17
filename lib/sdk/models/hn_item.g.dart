// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hn_item.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

HNItem _$HNItemFromJson(Map<String, dynamic> json) => new HNItem(
    id: json['id'] as int,
    deleted: json['deleted'] as bool,
    dead: json['dead'] as bool,
    type: json['type'] as String,
    title: json['title'] as String,
    url: json['url'] as String,
    text: json['text'] as String,
    time: json['time'] as int,
    by: json['by'] as String,
    score: json['score'] as int,
    descendants: json['descendants'] as int,
    kids: (json['kids'] as List).map((e) => e as int).toList(),
    parent: json['parent'] as int,
    poll: json['poll'],
    parts: json['parts'] as List,
    computed: json['computed'] == null
        ? null
        : new HNItemComputed.fromJson(
            json['computed'] as Map<String, dynamic>));

abstract class _$HNItemSerializerMixin {
  int get id;
  bool get deleted;
  bool get dead;
  String get type;
  String get title;
  String get url;
  String get text;
  int get time;
  String get by;
  int get score;
  int get descendants;
  List<int> get kids;
  int get parent;
  dynamic get poll;
  List<dynamic> get parts;
  HNItemComputed get computed;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'deleted': deleted,
        'dead': dead,
        'type': type,
        'title': title,
        'url': url,
        'text': text,
        'time': time,
        'by': by,
        'score': score,
        'descendants': descendants,
        'kids': kids,
        'parent': parent,
        'poll': poll,
        'parts': parts,
        'computed': computed
      };
}

HNItemComputed _$HNItemComputedFromJson(Map<String, dynamic> json) =>
    new HNItemComputed(
        markdown: json['markdown'] as String,
        simpleText: json['simpleText'] as String,
        urlHostname: json['urlHostname'] as String,
        imageUrl: json['imageUrl'] as String);

abstract class _$HNItemComputedSerializerMixin {
  String get markdown;
  String get simpleText;
  String get urlHostname;
  String get imageUrl;
  Map<String, dynamic> toJson() {
    var val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('markdown', markdown);
    writeNotNull('simpleText', simpleText);
    writeNotNull('urlHostname', urlHostname);
    writeNotNull('imageUrl', imageUrl);
    return val;
  }
}
