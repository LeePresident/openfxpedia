import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/services/error_classifier.dart';
import 'package:openfxpedia/services/exchange_api_exception.dart';
import 'package:openfxpedia/services/exchange_observability.dart';
import 'package:openfxpedia/services/update_service.dart';

void main() {
  group('ErrorClassifier', () {
    test(
      'classifies transport and API failures without preserving details',
      () {
        expect(
          ErrorClassifier.codeFor(Exception('SocketException: secret.host')),
          'network',
        );
        expect(
          ErrorClassifier.codeFor(Exception('OS Error: errno = 101')),
          'network',
        );
        expect(
          ErrorClassifier.codeFor(Exception('request timed out')),
          'timeout',
        );
        expect(
          ErrorClassifier.codeFor(
            ExchangeApiException('HTTP 503 fetching https://private.example'),
          ),
          'http_503',
        );
      },
    );

    test('classifies known remote services consistently', () {
      expect(
        ErrorClassifier.codeFor(
          Exception('Could not fetch https://api.github.com/releases'),
        ),
        'service_unavailable',
      );
      expect(
        ErrorClassifier.codeFor(
          Exception('Could not fetch https://currency-api.example/rates'),
        ),
        'service_unavailable',
      );
    });

    test('classifies update verification failures by failure type', () {
      expect(
        ErrorClassifier.codeFor(
          const UpdateVerificationException(
            'Downloaded update failed integrity verification',
          ),
        ),
        'update_integrity',
      );
      expect(
        ErrorClassifier.codeFor(
          const UpdateVerificationException('Update download failed (503)'),
        ),
        'update_download',
      );
      expect(
        ErrorClassifier.codeFor(
          const UpdateVerificationException('Invalid update artifact'),
        ),
        'update_verification',
      );
    });

    test('observability stores only a stable failure code', () {
      ExchangeObservability.clear();
      ExchangeObservability.recordAttempt(
        source: 'frankfurter',
        status: 'failed',
        base: 'usd',
        failureReason: 'SocketException: https://secret.example/token',
      );

      final event = ExchangeObservability.events.single;
      expect(event['failure_code'], 'network');
      expect(event.containsKey('failure_reason'), isFalse);
      expect(event.toString(), isNot(contains('secret.example')));
    });
  });
}
