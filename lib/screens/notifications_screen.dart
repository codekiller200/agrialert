import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/localization_service.dart';
import '../services/theme_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<NotificationService>(context);
    final theme = Theme.of(context);
    final locale =
        Provider.of<LocalizationService>(context).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('alerts', locale)),
        actions: [
          if (notifications.unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: () => notifications.markAllAsRead(),
              child: Text(
                'Tout marquer lu',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: notifications.notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications.notifications[index];
                return _buildNotificationCard(
                  context,
                  notification,
                  locale,
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationItem notification,
    String locale,
  ) {
    final theme = Theme.of(context);

    Color priorityColor;
    IconData priorityIcon;

    switch (notification.priority) {
      case NotificationPriority.urgent:
        priorityColor = const Color(0xFFD32F2F);
        priorityIcon = Icons.warning;
        break;
      case NotificationPriority.high:
        priorityColor = const Color(0xFFFF9800);
        priorityIcon = Icons.priority_high;
        break;
      case NotificationPriority.medium:
        priorityColor = const Color(0xFF2196F3);
        priorityIcon = Icons.info;
        break;
      case NotificationPriority.low:
        priorityColor = const Color(0xFF4CAF50);
        priorityIcon = Icons.check_circle;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? theme.cardTheme.color
            : theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? Colors.transparent
              : theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Provider.of<NotificationService>(context, listen: false)
                .markAsRead(notification.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône de type
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.typeIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            priorityIcon,
                            size: 16,
                            color: priorityColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bouton supprimer
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  onPressed: () {
                    Provider.of<NotificationService>(context, listen: false)
                        .deleteNotification(notification.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
