// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OpenFXpedia';

  @override
  String get settings_language => 'Language';

  @override
  String get language_english => 'English';

  @override
  String get language_simplified_chinese => 'Simplified Chinese';

  @override
  String get language_traditional_chinese => 'Traditional Chinese';

  @override
  String get converter_title => 'Converter';

  @override
  String get encyclopedia_title => 'Encyclopedia';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_app_version => 'App version';

  @override
  String get settings_check_updates => 'Check updates';

  @override
  String get settings_changelogs => 'Changelogs';

  @override
  String get settings_changelogs_subtitle =>
      'View concise changelogs for all versions';

  @override
  String get settings_license => 'License';

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
      'Choose a from and to currency to begin converting.';

  @override
  String get converter_choose_currencies => 'Choose your currencies';

  @override
  String get converter_currency_prompt =>
      'Which field should be filled with this currency?';

  @override
  String get converter_cancel => 'Cancel';

  @override
  String get converter_from_field => 'From';

  @override
  String get converter_to_field => 'To';

  @override
  String get converter_continue => 'Continue';

  @override
  String get amount_label => 'Amount';

  @override
  String get encyclopedia_currency_title => 'Currency Encyclopedia';

  @override
  String get encyclopedia_search => 'Search currencies...';

  @override
  String get encyclopedia_not_found => 'No currencies found.';

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
      'Which field should be filled with this currency?';

  @override
  String get detail_remove_favorite => 'Remove favorite';

  @override
  String get detail_add_favorite => 'Add to favorites';

  @override
  String get detail_iso_code => 'ISO Code';

  @override
  String get detail_name => 'Name';

  @override
  String get detail_symbol => 'Symbol';

  @override
  String get detail_regions => 'Regions';

  @override
  String get detail_description => 'Description';

  @override
  String get detail_convert => 'Convert';

  @override
  String get update_available => 'Update available';

  @override
  String get update_cancel => 'Cancel';

  @override
  String get update_download => 'Download';

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
  String get rate_info_live => 'live';

  @override
  String get rate_info_disclaimer => 'Exchange rates are for reference only.';
}
