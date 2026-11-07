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
    final samples = List<RateHistorySample?>.filled(count, null);
    var nextIndex = 0;

    Future<void> loadSamples() async {
      while (!(isCancelled?.call() ?? false)) {
        final index = nextIndex++;
        if (index >= count) return;
        final date = start.add(
          Duration(days: (index * (days - 1) / (count - 1)).round()),
        );
        samples[index] = await _loadSample(
          base: base,
          target: target,
          date: date,
          start: start,
          forceRefresh: forceRefresh,
        );
      }
    }

    final workerCount = count < 3 ? count : 3;
    await Future.wait(List.generate(workerCount, (_) => loadSamples()));
    return samples.whereType<RateHistorySample>().toList(growable: false);
  }

  Future<RateHistorySample> _loadSample({
    required String base,
    required String target,
    required DateTime date,
    required DateTime start,
    required bool forceRefresh,
  }) async {
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
    return RateHistorySample(date, quote);
  }
}
