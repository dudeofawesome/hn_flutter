#!/usr/bin/env dart
import 'dart:io';
import 'package:ansicolor/ansicolor.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

main() async {
  final pubspecFile =
      new File(path.join(Directory.current.path, 'pubspec.yaml'));
  if (!await pubspecFile.exists()) throw 'Could not find pubspec.yaml';
  final pubspec = loadYaml(await pubspecFile.readAsString());
  final String requiredFlutter = pubspec['environment']['flutter'];

  final tags = await Process
      .run('git', ['tag', '--merged', 'beta'],
          workingDirectory: Platform.environment['FLUTTER_HOME'])
      .then<String>((res) => res.stdout)
      .then<List<String>>((stdout) => stdout.split('\n'))
      .then<List<String>>((tags) => tags.where((tag) => tag != '').toList())
      .then<List<String>>((tags) =>
          tags.map((tag) => tag.replaceAll(new RegExp(r'^v'), '')).toList())
      .then<List<Version>>(
          (tags) => tags.map<Version>((tag) => new Version.parse(tag)).toList())
      .then<List<Version>>((tags) => tags
        ..sort((a, b) {
          if (a > b) return 1;
          if (b > a)
            return -1;
          else
            return 0;
        }))
      .then<List<Version>>((tags) => tags.reversed.toList());

  final flutterSemVer = new VersionConstraint.parse(requiredFlutter);
  final version =
      tags.firstWhere((tag) => flutterSemVer.allows(tag), orElse: () {
    print((new AnsiPen()
      ..red())('Error: no matching Flutter version found for $flutterSemVer'));
    exit(1);
  });
  print(version);
}
