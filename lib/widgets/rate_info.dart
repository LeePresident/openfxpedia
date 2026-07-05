import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 8),
          Text(l10n.rate_info_refreshing, style: const TextStyle(fontSize: 12)),
        ],
      );
    }

    if (rate == null) return const SizedBox.shrink();

    final formatter = DateFormat.yMMMd(l10n.localeName).add_Hm();
    final timeLabel = formatter.format(rate!.timestamp.toLocal());
    final sourceLabel = fromCache ? l10n.rate_info_cached : l10n.rate_info_live;
    final rateSummary =
        '1 ${rate!.baseCurrency.toUpperCase()} = ${rate!.rate.toStringAsFixed(4)} ${rate!.targetCurrency.toUpperCase()}';
    final metadata = '$timeLabel - $sourceLabel';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rateSummary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              fromCache ? Icons.cloud_off : Icons.cloud_done,
              size: 14,
              color: fromCache
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.green,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                metadata,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
