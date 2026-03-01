// Modèles de données pour l'application AgriAlert BF

class WeatherData {
  final String location;
  final DateTime date;
  final double temperature;
  final double humidity;
  final double precipitation;
  final double windSpeed;
  final String weatherCondition;
  
  WeatherData({
    required this.location,
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCondition,
  });
  
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      precipitation: (json['precipitation'] ?? 0.0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
      weatherCondition: json['weatherCondition'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'date': date.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'precipitation': precipitation,
      'windSpeed': windSpeed,
      'weatherCondition': weatherCondition,
    };
  }
}

class DroughtPrediction {
  final DateTime date;
  final DroughtRiskLevel riskLevel;
  final double riskScore;
  final List<String> recommendations;
  final String description;
  
  DroughtPrediction({
    required this.date,
    required this.riskLevel,
    required this.riskScore,
    required this.recommendations,
    required this.description,
  });
  
  factory DroughtPrediction.fromScore(double score, DateTime date) {
    DroughtRiskLevel level;
    List<String> recommendations;
    String description;
    
    if (score < 0.3) {
      level = DroughtRiskLevel.low;
      description = 'Risque de sécheresse faible. Conditions favorables pour l\'agriculture.';
      recommendations = [
        'Maintenir l\'irrigation régulière',
        'Continuer les pratiques agricoles normales',
        'Surveiller les prévisions météorologiques',
      ];
    } else if (score < 0.6) {
      level = DroughtRiskLevel.moderate;
      description = 'Risque modéré de sécheresse. Vigilance recommandée.';
      recommendations = [
        'Augmenter la fréquence d\'irrigation',
        'Privilégier les cultures résistantes à la sécheresse (mil, sorgho)',
        'Préparer des sources d\'eau alternatives',
        'Appliquer du paillis pour conserver l\'humidité du sol',
      ];
    } else {
      level = DroughtRiskLevel.high;
      description = 'Risque élevé de sécheresse. Actions urgentes nécessaires.';
      recommendations = [
        'URGENT: Irriguer abondamment 2-3 fois par jour',
        'Planter uniquement des variétés ultra-résistantes',
        'Créer des systèmes de récupération d\'eau',
        'Contacter les services agricoles locaux',
        'Envisager des cultures de contre-saison',
      ];
    }
    
    return DroughtPrediction(
      date: date,
      riskLevel: level,
      riskScore: score,
      recommendations: recommendations,
      description: description,
    );
  }
}

enum DroughtRiskLevel {
  low,
  moderate,
  high;
  
  String get label {
    switch (this) {
      case DroughtRiskLevel.low:
        return 'Faible';
      case DroughtRiskLevel.moderate:
        return 'Modéré';
      case DroughtRiskLevel.high:
        return 'Élevé';
    }
  }
  
  String get labelMoore {
    switch (this) {
      case DroughtRiskLevel.low:
        return 'Kãensã';
      case DroughtRiskLevel.moderate:
        return 'Tõnd yelle';
      case DroughtRiskLevel.high:
        return 'Gãnd-gãndo';
    }
  }
}

class RegionData {
  final String name;
  final String nameMoore;
  final double latitude;
  final double longitude;
  final DroughtRiskLevel? currentRisk;
  
  RegionData({
    required this.name,
    required this.nameMoore,
    required this.latitude,
    required this.longitude,
    this.currentRisk,
  });
}

// Régions principales du Burkina Faso
final List<RegionData> burkinaRegions = [
  RegionData(name: 'Ouagadougou', nameMoore: 'Wogodogo', latitude: 12.3714, longitude: -1.5197),
  RegionData(name: 'Bobo-Dioulasso', nameMoore: 'Sia', latitude: 11.1770, longitude: -4.2979),
  RegionData(name: 'Koudougou', nameMoore: 'Kudugu', latitude: 12.2528, longitude: -2.3625),
  RegionData(name: 'Ouahigouya', nameMoore: 'Waiguya', latitude: 13.5828, longitude: -2.4214),
  RegionData(name: 'Banfora', nameMoore: 'Banfora', latitude: 10.6333, longitude: -4.7500),
  RegionData(name: 'Fada N\'Gourma', nameMoore: 'Fada', latitude: 12.0611, longitude: 0.3586),
  RegionData(name: 'Kaya', nameMoore: 'Kaya', latitude: 13.0925, longitude: -1.0844),
  RegionData(name: 'Tenkodogo', nameMoore: 'Tẽkodogo', latitude: 11.7800, longitude: -0.3700),
  RegionData(name: 'Dori', nameMoore: 'Dori', latitude: 14.0344, longitude: -0.0344),
  RegionData(name: 'Gaoua', nameMoore: 'Gaoua', latitude: 10.3250, longitude: -3.1811),
];
