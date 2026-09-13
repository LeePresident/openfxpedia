import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:openfxpedia/services/update_service.dart';

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this.body);

  final List<int> body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.value(body), 200);
  }
}

void main() {
  const assetName = 'openfxpedia_1.0.4.apk';
  const assetUrl =
      'https://github.com/LeePresident/openfxpedia/releases/download/v1.0.4/$assetName';
  final body = utf8.encode('verified update');
  final digest = sha256.convert(body).toString();

  Map<String, dynamic> release({
    String url = assetUrl,
    String? assetDigest,
    bool includeDigest = true,
  }) {
    final resolvedDigest = assetDigest ?? digest;
    return {
      'assets': [
        {
          'name': assetName,
          'browser_download_url': url,
          if (includeDigest) 'digest': resolvedDigest,
        },
      ],
    };
  }

  group('UpdateService', () {
    test('accepts a matching HTTPS asset from the configured repository', () {
      final artifact = UpdateService().verifiedAsset(release(), assetName);

      expect(artifact, isNotNull);
      expect(artifact!.uri.toString(), assetUrl);
      expect(artifact.digest, digest);
    });

    test('rejects assets outside the configured HTTPS repository', () {
      expect(
        UpdateService().verifiedAsset(
          release(url: 'https://example.com/$assetName'),
          assetName,
        ),
        isNull,
      );
      expect(
        UpdateService().verifiedAsset(
          release(
              url:
                  'http://github.com/LeePresident/openfxpedia/releases/download/v1.0.4/$assetName'),
          assetName,
        ),
        isNull,
      );
    });

    test('rejects assets without a valid SHA-256 digest', () {
      expect(
        UpdateService().verifiedAsset(
          release(includeDigest: false),
          assetName,
        ),
        isNull,
      );
      expect(
        UpdateService().verifiedAsset(
          release(assetDigest: 'sha256:not-a-digest'),
          assetName,
        ),
        isNull,
      );
    });

    test('rejects downloaded bytes when the digest does not match', () async {
      final service = UpdateService(
        httpClient: _FakeHttpClient(utf8.encode('tampered update')),
      );

      expect(
        () => service.downloadVerifiedAsset(
          uri: Uri.parse(assetUrl),
          assetName: assetName,
          digest: digest,
        ),
        throwsA(isA<UpdateVerificationException>()),
      );
    });
  });
}
