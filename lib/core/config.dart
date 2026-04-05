class AppConfig {
  AppConfig._();

  static const String currencyListUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json';

  static const String exchangeApiBase =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies';

  static const String exchangeApiFallbackBase =
      'https://latest.currency-api.pages.dev/v1/currencies';

  static const String githubRepoOwner = 'LeePresident';
  static const String githubRepoName = 'openfxpedia';
  static const String githubTagsApiUrl =
      'https://api.github.com/repos/$githubRepoOwner/$githubRepoName/tags';
  static const String githubReleasesApiUrl =
      'https://api.github.com/repos/$githubRepoOwner/$githubRepoName/releases?per_page=10';

  static const int rateTtlHours = 12;
  static const int catalogTtlHours = 24;

  static const String ratesBoxName = 'rates';
  static const String currenciesBoxName = 'currencies';
  static const String prefsBoxName = 'prefs';

  static const String favoritesKey = 'favorites';
  static const String defaultBaseCurrencyKey = 'default_base';
  static const String defaultTargetCurrencyKey = 'default_target';
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';

  static const String defaultBaseCurrency = 'usd';
  static const String defaultTargetCurrency = 'eur';
}
