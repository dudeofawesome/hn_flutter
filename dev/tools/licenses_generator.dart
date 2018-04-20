import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:pub_cache/pub_cache.dart';
import 'package:yaml/yaml.dart';

import 'package:hn_flutter/utils/dedent.dart';

void main(List<String> args) async {
  final runner = new CommandRunner(
      'licenses_generator', 'Generate licenses file from dependencies')
    ..addCommand(new GenerateCommand());

  try {
    await runner.run(args);
    exit(0);
  } catch (err) {
    final pen = new AnsiPen()..red();
    print(pen(err.toString()));
    exit(1);
  }
}

class GenerateCommand extends Command {
  get name => 'generate';
  List<String> get aliases => const ['gen', 'g'];
  get description => 'Generate licenses file from dependencies';

  GenerateCommand() {
    this.argParser
      ..addOption(
        'output',
        abbr: 'o',
        defaultsTo: 'assets/strings/licenses.json',
        help: 'Path to write license json to',
      )
      ..addFlag(
        'transitive',
        negatable: true,
        defaultsTo: false,
        help: dedent('''
          Add licenses for transitive dependencies too
          (Currently not supported)
        '''),
      )
      ..addMultiOption(
        'dependency',
        abbr: 'd',
        help:
            '<name:license-path> A dependency name and license file path. Multiple allowed.',
      );
  }

  Future<Null> run() async {
    if (argResults['output'] == null) throw 'output is required';

    // find licenses from pubspec
    final pubLicenses = await generateLicenses();
    print(
        'Found ${pubLicenses.keys.length} licenses from pubspec for ${pubLicenses.keys.join(', ')}');

    // add manually specified licenses
    final manualLicenses = new Map<String, String>();
    for (final String dep in argResults['dependency']) {
      final String name = dep.split(':')[0];
      final String path = dep.split(':')[1];
      final licenseFile = new File(path);
      if (!await licenseFile.exists()) throw 'License $path not found';
      manualLicenses[name] = await licenseFile.readAsString();
    }
    print(
        'Found ${manualLicenses.keys.length} licenses from pubspec for ${manualLicenses.keys.join(', ')}');

    // write licenses to json file
    final licensesJson = json.encode(
        new Map<String, String>()..addAll(pubLicenses)..addAll(manualLicenses));
    final licensesFile = new File(argResults['output']);
    await licensesFile.writeAsString(licensesJson);
  }
}

Future<Map<String, String>> generateLicenses() async {
  final licenses = new Map<String, String>();
  final packages = await _getPackages();

  for (final name in packages.keys) {
    final licenseFile = new File(await _findLicenseFile(packages[name]));
    licenses[name] = await licenseFile.readAsString();
  }

  return licenses;
}

Future<Map<String, String>> _getPackages() async {
  final pubspecFile =
      new File(path.join(Directory.current.path, 'pubspec.yaml'));
  if (!await pubspecFile.exists()) throw 'Could not find pubspec.yaml';
  final pubspec = loadYaml(await pubspecFile.readAsString());
  final dependencies = new Map<String, dynamic>()
    ..addAll(pubspec['dependencies'])
    ..addAll(pubspec['dev_dependencies']);
  dependencies.removeWhere((name, version) => version.runtimeType != String);

  final cache = new PubCache();

  final depPaths = new Map<String, String>();
  for (final dep in dependencies.keys) {
    final latest = cache.getLatestVersion(dep);
    String packagePath;
    if (latest.sourceType == 'hosted') {
      // TODO: support other hosted sources
      packagePath = path.join(cache.location.path, latest.sourceType,
          'pub.dartlang.org', '${latest.name}-${latest.version}');
    } else if (latest.sourceType == 'git') {
      // TODO: add support for git dependencies
      // final packageFolders = await (new Directory(
      //         path.join(cache.location.path, latest.sourceType)))
      //     .list()
      //     .toList();

      // for (final folder in packageFolders) {
      //   final pubspecPath = path.join(folder.path, 'pubspec.yaml');
      //   final pubspecFile = new File(pubspecPath);
      //   if (!(await pubspecFile.exists())) continue;
      //   print('checking $pubspecPath');
      //   if (loadYaml(await pubspecFile.readAsString())['version'] ==
      //       latest.version) {
      //     packagePath = path.join(cache.location.path, folder.path);
      //     break;
      //   }
      // }
    }

    depPaths[dep] = packagePath;
  }
  return depPaths;
}

Future<String> _findLicenseFile(String packagePath) async {
  final children = await (new Directory(packagePath).list()).toList();
  return children
      .firstWhere(
          (item) => path.basename(item.path).toLowerCase().contains('license'),
          orElse: () => null)
      .path;
}
