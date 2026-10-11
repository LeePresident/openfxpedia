import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../core/config.dart';

class LatestStableRelease {
  const LatestStableRelease({
    required this.version,
    required this.data,
  });

  final String version;
  final Map<String, dynamic> data;
}

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

  Future<LatestStableRelease?> fetchLatestStableRelease() async {
    var page = 1;
    while (true) {
      final pageUri = Uri.parse('${AppConfig.githubReleasesApiUrl}&page=$page');
      final response = await _httpClient.get(
        pageUri,
        headers: const {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw http.ClientException(
          'GitHub releases request failed (${response.statusCode})',
          pageUri,
        );
      }

      final pageItems = jsonDecode(response.body);
      if (pageItems is! List<dynamic>) {
        throw const FormatException('Invalid GitHub releases response');
      }
      if (pageItems.isEmpty) return null;

      for (final item in pageItems) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid GitHub release entry');
        }
        if (item['draft'] == true || item['prerelease'] == true) continue;

        final version = normalizeVersion(item['tag_name'] as String?);
        if (version != null && version.isNotEmpty) {
          return LatestStableRelease(version: version, data: item);
        }
      }
      page++;
    }
  }

  static String? normalizeVersion(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var value = raw.trim();
    if (value.startsWith('v') || value.startsWith('V')) {
      value = value.substring(1);
    }
    final plus = value.indexOf('+');
    if (plus >= 0) {
      value = value.substring(0, plus);
    }
    final hyphen = value.indexOf('-');
    if (hyphen >= 0) {
      value = value.substring(0, hyphen);
    }
    if (!RegExp(r'^\d+(?:\.\d+)*$').hasMatch(value)) return null;
    return value;
  }

  static int compareVersions(String? current, String? latest) {
    final currentParts = (normalizeVersion(current) ?? '0.0.0').split('.');
    final latestParts = (normalizeVersion(latest) ?? '0.0.0').split('.');
    final maxLength = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for (var index = 0; index < maxLength; index++) {
      final currentPart = index < currentParts.length
          ? int.tryParse(currentParts[index]) ?? 0
          : 0;
      final latestPart = index < latestParts.length
          ? int.tryParse(latestParts[index]) ?? 0
          : 0;
      if (currentPart != latestPart) {
        return currentPart.compareTo(latestPart);
      }
    }
    return 0;
  }

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
