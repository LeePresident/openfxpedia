import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/currency.dart';
import '../providers/app_state.dart';
import '../widgets/region_flag.dart';

enum _ConversionFieldChoice { from, to }

class CurrencyDetailScreen extends StatelessWidget {
  final Currency currency;

  const CurrencyDetailScreen({super.key, required this.currency});

  Future<void> _showConvertChoiceDialog(
    BuildContext context,
    AppState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<_ConversionFieldChoice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${l10n.detail_convert} ${currency.name}'),
          content: Text(l10n.detail_currency_prompt),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.detail_cancel),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _ConversionFieldChoice.to,
              ),
              child: Text(l10n.detail_to_field),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _ConversionFieldChoice.from,
              ),
              child: Text(l10n.detail_from_field),
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
        final l10n = AppLocalizations.of(context);
        final isFav = state.isFavorite(currency.isoCode);

        return Scaffold(
          appBar: AppBar(
            title: Text(currency.name),
            actions: [
              IconButton(
                icon: Icon(isFav ? Icons.star : Icons.star_border),
                color: isFav ? Colors.amber : null,
                tooltip: isFav
                    ? l10n.detail_remove_favorite
                    : l10n.detail_add_favorite,
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
                    child: buildCurrencyFlag(
                      currencyCode: currency.isoCode,
                      regions: currency.regions,
                      regionCodes: currency.regionCodes,
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                    label: l10n.detail_iso_code, value: currency.isoCode),
                if (currency.isoNumeric != null)
                  _DetailRow(
                    label: l10n.detail_iso_numeric,
                    value: currency.isoNumeric!,
                  ),
                _DetailRow(label: l10n.detail_name, value: currency.name),
                if (currency.symbol != null)
                  _DetailRow(
                      label: l10n.detail_symbol, value: currency.symbol!),
                if (currency.regions.isNotEmpty)
                  _RegionsDetailRow(
                    label: l10n.detail_regions,
                    regions: currency.regions,
                    regionCodes: currency.regionCodes,
                    showMoreLabel: l10n.detail_show_more_regions,
                    showLessLabel: l10n.detail_show_less_regions,
                  ),
                if (currency.coins.isNotEmpty)
                  _DetailRow(
                    label: l10n.detail_coins,
                    value: _localizedDenominations(
                      currency.isoCode,
                      currency.coins,
                      l10n,
                    ),
                  ),
                if (currency.banknotes.isNotEmpty)
                  _DetailRow(
                    label: l10n.detail_banknotes,
                    value: _localizedDenominations(
                      currency.isoCode,
                      currency.banknotes,
                      l10n,
                    ),
                  ),
                if (currency.description != null &&
                    currency.description!.isNotEmpty)
                  _DetailRow(
                    label: l10n.detail_description,
                    value: currency.description!,
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.swap_horiz),
                    label: Text('${l10n.detail_convert} ${currency.name}'),
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

String _localizedDenominations(
  String isoCode,
  List<String> denominations,
  AppLocalizations l10n,
) {
  if (isoCode == 'PAB' && denominations.length == 1) {
    return l10n.detail_pab_no_banknotes;
  }
  if (isoCode == 'SOS' && denominations.length == 1) {
    return l10n.detail_sos_no_coins;
  }
  if (isoCode == 'VND' && denominations.length == 1) {
    return l10n.detail_vnd_no_coins;
  }
  return denominations.join(', ');
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

class _RegionsDetailRow extends StatefulWidget {
  static const initialRegionCount = 3;

  final String label;
  final List<String> regions;
  final List<String?> regionCodes;
  final String showMoreLabel;
  final String showLessLabel;

  const _RegionsDetailRow({
    required this.label,
    required this.regions,
    required this.regionCodes,
    required this.showMoreLabel,
    required this.showLessLabel,
  });

  @override
  State<_RegionsDetailRow> createState() => _RegionsDetailRowState();
}

class _RegionsDetailRowState extends State<_RegionsDetailRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasOverflow =
        widget.regions.length > _RegionsDetailRow.initialRegionCount;
    final visibleRegions = _isExpanded || !hasOverflow
        ? widget.regions
        : widget.regions.take(_RegionsDetailRow.initialRegionCount).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < visibleRegions.length; index++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildRegionFlag(
                        visibleRegions[index],
                        regionCode: widget.regionCodes.length > index
                            ? widget.regionCodes[index]
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(visibleRegions[index])),
                    ],
                  ),
                if (hasOverflow)
                  TextButton(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      _isExpanded ? widget.showLessLabel : widget.showMoreLabel,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
