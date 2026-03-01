import 'package:flutter/material.dart';
import '../models/data_models.dart';

class RegionSelectorDialog extends StatefulWidget {
  final Function(RegionData) onRegionSelected;

  const RegionSelectorDialog({
    super.key,
    required this.onRegionSelected,
  });

  @override
  State<RegionSelectorDialog> createState() => _RegionSelectorDialogState();
}

class _RegionSelectorDialogState extends State<RegionSelectorDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredRegions = burkinaRegions
        .where((region) =>
            region.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            region.nameMoore.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Barre de titre
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50), // Primary green
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Ligne de fermeture
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.location_city,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Choisissez votre région',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une région...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF4CAF50), // Primary green
                ),
                filled: true,
                fillColor: const Color(0xFF4CAF50).withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4CAF50), // Primary green
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Liste des régions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredRegions.length,
              itemBuilder: (context, index) {
                final region = filteredRegions[index];
                return _buildRegionItem(context, region);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionItem(BuildContext context, RegionData region) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2), // Primary green
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onRegionSelected(region),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50)
                        .withOpacity(0.1), // Primary green
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF4CAF50), // Primary green
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF212121), // Dark grey
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        region.nameMoore,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF212121).withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color:
                      const Color(0xFF4CAF50).withOpacity(0.5), // Primary green
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
