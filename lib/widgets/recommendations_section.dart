import 'package:flutter/material.dart';
import '../models/data_models.dart';

class RecommendationsSection extends StatelessWidget {
  final DroughtPrediction prediction;

  const RecommendationsSection({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recommandations Agricoles',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...prediction.recommendations.asMap().entries.map((entry) {
              return _buildRecommendationItem(
                context,
                entry.value,
                entry.key + 1,
              );
            }).toList(),
            const SizedBox(height: 16),
            _buildAdditionalTips(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
    BuildContext context,
    String recommendation,
    int index,
  ) {
    final theme = Theme.of(context);
    final isUrgent = recommendation.contains('URGENT');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgent
            ? theme.colorScheme.error.withOpacity(0.08)
            : theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? theme.colorScheme.error.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isUrgent
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation.replaceAll('URGENT: ', ''),
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
                color: isUrgent
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalTips(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondary.withOpacity(0.1),
            theme.colorScheme.tertiary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Conseils généraux',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipRow(
            context,
            Icons.phone,
            'En cas d\'urgence, contactez les services agricoles locaux',
          ),
          const SizedBox(height: 8),
          _buildTipRow(
            context,
            Icons.share,
            'Partagez cette alerte avec vos voisins agriculteurs',
          ),
          const SizedBox(height: 8),
          _buildTipRow(
            context,
            Icons.groups,
            'Rejoignez une coopérative agricole pour un soutien mutuel',
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.secondary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
