import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/currency.dart';
import 'currency_detail_screen.dart';
import '../widgets/theme_mode_button.dart';

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
            title: const Text('Currency Encyclopedia'),
            actions: [
              ThemeModeButton(
                themeMode: state.themeMode,
                onSelected: state.setThemeMode,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search currencies…',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(),
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
                  ? const Center(child: Text('No currencies found.'))
                  : ListView.builder(
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
    final isFav = state.isFavorite(currency.isoCode);
    return ListTile(
      leading: _CurrencyIcon(currency: currency),
      title: Text(currency.isoCode),
      subtitle: Text(currency.name),
      trailing: IconButton(
        icon: Icon(isFav ? Icons.star : Icons.star_border),
        color: isFav ? Colors.amber : null,
        tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
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
