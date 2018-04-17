import 'dart:io';
import 'dart:async';
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart';
import 'package:apk_parser/apk_parser.dart';

abstract class PackageTools {
  final String packagePath;

  PackageTools(this.packagePath);

  FutureOr<String> get packageName;
}

class AndroidPackageTools implements PackageTools {
  final String packagePath;
  String _packageName;
  Media _package;

  AndroidPackageTools(this.packagePath);

  Future<Null> load () async {
    final file = new File(this.packagePath);
    if (!await file.exists()) throw '''Can't find package at $packagePath''';
    this._package = new Media(file.openRead(), await file.length());
  }

  Media get package => this._package;

  Future<String> get packageName async {
    if (this._packageName != null) {
      return this._packageName;
    } else {
      // TODO: implement package name retrieval
      final manifest = await this._readPackageManifest();
      this._packageName = manifest.package;
      return this._packageName;
    }
  }

  Future<Manifest> _readPackageManifest () async {
    return await parseManifest(
        await this._package.stream.fold([], (curr, val) => curr..addAll(val)));
  }
}
