import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion du thème (sombre/clair)
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // Couleurs du thème
  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _accentOrange = Color(0xFFFF9800);
  static const Color _goldYellow = Color(0xFFFFC107);
  static const Color _warmBeige = Color(0xFFF5E6D3);
  static const Color _deepBrown = Color(0xFF5C4033);
  static const Color _alertRed = Color(0xFFD32F2F);
  static const Color _skyBlue = Color(0xFF2196F3);

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, mode == ThemeMode.dark);
    notifyListeners();
  }

  // Thème clair
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _primaryGreen,
        secondary: _accentOrange,
        tertiary: _goldYellow,
        surface: _warmBeige,
        error: _alertRed,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accentOrange,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Thème sombre
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primaryGreen,
        secondary: _accentOrange,
        tertiary: _goldYellow,
        surface: const Color(0xFF1E1E1E),
        error: _alertRed,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2C),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accentOrange,
        foregroundColor: Colors.white,
      ),
    );
  }
}
