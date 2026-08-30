import 'package:flutter/material.dart';
import 'package:pinyin/pinyin.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/currency.dart';
import '../widgets/region_flag.dart';
import 'currency_detail_screen.dart';

class EncyclopediaScreen extends StatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _CurrencySort _sort = _CurrencySort.codeAscending;
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final l10n = AppLocalizations.of(context);
        final all = state.currencies;
        final filtered = (_query.isEmpty
                ? List<Currency>.of(all)
                : all.where((c) {
                    final q = _query.toLowerCase();
                    return c.isoCode.toLowerCase().contains(q) ||
                        c.name.toLowerCase().contains(q) ||
                        (c.isoNumeric?.contains(q) ?? false);
                  }).toList())
            .where((currency) =>
                !_favoritesOnly || state.isFavorite(currency.isoCode))
            .toList();
        filtered.sort(
          (first, second) => _sort.compare(
            first,
            second,
            useChineseCollation:
                Localizations.localeOf(context).languageCode == 'zh',
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.encyclopedia_currency_title),
            actions: [
              IconButton(
                icon: Icon(
                  _favoritesOnly ? Icons.star : Icons.star_border,
                ),
                color: _favoritesOnly ? Colors.amber : null,
                tooltip: l10n.encyclopedia_favorites_only,
                onPressed: () =>
                    setState(() => _favoritesOnly = !_favoritesOnly),
              ),
              PopupMenuButton<_CurrencySort>(
                icon: const Icon(Icons.sort),
                tooltip: l10n.encyclopedia_sort,
                initialValue: _sort,
                onSelected: (sort) => setState(() => _sort = sort),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _CurrencySort.codeAscending,
                    child: Text(l10n.encyclopedia_sort_code_ascending),
                  ),
                  PopupMenuItem(
                    value: _CurrencySort.codeDescending,
                    child: Text(l10n.encyclopedia_sort_code_descending),
                  ),
                  PopupMenuItem(
                    value: _CurrencySort.nameAscending,
                    child: Text(l10n.encyclopedia_sort_name_ascending),
                  ),
                  PopupMenuItem(
                    value: _CurrencySort.nameDescending,
                    child: Text(l10n.encyclopedia_sort_name_descending),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.encyclopedia_search,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
          ),
          body: all.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(child: Text(l10n.encyclopedia_not_found))
                  : ListView.builder(
                      itemExtent: 72,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final currency = filtered[index];
                        return _CurrencyTile(currency: currency, state: state);
                      },
                    ),
        );
      },
    );
  }
}

enum _CurrencySort {
  codeAscending,
  codeDescending,
  nameAscending,
  nameDescending;

  int compare(
    Currency first,
    Currency second, {
    required bool useChineseCollation,
  }) {
    final comparison = switch (this) {
      _CurrencySort.codeAscending ||
      _CurrencySort.codeDescending =>
        first.isoCode.compareTo(second.isoCode),
      _CurrencySort.nameAscending ||
      _CurrencySort.nameDescending =>
        _compareNames(
          first.name,
          second.name,
          useChineseCollation: useChineseCollation,
        ),
    };

    return switch (this) {
      _CurrencySort.codeDescending ||
      _CurrencySort.nameDescending =>
        -comparison,
      _ => comparison,
    };
  }

  int _compareNames(
    String first,
    String second, {
    required bool useChineseCollation,
  }) {
    if (!useChineseCollation) return first.compareTo(second);

    return PinyinHelper.getPinyin(first, separator: '').compareTo(
      PinyinHelper.getPinyin(second, separator: ''),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final Currency currency;
  final AppState state;

  const _CurrencyTile({required this.currency, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFav = state.isFavorite(currency.isoCode);
    return ListTile(
      leading: buildCurrencyFlag(
        currencyCode: currency.isoCode,
        regions: currency.regions,
        regionCodes: currency.regionCodes,
      ),
      title: Text(currency.isoCode),
      subtitle: Text(currency.name),
      trailing: IconButton(
        icon: Icon(isFav ? Icons.star : Icons.star_border),
        color: isFav ? Colors.amber : null,
        tooltip: isFav ? l10n.favorites_remove : l10n.favorites_add,
        onPressed: () => state.toggleFavorite(currency.isoCode),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CurrencyDetailScreen(currency: currency),
        ),
      ),
    );
  }
}
