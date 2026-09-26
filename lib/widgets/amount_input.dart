import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInput extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final String label;

  const AmountInput({
    super.key,
    required this.onChanged,
    this.initialValue = 1.0,
    this.label = 'Amount',
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue == widget.initialValue ||
        double.tryParse(_controller.text) == widget.initialValue ||
        (_controller.text.isEmpty && widget.initialValue == 0)) {
      return;
    }

    final text = widget.initialValue.toString();
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,6}')),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
            widget.onChanged(0.0);
          },
        ),
      ),
      onChanged: (text) {
        final value = double.tryParse(text);
        if (value != null) widget.onChanged(value);
      },
    );
  }
}
