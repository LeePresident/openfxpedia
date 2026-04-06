import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/currency.dart';
import '../providers/app_state.dart';
import '../widgets/amount_input.dart';
import '../widgets/rate_info.dart';
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
      default:
        return l10n.error_generic;
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
          title: Text('${l10n.converter_currency_title}: ${currency.isoCode}'),
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
                          : 'Loading currencies...'),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
