import 'package:test/test.dart';

import 'package:hn_flutter/utils/dedent.dart';

void main() {
  group('dedent', () {
    test('unit test', () {
      final answers = <List<String>>[
        [
          dedent('''
            test string, please ignore
          '''),
          'test string, please ignore',
        ],
        [
          dedent('''
            test string,
              please ignore
          '''),
          'test string,\n'
              '  please ignore',
        ],
      ];
      print(answers.map((ans) => "'${ans[0]}' == '${ans[1]}'"));
      expect(answers.every((pair) => pair[0] == pair[1]), true);
    });
  });
}
