import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/currency.dart';
import '../providers/app_state.dart';
import '../services/exchange_api_source.dart';
import '../widgets/amount_input.dart';
import '../widgets/rate_info.dart';
import '../widgets/rate_history_chart.dart';
import '../widgets/favorites_bar.dart';
import '../widgets/search_bar.dart' as app_search;

enum _FavoriteFieldChoice { from, to }

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  String _localizedErrorForCode(AppLocalizations l10n, String code) {
    switch (code) {
      case 'error_network_unavailable':
        return l10n.error_network_unavailable;
      case 'error_service_unavailable':
        return l10n.error_service_unavailable;
      case 'error_historical_unavailable':
        return l10n.error_historical_unavailable;
      default:
        return l10n.error_generic;
    }
  }

  String _providerLabelFor(AppState state, AppLocalizations l10n) {
    final providerSrc = state.lastRate?.source;
    if (providerSrc != null) {
      final source = providerSrc.toLowerCase();
      if (source.contains('frank')) {
        return l10n.provider_frankfurter;
      }

      return l10n.provider_exchange_api;
    }

    switch (state.exchangeApiSource) {
      case ExchangeApiSource.exchangeApi:
        return l10n.provider_exchange_api;
      case ExchangeApiSource.frankfurter:
        return l10n.provider_frankfurter;
      case ExchangeApiSource.auto:
        return state.rateFromCache
            ? l10n.provider_exchange_api
            : l10n.provider_frankfurter;
    }
  }

  Future<void> _showFavoriteChoiceDialog(
    BuildContext context,
    AppState state,
    Currency currency,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<_FavoriteFieldChoice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${l10n.converter_currency_title}: ${currency.name}'),
          content: Text(l10n.converter_currency_prompt),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.converter_cancel),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _FavoriteFieldChoice.to,
              ),
              child: Text(l10n.converter_to_field),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _FavoriteFieldChoice.from,
              ),
              child: Text(l10n.converter_from_field),
            ),
          ],
        );
      },
    );

    if (choice == null || !context.mounted) return;

    switch (choice) {
      case _FavoriteFieldChoice.from:
        state.setBaseCurrency(currency);
        break;
      case _FavoriteFieldChoice.to:
        state.setTargetCurrency(currency);
        break;
    }
  }

  Future<void> _selectDate(BuildContext context, AppState state) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: state.conversionDate ?? today,
      firstDate: DateTime(1948),
      lastDate: today,
      helpText: AppLocalizations.of(context).converter_date,
    );
    if (date != null && context.mounted) {
      await state.setConversionDate(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final l10n = AppLocalizations.of(context);
        final isLoading = state.loadingState == LoadingState.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.converter_currency_title),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.converter_refresh_rates,
                onPressed: isLoading ? null : state.refreshRates,
              ),
            ],
          ),
          body: state.currencies.isEmpty
              ? Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(state.errorCode != null
                          ? _localizedErrorForCode(l10n, state.errorCode!)
                          : l10n.startup_loading),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.favoriteCurrencies.isNotEmpty) ...[
                        Text(
                          l10n.converter_favorites,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        FavoritesBar(
                          favorites: state.favoriteCurrencies,
                          onTap: (currency) => _showFavoriteChoiceDialog(
                              context, state, currency),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        l10n.converter_from,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      app_search.CurrencySearchBar(
                        currencies: state.currencies,
                        selectedCurrency: state.baseCurrency,
                        hint: l10n.converter_from_hint,
                        onSelected: state.setBaseCurrency,
                      ),
                      const SizedBox(height: 8),
                      AmountInput(
                        initialValue: state.inputAmount,
                        label: l10n.amount_label,
                        onChanged: state.setInputAmount,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.swap_vert),
                          iconSize: 32,
                          tooltip: l10n.converter_swap,
                          onPressed: state.baseCurrency == null ||
                                  state.targetCurrency == null
                              ? null
                              : state.swapCurrencies,
                        ),
                      ),
                      Text(
                        l10n.converter_to,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      app_search.CurrencySearchBar(
                        currencies: state.currencies,
                        selectedCurrency: state.targetCurrency,
                        hint: l10n.converter_to_hint,
                        onSelected: state.setTargetCurrency,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            key: const Key('conversion-date'),
                            onPressed: () => _selectDate(context, state),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                                '${l10n.converter_date}: ${state.conversionDate == null ? l10n.converter_latest : DateFormat.yMMMd(l10n.localeName).format(state.conversionDate!)}'),
                          ),
                          if (state.conversionDate != null)
                            TextButton.icon(
                              key: const Key('conversion-use-latest'),
                              onPressed: () => state.setConversionDate(null),
                              icon: const Icon(Icons.update),
                              label: Text(l10n.converter_use_latest),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (state.errorCode != null ||
                                  state.errorMessage != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            // Prefer localized message via errorCode when available
                                            state.errorCode != null
                                                ? _localizedErrorForCode(
                                                    AppLocalizations.of(
                                                        context),
                                                    state.errorCode!,
                                                  )
                                                : (state.errorMessage ?? ''),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                          ),
                                          // Technical details intentionally hidden from users.
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else if (state.baseCurrency == null ||
                                  state.targetCurrency == null)
                                Text(l10n.converter_choose_pair)
                              else
                                Text(
                                  state.convertedAmount != null
                                      ? '${state.convertedAmount} '
                                          '${state.targetCurrency?.isoCode ?? ''}'
                                      : '—',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              const SizedBox(height: 8),
                              RateInfoWidget(
                                rate: state.lastRate,
                                fromCache: state.rateFromCache,
                                isLoading: isLoading,
                                requestedDate: state.conversionDate,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.rate_info_disclaimer,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              // Localized source label under the disclaimer.
                              if (state.lastRate != null)
                                Builder(builder: (ctx) {
                                  final providerLabel =
                                      _providerLabelFor(state, l10n);

                                  return Text(
                                    '${l10n.rate_info_source_prefix} $providerLabel',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                        ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RateHistoryChart(state: state),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
