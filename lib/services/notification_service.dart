import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import 'market_service.dart';

/// Service de notifications intelligentes
class NotificationService extends ChangeNotifier {
  static const String _notificationsEnabledKey = 'notifications_enabled';

  bool _notificationsEnabled = true;
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;

  bool get notificationsEnabled => _notificationsEnabled;
  List<NotificationItem> get notifications => _notifications;
  List<NotificationItem> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  bool get isLoading => _isLoading;

  NotificationService() {
    _loadSettings();
    _generateSampleNotifications();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    notifyListeners();
  }

  void _generateSampleNotifications() {
    _notifications = [
      NotificationItem(
        id: '1',
        type: NotificationType.weatherAlert,
        title: 'Alerte chaleur extrême',
        message:
            'Température prévue: 42°C à Ouagadougou. Buvez beaucoup d\'eau.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        priority: NotificationPriority.high,
      ),
      NotificationItem(
        id: '2',
        type: NotificationType.droughtAlert,
        title: 'Alerte sécheresse',
        message: 'Risque élevé de sécheresse détecté dans la région du Sahel.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
        priority: NotificationPriority.urgent,
      ),
      NotificationItem(
        id: '3',
        type: NotificationType.marketPrice,
        title: 'Prix du mil en hausse',
        message:
            'Le prix du mil a augmenté de 15% cette semaine à Bobo-Dioulasso.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        priority: NotificationPriority.medium,
      ),
      NotificationItem(
        id: '4',
        type: NotificationType.rainAlert,
        title: 'Forte pluie prévue',
        message:
            'Forte pluie attendue dans les régions du Sud-Ouest. Protégez vos cultures.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        priority: NotificationPriority.high,
      ),
    ];
    notifyListeners();
  }

  Future<void> checkAndGenerateAlerts({
    DroughtPrediction? droughtPrediction,
    WeatherData? currentWeather,
    List<MarketData>? marketData,
  }) async {
    if (!_notificationsEnabled) return;

    // Alerte sécheresse
    if (droughtPrediction != null &&
        droughtPrediction.riskLevel == DroughtRiskLevel.high) {
      addNotification(
        type: NotificationType.droughtAlert,
        title: 'Alerte sécheresse',
        message:
            'Risque élevé de sécheresse détecté. ${droughtPrediction.description}',
        priority: NotificationPriority.urgent,
      );
    }

    // Alerte chaleur extrême
    if (currentWeather != null && currentWeather.temperature > 40) {
      addNotification(
        type: NotificationType.weatherAlert,
        title: 'Alerte chaleur extrême',
        message:
            'Température prévue: ${currentWeather.temperature.toStringAsFixed(0)}°C. Buvez beaucoup d\'eau.',
        priority: NotificationPriority.high,
      );
    }

    // Alerte forte pluie
    if (currentWeather != null && currentWeather.precipitation > 20) {
      addNotification(
        type: NotificationType.rainAlert,
        title: 'Forte pluie prévue',
        message:
            'Forte pluie attendue (${currentWeather.precipitation.toStringAsFixed(1)} mm). Protégez vos cultures.',
        priority: NotificationPriority.high,
      );
    }

    // Alerte prix du marché
    if (marketData != null) {
      for (var data in marketData) {
        if (data.priceChange > 20) {
          addNotification(
            type: NotificationType.marketPrice,
            title:
                'Prix du ${data.cropName} en ${data.priceChange > 0 ? 'hausse' : 'baisse'}',
            message:
                'Variation de ${data.priceChange.abs().toStringAsFixed(0)}% cette semaine.',
            priority: NotificationPriority.medium,
          );
        }
      }
    }
  }

  void addNotification({
    required NotificationType type,
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.medium,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
      priority: priority,
    );

    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}

enum NotificationType {
  weatherAlert,
  droughtAlert,
  rainAlert,
  frostAlert,
  marketPrice,
  diseaseAlert,
  general,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final NotificationPriority priority;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.priority = NotificationPriority.medium,
  });

  String get typeIcon {
    switch (type) {
      case NotificationType.weatherAlert:
        return '🌡️';
      case NotificationType.droughtAlert:
        return '🏜️';
      case NotificationType.rainAlert:
        return '🌧️';
      case NotificationType.frostAlert:
        return '❄️';
      case NotificationType.marketPrice:
        return '📊';
      case NotificationType.diseaseAlert:
        return '🦠';
      case NotificationType.general:
        return 'ℹ️';
    }
  }
}
