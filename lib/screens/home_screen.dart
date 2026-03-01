import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../services/drought_prediction_service.dart';
import '../services/location_service.dart';
import '../models/data_models.dart';
import '../widgets/drought_risk_card.dart';
import '../widgets/weather_forecast_card.dart';
import '../widgets/recommendations_section.dart';
import '../widgets/region_selector_dialog.dart';
import '../widgets/burkina_map_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;

    final locationService =
        Provider.of<LocationService>(context, listen: false);

    // Charger les données en cache d'abord
    await locationService.loadCachedLocation();

    // Tenter de récupérer la position GPS
    await locationService.getCurrentLocation();

    // Si on a une position, charger les données météo
    if (mounted && locationService.currentPosition != null) {
      await _loadWeatherData();
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      _animationController.forward();
    }
  }

  Future<void> _loadWeatherData() async {
    if (!mounted) return;

    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final weatherService = Provider.of<WeatherService>(context, listen: false);
    final predictionService =
        Provider.of<DroughtPredictionService>(context, listen: false);

    final position = locationService.currentPosition;
    if (position == null) return;

    // Charger les données météo
    await weatherService.fetchWeatherData(
      latitude: position.latitude,
      longitude: position.longitude,
      location: locationService.currentLocationName ?? 'Ma position',
    );

    // Faire les prédictions si on a les données météo
    if (weatherService.historical != null && weatherService.forecast != null) {
      await predictionService.predictDrought(
        historicalData: weatherService.historical!,
        forecastData: weatherService.forecast!,
      );

      await predictionService.predictWeeklyDrought(
        historicalData: weatherService.historical!,
        weeklyForecast: weatherService.forecast!,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: !_isInitialized ? _buildLoadingScreen() : _buildMainContent(),
        ),
      ),
      floatingActionButton: _isInitialized ? _buildFloatingActions() : null,
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo ou icône d'application
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.water_drop,
              size: 64,
              color: Color(0xFF2D5016),
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement d\'AgriAlert BF...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _loadWeatherData,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildLocationHeader(),
                    const SizedBox(height: 16),
                    _buildBurkinaMap(),
                    const SizedBox(height: 16),
                    _buildDroughtRiskSection(),
                    const SizedBox(height: 16),
                    _buildWeatherForecastSection(),
                    const SizedBox(height: 16),
                    _buildRecommendationsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'AgriAlert BF',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 40, right: 16),
            child: Align(
              alignment: Alignment.topRight,
              child: _buildMooreToggle(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMooreToggle() {
    // TODO: Implémenter le toggle Français/Mooré
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            'FR',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationService.currentLocationName ?? 'Chargement...',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Burkina Faso',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showRegionSelector(),
                icon: Icon(
                  Icons.edit_location_alt,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBurkinaMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 250,
      child: const BurkinaMapWidget(),
    );
  }

  Widget _buildDroughtRiskSection() {
    return Consumer<DroughtPredictionService>(
      builder: (context, predictionService, child) {
        if (predictionService.currentPrediction == null) {
          return const SizedBox.shrink();
        }

        return DroughtRiskCard(
          prediction: predictionService.currentPrediction!,
        );
      },
    );
  }

  Widget _buildWeatherForecastSection() {
    return Consumer<WeatherService>(
      builder: (context, weatherService, child) {
        if (weatherService.forecast == null ||
            weatherService.forecast!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Prévisions 7 jours',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: weatherService.forecast!.length,
                itemBuilder: (context, index) {
                  return WeatherForecastCard(
                    weather: weatherService.forecast![index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationsSection() {
    return Consumer<DroughtPredictionService>(
      builder: (context, predictionService, child) {
        if (predictionService.currentPrediction == null) {
          return const SizedBox.shrink();
        }

        return RecommendationsSection(
          prediction: predictionService.currentPrediction!,
        );
      },
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'share',
          onPressed: _shareAlert,
          child: const Icon(Icons.share),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'refresh',
          onPressed: _loadWeatherData,
          icon: const Icon(Icons.refresh),
          label: const Text('Actualiser'),
        ),
      ],
    );
  }

  void _showRegionSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegionSelectorDialog(
        onRegionSelected: (region) async {
          await Provider.of<LocationService>(context, listen: false)
              .selectRegion(region);
          await _loadWeatherData();
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _shareAlert() {
    final predictionService = Provider.of<DroughtPredictionService>(
      context,
      listen: false,
    );
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );

    if (predictionService.currentPrediction == null) return;

    final prediction = predictionService.currentPrediction!;
    final location = locationService.currentLocationName ?? 'Ma région';

    final message = '''
🌾 Alerte AgriAlert BF 🌾

📍 Localisation: $location
⚠️ Risque de sécheresse: ${prediction.riskLevel.label}
📊 Score: ${(prediction.riskScore * 100).toStringAsFixed(0)}%

${prediction.description}

📱 Téléchargez AgriAlert BF pour plus d'informations
''';

    // TODO: Implémenter le partage via share_plus
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message prêt à partager:\n$message'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
