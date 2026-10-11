import 'dart:async';

import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../models/exchange_rate.dart';
import '../services/conversion_service.dart';
import '../services/error_classifier.dart';

enum LoadingState { idle, loading, error }

class ConverterState {
  ConverterState({
    required ConversionService conversionService,
    required void Function() onChanged,
    required void Function() onHistoryRefresh,
  })  : _conversionService = conversionService,
        _onChanged = onChanged,
        _onHistoryRefresh = onHistoryRefresh;

  final ConversionService _conversionService;
  final void Function() _onChanged;
  final void Function() _onHistoryRefresh;

  int _requestSequence = 0;
  Currency? _baseCurrency;
  Currency? _targetCurrency;
  double _inputAmount = 1;
  DateTime? _conversionDate;
  double? _convertedAmount;
  ExchangeRate? _lastRate;
  bool _rateFromCache = false;
  LoadingState _loadingState = LoadingState.idle;
  String? _errorCode;

  Currency? get baseCurrency => _baseCurrency;
  Currency? get targetCurrency => _targetCurrency;
  double get inputAmount => _inputAmount;
  DateTime? get conversionDate => _conversionDate;
  double? get convertedAmount => _convertedAmount;
  ExchangeRate? get lastRate => _lastRate;
  bool get rateFromCache => _rateFromCache;
  LoadingState get loadingState => _loadingState;
  String? get errorCode => _errorCode;

  void setBaseCurrency(Currency currency) {
    _baseCurrency = currency;
    _onChanged();
    unawaited(convert());
  }

  void setBaseCurrencyAndAmount(Currency currency, double amount) {
    _baseCurrency = currency;
    _inputAmount = amount;
    _onChanged();
    unawaited(convert());
  }

  void setTargetCurrency(Currency currency) {
    _targetCurrency = currency;
    _onChanged();
    unawaited(convert());
  }

  void setCurrencyPair({
    required Currency baseCurrency,
    required Currency targetCurrency,
  }) {
    _baseCurrency = baseCurrency;
    _targetCurrency = targetCurrency;
    _onChanged();
    unawaited(convert());
  }

  void setInputAmount(double amount) {
    _inputAmount = amount;
    _onChanged();
    unawaited(convert());
  }

  void swapCurrencies() {
    final tmp = _baseCurrency;
    _baseCurrency = _targetCurrency;
    _targetCurrency = tmp;
    _onChanged();
    unawaited(convert());
  }

  Future<void> setConversionDate(DateTime? date) async {
    final normalized = date == null ? null : DateUtils.dateOnly(date);
    if (normalized != null &&
        normalized.isAfter(DateUtils.dateOnly(DateTime.now()))) {
      throw ArgumentError.value(date, 'date', 'Cannot select a future date');
    }
    if (_conversionDate == normalized) return;
    _conversionDate = normalized;
    await convert();
  }

  Future<void> convert({bool forceHistoricalRefresh = false}) async {
    final requestId = ++_requestSequence;
    _onHistoryRefresh();
    final requestedDate = _conversionDate;
    _convertedAmount = null;
    _lastRate = null;
    _rateFromCache = false;
    _errorCode = null;
    _loadingState = LoadingState.idle;
    if (_baseCurrency == null || _targetCurrency == null) {
      _onChanged();
      return;
    }
    if (_inputAmount <= 0) {
      _convertedAmount = 0;
      _onChanged();
      return;
    }

    setLoading();

    try {
      final result = requestedDate == null
          ? await _conversionService.convert(
              _inputAmount,
              _baseCurrency!.isoCode,
              _targetCurrency!.isoCode,
            )
          : await _conversionService.convertHistorical(
              _inputAmount,
              _baseCurrency!.isoCode,
              _targetCurrency!.isoCode,
              requestedDate,
              forceRefresh: forceHistoricalRefresh,
            );

      if (requestId != _requestSequence) return;

      _convertedAmount = result.amount;
      _lastRate = result.rate;
      _rateFromCache = result.fromCache;
      _errorCode = null;
      _loadingState = LoadingState.idle;
      _onChanged();
    } catch (error) {
      if (requestId != _requestSequence) return;
      setError(
        error,
        code: requestedDate == null ? null : 'error_historical_unavailable',
      );
    }
  }

  Future<void> refreshRates() async {
    if (_baseCurrency == null) return;
    if (_conversionDate != null) {
      await convert(forceHistoricalRefresh: true);
      return;
    }
    setLoading();

    final requestId = ++_requestSequence;

    try {
      await _conversionService.refreshRates(_baseCurrency!.isoCode);

      if (requestId != _requestSequence) return;

      setIdle();
      await convert();
    } catch (error) {
      if (requestId != _requestSequence) return;
      setError(error);
    }
  }

  void updateCurrencies(List<Currency> currencies) {
    if (currencies.isEmpty) return;
    final oldBaseIso = _baseCurrency?.isoCode;
    final oldTargetIso = _targetCurrency?.isoCode;

    if (oldBaseIso != null) {
      _baseCurrency = currencies.firstWhere(
        (currency) =>
            currency.isoCode.toLowerCase() == oldBaseIso.toLowerCase(),
        orElse: () => _baseCurrency ?? currencies.first,
      );
    }

    if (oldTargetIso != null) {
      _targetCurrency = currencies.firstWhere(
        (currency) =>
            currency.isoCode.toLowerCase() == oldTargetIso.toLowerCase(),
        orElse: () =>
            _targetCurrency ??
            (currencies.length > 1
                ? currencies.firstWhere(
                    (currency) =>
                        currency.isoCode.toLowerCase() !=
                        oldBaseIso?.toLowerCase(),
                    orElse: () => currencies.first,
                  )
                : currencies.first),
      );
    }
  }

  void setLoading() {
    _loadingState = LoadingState.loading;
    _errorCode = null;
    _onChanged();
  }

  void setIdle() {
    _loadingState = LoadingState.idle;
    _onChanged();
  }

  void setError(Object error, {String? code}) {
    debugPrint('Error code: ${ErrorClassifier.codeFor(error)}');
    _loadingState = LoadingState.error;
    _errorCode = code ?? ErrorClassifier.codeFor(error);
    _onChanged();
  }

  void reset() {
    _baseCurrency = null;
    _targetCurrency = null;
    _inputAmount = 0;
    _conversionDate = null;
    _convertedAmount = null;
    _lastRate = null;
    _rateFromCache = false;
    _errorCode = null;
  }

  void cancelPending() {
    _requestSequence++;
  }
}
