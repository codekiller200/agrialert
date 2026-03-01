import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/market_service.dart';
import '../services/localization_service.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _searchQuery = '';
  String _sortBy = 'price'; // 'price' or 'change'

  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketService>(context, listen: false).fetchMarketData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketService = Provider.of<MarketService>(context);
    final theme = Theme.of(context);
    final locale =
        Provider.of<LocalizationService>(context).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('market_prices', locale)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'price',
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color:
                          _sortBy == 'price' ? theme.colorScheme.primary : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Prix'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'change',
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: _sortBy == 'change'
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Variation'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
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
                hintText: AppTranslations.translate('search', locale),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Liste des prix
          Expanded(
            child: marketService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : marketService.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(marketService.errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => marketService.fetchMarketData(),
                              child: Text(
                                  AppTranslations.translate('retry', locale)),
                            ),
                          ],
                        ),
                      )
                    : _buildMarketList(marketService, locale),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => marketService.fetchMarketData(),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildMarketList(MarketService marketService, String locale) {
    List<dynamic> filteredData = marketService.marketData
        .where((data) =>
            data.cropName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            data.marketName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Trier
    if (_sortBy == 'change') {
      filteredData.sort((a, b) => b.priceChange.compareTo(a.priceChange));
    } else {
      filteredData.sort((a, b) => b.pricePerKg.compareTo(a.pricePerKg));
    }

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 60,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              AppTranslations.translate('no_data', locale),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        return _buildMarketCard(filteredData[index], locale);
      },
    );
  }

  Widget _buildMarketCard(MarketData data, String locale) {
    final theme = Theme.of(context);
    final isPositive = data.priceChange >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icône de la culture
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCropIcon(data.cropName),
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Nom et marché
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.cropName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data.marketName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Prix et variation
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${data.pricePerKg.toStringAsFixed(0)} F CFA/kg',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${data.priceChange.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCropIcon(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'mil':
      case 'sorgho':
      case 'maïs':
      case 'riz':
        return Icons.grass;
      case 'tomate':
      case 'oignon':
      case 'piment':
      case 'gombo':
        return Icons.local_florist;
      case 'niébé':
      case 'arachide':
        return Icons.eco;
      default:
        return Icons.agriculture;
    }
  }
}
