class CalculatorEntry {
  const CalculatorEntry({
    required this.id,
    required this.amount,
    required this.currencyCode,
  });

  final int id;
  final double amount;
  final String currencyCode;

  CalculatorEntry copyWith({double? amount, String? currencyCode}) {
    return CalculatorEntry(
      id: id,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
