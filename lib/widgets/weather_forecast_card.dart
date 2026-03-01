import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart';

class WeatherForecastCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherForecastCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = _isToday(weather.date);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isToday
            ? Border.all(
                color: theme.colorScheme.secondary,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  _formatDate(weather.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isToday
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Aujourd\'hui',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            _buildWeatherIcon(),
            Column(
              children: [
                Text(
                  '${weather.temperature.toStringAsFixed(0)}°C',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 14,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        weather.precipitation == 0.0
                            ? 'Aucune pluie'
                            : '${weather.precipitation.toStringAsFixed(1)} mm',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEE dd', 'fr_FR');
    return formatter.format(date);
  }

  Widget _buildWeatherIcon() {
    IconData icon;
    Color color;

    if (weather.precipitation > 5) {
      icon = Icons.water;
      color = Colors.blue;
    } else if (weather.temperature > 35) {
      icon = Icons.wb_sunny;
      color = Colors.orange;
    } else if (weather.temperature > 25) {
      icon = Icons.wb_sunny_outlined;
      color = Colors.amber;
    } else {
      icon = Icons.cloud;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 32,
        color: color,
      ),
    );
  }
}
