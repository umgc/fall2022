import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/vision/v1.dart';

class CredentialsProvider {
  CredentialsProvider();

  Future<ServiceAccountCredentials> get _credentials async {
    String file = await rootBundle.loadString('assets/credentials.json');
    debugPrint('Got this far##');
    return ServiceAccountCredentials.fromJson(file);
  }

  Future<AutoRefreshingAuthClient> get client async {
    debugPrint('Got this far2##');
    AutoRefreshingAuthClient client = await clientViaServiceAccount(
        await _credentials, [VisionApi.cloudVisionScope]);
    debugPrint('Got this far3##');
    return client;
  }
}
