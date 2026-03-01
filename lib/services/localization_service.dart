import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion des langues (français, mooré, dioula)
class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale _locale = const Locale('fr');
  Locale get locale => _locale;

  // Langues supportées
  static const Map<String, String> supportedLanguages = {
    'fr': 'Français',
    'mo': 'Mooré',
    'di': 'Dioula',
  };

  LocalizationService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'fr';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (supportedLanguages.containsKey(languageCode)) {
      _locale = Locale(languageCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }

  String getLanguageName(String code) {
    return supportedLanguages[code] ?? 'Français';
  }
}

// Traductions
class AppTranslations {
  static final Map<String, Map<String, String>> _translations = {
    // Français
    'fr': {
      'app_name': 'AgriAlert BF',
      'home': 'Accueil',
      'alerts': 'Alertes',
      'market': 'Marché',
      'settings': 'Paramètres',
      'drought_risk': 'Risque de sécheresse',
      'weather': 'Météo',
      'forecast': 'Prévisions',
      'recommendations': 'Recommandations',
      'low_risk': 'Faible',
      'moderate_risk': 'Modéré',
      'high_risk': 'Élevé',
      'temperature': 'Température',
      'humidity': 'Humidité',
      'precipitation': 'Précipitations',
      'wind': 'Vent',
      'today': "Aujourd'hui",
      'loading': 'Chargement...',
      'error': 'Erreur',
      'retry': 'Réessayer',
      'no_data': 'Aucune donnée',
      'language': 'Langue',
      'theme': 'Thème',
      'light_mode': 'Mode clair',
      'dark_mode': 'Mode sombre',
      'notifications': 'Notifications',
      'enable_notifications': 'Activer les notifications',
      'market_prices': 'Prix du marché',
      'crops': 'Cultures',
      'soil_moisture': 'Humidité du sol',
      'select_region': 'Sélectionner une région',
      'refresh': 'Actualiser',
      'share': 'Partager',
      'close': 'Fermer',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'search': 'Rechercher',
      'no_internet': 'Pas de connexion internet',
      'offline_mode': 'Mode hors-ligne',
      'syncing': 'Synchronisation...',
      'last_update': 'Dernière mise à jour',
      'urgent': 'URGENT',
      'warning': 'Avertissement',
      'info': 'Information',
      'severe_heat': 'Chaleur extrême',
      'heavy_rain': 'Forte pluie',
      'drought_alert': 'Alerte sécheresse',
      'frost_alert': 'Alerte gel',
    },
    // Mooré
    'mo': {
      'app_name': 'AgriAlert BF',
      'home': 'Tɩtɩnɛ',
      'alerts': 'Nandana',
      'market': 'Kɩɣyɩ',
      'settings': 'Tʋmbu',
      'drought_risk': 'Bɩsɩm-bɩsɩm fãa',
      'weather': 'Tɩsɩ',
      'forecast': 'Wɩsɩ kɩcɛ',
      'recommendations': 'Wɩsɩlɩ',
      'low_risk': 'Pɩɣa',
      'moderate_risk': 'Wɩ-tɩŋa',
      'high_risk': 'Kɩɣ',
      'temperature': 'Sɩkɩ-tɩŋa',
      'humidity': 'Tɩ-wɩso',
      'precipitation': 'Sɩ-bɩsɩ',
      'wind': 'Bɩlɩ',
      'today': 'Bɩsɩgo',
      'loading': 'Kʋyɩ...',
      'error': 'Tʋmbu',
      'retry': 'Fɛnɩ kɩcɛ',
      'no_data': 'A-data yʋ',
      'language': 'Tɩsɩna',
      'theme': 'Wɩsɩ',
      'light_mode': 'Wɩsɩ fɛ',
      'dark_mode': 'Wɩsɩ sɩ',
      'notifications': 'Nandana',
      'enable_notifications': 'Nandana fɛ',
      'market_prices': 'Kɩɣyɩ sɩtɩ',
      'crops': 'Bɩsɩm',
      'soil_moisture': 'Tɩ-wɩso tɩta',
      'select_region': 'Rɩɣma fɛ',
      'refresh': 'Leba',
      'share': 'Wɩlɩ',
      'close': 'Sɩ',
      'save': 'Tʋ',
      'cancel': 'Tõ',
      'confirm': 'Fɛnɩ',
      'search': 'Sʋmba',
      'no_internet': 'Internet a-yʋ',
      'offline_mode': 'A-internet fãa',
      'syncing': 'Kɩ-taalɩ...',
      'last_update': 'Lebg n-kɛ tʋmbu',
      'urgent': 'Sʋka',
      'warning': 'Pɩɣlɩ',
      'info': 'Fait',
      'severe_heat': 'Sɩkɩ-tɩŋa kɩɣ',
      'heavy_rain': 'Sɩ-bɩsɩ kɩɣ',
      'drought_alert': 'Bɩsɩm-bɩsɩm nandana',
      'frost_alert': 'Sɩkɩ-tɩŋa kaak',
    },
    // Dioula
    'di': {
      'app_name': 'AgriAlert BF',
      'home': 'Bawo',
      'alerts': 'Sɛgɛ',
      'market': 'Bɔn',
      'settings': 'Kunafoni',
      'drought_risk': 'Dugukɛnafɛ',
      'weather': 'Mali',
      'forecast': 'Wɛrɛ',
      'recommendations': 'Sɛbɛni',
      'low_risk': 'Sira',
      'moderate_risk': 'Wɛrɛw',
      'high_risk': 'Camɛ',
      'temperature': 'Kalansaba',
      'humidity': 'Dilaw',
      'precipitation': 'Suru',
      'wind': 'Jali',
      'today': 'Bɔnna',
      'loading': 'Kɛ...',
      'error': 'Cɛ',
      'retry': 'Kɛ cɛ',
      'no_data': 'A data',
      'language': 'Kalansabɔrɔ',
      'theme': 'Bawo',
      'light_mode': 'Bawo jɛrɛ',
      'dark_mode': 'Bawo sumɔ',
      'notifications': 'Sɛgɛ',
      'enable_notifications': 'Sɛgɛ fɔ',
      'market_prices': 'Bɔn kɔn',
      'crops': 'Kɛnafɔ',
      'soil_moisture': 'Dilaw kɛnafɔ',
      'select_region': 'Sira jala',
      'refresh': 'Sabati',
      'share': 'Kɔnata',
      'close': 'Tumɛ',
      'save': 'Da',
      'cancel': 'Ban',
      'confirm': 'Sɔn',
      'search': 'Sɔnni',
      'no_internet': 'Internet bɛ',
      'offline_mode': 'Internet fɛ',
      'syncing': 'Sɔnni...',
      'last_update': 'Kɛcɛ kɔn',
      'urgent': 'Woyi',
      'warning': 'Kɛcɛ',
      'info': 'Kɛ',
      'severe_heat': 'Kalansaba camel',
      'heavy_rain': 'Suru camel',
      'drought_alert': 'Dugukɛnafɛ sɛgɛ',
      'frost_alert': 'Kalansaba sumɔ sɛgɛ',
    },
  };

  static String translate(String key, String locale) {
    return _translations[locale]?[key] ?? _translations['fr']?[key] ?? key;
  }
}
