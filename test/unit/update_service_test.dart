import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:openfxpedia/services/update_service.dart';

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this.body, {this.statusCode = 200});

  final List<int> body;
  final int statusCode;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.value(body), statusCode);
  }
}

class _FakeReleaseHttpClient extends http.BaseClient {
  _FakeReleaseHttpClient(this.responses, {this.statusCode = 200});

  final List<String> responses;
  final int statusCode;
  final List<Uri> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request.url);
    return http.StreamedResponse(
      Stream.value(utf8.encode(responses.removeAt(0))),
      statusCode,
    );
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
    test('fetches the latest stable release across pages', () async {
      final client = _FakeReleaseHttpClient([
        jsonEncode([
          {'tag_name': 'v1.0.8-rc.1', 'prerelease': true},
          {'tag_name': 'v1.0.7', 'draft': true},
          {'tag_name': 'not-a-version'},
        ]),
        jsonEncode([
          {'tag_name': 'v1.0.6', 'draft': false, 'prerelease': false},
        ]),
      ]);

      final release =
          await UpdateService(httpClient: client).fetchLatestStableRelease();

      expect(release?.version, '1.0.6');
      expect(release?.data['tag_name'], 'v1.0.6');
      expect(client.requests, hasLength(2));
      expect(client.requests.first.queryParameters['page'], '1');
      expect(client.requests.last.queryParameters['page'], '2');
    });

    test('returns null when the release list is empty', () async {
      final client = _FakeReleaseHttpClient([jsonEncode([])]);

      expect(
        await UpdateService(httpClient: client).fetchLatestStableRelease(),
        isNull,
      );
      expect(client.requests, hasLength(1));
    });

    test('rejects failed HTTP responses and malformed release JSON', () async {
      final failedClient = _FakeReleaseHttpClient(
        [jsonEncode([])],
        statusCode: 503,
      );
      final malformedClient = _FakeReleaseHttpClient(['not-json']);

      await expectLater(
        UpdateService(httpClient: failedClient).fetchLatestStableRelease(),
        throwsA(isA<http.ClientException>()),
      );
      await expectLater(
        UpdateService(httpClient: malformedClient).fetchLatestStableRelease(),
        throwsA(isA<FormatException>()),
      );
    });

    test('normalizes and compares release versions', () {
      expect(UpdateService.normalizeVersion(' V1.2.3-beta+build.5'), '1.2.3');
      expect(UpdateService.normalizeVersion('not-a-version'), isNull);
      expect(
        UpdateService.compareVersions('1.2.3+build.5', 'v1.2.4'),
        lessThan(0),
      );
      expect(UpdateService.compareVersions('1.2.4', '1.2.4'), 0);
    });

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

    test('writes a verified download to the temporary directory', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const pathProviderChannel =
          MethodChannel('plugins.flutter.io/path_provider');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final temporaryDirectory =
          await Directory.systemTemp.createTemp('openfxpedia-update-test-');
      messenger.setMockMethodCallHandler(
        pathProviderChannel,
        (call) async => temporaryDirectory.path,
      );
      addTearDown(() async {
        messenger.setMockMethodCallHandler(pathProviderChannel, null);
        await temporaryDirectory.delete(recursive: true);
      });

      final service = UpdateService(httpClient: _FakeHttpClient(body));
      final file = await service.downloadVerifiedAsset(
        uri: Uri.parse(assetUrl),
        assetName: assetName,
        digest: digest,
      );

      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), body);
    });

    test('rejects failed download responses', () async {
      final service = UpdateService(
        httpClient: _FakeHttpClient(body, statusCode: 503),
      );

      await expectLater(
        service.downloadVerifiedAsset(
          uri: Uri.parse(assetUrl),
          assetName: assetName,
          digest: digest,
        ),
        throwsA(isA<UpdateVerificationException>()),
      );
    });
  });
}
