import 'exchange_api_exception.dart';
import 'update_service.dart';

class ErrorClassifier {
  const ErrorClassifier._();

  static String codeFor(Object error) {
    final suppliedCode = error.toString().toLowerCase();
    if (RegExp(
      r'^(network|timeout|invalid_response|unknown|missing_rate|exchange_api|update_integrity|update_download|update_verification|http_\d{3})$',
    ).hasMatch(suppliedCode)) {
      return suppliedCode;
    }

    if (error is UpdateVerificationException) {
      final message = error.message.toLowerCase();
      if (message.contains('integrity')) return 'update_integrity';
      if (message.contains('download')) return 'update_download';
      return 'update_verification';
    }

    if (error is ExchangeApiException) {
      final message = error.message.toLowerCase();
      final httpCode = RegExp(r'\b(4\d{2}|5\d{2})\b').firstMatch(message);
      if (httpCode != null) return 'http_${httpCode.group(1)}';
      if (message.contains('no rate found') ||
          message.contains('missing rate')) {
        return 'missing_rate';
      }
      return 'exchange_api';
    }

    final message = suppliedCode;
    if (message.contains('timeout') || message.contains('timed out')) {
      return 'timeout';
    }
    if (message.contains('missing rate') || message.contains('no rate found')) {
      return 'missing_rate';
    }
    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused') ||
        message.contains('connection reset')) {
      return 'network';
    }
    if (message.contains('format') || message.contains('json')) {
      return 'invalid_response';
    }
    return 'unknown';
  }
}
