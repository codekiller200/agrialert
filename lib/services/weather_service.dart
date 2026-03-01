import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

/// Service de récupération des données météorologiques
/// Utilise l'API Open-Meteo (gratuite, sans clé)
class WeatherService extends ChangeNotifier {
  // ==================== CONSTANTES ====================
  static const String _baseUrl = 'https://api.open-meteo.com/v1';
  static const String _timezone = 'Africa/Ouagadougou';
  static const Duration _timeout = Duration(seconds: 10);
  static const int _forecastDays = 7;
  static const int _historicalDays = 14;

  // Seuils pour les conditions météorologiques
  static const double _precipitationThreshold = 5.0;
  static const double _veryHotThreshold = 35.0;
  static const double _warmThreshold = 25.0;

  // ==================== ÉTAT ====================
  List<WeatherData>? _currentWeather;
  List<WeatherData>? _forecast;
  List<WeatherData>? _historical;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdate;

  // ==================== GETTERS ====================
  List<WeatherData>? get currentWeather => _currentWeather;
  List<WeatherData>? get forecast => _forecast;
  List<WeatherData>? get historical => _historical;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdate => _lastUpdate;

  /// Vérifie si les données en cache sont disponibles
  bool get hasCachedData => _currentWeather != null || _forecast != null;

  // ==================== MÉTHODES PUBLIQUES ====================

