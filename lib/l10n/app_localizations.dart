import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// The title of the application.
  ///
  /// In en, this message translates to:
  /// **'OpenFXpedia'**
  String get appTitle;

  /// Label for language settings option.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// English language name.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// Simplified Chinese language name.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get language_simplified_chinese;

  /// Traditional Chinese language name.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get language_traditional_chinese;

  /// Title for the converter screen.
  ///
  /// In en, this message translates to:
  /// **'Converter'**
  String get converter_title;

  /// Title for the encyclopedia screen.
  ///
  /// In en, this message translates to:
  /// **'Encyclopedia'**
  String get encyclopedia_title;

  /// Title for the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// Label for theme settings option.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// Label for exchange rate API source settings option.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate API'**
  String get settings_exchange_api_source;

  /// Dialog title for selecting an exchange rate API source.
  ///
  /// In en, this message translates to:
  /// **'Select exchange rate API'**
  String get settings_select_exchange_api_source;

  /// Option to automatically choose the exchange rate API source.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settings_exchange_api_source_auto;

  /// Label for app version display in settings.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settings_app_version;

  /// Label for checking updates option.
  ///
  /// In en, this message translates to:
  /// **'Check updates'**
  String get settings_check_updates;

  /// Label for viewing changelogs.
  ///
  /// In en, this message translates to:
  /// **'Changelogs'**
  String get settings_changelogs;

  /// Subtitle explaining the changelogs feature.
  ///
  /// In en, this message translates to:
  /// **'View concise changelogs for all versions'**
  String get settings_changelogs_subtitle;

  /// Label for license information.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get settings_license;

  /// Dialog title for selecting a theme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get settings_select_theme;

  /// Theme option for system/auto theme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_system;

  /// Theme option for light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_light;

  /// Theme option for dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_dark;

  /// Dialog title for language selection.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settings_language_dialog_title;

  /// Dialog subtitle for language selection.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language.'**
  String get settings_language_dialog_subtitle;

  /// Title for the currency converter.
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get converter_currency_title;

  /// Label for refreshing exchange rates button.
  ///
  /// In en, this message translates to:
  /// **'Refresh rates'**
  String get converter_refresh_rates;

  /// Label for favorites feature in converter.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get converter_favorites;

  /// Label for the 'from' currency field.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get converter_from;

  /// Label for the 'to' currency field.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get converter_to;

  /// Hint text for the 'from' currency input field.
  ///
  /// In en, this message translates to:
  /// **'From currency...'**
  String get converter_from_hint;

  /// Hint text for the 'to' currency input field.
  ///
  /// In en, this message translates to:
  /// **'To currency...'**
  String get converter_to_hint;

  /// Label for button to swap from and to currencies.
  ///
  /// In en, this message translates to:
  /// **'Swap currencies'**
  String get converter_swap;

  /// Message prompting user to select currencies.
  ///
  /// In en, this message translates to:
  /// **'Choose a from and to currency to begin converting.'**
  String get converter_choose_pair;

  /// Prompt asking which field to fill with selected currency.
  ///
  /// In en, this message translates to:
  /// **'Which field should be filled with this currency?'**
  String get converter_currency_prompt;

  /// Label for cancel button in converter.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get converter_cancel;

  /// Label for 'from' field in currency selection dialog.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get converter_from_field;

  /// Label for 'to' field in currency selection dialog.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get converter_to_field;

  /// Label for the amount input field.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount_label;

  /// Title for the currency encyclopedia.
  ///
  /// In en, this message translates to:
  /// **'Currency Encyclopedia'**
  String get encyclopedia_currency_title;

  /// Hint text for currency search field.
  ///
  /// In en, this message translates to:
  /// **'Search currencies...'**
  String get encyclopedia_search;

  /// Message when no currencies match the search.
  ///
  /// In en, this message translates to:
  /// **'No currencies found.'**
  String get encyclopedia_not_found;

  /// Label for adding currency to favorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favorites_add;

  /// Label for removing currency from favorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favorites_remove;

  /// Label for cancel button in detail view.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get detail_cancel;

  /// Label for 'from' field in detail view.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get detail_from_field;

  /// Label for 'to' field in detail view.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get detail_to_field;

  /// Prompt in detail view for field selection.
  ///
  /// In en, this message translates to:
  /// **'Which field should be filled with this currency?'**
  String get detail_currency_prompt;

  /// Label for removing favorite in detail view.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get detail_remove_favorite;

  /// Label for adding favorite in detail view.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get detail_add_favorite;

  /// Label for ISO currency code in detail view.
  ///
  /// In en, this message translates to:
  /// **'ISO Code'**
  String get detail_iso_code;

  /// Label for currency name in detail view.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get detail_name;

  /// Label for currency symbol in detail view.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get detail_symbol;

  /// Label for regions where currency is used.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get detail_regions;

  /// Label for currency description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detail_description;

  /// Label for convert button in detail view.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get detail_convert;

  /// Title for update available dialog.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get update_available;

  /// Label for cancel button in update dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get update_cancel;

  /// Label for download button in update dialog.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get update_download;

  /// Body text for the update download confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available.\n\nDownload {assetName} from GitHub releases for this device?'**
  String update_download_prompt(String version, String assetName);

  /// Message shown when the app cannot determine the latest stable release version.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine the latest stable release from GitHub.'**
  String get update_latest_release_unavailable;

  /// Message shown when no matching release asset exists for the current device.
  ///
  /// In en, this message translates to:
  /// **'No release asset was found for this device on GitHub releases.'**
  String get update_asset_not_found;

  /// Message shown when opening the external release download URL fails.
  ///
  /// In en, this message translates to:
  /// **'Could not open the GitHub release download link.'**
  String get update_open_download_failed;

  /// Message shown when the device type is unsupported for direct release downloads.
  ///
  /// In en, this message translates to:
  /// **'This device does not support direct release downloads.'**
  String get update_direct_download_unsupported;

  /// Message indicating app is up to date.
  ///
  /// In en, this message translates to:
  /// **'You are on the latest version'**
  String get update_latest;

  /// Message shown when the app is already on the latest version.
  ///
  /// In en, this message translates to:
  /// **'You are on the latest version ({version}).'**
  String settings_latest_version(String version);

  /// Message shown while refreshing exchange rates.
  ///
  /// In en, this message translates to:
  /// **'Refreshing rates...'**
  String get rate_info_refreshing;

  /// Label indicating the rate is from cache.
  ///
  /// In en, this message translates to:
  /// **'cached'**
  String get rate_info_cached;

  /// Label indicating the rate is live.
  ///
  /// In en, this message translates to:
  /// **'live'**
  String get rate_info_live;

  /// Label prefix for the rate source.
  ///
  /// In en, this message translates to:
  /// **'Source:'**
  String get rate_info_source_prefix;

  /// Name of the Frankfurter exchange rate provider.
  ///
  /// In en, this message translates to:
  /// **'Frankfurter'**
  String get provider_frankfurter;

  /// Name of the Exchange API provider.
  ///
  /// In en, this message translates to:
  /// **'Exchange API'**
  String get provider_exchange_api;

  /// Disclaimer about exchange rate accuracy.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates are for reference only.'**
  String get rate_info_disclaimer;

  /// Error message when network is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Network error — unable to reach the server. Please check your internet connection and try again.'**
  String get error_network_unavailable;

  /// Error message when service is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the remote service right now. Please try again later.'**
  String get error_service_unavailable;

  /// Generic error message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_generic;

  /// Label used in the UI for the pick control (e.g. dropdown header).
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pick;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
