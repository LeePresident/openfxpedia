import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/screens/settings_screen.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/favorites_service.dart';
import 'package:openfxpedia/services/update_service.dart';

void main() {
  testWidgets('privacy statement is available from settings', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final state = _createAppState();
    addTearDown(state.dispose);

    await _pumpSettings(
      tester,
      state: state,
      updateService: _FakeUpdateService(null),
      currentVersion: '1.0.6',
    );

    await tester.ensureVisible(find.text(l10n.settings_privacy));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settings_privacy));
    await tester.pumpAndSettle();

    expect(find.text(l10n.settings_privacy), findsOneWidget);
    expect(find.text(l10n.privacy_statement_no_account), findsOneWidget);
  });

  testWidgets(
    'cancelling an update prompt does not verify or download an asset',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final updateService = _FakeUpdateService(
        const LatestStableRelease(
          version: '1.0.7',
          data: {'tag_name': 'v1.0.7'},
        ),
      );
      final state = _createAppState();
      addTearDown(state.dispose);

      await _pumpSettings(
        tester,
        state: state,
        updateService: updateService,
        currentVersion: '1.0.6',
      );
      await tester.tap(find.text(l10n.settings_check_updates));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(l10n.update_available), findsOneWidget);
      expect(
        find.text(l10n.update_download_prompt('1.0.7', 'installer-1.0.7.exe')),
        findsOneWidget,
      );

      await tester.tap(find.text(l10n.update_cancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.update_available), findsNothing);
      expect(updateService.fetchCount, 1);
      expect(updateService.verifiedAssetCount, 0);
      expect(updateService.downloadCount, 0);
    },
  );

  testWidgets('an up-to-date version shows the latest-version message', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final updateService = _FakeUpdateService(
      const LatestStableRelease(version: '1.0.6', data: {'tag_name': 'v1.0.6'}),
    );
    final state = _createAppState();
    addTearDown(state.dispose);

    await _pumpSettings(
      tester,
      state: state,
      updateService: updateService,
      currentVersion: '1.0.6',
    );
    await tester.tap(find.text(l10n.settings_check_updates));
    await tester.pumpAndSettle();

    expect(find.text(l10n.settings_latest_version('1.0.6')), findsOneWidget);
    expect(find.text(l10n.update_available), findsNothing);
    expect(updateService.verifiedAssetCount, 0);
    expect(updateService.downloadCount, 0);
  });

  testWidgets('a failed update lookup shows a localized network error', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final updateService = _FakeUpdateService(
      null,
      fetchError: Exception('SocketException: failed host lookup'),
    );
    final state = _createAppState();
    addTearDown(state.dispose);

    await _pumpSettings(
      tester,
      state: state,
      updateService: updateService,
      currentVersion: '1.0.6',
    );
    await tester.tap(find.text(l10n.settings_check_updates));
    await tester.pumpAndSettle();

    expect(find.text(l10n.error_network_unavailable), findsOneWidget);
    expect(updateService.verifiedAssetCount, 0);
    expect(updateService.downloadCount, 0);
  });

  testWidgets('a missing verified asset is reported without downloading', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final updateService = _FakeUpdateService(
      const LatestStableRelease(version: '1.0.7', data: {'tag_name': 'v1.0.7'}),
      assetAvailable: false,
    );
    final state = _createAppState();
    addTearDown(state.dispose);

    await _pumpSettings(
      tester,
      state: state,
      updateService: updateService,
      currentVersion: '1.0.6',
    );
    await tester.tap(find.text(l10n.settings_check_updates));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text(l10n.update_download));
    await tester.pumpAndSettle();

    expect(find.text(l10n.update_asset_not_found), findsOneWidget);
    expect(updateService.verifiedAssetCount, 1);
    expect(updateService.downloadCount, 0);
  });
}

AppState _createAppState() {
  final cache = CacheService();
  final client = ExchangeClient();
  return AppState(
    conversionService: ConversionService(client: client, cache: cache),
    catalogService: CurrencyCatalogService(client: client, cache: cache),
    favoritesService: FavoritesService(cache: cache),
    cacheService: cache,
    systemLocales: () => const [Locale('en')],
  );
}

Future<void> _pumpSettings(
  WidgetTester tester, {
  required AppState state,
  required _FakeUpdateService updateService,
  required String currentVersion,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SettingsScreen(
          updateService: updateService,
          packageInfoLoader: () async => PackageInfo(
            appName: 'OpenFXpedia',
            packageName: 'com.example.openfxpedia',
            version: currentVersion,
            buildNumber: '1',
          ),
          updateAssetNameResolver: (version) => 'installer-$version.exe',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeUpdateService extends UpdateService {
  _FakeUpdateService(
    this.release, {
    this.fetchError,
    this.assetAvailable = true,
  });

  final LatestStableRelease? release;
  final Object? fetchError;
  final bool assetAvailable;
  var fetchCount = 0;
  var verifiedAssetCount = 0;
  var downloadCount = 0;

  @override
  Future<LatestStableRelease?> fetchLatestStableRelease() async {
    fetchCount++;
    if (fetchError != null) throw fetchError!;
    return release;
  }

  @override
  VerifiedUpdateArtifact? verifiedAsset(
    Map<String, dynamic>? release,
    String assetName,
  ) {
    verifiedAssetCount++;
    if (!assetAvailable) return null;
    return VerifiedUpdateArtifact(
      uri: Uri.parse(
        'https://github.com/LeePresident/openfxpedia/releases/download/v1.0.7/$assetName',
      ),
      digest: 'sha256:${'a' * 64}',
    );
  }

  @override
  Future<File> downloadVerifiedAsset({
    required Uri uri,
    required String assetName,
    required String digest,
  }) async {
    downloadCount++;
    return File(assetName);
  }
}
