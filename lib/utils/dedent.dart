import 'dart:math';

int _getIndentationSize (String input) {
  return input.split('\n')
    // filter out lines with only whitespace
    .where((line) => line.trimLeft().length > 0)
    // map to indentation size
    .map((line) => line.indexOf(new RegExp(r'\S')))
    .reduce(min);
}

String dedent (String input) {
  final int indent = _getIndentationSize(input);

  return input
    .replaceFirst(new RegExp(r'\s+$'), '')
    .split('\n')
    .map((line) => line.replaceFirst(new RegExp(r'^[\ ]{' + '$indent' + ',' + '$indent' + '}'), ''))
    .join('\n');
}
