import 'package:flutter/material.dart';
import '../models/data_models.dart';
import 'dart:math' as math;

class DroughtRiskCard extends StatelessWidget {
  final DroughtPrediction prediction;

  const DroughtRiskCard({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = _getRiskColor();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            riskColor,
            riskColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Motif décoratif en arrière-plan (inspiré des tissus burkinabè)
          Positioned(
            right: -30,
            top: -30,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: math.pi / 6,
                child: Icon(
                  Icons.water_drop,
                  size: 150,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildRiskIcon(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Risque de Sécheresse',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prediction.riskLevel.label.toUpperCase(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildRiskMeter(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    prediction.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIcon() {
    IconData icon;
    
    switch (prediction.riskLevel) {
      case DroughtRiskLevel.low:
        icon = Icons.cloud;
        break;
      case DroughtRiskLevel.moderate:
        icon = Icons.wb_sunny_outlined;
        break;
      case DroughtRiskLevel.high:
        icon = Icons.warning_amber;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRiskMeter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Score de risque',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(prediction.riskScore * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: prediction.riskScore,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRiskLabel('Faible', 0.0),
            _buildRiskLabel('Modéré', 0.5),
            _buildRiskLabel('Élevé', 1.0),
          ],
        ),
      ],
    );
  }

  Widget _buildRiskLabel(String label, double position) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _getRiskColor() {
    switch (prediction.riskLevel) {
      case DroughtRiskLevel.low:
        return const Color(0xFF4CAF50); // Vert
      case DroughtRiskLevel.moderate:
        return const Color(0xFFFF9800); // Orange
      case DroughtRiskLevel.high:
        return const Color(0xFFD32F2F); // Rouge
    }
  }
}
