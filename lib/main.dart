import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/currency.dart';
import 'providers/app_state.dart';
import 'screens/converter_screen.dart';
import 'screens/encyclopedia_screen.dart';
import 'services/cache_service.dart';
import 'services/conversion_service.dart';
import 'services/currency_catalog.dart';
import 'services/exchange_client.dart';
import 'services/favorites_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cache = CacheService();
  await cache.init();

  final exchangeClient = ExchangeClient();
  final conversionService =
      ConversionService(client: exchangeClient, cache: cache);
  final catalogService =
      CurrencyCatalogService(client: exchangeClient, cache: cache);
  final favoritesService = FavoritesService(cache: cache);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(
        conversionService: conversionService,
        catalogService: catalogService,
        favoritesService: favoritesService,
        cacheService: cache,
      )..initialize(),
      child: const OpenFXpediaApp(),
    ),
  );
}

class OpenFXpediaApp extends StatelessWidget {
  const OpenFXpediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'OpenFXpedia',
          debugShowCheckedModeBanner: false,
          themeMode: state.themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          home: const _HomeShell(),
        );
      },
    );
  }
}

ThemeData _buildLightTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0B5CAD),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD6E4FF),
    onPrimaryContainer: Color(0xFF001B3D),
    secondary: Color(0xFF006C67),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF88F1E7),
    onSecondaryContainer: Color(0xFF00201E),
    tertiary: Color(0xFF7B5700),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFDEA8),
    onTertiaryContainer: Color(0xFF261900),
    error: Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFF7F9FC),
    onSurface: Color(0xFF191C20),
    surfaceContainerHighest: Color(0xFFDDE3EA),
    onSurfaceVariant: Color(0xFF41484D),
    outline: Color(0xFF71787E),
    outlineVariant: Color(0xFFC1C7CE),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2E3135),
    onInverseSurface: Color(0xFFF0F1F5),
    inversePrimary: Color(0xFFA7C8FF),
    surfaceTint: Color(0xFF0B5CAD),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: const AppBarTheme(centerTitle: false),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

ThemeData _buildDarkTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA7C8FF),
    onPrimary: Color(0xFF002E68),
    primaryContainer: Color(0xFF0B447E),
    onPrimaryContainer: Color(0xFFD6E4FF),
    secondary: Color(0xFF6EDDD2),
    onSecondary: Color(0xFF003734),
    secondaryContainer: Color(0xFF00504C),
    onSecondaryContainer: Color(0xFF88F1E7),
    tertiary: Color(0xFFF0C670),
    onTertiary: Color(0xFF402D00),
    tertiaryContainer: Color(0xFF5C4100),
    onTertiaryContainer: Color(0xFFFFDEA8),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: Color(0xFF101417),
    onSurface: Color(0xFFE1E2E6),
    surfaceContainerHighest: Color(0xFF41484D),
    onSurfaceVariant: Color(0xFFC1C7CE),
    outline: Color(0xFF8B9298),
    outlineVariant: Color(0xFF41484D),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE1E2E6),
    onInverseSurface: Color(0xFF2E3135),
    inversePrimary: Color(0xFF0B5CAD),
    surfaceTint: Color(0xFFA7C8FF),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: const AppBarTheme(centerTitle: false),
    cardTheme: CardThemeData(
      color: const Color(0xFF171C20),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF171C20),
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF171C20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  bool _showingInitialCurrencyDialog = false;

  static const _screens = [
    ConverterScreen(),
    EncyclopediaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!_showingInitialCurrencyDialog &&
            state.loadingState == LoadingState.idle &&
            state.currencies.isNotEmpty &&
            (state.baseCurrency == null || state.targetCurrency == null)) {
          _showingInitialCurrencyDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _showInitialCurrencyPicker(context, state);
            if (mounted) {
              setState(() => _showingInitialCurrencyDialog = false);
            } else {
              _showingInitialCurrencyDialog = false;
            }
          });
        }

        return Scaffold(
          body: _screens[state.selectedTab],
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.selectedTab,
            onDestinationSelected: state.setSelectedTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.currency_exchange),
                label: 'Converter',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book),
                label: 'Encyclopedia',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showInitialCurrencyPicker(
    BuildContext context,
    AppState state,
  ) async {
    Currency? selectedFrom = state.baseCurrency ?? state.currencies.first;
    Currency? selectedTo = state.targetCurrency ??
        state.currencies.firstWhere(
          (currency) => currency.isoCode != selectedFrom!.isoCode,
          orElse: () => state.currencies.first,
        );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Choose your currencies'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Currency>(
                      initialValue: selectedFrom,
                      decoration: const InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                      ),
                      items: state.currencies
                          .map(
                            (currency) => DropdownMenuItem<Currency>(
                              value: currency,
                              child: Text(
                                '${currency.isoCode} — ${currency.name}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedFrom = value;
                          if (selectedTo?.isoCode == value.isoCode) {
                            selectedTo = state.currencies.firstWhere(
                              (currency) => currency.isoCode != value.isoCode,
                              orElse: () => value,
                            );
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Currency>(
                      initialValue: selectedTo,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(),
                      ),
                      items: state.currencies
                          .map(
                            (currency) => DropdownMenuItem<Currency>(
                              value: currency,
                              child: Text(
                                '${currency.isoCode} — ${currency.name}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedTo = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Select the currencies to prefill the converter.',
                    ),
                  ],
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: selectedFrom == null ||
                          selectedTo == null ||
                          selectedFrom!.isoCode == selectedTo!.isoCode
                      ? null
                      : () {
                          state.setCurrencyPair(
                            baseCurrency: selectedFrom!,
                            targetCurrency: selectedTo!,
                          );
                          state.setSelectedTab(0);
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
