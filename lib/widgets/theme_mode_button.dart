import 'package:flutter/material.dart';

class ThemeModeButton extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onSelected;

  const ThemeModeButton({
    super.key,
    required this.themeMode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        _menuItem(
          context,
          mode: ThemeMode.light,
          icon: Icons.light_mode,
          label: 'Light',
        ),
        _menuItem(
          context,
          mode: ThemeMode.dark,
          icon: Icons.dark_mode,
          label: 'Dark',
        ),
        _menuItem(
          context,
          mode: ThemeMode.system,
          icon: Icons.settings_suggest,
          label: 'System',
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          tooltip: 'Change theme',
          icon: Icon(_iconFor(themeMode)),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required ThemeMode mode,
    required IconData icon,
    required String label,
  }) {
    final selected = mode == themeMode;
    return MenuItemButton(
      leadingIcon: Icon(icon),
      trailingIcon: selected ? const Icon(Icons.check) : null,
      onPressed: () => onSelected(mode),
      child: Text(label),
    );
  }

  IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_suggest;
    }
  }
}
