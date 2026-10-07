import 'conversion_service.dart';

class RateHistorySample {
  const RateHistorySample(this.requestedDate, this.quote);

  final DateTime requestedDate;
  final ConversionResult? quote;
}

class RateHistoryService {
  RateHistoryService(this._conversion);

  final ConversionService _conversion;

  Future<List<RateHistorySample>> load({
    required String base,
    required String target,
    required DateTime endDate,
    required int days,
    bool forceRefresh = false,
    bool Function()? isCancelled,
  }) async {
    if (days < 2) throw ArgumentError.value(days, 'days');
    final end = DateTime.utc(endDate.year, endDate.month, endDate.day);
    final start = end.subtract(Duration(days: days - 1));
    final count = days < 8 ? days : 8;
    final samples = <RateHistorySample>[];
    for (var index = 0; index < count; index++) {
      if (isCancelled?.call() ?? false) break;
      final date = start.add(
        Duration(days: (index * (days - 1) / (count - 1)).round()),
      );
      ConversionResult? quote;
      try {
        final result = await _conversion.convertHistorical(
          1,
          base,
          target,
          date,
          forceRefresh: forceRefresh,
        );
        final timestamp = result.rate.timestamp;
        if (!timestamp.isBefore(start) &&
            !timestamp.isAfter(date) &&
            result.rate.rate.isFinite &&
            result.rate.rate > 0) {
          quote = result;
        }
      } catch (_) {
        quote = null;
      }
      samples.add(RateHistorySample(date, quote));
    }
    return samples;
  }
}
