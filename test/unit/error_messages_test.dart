import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/l10n/error_messages.dart';

void main() {
  test('known error codes map to localized messages with a generic fallback',
      () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(
      localizedErrorMessage(l10n, 'network'),
      l10n.error_network_unavailable,
    );
    expect(
      localizedErrorMessage(l10n, 'timeout'),
      l10n.error_network_unavailable,
    );
    expect(
      localizedErrorMessage(l10n, 'http_503'),
      l10n.error_service_unavailable,
    );
    expect(
      localizedErrorMessage(l10n, 'error_historical_unavailable'),
      l10n.error_historical_unavailable,
    );
    expect(
      localizedErrorMessage(l10n, 'unrecognized_code'),
      l10n.error_generic,
    );
  });
}
