import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'screens/home_screen.dart';
import 'services/weather_service.dart';
import 'services/drought_prediction_service.dart';
import 'services/location_service.dart';

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
        ChangeNotifierProvider(create: (_) => WeatherService()),
        ChangeNotifierProvider(create: (_) => DroughtPredictionService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
      ],
      child: MaterialApp(
        title: 'AgriAlert BF',
        debugShowCheckedModeBanner: false,
        theme: _buildBurkinabeTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildBurkinabeTheme() {
    // Palette de couleurs inspirée du Burkina Faso
    // Vert forêt (végétation), Rouge terre (latérite), Jaune or (soleil sahélien)
    const Color primaryGreen = Color(0xFF2D5016); // Vert profond agriculture
    const Color accentOrange = Color(0xFFE07B39); // Orange terre burkinabè
    const Color goldYellow = Color(0xFFF4C430); // Or sahélien
    const Color warmBeige = Color(0xFFF5E6D3); // Beige chaud harmattan
    const Color deepBrown = Color(0xFF5C4033); // Brun terre
    const Color alertRed = Color(0xFFD32F2F); // Rouge alerte sécheresse

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentOrange,
        tertiary: goldYellow,
        surface: warmBeige,
        error: alertRed,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryGreen,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: deepBrown,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          color: deepBrown,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          color: deepBrown.withOpacity(0.8),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: deepBrown.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }
}
