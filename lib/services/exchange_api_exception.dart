class ExchangeApiException implements Exception {
  final String message;

  ExchangeApiException(this.message);

  @override
  String toString() => 'ExchangeApiException: $message';
}
