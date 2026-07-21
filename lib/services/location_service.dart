import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../models/location_model.dart';

/// Device Location & Store Distance Utility Service.
/// 
/// Handles device GPS permissions, location fetching using [Geolocator],
/// Haversine distance calculations (in KM), nearest store branch resolution, and mock reverse geocoding.
class LocationService extends GetxService {
  Future<LocationService> init() async {
    return this;
  }

  /// Requests location permissions and retrieves the user's current GPS position.
  /// Returns `null` if location services are disabled or permissions are denied.
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  /// Calculates the geodesic distance between two coordinate pairs in Kilometers (KM).
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    final double distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return distanceInMeters / 1000; // Convert meters to KM
  }

  /// Computes and returns the nearest store branch to the user's coordinates.
  /// Enriches the returned [LocationModel] with the calculated `distanceInKm`.
  LocationModel? findNearestBranch(double userLat, double userLng, List<LocationModel> branches) {
    if (branches.isEmpty) return null;
    
    LocationModel? nearest;
    double minDistance = double.infinity;

    for (final branch in branches) {
      final distance = calculateDistance(userLat, userLng, branch.latitude, branch.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = branch.copyWith(distanceInKm: distance);
      }
    }

    return nearest;
  }

  /// Converts latitude and longitude coordinates into a human-readable street address string.
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Boundary matching for key Pakistani cities (Lahore, Islamabad, Rawalpindi, Multan)
    if (latitude >= 31.4 && latitude <= 31.6 && longitude >= 74.2 && longitude <= 74.4) {
      return 'DHA Phase 6, Sector C, House 42, Lahore, Pakistan';
    } else if (latitude >= 33.6 && latitude <= 33.8 && longitude >= 72.9 && longitude <= 73.1) {
      return 'Street 14, F-11 Markaz, Capital Appts, Islamabad, Pakistan';
    } else if (latitude >= 33.5 && latitude <= 33.65 && longitude >= 73.0 && longitude <= 73.15) {
      return 'Civic Center, Block B, Bahria Phase 4, Rawalpindi, Pakistan';
    } else {
      return 'Gulgasht Colony, St 3, Multan, Pakistan';
    }
  }
}
