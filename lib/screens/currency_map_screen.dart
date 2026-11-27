import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/currency.dart';
import '../providers/app_state.dart';
import '../services/world_map_data.dart';
import '../widgets/search_bar.dart';

class CurrencyMapScreen extends StatefulWidget {
  const CurrencyMapScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<CurrencyMapScreen> createState() => _CurrencyMapScreenState();
}

class _CurrencyMapScreenState extends State<CurrencyMapScreen> {
  final _map = WorldMapData.load();
  final _transform = TransformationController();
  final _viewerKey = GlobalKey();
  String? _currencyCode;
  String? _regionCode;
  String? _regionName;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _selectRegion(String? code, String name) {
    setState(() {
      _regionCode = code;
      _regionName = name;
      _currencyCode = null;
    });
  }

  Future<void> _selectMapRegions(
    List<MapRegion> regions,
    List<Currency> currencies,
  ) async {
    if (regions.isEmpty) return;
    var selected = regions.first;
    if (regions.length > 1) {
      final l10n = AppLocalizations.of(context);
      final choice = await showDialog<MapRegion>(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text(l10n.map_find_region),
          children: [
            for (final region in regions)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, region),
                child: Text(
                  region.code == null
                      ? region.name
                      : _nameForCode(currencies, region.code!) ?? region.name,
                ),
              ),
          ],
        ),
      );
      if (choice == null || !mounted) return;
      selected = choice;
    }
    _selectRegion(selected.code, selected.name);
  }

  void _zoom(double factor) {
    final viewport =
        _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewport == null) return;
    final scale = (_transform.value.getMaxScaleOnAxis() * factor).clamp(
      1.0,
      64.0,
    );
    final center = viewport.size.center(Offset.zero);
    final sceneCenter = _transform.toScene(center);
    _transform.value = Matrix4.identity()
      ..translateByDouble(
        center.dx - sceneCenter.dx * scale,
        center.dy - sceneCenter.dy * scale,
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencies = context.watch<AppState>().currencies;
    final selectedCurrency = currencies
        .where((currency) => currency.isoCode == _currencyCode)
        .firstOrNull;
    final regionCurrencies = currencies.where((currency) {
      for (var i = 0; i < currency.regions.length; i++) {
        final code = i < currency.regionCodes.length
            ? currency.regionCodes[i]
            : null;
        if (_regionCode != null &&
                code != null &&
                mapCodesForCatalogRegion(code).contains(_regionCode) ||
            _regionCode == null &&
                _regionName != null &&
                currency.regions[i] == _regionName) {
          return true;
        }
      }
      return false;
    }).toList();
    final localizedRegionName = _regionCode == null
        ? _regionName
        : _nameForCode(currencies, _regionCode!) ?? _regionName;
    final highlightedCodes =
        selectedCurrency?.regionCodes
            .whereType<String>()
            .expand(mapCodesForCatalogRegion)
            .toSet() ??
        {};

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onBack),
        title: Text(l10n.map_title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: CurrencySearchBar(
                    currencies: currencies,
                    selectedCurrency: selectedCurrency,
                    hint: l10n.map_choose_currency,
                    unselectedLabel: l10n.map_choose_currency,
                    onSelected: (currency) => setState(() {
                      _currencyCode = currency.isoCode;
                      _regionCode = null;
                      _regionName = null;
                    }),
                  ),
                ),
                if (selectedCurrency != null)
                  IconButton(
                    tooltip: l10n.map_clear_currency,
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _currencyCode = null),
                  ),
                IconButton(
                  tooltip: l10n.map_find_region,
                  icon: const Icon(Icons.public),
                  onPressed: () async {
                    final region = await showDialog<_RegionChoice>(
                      context: context,
                      builder: (_) =>
                          _RegionSearchDialog(currencies: currencies),
                    );
                    if (region != null && mounted) {
                      _selectRegion(region.code, region.name);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<WorldMapData>(
              future: _map,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Offline map load failed: ${snapshot.error}');
                  return Center(child: Text(l10n.map_no_map));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.requireData;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = math.min(
                            constraints.maxWidth,
                            constraints.maxHeight * 2,
                          );
                          return InteractiveViewer(
                            key: _viewerKey,
                            transformationController: _transform,
                            minScale: 1,
                            maxScale: 64,
                            boundaryMargin: const EdgeInsets.all(300),
                            child: Center(
                              child: SizedBox(
                                width: width,
                                height: width / 2,
                                child: LayoutBuilder(
                                  builder: (context, mapConstraints) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapUp: (details) {
                                        final point = Offset(
                                          details.localPosition.dx /
                                              mapConstraints.maxWidth *
                                              360,
                                          details.localPosition.dy /
                                              mapConstraints.maxHeight *
                                              180,
                                        );
                                        final mapUnitsPerPixel =
                                            360 /
                                            mapConstraints.maxWidth /
                                            _transform.value
                                                .getMaxScaleOnAxis();
                                        _selectMapRegions(
                                          data.regionsAt(
                                            point,
                                            mapUnitsPerPixel: mapUnitsPerPixel,
                                          ),
                                          currencies,
                                        );
                                      },
                                      child: RepaintBoundary(
                                        key: const ValueKey(
                                          'currency-world-map',
                                        ),
                                        child: CustomPaint(
                                          painter: _WorldMapPainter(
                                            data: data,
                                            highlightedCodes: highlightedCodes,
                                            selectedCode: _regionCode,
                                            colors: Theme.of(
                                              context,
                                            ).colorScheme,
                                            transform: _transform,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: l10n.map_zoom_in,
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _zoom(2),
                          ),
                          IconButton(
                            tooltip: l10n.map_zoom_out,
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _zoom(0.5),
                          ),
                          IconButton(
                            tooltip: l10n.map_reset_zoom,
                            icon: const Icon(Icons.center_focus_strong),
                            onPressed: () =>
                                _transform.value = Matrix4.identity(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.3,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (localizedRegionName != null) ...[
                    Text(
                      localizedRegionName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (regionCurrencies.isEmpty)
                      Text(l10n.map_no_currency)
                    else
                      for (final currency in regionCurrencies)
                        Text('${currency.isoCode} — ${currency.name}'),
                  ] else
                    Text(l10n.map_instructions),
                  if (selectedCurrency != null) ...[
                    const SizedBox(height: 8),
                    Text(l10n.map_currency_regions),
                    Text(selectedCurrency.regions.join(', ')),
                  ],
                  if (selectedCurrency != null || localizedRegionName != null)
                    Wrap(
                      spacing: 16,
                      children: [
                        if (selectedCurrency != null)
                          _MapLegendItem(
                            color: Theme.of(context).colorScheme.primary,
                            label: l10n.map_legend_usage,
                          ),
                        if (localizedRegionName != null)
                          _MapLegendItem(
                            color: Theme.of(context).colorScheme.tertiary,
                            label: l10n.map_legend_selected,
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.map_catalog_note,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLegendItem extends StatelessWidget {
  const _MapLegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 12, color: color),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

String? _nameForCode(List<Currency> currencies, String code) {
  for (final currency in currencies) {
    for (var i = 0; i < currency.regions.length; i++) {
      if (i < currency.regionCodes.length && currency.regionCodes[i] == code) {
        return currency.regions[i];
      }
    }
  }
  return null;
}

class _WorldMapPainter extends CustomPainter {
  _WorldMapPainter({
    required this.data,
    required this.highlightedCodes,
    required this.selectedCode,
    required this.colors,
    required this.transform,
  }) : super(repaint: transform);

  final WorldMapData data;
  final Set<String> highlightedCodes;
  final String? selectedCode;
  final ColorScheme colors;
  final TransformationController transform;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 360, size.height / 180);
    final fill = Paint();
    final border = Paint()
      ..color = colors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.12;
    for (final region in data.mapShapes) {
      fill.color = region.code != null && region.code == selectedCode
          ? colors.tertiary
          : highlightedCodes.contains(region.code)
          ? colors.primary
          : colors.surfaceContainerHighest;
      canvas.drawPath(region.path, fill);
    }
    for (final region in data.mapShapes) {
      canvas.drawPath(region.path, border);
    }
    final marker = Paint();
    final mapUnitsPerPixel =
        360 / size.width / transform.value.getMaxScaleOnAxis();
    final markerRadius = 3 * mapUnitsPerPixel;
    for (final region in data.regions) {
      if (region.needsMarker(mapUnitsPerPixel)) {
        marker.color = region.code == selectedCode
            ? colors.tertiary
            : highlightedCodes.contains(region.code)
            ? colors.primary
            : colors.outline;
        canvas.drawCircle(region.bounds.center, markerRadius, marker);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter oldDelegate) => true;
}

class _RegionChoice {
  const _RegionChoice(this.code, this.name);
  final String? code;
  final String name;
}

class _RegionSearchDialog extends StatefulWidget {
  const _RegionSearchDialog({required this.currencies});
  final List<Currency> currencies;

  @override
  State<_RegionSearchDialog> createState() => _RegionSearchDialogState();
}

class _RegionSearchDialogState extends State<_RegionSearchDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final regions = <String, _RegionChoice>{};
    for (final currency in widget.currencies) {
      for (var i = 0; i < currency.regions.length; i++) {
        final code = i < currency.regionCodes.length
            ? currency.regionCodes[i]
            : null;
        final name = currency.regions[i];
        regions.putIfAbsent(code ?? name, () => _RegionChoice(code, name));
      }
    }
    final matches =
        regions.values
            .where(
              (region) =>
                  region.name.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.map_search_region,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? Center(child: Text(l10n.map_no_regions))
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(matches[index].name),
                        onTap: () => Navigator.pop(context, matches[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
