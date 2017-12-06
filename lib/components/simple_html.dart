import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart';
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownBody;

class SimpleHTML extends StatelessWidget {
  final Dom.Document doc;

  SimpleHTML (
    String body,
    {
      Key key,
    }
  ) : doc = parse(body),
      super(key: key)
  {
    // this._parse(body);

    // List<Match> openingTags = new RegExp(r'\<([a-zA-Z\-]+)\>').allMatches(this.body).toList();
    // List<Match> closingTags = new RegExp(r'\<\/([a-zA-Z\-]+)\>').allMatches(this.body).toList();
    // this.body = openingTags.first.end.toString();

    // var openingTag = openingTags.elementAt(0);
    // var closingTag = closingTags.firstWhere((tag) => tag.groupCount > 0 && tag.group(1) == openingTag.group(1));
    // if (closingTag == null) {
    //   // auto-place a closing tag
    // } else {
    //   closingTags.removeAt(0);
    // }

    // switch (openingTag.group(1)) {
    //   case 'a':
    //     this.spans.add(new TextSpan(
    //       text: this.body.substring(openingTag.end, closingTag.start),
    //       // style: style
    //     ));
    //     break;
    //   case 'i':
    //     this.spans.add(new TextSpan(
    //       text: this.body.substring(openingTag.end, closingTag.start),
    //       // style: style
    //     ));
    //     break;
    //   case 'b':
    //     this.spans.add(new TextSpan(
    //       text: this.body.substring(openingTag.end, closingTag.start),
    //     ));
    //     break;
    //   case 'p':
    //     this.spans.add(new TextSpan(
    //       text: this.body.substring(openingTag.end, closingTag.start),
    //     ));
    //     break;
    //   case 'u':
    //     this.spans.add(new TextSpan(
    //       text: this.body.substring(openingTag.end, closingTag.start),
    //     ));
    //     break;
    //   case 's':
    //     this.spans.add(new TextSpan(
    //       text: this.body.substring(openingTag.end, closingTag.start),
    //     ));
    //     break;
    //   case 'q':
    //     this.spans.add(new TextSpan(
    //       text: this.body.substring(openingTag.end, closingTag.start),
    //     ));
    //     break;
    // }

  }

  List<TextSpan> _transform (BuildContext ctx) {
    // for (var i = 0; i < this.doc.body.children.length; i++) {
    //
    // }
    // print(this.doc.body.children.map((child) => this._transformNode(child)).first);

    // print(this.doc.body.children.length);
    return this.doc.body.children.map((child) => this._transformNode(ctx, child)).toList();
  }

  TextSpan _transformNode (BuildContext ctx, Dom.Element node) {
    String text;
    TextStyle style;

    print(node.localName);

    switch (node.localName) {
      case 'a':
        text = '[${node.text}](${node.attributes['href']})';
        style = DefaultTextStyle.of(ctx).style.copyWith(
          decoration: TextDecoration.underline,
          color: Colors.lightBlue,
        );
        break;
      case 'b':
        text = node.text;
        style = DefaultTextStyle.of(ctx).style.copyWith(fontWeight: FontWeight.bold);
        break;
      case 'i':
        text = node.text;
        style = DefaultTextStyle.of(ctx).style.copyWith(fontStyle: FontStyle.italic);
        break;
      case 'p':
        if (node.parent.children.last != node) {
          text = '${node.text}\n\n';
        } else {
          text = node.text;
        }
        break;
      case 's':
        text = node.text;
        style = DefaultTextStyle.of(ctx).style.copyWith(decoration: TextDecoration.lineThrough);
        break;
      case 'u':
        text = node.text;
        style = DefaultTextStyle.of(ctx).style.copyWith(decoration: TextDecoration.underline);
        break;
      default:
        text = node.text;
    }

    if (node.children.length != 0) {
      return new TextSpan(
        text: text,
        style: style,
        children: node.children.map((child) => this._transformNode(ctx, child)).toList(),
      );
    } else {
      return new TextSpan(
        text: text,
        style: style,
      );
    }
  }

  @override
  Widget build (BuildContext context) {
    String body = this.doc.body.innerHtml;
    body = body
      .replaceAll('&#x2F;', '/')
      .replaceAll('&#x27;', '\'')
      .replaceAll('&amp;', '&');

    body = body
      .replaceAllMapped(
        new RegExp(r'\<a.*?href\=\\?"([a-z0-9\/\-\.:]*)\\?".*?\>(.*?)\<\/a\>', caseSensitive: false),
        (match) => '[${match[2]}](${match[1]})'
      )
      // .replaceAll(new RegExp(r'\<\/?a\>', caseSensitive: false), '')
      .replaceAll(new RegExp(r'\<\/?b\>', caseSensitive: false), '**')
      .replaceAll(new RegExp(r'\<\/?i\>', caseSensitive: false), '_')
      .replaceAll(new RegExp(r'\<\/?p\>', caseSensitive: false), '\n\n')
      .replaceAll(new RegExp(r'\<\/?s\>', caseSensitive: false), '~~')
      .replaceAll(new RegExp(r'\<\/?u\>', caseSensitive: false), '__');

    return new MarkdownBody(
      data: body,
    );
    // return new RichText(
    //   text: new TextSpan(
    //     // text: this.body,
    //     style: DefaultTextStyle.of(context).style,
    //     children: [this._transformNode(context, this.doc.body)],
    //   ),
    // );
  }
}

class TransformedNode {
  TextSpan element;
  List<TransformedNode> children;

  TransformedNode(this.element, [this.children]);
}
