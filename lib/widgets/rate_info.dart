import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exchange_rate.dart';

class RateInfoWidget extends StatelessWidget {
  final ExchangeRate? rate;
  final bool fromCache;
  final bool isLoading;

  const RateInfoWidget({
    super.key,
    this.rate,
    this.fromCache = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('Refreshing rates…', style: TextStyle(fontSize: 12)),
        ],
      );
    }

    if (rate == null) return const SizedBox.shrink();

    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    final timeLabel = formatter.format(rate!.timestamp.toLocal());
    final sourceLabel = fromCache ? 'cached' : 'live';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          fromCache ? Icons.cloud_off : Icons.cloud_done,
          size: 14,
          color: fromCache
              ? Theme.of(context).colorScheme.secondary
              : Colors.green,
        ),
        const SizedBox(width: 4),
        Text(
          '1 ${rate!.baseCurrency.toUpperCase()} = '
          '${rate!.rate.toStringAsFixed(4)} ${rate!.targetCurrency.toUpperCase()} '
          '· $timeLabel ($sourceLabel)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
