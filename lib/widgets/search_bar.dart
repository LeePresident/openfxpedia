import 'package:flutter/material.dart';
import '../models/currency.dart';

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
      builder: (dialogContext) {
        List<Currency> localFiltered = widget.currencies;
        final TextEditingController dialogController = TextEditingController();

        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      key: const Key('currency_search_field'),
                      controller: dialogController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ),
                      onChanged: (query) {
                        final q = query.toLowerCase();
                        setDialogState(() {
                          localFiltered = widget.currencies.where((c) {
                            return c.isoCode.toLowerCase().contains(q) ||
                                c.name.toLowerCase().contains(q);
                          }).toList();
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: localFiltered.length,
                      itemBuilder: (context, index) {
                        final currency = localFiltered[index];
                        return ListTile(
                          title: Text(currency.isoCode),
                          subtitle: Text(currency.name),
                          onTap: () => Navigator.pop(dialogContext, currency),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
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
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedCurrency != null
                        ? '${widget.selectedCurrency!.isoCode} — ${widget.selectedCurrency!.name}'
                        : 'Pick',
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
