import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/calculator_entry.dart';
import '../models/currency.dart';
import '../providers/app_state.dart';
import '../widgets/amount_input.dart';
import '../widgets/rate_info.dart';
import '../widgets/search_bar.dart' as app_search;

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  Future<void> _selectDate(BuildContext context, AppState state) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: state.calculatorDate ?? today,
      firstDate: DateTime(1948),
      lastDate: today,
      helpText: AppLocalizations.of(context).calculator_date,
    );
    if (date != null && context.mounted) {
      await state.setCalculatorDate(date);
    }
  }

  Currency? _currencyFor(AppState state, String code) {
    for (final currency in state.currencies) {
      if (currency.isoCode.toLowerCase() == code.toLowerCase()) {
        return currency;
      }
    }
    return null;
  }

  String _errorFor(AppLocalizations l10n, String? code) {
    switch (code) {
      case 'error_network_unavailable':
        return l10n.error_network_unavailable;
      case 'error_service_unavailable':
        return l10n.error_service_unavailable;
      default:
        return l10n.error_generic;
    }
  }

  int _decimalDigits(Currency currency) {
    final minorUnits = currency.minorUnitsPerMajor;
    if (minorUnits == null || minorUnits <= 0) return 2;
    var value = minorUnits;
    var digits = 0;
    while (value > 1 && value % 10 == 0) {
      value ~/= 10;
      digits++;
    }
    return value == 1 ? digits : 2;
  }

  String _formatAmount(
      AppLocalizations l10n, Currency currency, double amount) {
    return NumberFormat.currency(
      locale: l10n.localeName,
      name: currency.isoCode,
      symbol: currency.symbol ?? currency.isoCode,
      decimalDigits: _decimalDigits(currency),
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final l10n = AppLocalizations.of(context);
        final outputCurrency = state.calculatorOutputCurrency;
        final dateLabel = state.calculatorDate == null
            ? l10n.calculator_latest
            : DateFormat.yMMMd(l10n.localeName).format(state.calculatorDate!);

        if (state.currencies.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.calculator_title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.calculator_title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
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
                              l10n.calculator_result_currency,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            app_search.CurrencySearchBar(
                              key: const ValueKey('calculator-output-currency'),
                              currencies: state.currencies,
                              selectedCurrency: outputCurrency,
                              hint: l10n.calculator_result_currency,
                              onSelected: state.setCalculatorOutputCurrency,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _selectDate(context, state),
                                  icon: const Icon(Icons.calendar_today),
                                  label: Text(dateLabel),
                                ),
                                if (state.calculatorDate != null)
                                  TextButton.icon(
                                    onPressed: () =>
                                        state.setCalculatorDate(null),
                                    icon: const Icon(Icons.update),
                                    label: Text(l10n.calculator_use_latest),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.calculatorEntries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(l10n.calculator_no_entries),
                        ),
                      )
                    else
                      for (var index = 0;
                          index < state.calculatorEntries.length;
                          index++)
                        _entryCard(
                          context,
                          state,
                          l10n,
                          state.calculatorEntries[index],
                          index,
                          outputCurrency,
                        ),
                    OutlinedButton.icon(
                      onPressed: state.addCalculatorEntry,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.calculator_add_entry),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.calculator_total,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            if (state.calculatorLoading)
                              const LinearProgressIndicator(),
                            if (state.calculatorErrorCode != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _errorFor(l10n, state.calculatorErrorCode),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ] else if (state.calculatorTotal != null &&
                                outputCurrency != null) ...[
                              Text(
                                _formatAmount(
                                  l10n,
                                  outputCurrency,
                                  state.calculatorTotal!,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _entryCard(
    BuildContext context,
    AppState state,
    AppLocalizations l10n,
    CalculatorEntry entry,
    int index,
    Currency? outputCurrency,
  ) {
    final currency = _currencyFor(state, entry.currencyCode);
    final result = state.calculatorLineResults[entry.id];
    return Card(
      key: ValueKey('calculator-entry-${entry.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.calculator_entry(index + 1),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: l10n.calculator_remove_entry,
                  onPressed: () => state.removeCalculatorEntry(entry.id),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            AmountInput(
              key: ValueKey('calculator-amount-${entry.id}'),
              initialValue: entry.amount,
              label: l10n.calculator_amount,
              onChanged: (amount) =>
                  state.setCalculatorEntryAmount(entry.id, amount),
            ),
            const SizedBox(height: 8),
            app_search.CurrencySearchBar(
              key: ValueKey('calculator-currency-${entry.id}'),
              currencies: state.currencies,
              selectedCurrency: currency,
              hint: l10n.calculator_currency,
              onSelected: (selected) =>
                  state.setCalculatorEntryCurrency(entry.id, selected),
            ),
            if (result != null && outputCurrency != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatAmount(l10n, outputCurrency, result.amount),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              RateInfoWidget(
                rate: result.rate,
                fromCache: result.fromCache,
                requestedDate: state.calculatorDate,
              ),
            ] else if (state.calculatorLoading && entry.amount > 0) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
