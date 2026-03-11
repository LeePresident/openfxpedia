import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/currency.dart';
import '../providers/app_state.dart';
import '../widgets/amount_input.dart';
import '../widgets/rate_info.dart';
import '../widgets/favorites_bar.dart';
import '../widgets/search_bar.dart' as app_search;
import '../widgets/theme_mode_button.dart';

enum _FavoriteFieldChoice { from, to }

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  Future<void> _showFavoriteChoiceDialog(
    BuildContext context,
    AppState state,
    Currency currency,
  ) async {
    final choice = await showDialog<_FavoriteFieldChoice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Use ${currency.isoCode} in converter'),
          content:
              const Text('Which field should be filled with this currency?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _FavoriteFieldChoice.to,
              ),
              child: const Text('To'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _FavoriteFieldChoice.from,
              ),
              child: const Text('From'),
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
        final isLoading = state.loadingState == LoadingState.loading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Currency Converter'),
            actions: [
              ThemeModeButton(
                themeMode: state.themeMode,
                onSelected: state.setThemeMode,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh rates',
                onPressed: isLoading ? null : state.refreshRates,
              ),
            ],
          ),
          body: state.currencies.isEmpty
              ? Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(state.errorMessage ?? 'Loading currencies…'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Favorites quick-select
                      if (state.favoriteCurrencies.isNotEmpty) ...[
                        Text(
                          'Favorites',
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

                      // Base currency selector
                      Text(
                        'From',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      app_search.CurrencySearchBar(
                        currencies: state.currencies,
                        selectedCurrency: state.baseCurrency,
                        hint: 'From currency…',
                        onSelected: state.setBaseCurrency,
                      ),
                      const SizedBox(height: 8),

                      // Amount input
                      AmountInput(
                        initialValue: state.inputAmount,
                        onChanged: state.setInputAmount,
                      ),
                      const SizedBox(height: 8),

                      // Swap button
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.swap_vert),
                          iconSize: 32,
                          tooltip: 'Swap currencies',
                          onPressed: state.baseCurrency == null ||
                                  state.targetCurrency == null
                              ? null
                              : state.swapCurrencies,
                        ),
                      ),

                      // Target currency selector
                      Text(
                        'To',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      app_search.CurrencySearchBar(
                        currencies: state.currencies,
                        selectedCurrency: state.targetCurrency,
                        hint: 'To currency…',
                        onSelected: state.setTargetCurrency,
                      ),
                      const SizedBox(height: 16),

                      // Result
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (state.errorMessage != null)
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber,
                                        color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.errorMessage!,
                                        style: const TextStyle(
                                            color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                )
                              else if (state.baseCurrency == null ||
                                  state.targetCurrency == null)
                                const Text(
                                  'Choose a from and to currency to begin converting.',
                                )
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
