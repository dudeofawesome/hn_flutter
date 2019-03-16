import 'package:html_unescape/html_unescape_small.dart' show HtmlUnescape;

import 'package:hn_flutter/utils/regexes.dart';

class SimpleMarkdownConversion {
  static String htmlToMD(String html) {
    return new HtmlUnescape()
        .convert(html)
        .replaceAllMapped(htmlTagA, (match) => '[${match[2]}](${match[1]})')
        .replaceAll(new RegExp(r'\<\/?a\>', caseSensitive: false), '')
        .replaceAll(new RegExp(r'\<\/?b\>', caseSensitive: false), '**')
        .replaceAll(new RegExp(r'\<\/?i\>', caseSensitive: false), '_')
        .replaceAll(new RegExp(r'\<\/?p\>', caseSensitive: false), '\n\n')
        .replaceAll(new RegExp(r'\<\/?s\>', caseSensitive: false), '~~')
        .replaceAll(new RegExp(r'\<\/?u\>', caseSensitive: false), '__')
        .replaceAllMapped(new RegExp(r'^([0-9]+)\.', caseSensitive: false),
            (match) => '${match[1]}\\.')
        .replaceAllMapped(gfmAutolinkUrl, (match) {
      try {
        Uri.parse(match[0]);
        return '[${match[0]}](${match[0]})';
      } catch (e) {
        return match[0];
      }
    });
  }
}
