import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/data_models.dart';

class BurkinaMapWidget extends StatelessWidget {
  const BurkinaMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(12.3714, -1.5197), // Ouagadougou
          zoom: 6.5,
          minZoom: 6.0,
          maxZoom: 8.0,
          interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.agrialert.bf',
            tileBuilder: (context, widget, tile) {
              return ColorFiltered(
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary.withOpacity(0.15),
                  BlendMode.darken,
                ),
                child: widget,
              );
            },
          ),
          MarkerLayer(
            markers: burkinaRegions.map((region) {
              return Marker(
                point: LatLng(region.latitude, region.longitude),
                width: 40,
                height: 40,
                child: _buildRegionMarker(context, region),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionMarker(BuildContext context, RegionData region) {
    final theme = Theme.of(context);

    // Pour le MVP, couleur uniforme. Dans la version complète,
    // la couleur dépendrait du risque de sécheresse de chaque région
    final markerColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        _showRegionInfo(context, region);
      },
      child: Container(
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: markerColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showRegionInfo(BuildContext context, RegionData region) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.location_city,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                region.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nom en Mooré: ${region.nameMoore}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Coordonnées:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Lat: ${region.latitude.toStringAsFixed(4)}°',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Long: ${region.longitude.toStringAsFixed(4)}°',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
