import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/currency.dart';
import '../providers/app_state.dart';
import '../widgets/theme_mode_button.dart';

enum _ConversionFieldChoice { from, to }

class CurrencyDetailScreen extends StatelessWidget {
  final Currency currency;

  const CurrencyDetailScreen({super.key, required this.currency});

  Future<void> _showConvertChoiceDialog(
    BuildContext context,
    AppState state,
  ) async {
    final choice = await showDialog<_ConversionFieldChoice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Use ${currency.isoCode} for conversion'),
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
                _ConversionFieldChoice.to,
              ),
              child: const Text('To'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _ConversionFieldChoice.from,
              ),
              child: const Text('From'),
            ),
          ],
        );
      },
    );

    if (choice == null || !context.mounted) return;

    switch (choice) {
      case _ConversionFieldChoice.from:
        state.setBaseCurrency(currency);
        break;
      case _ConversionFieldChoice.to:
        state.setTargetCurrency(currency);
        break;
    }

    state.setSelectedTab(0);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final isFav = state.isFavorite(currency.isoCode);

        return Scaffold(
          appBar: AppBar(
            title: Text(currency.isoCode),
            actions: [
              ThemeModeButton(
                themeMode: state.themeMode,
                onSelected: state.setThemeMode,
              ),
              IconButton(
                icon: Icon(isFav ? Icons.star : Icons.star_border),
                color: isFav ? Colors.amber : null,
                tooltip: isFav ? 'Remove favorite' : 'Add to favorites',
                onPressed: () => state.toggleFavorite(currency.isoCode),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: 'currency_icon_${currency.isoCode}',
                    child: CircleAvatar(
                      radius: 40,
                      child: Text(
                        currency.isoCode.length >= 2
                            ? currency.isoCode.substring(0, 2)
                            : currency.isoCode,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(label: 'ISO Code', value: currency.isoCode),
                _DetailRow(label: 'Name', value: currency.name),
                if (currency.symbol != null)
                  _DetailRow(label: 'Symbol', value: currency.symbol!),
                if (currency.regions.isNotEmpty)
                  _DetailRow(
                    label: 'Regions',
                    value: currency.regions.join(', '),
                  ),
                if (currency.description != null &&
                    currency.description!.isNotEmpty)
                  _DetailRow(
                    label: 'Description',
                    value: currency.description!,
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.swap_horiz),
                    label: Text('Convert ${currency.isoCode}'),
                    onPressed: () => _showConvertChoiceDialog(context, state),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
