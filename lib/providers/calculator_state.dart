import 'dart:async';

import '../models/calculator_entry.dart';
import '../models/currency.dart';
import '../services/conversion_service.dart';
import '../services/error_classifier.dart';

class CalculatorState {
  CalculatorState({
    required ConversionService conversionService,
    required List<Currency> Function() currencies,
    required void Function() onChanged,
  }) : _conversionService = conversionService,
       _currencies = currencies,
       _onChanged = onChanged;

  final ConversionService _conversionService;
  final List<Currency> Function() _currencies;
  final void Function() _onChanged;
  final List<CalculatorEntry> _entries = [];
  final Map<int, ConversionResult> _lineResults = {};

  int _requestSequence = 0;
  int _nextEntryId = 0;
  String? _outputCurrencyCode;
  DateTime? _date;
  double? _total;
  bool _loading = false;
  String? _errorCode;

  List<CalculatorEntry> get entries => List.unmodifiable(_entries);
  String? get outputCurrencyCode => _outputCurrencyCode;
  Currency? get outputCurrency => _currencyForCode(_outputCurrencyCode);
  DateTime? get date => _date;
  double? get total => _total;
  Map<int, ConversionResult> get lineResults => Map.unmodifiable(_lineResults);
  bool get loading => _loading;
  String? get errorCode => _errorCode;

  void initialize({
    required Currency? baseCurrency,
    required Currency? targetCurrency,
  }) {
    final currencies = _currencies();
    if (currencies.isEmpty) return;
    _outputCurrencyCode ??= targetCurrency?.isoCode ?? currencies.first.isoCode;
    if (_entries.isEmpty) {
      _entries.add(
        CalculatorEntry(
          id: _nextEntryId++,
          amount: 0,
          currencyCode: baseCurrency?.isoCode ?? currencies.first.isoCode,
        ),
      );
    }
  }

  void addEntry() {
    final currencyCode =
        _outputCurrencyCode ??
        (_currencies().isEmpty ? null : _currencies().first.isoCode);
    if (currencyCode == null) return;
    _entries.add(
      CalculatorEntry(
        id: _nextEntryId++,
        amount: 0,
        currencyCode: currencyCode,
      ),
    );
    unawaited(calculate());
  }

  void removeEntry(int id) {
    _entries.removeWhere((entry) => entry.id == id);
    unawaited(calculate());
  }

  void setEntryAmount(int id, double amount) {
    if (!amount.isFinite || amount < 0) return;
    _updateEntry(id, (entry) => entry.copyWith(amount: amount));
  }

  void setEntryCurrency(int id, Currency currency) {
    _updateEntry(id, (entry) => entry.copyWith(currencyCode: currency.isoCode));
  }

  void _updateEntry(int id, CalculatorEntry Function(CalculatorEntry) update) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index < 0) return;
    _entries[index] = update(_entries[index]);
    unawaited(calculate());
  }

  void setOutputCurrency(Currency currency) {
    if (_outputCurrencyCode == currency.isoCode) return;
    _outputCurrencyCode = currency.isoCode;
    unawaited(calculate());
  }

  Future<void> setDate(DateTime? date) async {
    final normalized = date == null
        ? null
        : DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    if (normalized != null &&
        normalized.isAfter(DateTime(today.year, today.month, today.day))) {
      throw ArgumentError.value(date, 'date', 'Cannot select a future date');
    }
    if (_date == normalized) return;
    _date = normalized;
    await calculate();
  }

  Future<void> calculate() async {
    final requestId = ++_requestSequence;
    final entries = List<CalculatorEntry>.of(_entries);
    final target = _outputCurrencyCode;
    if (entries.isEmpty || target == null) {
      _lineResults.clear();
      _total = null;
      _loading = false;
      _errorCode = null;
      _onChanged();
      return;
    }

    _lineResults.clear();
    _total = null;
    _loading = true;
    _errorCode = null;
    _onChanged();

    try {
      final results = await Future.wait(
        entries.map((entry) async {
          if (entry.amount == 0) return null;
          final date = _date;
          return date == null
              ? _conversionService.convertPrecise(
                  entry.amount,
                  entry.currencyCode,
                  target,
                )
              : _conversionService.convertHistoricalPrecise(
                  entry.amount,
                  entry.currencyCode,
                  target,
                  date,
                );
        }),
      );

      if (requestId != _requestSequence) return;
      var total = 0.0;
      for (var index = 0; index < entries.length; index++) {
        final result = results[index];
        if (result == null) continue;
        _lineResults[entries[index].id] = result;
        total += result.amount;
      }
      final outputCurrency = this.outputCurrency;
      _total = outputCurrency == null
          ? total
          : _roundToCurrency(total, outputCurrency);
      _loading = false;
      _errorCode = null;
      _onChanged();
    } catch (error) {
      if (requestId != _requestSequence) return;
      _loading = false;
      _total = null;
      _errorCode = ErrorClassifier.codeFor(error);
      _onChanged();
    }
  }

  void reset() {
    cancelPending();
    _entries.clear();
    _outputCurrencyCode = null;
    _date = null;
    _lineResults.clear();
    _total = null;
    _loading = false;
    _errorCode = null;
  }

  void cancelPending() {
    _requestSequence++;
  }

  Currency? _currencyForCode(String? code) {
    if (code == null) return null;
    for (final currency in _currencies()) {
      if (currency.isoCode.toLowerCase() == code.toLowerCase()) {
        return currency;
      }
    }
    return null;
  }

  double _roundToCurrency(double amount, Currency currency) {
    final minorUnits = currency.minorUnitsPerMajor;
    if (minorUnits == null || minorUnits <= 0) {
      return _roundToPlaces(amount, 2);
    }
    return (amount * minorUnits).roundToDouble() / minorUnits;
  }

  double _roundToPlaces(double amount, int places) {
    var factor = 1.0;
    for (var index = 0; index < places; index++) {
      factor *= 10;
    }
    return (amount * factor).roundToDouble() / factor;
  }
}