  /// Récupère les données météorologiques pour une localisation
  Future<void> fetchWeatherData({
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    // Validation des paramètres d'entrée
    if (!_validateCoordinates(latitude, longitude)) {
      _setError('Coordonnées invalides');
      return;
    }

    _setLoading(true);

    try {
      // Exécution parallèle des requêtes API
      final currentWeather =
          await _fetchCurrentWeather(latitude, longitude, location);
      final forecastData = await _fetchDailyForecast(
          latitude, longitude, location, _forecastDays);
      final historicalData =
          await _fetchHistoricalData(latitude, longitude, location);

      _updateWeatherData(
        current: currentWeather,
        forecast: forecastData,
        historical: historicalData,
      );

      await _saveToCache();
      _setLoading(false);
    } catch (e) {
      _handleError('Erreur de connexion. Chargement des données offline...');
      await loadCachedData();
    }
  }

  /// Charge les données depuis le cache (mode offline)
  Future<void> loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool hasData = false;

      // Chargement données actuelles
      final cachedCurrent = prefs.getString('cached_current_weather');
      if (cachedCurrent != null) {
        _currentWeather = [WeatherData.fromJson(json.decode(cachedCurrent))];
        hasData = true;
      }

      // Chargement prévisions
      final cachedForecast = prefs.getString('cached_forecast');
      if (cachedForecast != null) {
        final List<dynamic> forecastList = json.decode(cachedForecast);
        _forecast = forecastList
            .map((w) => WeatherData.fromJson(w as Map<String, dynamic>))
            .toList();
        hasData = true;
      }

      // Chargement données historiques
      final cachedHistorical = prefs.getString('cached_historical');
      if (cachedHistorical != null) {
        final List<dynamic> historicalList = json.decode(cachedHistorical);
        _historical = historicalList
            .map((w) => WeatherData.fromJson(w as Map<String, dynamic>))
            .toList();
        hasData = true;
      }

      // Horodatage du cache
      final lastUpdate = prefs.getString('last_cache_update');
      if (lastUpdate != null) {
        _lastUpdate = DateTime.tryParse(lastUpdate);
      }

      if (hasData) {
        _setLoading(false);
      } else {
        _setError('Aucune donnée disponible. Vérifiez votre connexion.');
      }
    } catch (e) {
      debugPrint('Erreur chargement cache: $e');
      _setError('Erreur lors du chargement du cache');
    }
  }

  /// Efface toutes les données en cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_current_weather');
      await prefs.remove('cached_forecast');
      await prefs.remove('cached_historical');
      await prefs.remove('last_cache_update');

      _currentWeather = null;
      _forecast = null;
      _historical = null;
      _lastUpdate = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur suppression cache: $e');
    }
  }

  // ==================== MÉTHODES PRIVÉES - API ====================

  Future<WeatherData> _fetchCurrentWeather(
    double latitude,
    double longitude,
    String location,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/forecast?'
      'latitude=$latitude&'
      'longitude=$longitude&'
      'current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m&'
      'timezone=$_timezone',
    );

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>?;

      if (current == null) {
        throw Exception('Données current manquantes');
      }

      return WeatherData(
        location: location,
        date: DateTime.tryParse(current['time']?.toString() ?? '') ??
            DateTime.now(),
        temperature: _toDouble(current['temperature_2m']),
        humidity: _toDouble(current['relative_humidity_2m']),
        precipitation: _toDouble(current['precipitation']),
        windSpeed: _toDouble(current['wind_speed_10m']),
        weatherCondition: _determineCondition(
          current['temperature_2m'],
          current['precipitation'],
        ),
      );
    }
    throw HttpException('Erreur API: ${response.statusCode}');
  }

  Future<List<WeatherData>> _fetchDailyForecast(
    double latitude,
    double longitude,
    String location,
    int days,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/forecast?'
      'latitude=$latitude&'
      'longitude=$longitude&'
      'daily=temperature_2m_max,relative_humidity_2m_mean,'
      'precipitation_sum,wind_speed_10m_max&'
      'timezone=$_timezone&'
      'forecast_days=$days',
    );

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final daily = data['daily'] as Map<String, dynamic>?;

      return _parseDailyData(daily, location);
    }
    throw HttpException('Erreur API: ${response.statusCode}');
  }

  Future<List<WeatherData>> _fetchHistoricalData(
    double latitude,
    double longitude,
    String location,
  ) async {
    final endDate = DateTime.now().subtract(const Duration(days: 1));
    final startDate = endDate.subtract(Duration(days: _historicalDays));

    final uri = Uri.parse(
      '$_baseUrl/forecast?'
      'latitude=$latitude&'
      'longitude=$longitude&'
      'start_date=${_formatDate(startDate)}&'
      'end_date=${_formatDate(endDate)}&'
      'daily=temperature_2m_max,relative_humidity_2m_mean,'
      'precipitation_sum,wind_speed_10m_max&'
      'timezone=$_timezone',
    );

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final daily = data['daily'] as Map<String, dynamic>?;

      return _parseDailyData(daily, location);
    }
    throw HttpException('Erreur API: ${response.statusCode}');
  }

  // ==================== MÉTHODES PRIVÉES - PARSING ====================

  List<WeatherData> _parseDailyData(
    Map<String, dynamic>? daily,
    String location,
  ) {
    if (daily == null) {
      return [];
    }

    final times = daily['time'] as List<dynamic>?;
    if (times == null || times.isEmpty) {
      return [];
    }

    return List.generate(times.length, (i) {
      return WeatherData(
        location: location,
        date: DateTime.tryParse(times[i].toString()) ?? DateTime.now(),
        temperature: _toDoubleIndex(daily['temperature_2m_max'], i),
        humidity: _toDoubleIndex(daily['relative_humidity_2m_mean'], i),
        precipitation: _toDoubleIndex(daily['precipitation_sum'], i),
        windSpeed: _toDoubleIndex(daily['wind_speed_10m_max'], i),
        weatherCondition: _determineCondition(
          daily['temperature_2m_max']?[i],
          daily['precipitation_sum']?[i],
        ),
      );
    });
  }

  String _determineCondition(dynamic temp, dynamic precip) {
    final precipValue = _toDouble(precip);
    final tempValue = _toDouble(temp);

    if (precipValue > _precipitationThreshold) {
      return 'Pluvieux';
    } else if (tempValue > _veryHotThreshold) {
      return 'Très chaud';
    } else if (tempValue > _warmThreshold) {
      return 'Ensoleillé';
    }
    return 'Dégagé';
  }

  // ==================== MÉTHODES PRIVÉES - UTILITAIRES ====================

  bool _validateCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double _toDoubleIndex(dynamic list, int index) {
    if (list == null || list is! List || index >= list.length) {
      return 0.0;
    }
    return _toDouble(list[index]);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _updateWeatherData({
    required WeatherData current,
    required List<WeatherData> forecast,
    required List<WeatherData> historical,
  }) {
    _currentWeather = [current];
    _forecast = forecast;
    _historical = historical;
    _lastUpdate = DateTime.now();
    _errorMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _handleError(String message) {
    debugPrint(message);
    _setError(message);
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentWeather != null && _currentWeather!.isNotEmpty) {
        await prefs.setString(
          'cached_current_weather',
          json.encode(_currentWeather!.first.toJson()),
        );
      }

      if (_forecast != null) {
        await prefs.setString(
          'cached_forecast',
          json.encode(_forecast!.map((w) => w.toJson()).toList()),
        );
      }

      if (_historical != null) {
        await prefs.setString(
          'cached_historical',
          json.encode(_historical!.map((w) => w.toJson()).toList()),
        );
      }

      await prefs.setString(
        'last_cache_update',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Erreur sauvegarde cache: $e');
    }
  }
}

/// Exception personnalisée pour les erreurs HTTP
class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}
