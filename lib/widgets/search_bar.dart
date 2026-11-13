import 'package:material_ui/material_ui.dart';
import '../models/currency.dart';
import '../models/currency_search_index.dart';
import '../l10n/app_localizations.dart';

class CurrencySearchBar extends StatefulWidget {
  final List<Currency> currencies;
  final ValueChanged<Currency> onSelected;
  final Currency? selectedCurrency;
  final String hint;

  const CurrencySearchBar({
    super.key,
    required this.currencies,
    required this.onSelected,
    this.selectedCurrency,
    this.hint = 'Search currency...',
  });

  @override
  State<CurrencySearchBar> createState() => _CurrencySearchBarState();
}

class _CurrencySearchBarState extends State<CurrencySearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedCurrency != null) {
      _controller.text =
          '${widget.selectedCurrency!.isoCode} — ${widget.selectedCurrency!.name}';
    }
  }

  @override
  void didUpdateWidget(covariant CurrencySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCurrency?.isoCode !=
        oldWidget.selectedCurrency?.isoCode) {
      if (widget.selectedCurrency != null) {
        _controller.text =
            '${widget.selectedCurrency!.isoCode} — ${widget.selectedCurrency!.name}';
      } else {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(Currency currency) {
    _controller.text = '${currency.isoCode} — ${currency.name}';
    widget.onSelected(currency);
  }

  Future<void> _openSelectorDialog() async {
    final picked = await showDialog<Currency>(
      context: context,
      builder: (_) => _CurrencySelectorDialog(
        currencies: widget.currencies,
        hint: widget.hint,
      ),
    );

    if (picked != null) {
      _select(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _openSelectorDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedCurrency != null
                        ? '${widget.selectedCurrency!.isoCode} — ${widget.selectedCurrency!.name}'
                        : AppLocalizations.of(context).pick,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencySelectorDialog extends StatefulWidget {
  const _CurrencySelectorDialog({required this.currencies, required this.hint});

  final List<Currency> currencies;
  final String hint;

  @override
  State<_CurrencySelectorDialog> createState() =>
      _CurrencySelectorDialogState();
}

class _CurrencySelectorDialogState extends State<_CurrencySelectorDialog> {
  final TextEditingController _controller = TextEditingController();
  late final List<CurrencySearchIndex> _currencies;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _currencies = widget.currencies
        .map(CurrencySearchIndex.new)
        .toList(growable: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = CurrencySearchQuery(_query);
    final filtered = _currencies
        .where((currency) => currency.matches(query))
        .toList(growable: false);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                key: const Key('currency_search_field'),
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          key: const Key('currency_search_clear'),
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear search',
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
                onChanged: (query) => setState(() => _query = query),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final currency = filtered[index].currency;
                  return ListTile(
                    title: Text(currency.isoCode),
                    subtitle: Text(currency.name),
                    onTap: () => Navigator.pop(context, currency),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
