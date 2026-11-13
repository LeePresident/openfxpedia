import 'package:material_ui/material_ui.dart';
import 'package:pinyin/pinyin.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/currency.dart';
import '../models/currency_search_index.dart';
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
  List<Currency>? _indexedCurrenciesSource;
  String? _indexedLanguageCode;
  List<_CurrencySearchEntry> _indexedCurrencies = [];

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
        final languageCode = Localizations.localeOf(context).languageCode;
        if (!identical(_indexedCurrenciesSource, all) ||
            _indexedLanguageCode != languageCode) {
          _indexedCurrenciesSource = all;
          _indexedLanguageCode = languageCode;
          _indexedCurrencies = all
              .map(
                (currency) => _CurrencySearchEntry(
                  searchIndex: CurrencySearchIndex(currency),
                  sortName: languageCode == 'zh'
                      ? PinyinHelper.getPinyin(currency.name, separator: '')
                      : currency.name,
                ),
              )
              .toList(growable: false);
        }

        final query = CurrencySearchQuery(_query);
        final filtered = _indexedCurrencies.where((entry) {
          return entry.searchIndex.matches(query) &&
              (!_favoritesOnly ||
                  state.isFavorite(entry.searchIndex.currency.isoCode));
        }).toList()..sort((first, second) => _sort.compare(first, second));

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.encyclopedia_currency_title),
            actions: [
              IconButton(
                icon: Icon(_favoritesOnly ? Icons.star : Icons.star_border),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                    final currency = filtered[index].searchIndex.currency;
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

  int compare(_CurrencySearchEntry first, _CurrencySearchEntry second) {
    final comparison = switch (this) {
      _CurrencySort.codeAscending || _CurrencySort.codeDescending =>
        first.searchIndex.normalizedIsoCode.compareTo(
          second.searchIndex.normalizedIsoCode,
        ),
      _CurrencySort.nameAscending ||
      _CurrencySort.nameDescending => first.sortName.compareTo(second.sortName),
    };

    return switch (this) {
      _CurrencySort.codeDescending ||
      _CurrencySort.nameDescending => -comparison,
      _ => comparison,
    };
  }
}

class _CurrencySearchEntry {
  const _CurrencySearchEntry({
    required this.searchIndex,
    required this.sortName,
  });

  final CurrencySearchIndex searchIndex;
  final String sortName;
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
