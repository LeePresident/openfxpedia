import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../core/config.dart';

class UpdateVerificationException implements Exception {
  const UpdateVerificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VerifiedUpdateArtifact {
  const VerifiedUpdateArtifact({required this.uri, required this.digest});

  final Uri uri;
  final String digest;
}

class UpdateService {
  UpdateService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  VerifiedUpdateArtifact? verifiedAsset(
    Map<String, dynamic>? release,
    String assetName,
  ) {
    if (release == null) return null;

    final assets = release['assets'];
    if (assets is! List) return null;

    for (final asset in assets) {
      if (asset is! Map<String, dynamic> || asset['name'] != assetName) {
        continue;
      }

      final rawUrl = asset['browser_download_url'];
      final uri = rawUrl is String ? Uri.tryParse(rawUrl) : null;
      if (uri == null || !_isAllowedAssetUri(uri, assetName)) return null;

      final digest = asset['digest'];
      if (digest is! String || !_isSha256Digest(digest)) return null;

      return VerifiedUpdateArtifact(
        uri: uri,
        digest: digest,
      );
    }

    return null;
  }

  Future<File> downloadVerifiedAsset({
    required Uri uri,
    required String assetName,
    required String digest,
  }) async {
    final response = await _httpClient.get(uri).timeout(
          const Duration(seconds: 60),
        );
    if (response.statusCode != 200) {
      throw UpdateVerificationException(
        'Update download failed (${response.statusCode})',
      );
    }

    final expectedDigest = _normalizeDigest(digest);
    final actualDigest = sha256.convert(response.bodyBytes).toString();
    if (actualDigest != expectedDigest) {
      throw const UpdateVerificationException(
        'Downloaded update failed integrity verification',
      );
    }

    final temporaryDirectory = await getTemporaryDirectory();
    final file =
        File('${temporaryDirectory.path}${Platform.pathSeparator}$assetName');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file;
  }

  bool _isAllowedAssetUri(Uri uri, String assetName) {
    const expectedPath =
        '/${AppConfig.githubRepoOwner}/${AppConfig.githubRepoName}/releases/download/';
    return uri.scheme == 'https' &&
        uri.host.toLowerCase() == 'github.com' &&
        !uri.hasPort &&
        uri.userInfo.isEmpty &&
        uri.path.startsWith(expectedPath) &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.last == assetName &&
        uri.query.isEmpty &&
        uri.fragment.isEmpty;
  }

  bool _isSha256Digest(String value) {
    final normalized = _normalizeDigest(value);
    return normalized.length == 64 &&
        RegExp(r'^[a-f0-9]{64}$').hasMatch(normalized);
  }

  String _normalizeDigest(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed.startsWith('sha256:') ? trimmed.substring(7) : trimmed;
  }
}
