import '../services/conversion_service.dart';
import '../services/exchange_api_source.dart';
import '../services/rate_history_service.dart';

class RateHistoryState {
  RateHistoryState({
    required ConversionService conversionService,
    required void Function() onChanged,
  }) : _service = RateHistoryService(conversionService),
       _onChanged = onChanged;

  final RateHistoryService _service;
  final void Function() _onChanged;

  bool _visible = false;
  bool _loading = false;
  int _days = 30;
  int _requestSequence = 0;
  String? _key;
  List<RateHistorySample> _samples = [];

  bool get visible => _visible;
  bool get loading => _loading;
  int get days => _days;
  List<RateHistorySample> get samples => List.unmodifiable(_samples);

  void setVisible(bool visible) {
    _visible = visible;
    if (!visible) {
      cancelPending();
      _key = null;
      _loading = false;
    }
    _onChanged();
  }

  bool setDays(int days) {
    if (![7, 30, 90].contains(days)) throw ArgumentError.value(days, 'days');
    if (_days == days) return false;
    _days = days;
    return true;
  }

  Future<void> load({
    required String base,
    required String target,
    required DateTime endDate,
    required ExchangeApiSource source,
    bool forceRefresh = false,
  }) async {
    if (!_visible) return;
    final date = DateTime(endDate.year, endDate.month, endDate.day);
    final key = '$base:$target:$date:$_days:$source';
    if (!forceRefresh && key == _key) return;
    _key = key;
    final requestId = ++_requestSequence;
    _samples = [];
    _loading = true;
    _onChanged();

    final samples = await _service.load(
      base: base,
      target: target,
      endDate: date,
      days: _days,
      forceRefresh: forceRefresh,
      isCancelled: () => requestId != _requestSequence,
    );
    if (requestId != _requestSequence) return;
    _samples = samples;
    _loading = false;
    _onChanged();
  }

  void reset() {
    cancelPending();
    _visible = false;
    _loading = false;
    _key = null;
    _samples = [];
  }

  void cancelPending() {
    _requestSequence++;
  }
}
