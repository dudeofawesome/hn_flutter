import 'dart:async';
import 'package:googleapis/androidpublisher/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as Http;
import 'package:meta/meta.dart';

import './package_tools.dart';

class AndroidUploader {
  AndroidpublisherApi _publisherApi;

  Future<Null> login ({
    @required String email,
    @required String clientId,
    @required String privateKeyId,
    @required String privateKey,
  }) async {
    final clientCredentials =
        new ServiceAccountCredentials.fromJson({
          'client_email': email,
          'client_id': clientId,
          'private_key_id': privateKeyId,
          'private_key': privateKey,
          'type': 'service_account',
        });
    final scopes = ['https://www.googleapis.com/auth/androidpublisher'];
    final httpClient = await clientViaServiceAccount(clientCredentials, scopes);

    this._publisherApi = new AndroidpublisherApi(httpClient);
  }

  Future publishUpdate (AndroidPackageTools packageTools) async {
    final edit = await this.createEdit(await packageTools.packageName);
    await this.uploadApk(edit, packageTools);
    await this.updateChangelog(edit, await packageTools.packageName, 'alpha');

    await _publisherApi.edits.commit(await packageTools.packageName, edit.id);
  }

  Future<AppEdit> createEdit (String packageName) async {
    return await this._publisherApi.edits.insert(new AppEdit(), packageName);
  }

  Future<Null> uploadApk (AppEdit edit, AndroidPackageTools packageTools) async {
    // (await this._publisherApi.edits.listings.get(await packageTools.packageName, editReq.id, 'us-EN')).
    print('Uploading APK');
    final uploadedApk = await this._publisherApi.edits.apks.upload(
          await packageTools.packageName,
          edit.id,
          uploadMedia: packageTools.package,
          // uploadOptions: new UploadOptions(),
          uploadOptions: new ResumableUploadOptions(),
        );
    print('Uploaded APK');
    print(uploadedApk.versionCode);
  }

  Future<Null> updateChangelog (AppEdit edit, String packageName, String trackName) async {
    print('setting changelog');
    final track = await this._publisherApi.edits.tracks.get(packageName, edit.id, trackName);
    print(track);
    // this._publisherApi.edits.tracks.update(track, packageName, edit.id, trackName);
    final a = await this._publisherApi.edits.details.get(packageName, edit.id);
    print(a);
  }
}
