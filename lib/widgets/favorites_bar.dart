import 'package:flutter/material.dart';
import '../models/currency.dart';

class FavoritesBar extends StatelessWidget {
  final List<Currency> favorites;
  final ValueChanged<Currency> onTap;
  final String emptyMessage;

  const FavoritesBar({
    super.key,
    required this.favorites,
    required this.onTap,
    this.emptyMessage = 'No favorites yet.',
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final currency = favorites[index];
          return ActionChip(
            label: Text(currency.isoCode),
            tooltip: currency.name,
            onPressed: () => onTap(currency),
          );
        },
      ),
    );
  }
}
