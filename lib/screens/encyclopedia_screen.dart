import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/currency.dart';
import 'currency_detail_screen.dart';

class EncyclopediaScreen extends StatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final l10n = AppLocalizations.of(context);
        final all = state.currencies;
        final filtered = _query.isEmpty
            ? all
            : all.where((c) {
                final q = _query.toLowerCase();
                return c.isoCode.toLowerCase().contains(q) ||
                    c.name.toLowerCase().contains(q);
              }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.encyclopedia_currency_title),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.encyclopedia_search,
                    prefixIcon: const Icon(Icons.search),
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
                      cacheExtent: 480,
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

class _CurrencyTile extends StatelessWidget {
  final Currency currency;
  final AppState state;

  const _CurrencyTile({required this.currency, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFav = state.isFavorite(currency.isoCode);
    return ListTile(
      leading: _CurrencyIcon(currency: currency),
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

class _CurrencyIcon extends StatelessWidget {
  final Currency currency;
  const _CurrencyIcon({required this.currency});

  @override
  Widget build(BuildContext context) {
    if (currency.iconAsset != null && currency.iconAsset!.isNotEmpty) {
      return SizedBox(
        width: 40,
        height: 40,
        child: ClipOval(
          child: SvgPicture.asset(
            currency.iconAsset!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholderBuilder: (_) => _fallbackTextIcon(currency),
          ),
        ),
      );
    }

    return _fallbackTextIcon(currency);
  }

  Widget _fallbackTextIcon(Currency currency) {
    return CircleAvatar(
      child: Text(
        currency.isoCode.length >= 2
            ? currency.isoCode.substring(0, 2)
            : currency.isoCode,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
