import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

/// Service de gestion de la localisation de l'utilisateur
class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentLocationName;
  RegionData? _selectedRegion;
  bool _isLoading = false;
  String? _errorMessage;
  
  Position? get currentPosition => _currentPosition;
  String? get currentLocationName => _currentLocationName;
  RegionData? get selectedRegion => _selectedRegion;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Obtient la position GPS actuelle de l'utilisateur
  Future<Position?> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Services de localisation désactivés';
        _isLoading = false;
        notifyListeners();
        return null;
      }
      
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Permission de localisation refusée';
          _isLoading = false;
          notifyListeners();
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Permission de localisation définitivement refusée';
        _isLoading = false;
        notifyListeners();
        return null;
      }
      
      // Obtenir la position actuelle
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      
      // Geocoding inverse pour obtenir le nom de la localisation
      await _reverseGeocode(_currentPosition!);
      
      // Sauvegarder dans le cache
      await _saveLocationToCache();
      
      _isLoading = false;
      notifyListeners();
      
      return _currentPosition;
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération de la position: $e';
      _isLoading = false;
      notifyListeners();
      
      // Charger depuis le cache en cas d'erreur
      await loadCachedLocation();
      return null;
    }
  }
  
  /// Effectue un geocoding inverse pour obtenir le nom de la localisation
  Future<void> _reverseGeocode(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _currentLocationName = place.locality ?? 
                              place.subAdministrativeArea ?? 
                              place.administrativeArea ?? 
                              'Localisation inconnue';
      }
    } catch (e) {
      debugPrint('Erreur geocoding: $e');
      _currentLocationName = 'Lat: ${position.latitude.toStringAsFixed(2)}, '
                            'Long: ${position.longitude.toStringAsFixed(2)}';
    }
  }
  
  /// Sélectionne manuellement une région du Burkina Faso
  Future<void> selectRegion(RegionData region) async {
    _selectedRegion = region;
    
    // Créer une position virtuelle pour la région sélectionnée
    _currentPosition = Position(
      latitude: region.latitude,
      longitude: region.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    
    _currentLocationName = region.name;
    
    // Sauvegarder la sélection
    await _saveLocationToCache();
    
    notifyListeners();
  }
  
  /// Trouve la région la plus proche de la position actuelle
  RegionData? findNearestRegion() {
    if (_currentPosition == null) return null;
    
    RegionData? nearest;
    double minDistance = double.infinity;
    
    for (var region in burkinaRegions) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        region.latitude,
        region.longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearest = region;
      }
    }
    
    return nearest;
  }
  
  /// Sauvegarde la localisation dans le cache
  Future<void> _saveLocationToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentPosition != null) {
        await prefs.setDouble('cached_latitude', _currentPosition!.latitude);
        await prefs.setDouble('cached_longitude', _currentPosition!.longitude);
      }
      
      if (_currentLocationName != null) {
        await prefs.setString('cached_location_name', _currentLocationName!);
      }
      
      if (_selectedRegion != null) {
        await prefs.setString('selected_region_name', _selectedRegion!.name);
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde localisation: $e');
    }
  }
  
  /// Charge la localisation depuis le cache
  Future<void> loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final lat = prefs.getDouble('cached_latitude');
      final lon = prefs.getDouble('cached_longitude');
      
      if (lat != null && lon != null) {
        _currentPosition = Position(
          latitude: lat,
          longitude: lon,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      
      _currentLocationName = prefs.getString('cached_location_name');
      
      final regionName = prefs.getString('selected_region_name');
      if (regionName != null) {
        _selectedRegion = burkinaRegions.firstWhere(
          (r) => r.name == regionName,
          orElse: () => burkinaRegions.first,
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement localisation: $e');
    }
  }
}
