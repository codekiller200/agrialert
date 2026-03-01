import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'services/weather_service.dart';
import 'services/drought_prediction_service.dart';
import 'services/location_service.dart';
import 'services/theme_service.dart';
import 'services/localization_service.dart';
import 'services/notification_service.dart';
import 'services/market_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des dates pour la locale française
  await initializeDateFormatting('fr_FR', null);

  // Configuration de l'orientation et de la barre de statut
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AgriAlertApp());
}

class AgriAlertApp extends StatelessWidget {
  const AgriAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services principaux
        ChangeNotifierProvider(create: (_) => WeatherService()),
        ChangeNotifierProvider(create: (_) => DroughtPredictionService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        // Nouveaux services
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => MarketService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return Consumer<LocalizationService>(
            builder: (context, localizationService, child) {
              return MaterialApp(
                title: 'AgriAlert BF',
                debugShowCheckedModeBanner: false,
                theme: ThemeService.lightTheme,
                darkTheme: ThemeService.darkTheme,
                themeMode: themeService.themeMode,
                locale: localizationService.locale,
                supportedLocales: const [
                  Locale('fr', 'FR'),
                  Locale('mo', 'MO'),
                  Locale('di', 'DI'),
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
