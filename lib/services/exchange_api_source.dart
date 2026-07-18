enum ExchangeApiSource {
  auto,
  frankfurter,
  exchangeApi,
}

extension ExchangeApiSourceStorage on ExchangeApiSource {
  String get storageValue {
    switch (this) {
      case ExchangeApiSource.auto:
        return 'auto';
      case ExchangeApiSource.frankfurter:
        return 'frankfurter';
      case ExchangeApiSource.exchangeApi:
        return 'exchange_api';
    }
  }

  static ExchangeApiSource fromStorage(String? value) {
    switch (value) {
      case 'frankfurter':
        return ExchangeApiSource.frankfurter;
      case 'exchange_api':
        return ExchangeApiSource.exchangeApi;
      default:
        return ExchangeApiSource.auto;
    }
  }
}
