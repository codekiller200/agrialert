import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import 'dart:math' as math;

/// Service de prédiction de sécheresse utilisant un modèle simplifié
/// Pour le MVP, utilise un algorithme de score basé sur plusieurs indicateurs
/// Dans une version future, sera remplacé par TensorFlow Lite
class DroughtPredictionService extends ChangeNotifier {
  DroughtPrediction? _currentPrediction;
  List<DroughtPrediction>? _weeklyPredictions;
  bool _isLoading = false;
  String? _errorMessage;
  
  DroughtPrediction? get currentPrediction => _currentPrediction;
  List<DroughtPrediction>? get weeklyPredictions => _weeklyPredictions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Calcule le risque de sécheresse basé sur les données météorologiques
  /// Algorithme simplifié pour le MVP (sera remplacé par modèle TFLite)
  Future<DroughtPrediction> predictDrought({
    required List<WeatherData> historicalData,
    required List<WeatherData> forecastData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulation d'un délai de traitement IA
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Calcul du score de risque de sécheresse (0.0 à 1.0)
      double riskScore = _calculateDroughtRiskScore(
        historicalData: historicalData,
        forecastData: forecastData,
      );
      
      final prediction = DroughtPrediction.fromScore(
        riskScore,
        DateTime.now(),
      );
      
      _currentPrediction = prediction;
      
      // Sauvegarde dans le cache local
      await _savePredictionToCache(prediction);
      
      _isLoading = false;
      notifyListeners();
      
      return prediction;
    } catch (e) {
      _errorMessage = 'Erreur lors de la prédiction: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  /// Génère des prédictions pour les 7 prochains jours
  Future<List<DroughtPrediction>> predictWeeklyDrought({
    required List<WeatherData> historicalData,
    required List<WeatherData> weeklyForecast,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      List<DroughtPrediction> predictions = [];
      
      for (int i = 0; i < 7 && i < weeklyForecast.length; i++) {
        final dayForecast = weeklyForecast[i];
        
        // Données historiques + prévisions jusqu'à ce jour
        final relevantData = [
          ...historicalData,
          ...weeklyForecast.sublist(0, i + 1),
        ];
        
        double riskScore = _calculateDroughtRiskScore(
          historicalData: relevantData,
          forecastData: [dayForecast],
        );
        
        predictions.add(DroughtPrediction.fromScore(
          riskScore,
          dayForecast.date,
        ));
      }
      
      _weeklyPredictions = predictions;
      _isLoading = false;
      notifyListeners();
      
      return predictions;
    } catch (e) {
      _errorMessage = 'Erreur lors des prédictions hebdomadaires: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  /// Algorithme de calcul du score de risque de sécheresse
  /// Basé sur plusieurs indicateurs météorologiques
  double _calculateDroughtRiskScore({
    required List<WeatherData> historicalData,
    required List<WeatherData> forecastData,
  }) {
    // Indicateurs utilisés pour le calcul
    double precipitationScore = _calculatePrecipitationScore(
      [...historicalData, ...forecastData]
    );
    double temperatureScore = _calculateTemperatureScore(forecastData);
    double humidityScore = _calculateHumidityScore(forecastData);
    
    // Pondération des indicateurs
    // Précipitations: 50%, Température: 30%, Humidité: 20%
    double finalScore = (
      precipitationScore * 0.50 +
      temperatureScore * 0.30 +
      humidityScore * 0.20
    );
    
    // Normalisation entre 0 et 1
    return finalScore.clamp(0.0, 1.0);
  }
  
  /// Score basé sur les précipitations (cumul des 7-14 derniers jours)
  double _calculatePrecipitationScore(List<WeatherData> data) {
    if (data.isEmpty) return 0.5;
    
    // Prendre les 14 derniers jours
    final recentData = data.length > 14 
        ? data.sublist(data.length - 14) 
        : data;
    
    double totalPrecipitation = recentData.fold(
      0.0, 
      (sum, weather) => sum + weather.precipitation
    );
    
    // Seuils pour le Burkina Faso (zone sahélienne)
    // Excellent: >100mm, Bon: 50-100mm, Modéré: 20-50mm, Faible: <20mm
    if (totalPrecipitation > 100) return 0.0;  // Pas de risque
    if (totalPrecipitation > 50) return 0.2;   // Risque faible
    if (totalPrecipitation > 20) return 0.5;   // Risque modéré
    if (totalPrecipitation > 5) return 0.8;    // Risque élevé
    return 1.0;  // Risque très élevé
  }
  
  /// Score basé sur les températures élevées
  double _calculateTemperatureScore(List<WeatherData> data) {
    if (data.isEmpty) return 0.5;
    
    double avgTemperature = data.fold(
      0.0, 
      (sum, weather) => sum + weather.temperature
    ) / data.length;
    
    // Seuils adaptés au climat sahélien du Burkina Faso
    if (avgTemperature < 30) return 0.0;   // Pas de risque
    if (avgTemperature < 35) return 0.3;   // Risque faible
    if (avgTemperature < 40) return 0.6;   // Risque modéré
    return 0.9;  // Risque élevé
  }
  
  /// Score basé sur l'humidité de l'air
  double _calculateHumidityScore(List<WeatherData> data) {
    if (data.isEmpty) return 0.5;
    
    double avgHumidity = data.fold(
      0.0, 
      (sum, weather) => sum + weather.humidity
    ) / data.length;
    
    // Humidité faible = risque élevé de sécheresse
    if (avgHumidity > 60) return 0.0;   // Pas de risque
    if (avgHumidity > 40) return 0.3;   // Risque faible
    if (avgHumidity > 25) return 0.6;   // Risque modéré
    return 0.9;  // Risque élevé
  }
  
  /// Sauvegarde la prédiction dans le cache local (mode offline)
  Future<void> _savePredictionToCache(DroughtPrediction prediction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_risk_score', prediction.riskScore);
      await prefs.setString('last_prediction_date', prediction.date.toIso8601String());
      await prefs.setString('last_risk_level', prediction.riskLevel.toString());
    } catch (e) {
      debugPrint('Erreur sauvegarde cache: $e');
    }
  }
  
  /// Charge la dernière prédiction depuis le cache (mode offline)
  Future<DroughtPrediction?> loadCachedPrediction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final riskScore = prefs.getDouble('last_risk_score');
      final dateString = prefs.getString('last_prediction_date');
      
      if (riskScore != null && dateString != null) {
        return DroughtPrediction.fromScore(
          riskScore,
          DateTime.parse(dateString),
        );
      }
    } catch (e) {
      debugPrint('Erreur chargement cache: $e');
    }
    return null;
  }
}
