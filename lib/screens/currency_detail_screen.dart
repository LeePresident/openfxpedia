import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          title: Text('${l10n.detail_convert} ${currency.isoCode}'),
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
                    child: _DetailCurrencyIcon(currency: currency),
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
                    showMoreLabel: l10n.detail_show_more_regions,
                    showLessLabel: l10n.detail_show_less_regions,
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
                    label: Text('${l10n.detail_convert} ${currency.isoCode}'),
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

class _DetailCurrencyIcon extends StatelessWidget {
  final Currency currency;

  const _DetailCurrencyIcon({required this.currency});

  @override
  Widget build(BuildContext context) {
    if (currency.iconAsset != null && currency.iconAsset!.isNotEmpty) {
      return SizedBox(
        width: 80,
        height: 80,
        child: ClipOval(
          child: SvgPicture.asset(
            currency.iconAsset!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholderBuilder: (_) => _fallbackTextIcon(),
          ),
        ),
      );
    }

    return _fallbackTextIcon();
  }

  Widget _fallbackTextIcon() {
    return CircleAvatar(
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

class _RegionsDetailRow extends StatefulWidget {
  static const initialRegionCount = 3;

  final String label;
  final List<String> regions;
  final String showMoreLabel;
  final String showLessLabel;

  const _RegionsDetailRow({
    required this.label,
    required this.regions,
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
                for (final region in visibleRegions)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildRegionFlag(region),
                      const SizedBox(width: 8),
                      Expanded(child: Text(region)),
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
