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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenFXpedia'**
  String get appTitle;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_simplified_chinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get language_simplified_chinese;

  /// No description provided for @language_traditional_chinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get language_traditional_chinese;

  /// No description provided for @converter_title.
  ///
  /// In en, this message translates to:
  /// **'Converter'**
  String get converter_title;

  /// No description provided for @encyclopedia_title.
  ///
  /// In en, this message translates to:
  /// **'Encyclopedia'**
  String get encyclopedia_title;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_app_version.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settings_app_version;

  /// No description provided for @settings_check_updates.
  ///
  /// In en, this message translates to:
  /// **'Check updates'**
  String get settings_check_updates;

  /// No description provided for @settings_changelogs.
  ///
  /// In en, this message translates to:
  /// **'Changelogs'**
  String get settings_changelogs;

  /// No description provided for @settings_changelogs_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View concise changelogs for all versions'**
  String get settings_changelogs_subtitle;

  /// No description provided for @settings_license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get settings_license;

  /// No description provided for @settings_select_theme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get settings_select_theme;

  /// No description provided for @settings_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_system;

  /// No description provided for @settings_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_light;

  /// No description provided for @settings_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_dark;

  /// No description provided for @settings_language_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settings_language_dialog_title;

  /// No description provided for @settings_language_dialog_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language.'**
  String get settings_language_dialog_subtitle;

  /// No description provided for @converter_currency_title.
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get converter_currency_title;

  /// No description provided for @converter_refresh_rates.
  ///
  /// In en, this message translates to:
  /// **'Refresh rates'**
  String get converter_refresh_rates;

  /// No description provided for @converter_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get converter_favorites;

  /// No description provided for @converter_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get converter_from;

  /// No description provided for @converter_to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get converter_to;

  /// No description provided for @converter_from_hint.
  ///
  /// In en, this message translates to:
  /// **'From currency...'**
  String get converter_from_hint;

  /// No description provided for @converter_to_hint.
  ///
  /// In en, this message translates to:
  /// **'To currency...'**
  String get converter_to_hint;

  /// No description provided for @converter_swap.
  ///
  /// In en, this message translates to:
  /// **'Swap currencies'**
  String get converter_swap;

  /// No description provided for @converter_choose_pair.
  ///
  /// In en, this message translates to:
  /// **'Choose a from and to currency to begin converting.'**
  String get converter_choose_pair;

  /// No description provided for @converter_choose_currencies.
  ///
  /// In en, this message translates to:
  /// **'Choose your currencies'**
  String get converter_choose_currencies;

  /// No description provided for @converter_currency_prompt.
  ///
  /// In en, this message translates to:
  /// **'Which field should be filled with this currency?'**
  String get converter_currency_prompt;

  /// No description provided for @converter_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get converter_cancel;

  /// No description provided for @converter_from_field.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get converter_from_field;

  /// No description provided for @converter_to_field.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get converter_to_field;

  /// No description provided for @converter_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get converter_continue;

  /// No description provided for @amount_label.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount_label;

  /// No description provided for @encyclopedia_currency_title.
  ///
  /// In en, this message translates to:
  /// **'Currency Encyclopedia'**
  String get encyclopedia_currency_title;

  /// No description provided for @encyclopedia_search.
  ///
  /// In en, this message translates to:
  /// **'Search currencies...'**
  String get encyclopedia_search;

  /// No description provided for @encyclopedia_not_found.
  ///
  /// In en, this message translates to:
  /// **'No currencies found.'**
  String get encyclopedia_not_found;

  /// No description provided for @favorites_add.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favorites_add;

  /// No description provided for @favorites_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favorites_remove;

  /// No description provided for @detail_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get detail_cancel;

  /// No description provided for @detail_from_field.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get detail_from_field;

  /// No description provided for @detail_to_field.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get detail_to_field;

  /// No description provided for @detail_currency_prompt.
  ///
  /// In en, this message translates to:
  /// **'Which field should be filled with this currency?'**
  String get detail_currency_prompt;

  /// No description provided for @detail_remove_favorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get detail_remove_favorite;

  /// No description provided for @detail_add_favorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get detail_add_favorite;

  /// No description provided for @detail_iso_code.
  ///
  /// In en, this message translates to:
  /// **'ISO Code'**
  String get detail_iso_code;

  /// No description provided for @detail_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get detail_name;

  /// No description provided for @detail_symbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get detail_symbol;

  /// No description provided for @detail_regions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get detail_regions;

  /// No description provided for @detail_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detail_description;

  /// No description provided for @detail_convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get detail_convert;

  /// No description provided for @update_available.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get update_available;

  /// No description provided for @update_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get update_cancel;

  /// No description provided for @update_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get update_download;

  /// No description provided for @update_latest.
  ///
  /// In en, this message translates to:
  /// **'You are on the latest version'**
  String get update_latest;

  /// Message shown when the app is already on the latest version.
  ///
  /// In en, this message translates to:
  /// **'You are on the latest version ({version}).'**
  String settings_latest_version(String version);

  /// No description provided for @rate_info_refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing rates...'**
  String get rate_info_refreshing;

  /// No description provided for @rate_info_cached.
  ///
  /// In en, this message translates to:
  /// **'cached'**
  String get rate_info_cached;

  /// No description provided for @rate_info_live.
  ///
  /// In en, this message translates to:
  /// **'live'**
  String get rate_info_live;

  /// No description provided for @rate_info_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates are for reference only.'**
  String get rate_info_disclaimer;

  /// No description provided for @error_network_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Network error — unable to reach the server. Please check your internet connection and try again.'**
  String get error_network_unavailable;

  /// No description provided for @error_service_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the remote service right now. Please try again later.'**
  String get error_service_unavailable;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_generic;
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
