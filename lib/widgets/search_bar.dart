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
    this.hint = 'Search currency…',
  });

  @override
  State<CurrencySearchBar> createState() => _CurrencySearchBarState();
}

class _CurrencySearchBarState extends State<CurrencySearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<Currency> _filtered = [];
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _filtered = widget.currencies;
    if (widget.selectedCurrency != null) {
      _controller.text =
          '${widget.selectedCurrency!.isoCode} — ${widget.selectedCurrency!.name}';
    }
  }

  @override
  void didUpdateWidget(covariant CurrencySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the controller text when the externally selected currency changes
    if (widget.selectedCurrency?.isoCode !=
        oldWidget.selectedCurrency?.isoCode) {
      if (widget.selectedCurrency != null) {
        _controller.text =
            '${widget.selectedCurrency!.isoCode} — ${widget.selectedCurrency!.name}';
      } else {
        _controller.clear();
      }
    }
    // Refresh the filtered list if the currencies list changed
    if (widget.currencies != oldWidget.currencies) {
      _filtered = widget.currencies;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = widget.currencies.where((c) {
        return c.isoCode.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q);
      }).toList();
      _showDropdown = query.isNotEmpty;
    });
  }

  void _select(Currency currency) {
    _controller.text = '${currency.isoCode} — ${currency.name}';
    setState(() => _showDropdown = false);
    widget.onSelected(currency);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: _onTextChanged,
        ),
        if (_showDropdown && _filtered.isNotEmpty)
          Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final currency = _filtered[index];
                  return ListTile(
                    dense: true,
                    title: Text(currency.isoCode),
                    subtitle: Text(currency.name),
                    onTap: () => _select(currency),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
