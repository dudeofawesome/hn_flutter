import 'package:test/test.dart';

import 'package:hn_flutter/utils/regexes.dart';

void main() {
  group('regexes', () {
    test('htmlTagA unit test', () {
      final answers = [
        htmlTagA.hasMatch(
            r'<a href="https://posteo.de/en/blog/new-easy-email-encryption-with-autocrypt-and-openpgp-header" rel="nofollow">https://posteo.de/en/blog/new-easy-email-encryption-with-aut...</a>'),
        htmlTagA.hasMatch(
            r'<a href=\"https://posteo.de/en/blog/new-easy-email-encryption-with-autocrypt-and-openpgp-header\" rel=\"nofollow\">https://posteo.de/en/blog/new-easy-email-encryption-with-aut...</a>'),
        htmlTagA.hasMatch(
            r'<a href=\"http://blog.airbornos.com/post/2017/08/03/Transparent-Web-Apps-using-Service-Worker\" rel=\"nofollow\">http://blog.airbornos.com/post/2017/08/03/Transparent-Web-Ap...</a>'),
        htmlTagA.hasMatch(
            r'<a href=\"https://lwn.net/Articles/720336/\" rel=\"nofollow\">https://lwn.net/Articles/720336/</a>'),
        htmlTagA.hasMatch(
            r'<a href=\"https://lwn.net/Articles/720336?id=42&name=louis" rel="nofollow">Some link text here.</a>'),
        htmlTagA.hasMatch(
            r'''<a href=\"https://en.wikipedia.org/wiki/Duff's_device\" rel=\"nofollow\">https://en.wikipedia.org/wiki/Duff's_device</a>'''),
      ];
      expect(answers.every((answer) => answer == true), true);
    });
  });
}
