import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../models/currency.dart';
import '../providers/app_state.dart';
import '../services/conversion_service.dart';
import '../services/error_classifier.dart';
import '../widgets/search_bar.dart' as app_search;

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  String? _baseCode;
  final Set<String> _targetCodes = {};
  LatestRatesResult? _rates;
  String? _errorMessage;
  bool _loading = false;
  bool _initialized = false;
  int _requestSequence = 0;

  @override
  void dispose() {
    _requestSequence++;
    super.dispose();
  }

  void _initialize(AppState state) {
    if (_initialized || state.currencies.isEmpty) return;
    _initialized = true;
    _baseCode = state.baseCurrency?.isoCode ?? state.currencies.first.isoCode;

    final targetCode = state.targetCurrency?.isoCode;
    if (targetCode != null &&
        targetCode.toLowerCase() != _baseCode!.toLowerCase()) {
      _targetCodes.add(targetCode);
    }
    if (_targetCodes.isEmpty) {
      for (final currency in state.currencies) {
        if (currency.isoCode.toLowerCase() != _baseCode!.toLowerCase()) {
          _targetCodes.add(currency.isoCode);
          break;
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _baseCode != null) {
        _loadRates(state, _baseCode!);
      }
    });
  }

  Future<void> _loadRates(
    AppState state,
    String baseCode, {
    bool forceRefresh = false,
  }) async {
    final requestId = ++_requestSequence;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final rates = await state.loadComparisonRates(
        baseCode,
        forceRefresh: forceRefresh,
      );
      if (!mounted || requestId != _requestSequence) return;
      setState(() => _rates = rates);
    } catch (error) {
      if (!mounted || requestId != _requestSequence) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _rates = null;
        _errorMessage = localizedErrorMessage(
          l10n,
          ErrorClassifier.codeFor(error),
        );
      });
    } finally {
      if (mounted && requestId == _requestSequence) {
        setState(() => _loading = false);
      }
    }
  }

  Currency? _currencyFor(AppState state, String? code) {
    if (code == null) return null;
    for (final currency in state.currencies) {
      if (currency.isoCode.toLowerCase() == code.toLowerCase()) {
        return currency;
      }
    }
    return null;
  }

  Future<void> _selectComparisonCurrencies(
    BuildContext context,
    AppState state,
  ) async {
    final baseCode = _baseCode;
    if (baseCode == null) return;
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _ComparisonCurrencyDialog(
        currencies: state.currencies,
        baseCode: baseCode,
        selectedCodes: _targetCodes,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _targetCodes
        ..clear()
        ..addAll(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final l10n = AppLocalizations.of(context);
        _initialize(state);
        final baseCurrency = _currencyFor(state, _baseCode);
        final dateLabel = _rates == null
            ? null
            : DateFormat.yMMMd(
                l10n.localeName,
              ).format(_rates!.timestamp.toLocal());
        final rateSource = _rates?.source.toLowerCase() ?? '';
        final sourceLabel = rateSource.contains('frank')
            ? l10n.provider_frankfurter
            : rateSource.contains('legacy') ||
                  rateSource.contains('exchangeapi') ||
                  rateSource.contains('exchange_api')
            ? l10n.provider_exchange_api
            : null;
        final displayedCurrencies =
            state.currencies
                .where((currency) => _targetCodes.contains(currency.isoCode))
                .toList()
              ..sort(
                (first, second) => first.isoCode.compareTo(second.isoCode),
              );
        final rateFormat = NumberFormat.decimalPattern(l10n.localeName)
          ..maximumFractionDigits = 8;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.comparison_title),
            actions: [
              IconButton(
                tooltip: l10n.converter_refresh_rates,
                onPressed: _loading || _baseCode == null
                    ? null
                    : () => _loadRates(state, _baseCode!, forceRefresh: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: state.currencies.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.comparison_base_currency,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              app_search.CurrencySearchBar(
                                key: const ValueKey('comparison-base-currency'),
                                currencies: state.currencies,
                                selectedCurrency: baseCurrency,
                                hint: l10n.comparison_base_currency,
                                onSelected: (currency) {
                                  final code = currency.isoCode;
                                  setState(() {
                                    _baseCode = code;
                                    _rates = null;
                                    _targetCodes.removeWhere(
                                      (target) =>
                                          target.toLowerCase() ==
                                          code.toLowerCase(),
                                    );
                                  });
                                  _loadRates(state, code);
                                },
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: OutlinedButton.icon(
                                  key: const Key(
                                    'comparison-select-currencies',
                                  ),
                                  onPressed: () => _selectComparisonCurrencies(
                                    context,
                                    state,
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    l10n.comparison_select_currencies,
                                  ),
                                ),
                              ),
                              if (_targetCodes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: _targetCodes.map((code) {
                                    final currency = _currencyFor(state, code);
                                    return InputChip(
                                      label: Text(
                                        currency == null
                                            ? code
                                            : '${currency.isoCode} — ${currency.name}',
                                      ),
                                      onDeleted: () {
                                        setState(
                                          () => _targetCodes.remove(code),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      if (_loading) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(),
                      ],
                      if (_rates != null) ...[
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _rates!.fromCache
                                          ? Icons.cloud_off
                                          : Icons.cloud_done,
                                      size: 16,
                                      color: _rates!.fromCache
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.secondary
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        [
                                          dateLabel!,
                                          _rates!.fromCache
                                              ? l10n.rate_info_cached
                                              : l10n.rate_info_live,
                                          if (sourceLabel != null)
                                            '${l10n.rate_info_source_prefix} $sourceLabel',
                                        ].join(' · '),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (displayedCurrencies.isEmpty)
                                  Text(l10n.comparison_empty)
                                else
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: [
                                        DataColumn(
                                          label: Text(l10n.comparison_currency),
                                        ),
                                        DataColumn(
                                          numeric: true,
                                          label: Text(
                                            l10n.comparison_rate_for_base(
                                              _baseCode!,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: displayedCurrencies.map((currency) {
                                        final rate =
                                            _rates!.rates[currency.isoCode
                                                .toLowerCase()];
                                        return DataRow(
                                          key: ValueKey(
                                            'comparison-row-${currency.isoCode}',
                                          ),
                                          cells: [
                                            DataCell(
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(currency.isoCode),
                                                  Text(
                                                    currency.name,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                rate == null
                                                    ? l10n.comparison_no_rate
                                                    : rateFormat.format(rate),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _ComparisonCurrencyDialog extends StatefulWidget {
  const _ComparisonCurrencyDialog({
    required this.currencies,
    required this.baseCode,
    required this.selectedCodes,
  });

  final List<Currency> currencies;
  final String baseCode;
  final Set<String> selectedCodes;

  @override
  State<_ComparisonCurrencyDialog> createState() =>
      _ComparisonCurrencyDialogState();
}

class _ComparisonCurrencyDialogState extends State<_ComparisonCurrencyDialog> {
  late final TextEditingController _controller;
  late final Set<String> _selectedCodes;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _selectedCodes = Set<String>.of(widget.selectedCodes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final visibleCurrencies = widget.currencies.where((currency) {
      if (currency.isoCode.toLowerCase() == widget.baseCode.toLowerCase()) {
        return false;
      }
      final normalizedQuery = _query.toLowerCase();
      return currency.isoCode.toLowerCase().contains(normalizedQuery) ||
          currency.name.toLowerCase().contains(normalizedQuery) ||
          (currency.isoNumeric?.contains(normalizedQuery) ?? false);
    }).toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: SizedBox(
        width: 420,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.comparison_choose_currencies,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('comparison_currency_search'),
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.comparison_choose_currencies,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.clear_search,
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: visibleCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = visibleCurrencies[index];
                    return CheckboxListTile(
                      key: ValueKey('comparison-currency-${currency.isoCode}'),
                      value: _selectedCodes.contains(currency.isoCode),
                      title: Text(currency.isoCode),
                      subtitle: Text(currency.name),
                      onChanged: (checked) {
                        setState(() {
                          if (checked ?? false) {
                            _selectedCodes.add(currency.isoCode);
                          } else {
                            _selectedCodes.remove(currency.isoCode);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.converter_cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, Set<String>.of(_selectedCodes)),
                    child: Text(l10n.comparison_done),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
