import 'dart:math';

int _getIndentationSize (String input) {
  return input.split('\n')
    // filter out lines with only whitespace
    .where((line) => line.replaceFirst(new RegExp(r'^\s*'), '').length > 0)
    // map to indentation size
    .map((line) => line.indexOf(new RegExp(r'\S')))
    .reduce(min);
}

String dedent (String input) {
  final int indent = _getIndentationSize(input);

  return input.split('\n')
    .map((line) => line.length >= indent ? line.substring(indent) : line)
    .join('\n');
}
