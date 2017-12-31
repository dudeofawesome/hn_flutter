import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape_small.dart' show HtmlUnescape;

class SimpleHTMLtoMarkdown {
  final Dom.Document doc;

  SimpleHTMLtoMarkdown (
    String body,
  ) : doc = parse(body);

  String transform () {
    String body = new HtmlUnescape()
      .convert(this.doc.body.innerHtml);

    return body
      .replaceAllMapped(
        new RegExp(r'\<a.*?href\=\\?"([a-z0-9\/\-_\.:\&\?\=\#]*)\\?".*?\>(.*?)\<\/a\>', caseSensitive: false),
        (match) => '[${match[2]}](${match[1]})'
      )
      .replaceAll(new RegExp(r'\<\/?a\>', caseSensitive: false), '')
      .replaceAll(new RegExp(r'\<\/?b\>', caseSensitive: false), '**')
      .replaceAll(new RegExp(r'\<\/?i\>', caseSensitive: false), '_')
      .replaceAll(new RegExp(r'\<\/?p\>', caseSensitive: false), '\n\n')
      .replaceAll(new RegExp(r'\<\/?s\>', caseSensitive: false), '~~')
      .replaceAll(new RegExp(r'\<\/?u\>', caseSensitive: false), '__')
      .replaceAllMapped(
        new RegExp(r'^([0-9]+)\.', caseSensitive: false),
        (match) => '${match[1]}\\.'
      );
  }
}
