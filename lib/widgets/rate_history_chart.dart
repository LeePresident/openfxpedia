import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../services/conversion_service.dart';

class RateHistoryChart extends StatelessWidget {
  const RateHistoryChart({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    if (state.baseCurrency == null || state.targetCurrency == null) {
      return const SizedBox.shrink();
    }
    final quotes = state.historySamples
        .map((sample) => sample.quote)
        .whereType<ConversionResult>()
        .toList();
    final formatter = DateFormat.yMMMd(l10n.localeName);
    final number = NumberFormat('0.######', l10n.localeName);
    String describe(ConversionResult quote) {
      final provider = quote.rate.source == 'frankfurter'
          ? l10n.provider_frankfurter
          : l10n.provider_exchange_api;
      return '${formatter.format(quote.rate.timestamp)}\n'
          '1 ${state.baseCurrency!.isoCode} = '
          '${number.format(quote.rate.rate)} ${state.targetCurrency!.isoCode}\n'
          '$provider · ${quote.fromCache ? l10n.rate_info_cached : l10n.rate_info_live}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: state.historyVisible,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('history-toggle'),
              onTap: () => state.setHistoryVisible(!state.historyVisible),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colors.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.show_chart, color: colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l10n.history_title,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Icon(state.historyVisible
                        ? Icons.expand_less
                        : Icons.expand_more),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (state.historyVisible) ...[
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<int>(
                key: const Key('history-range'),
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: 7, label: Text(l10n.history_week)),
                  ButtonSegment(value: 30, label: Text(l10n.history_month)),
                  ButtonSegment(value: 90, label: Text(l10n.history_quarter)),
                ],
                selected: {state.historyDays},
                onSelectionChanged: (values) =>
                    state.setHistoryDays(values.single),
              ),
              IconButton(
                key: const Key('history-refresh'),
                tooltip: l10n.converter_refresh_rates,
                onPressed: state.historyLoading
                    ? null
                    : () => state.loadHistory(forceRefresh: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.historyLoading)
            const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (quotes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(l10n.history_unavailable),
            )
          else ...[
            Text('1 ${state.baseCurrency!.isoCode} / '
                '${state.targetCurrency!.isoCode}'),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: Semantics(
                label: quotes.map(describe).join('\n'),
                child: _plot(context, quotes, describe),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              children: [
                Text(
                    formatter.format(state.historySamples.first.requestedDate)),
                Text(formatter.format(state.historySamples.last.requestedDate)),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.history_available(
                quotes.length, state.historySamples.length)),
            Wrap(
              spacing: 12,
              children: [
                if (quotes.any((quote) => quote.rate.source == 'frankfurter'))
                  Text(l10n.provider_frankfurter),
                if (quotes.any((quote) => quote.rate.source != 'frankfurter'))
                  Text(l10n.provider_exchange_api),
                if (quotes.any((quote) => quote.fromCache))
                  Text(l10n.rate_info_cached),
                if (quotes.any((quote) => !quote.fromCache))
                  Text(l10n.rate_info_live),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(l10n.rate_info_disclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  )),
        ],
      ],
    );
  }

  Widget _plot(BuildContext context, List<ConversionResult> quotes,
      String Function(ConversionResult) describe) {
    final colors = Theme.of(context).colorScheme;
    final start = state.historySamples.first.requestedDate;
    final spots = <FlSpot>[];
    DateTime? previousDate;
    for (final sample in state.historySamples) {
      final quote = sample.quote;
      if (quote == null) {
        spots.add(FlSpot.nullSpot);
        previousDate = null;
      } else if (quote.rate.timestamp != previousDate) {
        spots.add(FlSpot(
          quote.rate.timestamp.difference(start).inDays.toDouble(),
          quote.rate.rate,
        ));
        previousDate = quote.rate.timestamp;
      }
    }
    final values = quotes.map((quote) => quote.rate.rate);
    final min = values.reduce((left, right) => left < right ? left : right);
    final max = values.reduce((left, right) => left > right ? left : right);
    final padding = max == min ? min * 0.01 : (max - min) * 0.15;
    return LineChart(
      key: const Key('history-plot'),
      duration: Duration.zero,
      LineChartData(
        minX: 0,
        maxX: (state.historyDays - 1).toDouble(),
        minY: min - padding,
        maxY: max + padding,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 68,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                    NumberFormat(
                            '0.#####', AppLocalizations.of(context).localeName)
                        .format(value),
                    style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: colors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: true),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            maxContentWidth: 240,
            getTooltipColor: (_) => colors.inverseSurface,
            getTooltipItems: (touched) => touched.map((spot) {
              final quote = quotes.firstWhere((quote) =>
                  quote.rate.timestamp.difference(start).inDays == spot.x &&
                  quote.rate.rate == spot.y);
              return LineTooltipItem(describe(quote),
                  TextStyle(color: colors.onInverseSurface, fontSize: 12));
            }).toList(),
          ),
        ),
      ),
    );
  }
}
