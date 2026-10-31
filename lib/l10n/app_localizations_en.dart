// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get history_title => 'Rate history';

  @override
  String get history_week => '1W';

  @override
  String get history_month => '1M';

  @override
  String get history_year => '1Y';

  @override
  String get history_unavailable =>
      'No historical quotes available for this range. Try another date or rate source.';

  @override
  String history_available(int available, int total) {
    return 'Sampled quotes: $available/$total';
  }

  @override
  String get converter_date => 'Conversion date';

  @override
  String get converter_latest => 'Latest';

  @override
  String get converter_use_latest => 'Use latest rates';

  @override
  String get error_historical_unavailable =>
      'Historical rates could not be loaded for this currency pair and date. Check your connection or try another date or rate source.';

  @override
  String rate_info_requested_date(String date) {
    return 'Requested date: $date';
  }

  @override
  String rate_info_effective_date(String date) {
    return 'Rate date: $date';
  }

  @override
  String get appTitle => 'OpenFXpedia';

  @override
  String get startup_loading => 'Loading currencies and cached rates';

  @override
  String get startup_error_title => 'Startup failed';

  @override
  String get settings_language => 'Language';

  @override
  String get clear_search => 'Clear search';

  @override
  String get language_english => 'English';

  @override
  String get language_simplified_chinese => '简体中文';

  @override
  String get language_traditional_chinese => '繁體中文';

  @override
  String get converter_title => 'Converter';

  @override
  String get calculator_title => 'Calculator';

  @override
  String get comparison_title => 'Compare rates';

  @override
  String get comparison_base_currency => 'Base currency';

  @override
  String get comparison_select_currencies => 'Select currencies';

  @override
  String get comparison_choose_currencies => 'Choose currencies to compare';

  @override
  String get comparison_done => 'Done';

  @override
  String get comparison_currency => 'Currency';

  @override
  String comparison_rate_for_base(String base) {
    return 'Rate per 1 $base';
  }

  @override
  String get comparison_no_rate => 'Not available';

  @override
  String get comparison_empty => 'Choose currencies above to see rates.';

  @override
  String get calculator_amount => 'Amount';

  @override
  String get calculator_currency => 'Currency';

  @override
  String get calculator_result_currency => 'Result currency';

  @override
  String get calculator_total => 'Total';

  @override
  String get calculator_add_entry => 'Add amount';

  @override
  String get calculator_remove_entry => 'Remove amount';

  @override
  String calculator_entry(int number) {
    return 'Amount $number';
  }

  @override
  String get calculator_no_entries => 'Add an amount to calculate a total.';

  @override
  String get calculator_date => 'Rate date';

  @override
  String get calculator_latest => 'Latest rates';

  @override
  String get calculator_use_latest => 'Use latest rates';

  @override
  String get encyclopedia_title => 'Encyclopedia';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_exchange_api_source => 'Exchange rate API';

  @override
  String get settings_select_exchange_api_source => 'Select exchange rate API';

  @override
  String get settings_exchange_api_source_auto => 'Auto';

  @override
  String get settings_app_version => 'App version';

  @override
  String get settings_check_updates => 'Check for updates';

  @override
  String get settings_changelogs => 'Change log';

  @override
  String get settings_changelogs_subtitle =>
      'View a concise change log for every version';

  @override
  String get settings_license => 'License';

  @override
  String get settings_privacy => 'Privacy statement';

  @override
  String get privacy_statement_no_account =>
      'OpenFXpedia does not require an account and does not collect names, email addresses, payment information, contacts, location, camera, microphone, or advertising identifiers. The app does not include analytics, advertising, crash-reporting, or user-tracking SDKs.';

  @override
  String get privacy_statement_network =>
      'The app makes HTTPS requests to the configured exchange-rate and currency-catalog providers. These requests include the selected currency codes needed to retrieve rates and catalog data. The app also contacts the OpenFXpedia GitHub repository when you check for updates. External providers and GitHub may receive normal connection metadata such as your IP address according to their own privacy policies.';

  @override
  String get privacy_statement_local_storage =>
      'Rates and currency catalog data are cached locally for offline use. Favorites and app preferences are also stored locally. These Hive data boxes are encrypted with a randomly generated key stored in the app-support directory. Encryption protects stored data from casual inspection, but the key is stored locally rather than in a hardware-backed vault, so it does not protect data on a device that is already compromised or unlocked by an attacker.';

  @override
  String get privacy_statement_data_deletion =>
      'To delete locally stored rates, catalog data, favorites, and preferences, open Settings and choose Clear local data. Clearing local data retains the encryption key so any future cached data remains encrypted. Uninstalling the app removes its application data according to the operating system\'s normal uninstall behavior.';

  @override
  String get privacy_statement_android =>
      'The Android app requests only the INTERNET permission. Network communication uses HTTPS, and update files are downloaded only after their GitHub release URL and SHA-256 digest have been checked against GitHub release metadata. This detects incorrect or corrupted downloads; it is not an independent publisher signature, so a compromised release source remains outside the app\'s trust boundary. No personal data is intentionally included in exchange-rate requests or update checks.';

  @override
  String get settings_clear_local_data => 'Clear local data';

  @override
  String get settings_clear_local_data_subtitle =>
      'Delete cached rates, catalog data, favorites, and preferences';

  @override
  String get settings_clear_local_data_title => 'Clear local data?';

  @override
  String get settings_clear_local_data_message =>
      'This deletes cached rates, catalog data, favorites, and preferences from this device.';

  @override
  String get settings_clear_local_data_confirm => 'Clear data';

  @override
  String get settings_clear_local_data_done => 'Local data cleared';

  @override
  String get settings_clear_local_data_failed => 'Could not clear local data';

  @override
  String get settings_select_theme => 'Select theme';

  @override
  String get settings_system => 'System';

  @override
  String get settings_light => 'Light';

  @override
  String get settings_dark => 'Dark';

  @override
  String get settings_language_dialog_title => 'Select language';

  @override
  String get settings_language_dialog_subtitle => 'Choose the app language.';

  @override
  String get converter_currency_title => 'Currency Converter';

  @override
  String get converter_refresh_rates => 'Refresh rates';

  @override
  String get converter_favorites => 'Favorites';

  @override
  String get converter_from => 'From';

  @override
  String get converter_to => 'To';

  @override
  String get converter_from_hint => 'From currency...';

  @override
  String get converter_to_hint => 'To currency...';

  @override
  String get converter_swap => 'Swap currencies';

  @override
  String get converter_choose_pair =>
      'Select source and target currencies to start converting.';

  @override
  String get converter_currency_prompt =>
      'Use this as the source or target currency?';

  @override
  String get converter_cancel => 'Cancel';

  @override
  String get converter_from_field => 'From';

  @override
  String get converter_to_field => 'To';

  @override
  String get amount_label => 'Amount';

  @override
  String get encyclopedia_currency_title => 'Currency Encyclopedia';

  @override
  String get encyclopedia_search => 'Search currencies...';

  @override
  String get encyclopedia_not_found => 'No currencies found.';

  @override
  String get encyclopedia_sort => 'Sort currencies';

  @override
  String get encyclopedia_sort_code_ascending => 'Code (A-Z)';

  @override
  String get encyclopedia_sort_code_descending => 'Code (Z-A)';

  @override
  String get encyclopedia_sort_name_ascending => 'Name (A-Z)';

  @override
  String get encyclopedia_sort_name_descending => 'Name (Z-A)';

  @override
  String get encyclopedia_favorites_only => 'Show favorites only';

  @override
  String get favorites_add => 'Add to favorites';

  @override
  String get favorites_remove => 'Remove from favorites';

  @override
  String get detail_cancel => 'Cancel';

  @override
  String get detail_from_field => 'From';

  @override
  String get detail_to_field => 'To';

  @override
  String get detail_currency_prompt =>
      'Use this as the source or target currency?';

  @override
  String get detail_remove_favorite => 'Remove from favorites';

  @override
  String get detail_add_favorite => 'Add to favorites';

  @override
  String get detail_iso_code => 'ISO Code';

  @override
  String get detail_iso_numeric => 'ISO numeric code';

  @override
  String get detail_name => 'Name';

  @override
  String get detail_symbol => 'Symbol';

  @override
  String get detail_regions => 'Regions';

  @override
  String get detail_show_more_regions => 'Show more';

  @override
  String get detail_show_less_regions => 'Show less';

  @override
  String get detail_description => 'Description';

  @override
  String get detail_coins => 'Coins';

  @override
  String get detail_banknotes => 'Banknotes';

  @override
  String get detail_units => 'Units';

  @override
  String detail_unit_summary(String majorUnit, String minorUnit, int ratio) {
    return '$majorUnit / $minorUnit (1:$ratio)';
  }

  @override
  String detail_unit_summary_no_minor(String majorUnit) {
    return '$majorUnit (no minor unit)';
  }

  @override
  String get detail_pab_no_banknotes =>
      'No Balboa banknotes; US dollar banknotes are used instead';

  @override
  String get detail_sos_no_coins =>
      'No Somali Shilling coins currently circulate';

  @override
  String get detail_vnd_no_coins =>
      'No Vietnamese đồng coins currently circulate';

  @override
  String get detail_convert => 'Convert';

  @override
  String get update_available => 'Update available';

  @override
  String get update_cancel => 'Cancel';

  @override
  String get update_download => 'Download';

  @override
  String update_download_prompt(String version, String assetName) {
    return 'Version $version is available.\n\nDownload $assetName for this device from GitHub Releases?';
  }

  @override
  String get update_latest_release_unavailable =>
      'Unable to determine the latest stable release from GitHub.';

  @override
  String get update_asset_not_found =>
      'No download is available for this device on GitHub Releases.';

  @override
  String get update_open_download_failed =>
      'Could not open the GitHub release download link.';

  @override
  String get update_direct_download_unsupported =>
      'This device does not support direct release downloads.';

  @override
  String get update_latest => 'You are on the latest version';

  @override
  String settings_latest_version(String version) {
    return 'You are on the latest version ($version).';
  }

  @override
  String get rate_info_refreshing => 'Refreshing rates...';

  @override
  String get rate_info_cached => 'cached';

  @override
  String get rate_info_live => 'Online';

  @override
  String get rate_info_source_prefix => 'Source:';

  @override
  String get provider_frankfurter => 'Frankfurter';

  @override
  String get provider_exchange_api => 'Exchange API';

  @override
  String get rate_info_disclaimer => 'Exchange rates are for reference only.';

  @override
  String get error_network_unavailable =>
      'Network error — unable to reach the server. Please check your internet connection and try again.';

  @override
  String get error_service_unavailable =>
      'Unable to reach the remote service right now. Please try again later.';

  @override
  String get error_generic => 'Something went wrong. Please try again.';

  @override
  String get pick => 'Pick';
}
