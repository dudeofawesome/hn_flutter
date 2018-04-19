import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pub_cache/pub_cache.dart';
import 'package:yaml/yaml.dart';

void main() async {
  final licenses = await generateLicenses();
  print('Found licenses for ${licenses.keys.join(', ')}');
  final licensesJson = json.encode(licenses);
  final licensesFile =
      new File(path.join(Directory.current.path, 'licenses.json'));
  await licensesFile.writeAsString(licensesJson);
}

Future<Map<String, String>> generateLicenses() async {
  final licenses = new Map<String, String>();
  final packages = await _getPackages();

  for (final name in packages.keys) {
    final licenseFile = new File(await _findLicenseFile(packages[name]));
    licenses[name] = await licenseFile.readAsString();
  }

  // if (forLibrary) {
  //   var name = library.element.name;
  //   if (name.isEmpty) {
  //     name = library.element.source.uri.pathSegments.last;
  //   }
  //   output.writeln('// Code for "$name"');
  // }
  // if (forClasses) {
  //   for (var classElement
  //       in library.allElements.where((e) => e is ClassElement)) {
  //     if (classElement.displayName.contains('GoodError')) {
  //       throw new InvalidGenerationSourceError(
  //           "Don't use classes with the word 'Error' in the name",
  //           todo: 'Rename ${classElement.displayName} to something else.',
  //           element: classElement);
  //     }
  //     output.writeln('// Code for "$classElement"');
  //   }
  // }
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
