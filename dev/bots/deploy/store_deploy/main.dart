import 'dart:async';
import 'dart:io';
import 'dart:convert' show json;
// import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import './uploader.dart';
import './package_tools.dart';

main(List<String> args) async {
  // final parser = new ArgParser()
  //   ..addOption('auth');
  // parser.addCommand('upload');

  // parser.parse(args);

  final runner =
      new CommandRunner('store_deploy', 'Deploy app packages to stores')
        ..addCommand(new UploadCommand());

  await runner.run(args);

  print('EXITING PROGRAM');
  exit(0);
}

class UploadCommand extends Command {
  get name => 'upload';
  get description => 'Sample [upload] description';

  UploadCommand() {
    this.addSubcommand(new UploadAndroidCommand());
  }

  // void run () {
  //   print(argResults['package-path']);
  // }
}

class UploadAndroidCommand extends Command {
  get name => 'android';
  get description => 'Sample [upload-android] description';

  UploadAndroidCommand () {
    this.argParser
      ..addOption('package-path')
      ..addOption(
        'google-email',
        help:
            'https://github.com/dart-lang/googleapis_auth#autonomous-application--service-account',
      )
      ..addOption('google-id')
      ..addOption('google-pkey-id')
      ..addOption('google-pkey')
      ..addOption(
        'google-user-json',
        help: 'path to Google JSON private key file',
      )
      ..addOption(
        'track',
        help: 'Release track to deploy app to',
        allowed: ['alpha', 'beta', 'staged rollout', 'production'],
        defaultsTo: 'alpha',
      )
      ..addOption(
        'name',
        help: 'Release name to identify release in the Play Console only, such '
            'as an internal code name or build version.',
      )
      // TODO: figure i18n support
      ..addOption(
        'changelog-path',
        help: '',
      )
      ..addFlag(
        'changelog-md',
        help: '',
      );
  }

  Future<Null> run () async {
    if (argResults['package-path'] == null) throw 'package-path is required';

    Map<String, String> googleUserJson = new Map();
    if (argResults['google-user-json'] != null) {
      final jsonFile = new File(argResults['google-user-json']);
      if (!(await jsonFile.exists())) throw 'Missing google-user-json file';
      googleUserJson = json.decode(await jsonFile.readAsString());
    }

    final email = googleUserJson['client_email'] ??
        argResults['google-email'] ??
        Platform.environment['GOOGLE_EMAIL'];
    final clientId = googleUserJson['client_id'] ??
        argResults['google-id'] ??
        Platform.environment['GOOGLE_ID'];
    final privateKeyId = googleUserJson['private_key_id'] ??
        argResults['google-pkey-id'] ??
        Platform.environment['GOOGLE_PKEY_ID'];
    final privateKey = googleUserJson['private_key'] ??
        argResults['google-pkey'] ??
        Platform.environment['GOOGLE_PKEY'];
    if (email == null) throw 'google-email is required';
    if (clientId == null) throw 'google-id is required';
    if (privateKeyId == null) throw 'google-pkey-id is required';
    if (privateKey == null) throw 'google-pkey is required';

    final packageTools = new AndroidPackageTools(argResults['package-path']);
    await packageTools.load();
    print('packageName: ${await packageTools.packageName}');

    final upload = new AndroidUploader();
    await upload.login(
      email: email,
      clientId: clientId,
      privateKeyId: privateKeyId,
      privateKey: privateKey,
    );
    await upload.publishUpdate(packageTools);
    print('Finished publishUpdate');
  }
}
