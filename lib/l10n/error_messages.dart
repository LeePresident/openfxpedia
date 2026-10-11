import 'app_localizations.dart';

String localizedErrorMessage(AppLocalizations l10n, String code) {
  if (code.startsWith('http_')) return l10n.error_service_unavailable;

  switch (code) {
    case 'network':
    case 'timeout':
    case 'error_network_unavailable':
      return l10n.error_network_unavailable;
    case 'service_unavailable':
    case 'error_service_unavailable':
      return l10n.error_service_unavailable;
    case 'error_historical_unavailable':
      return l10n.error_historical_unavailable;
    default:
      return l10n.error_generic;
  }
}
