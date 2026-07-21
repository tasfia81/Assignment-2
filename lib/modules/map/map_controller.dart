import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/values/constants.dart';
import '../../models/location_model.dart';
import '../../repository/auth_repository.dart';
import '../../repository/burger_repository.dart';
import '../../services/location_service.dart';

/// View Controller for the Interactive Google Maps & Store Branch Picker Screen.
/// 
/// Manages map controller initialization, map marker placement for store branches (Lahore, Islamabad, Rawalpindi, Multan),
/// camera movement handling, reverse geocoding on idle camera, user location GPS fetching, and address saving.
class MapController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final BurgerRepository _burgerRepository = Get.find<BurgerRepository>();

  /// Native Google Map controller instance.
  GoogleMapController? googleMapController;

  /// Observable set of Google Map markers displayed on the map view.
  final markers = <Marker>{}.obs;
  
  /// Formatted address string resulting from pin placement or geocoding.
  final selectedAddress = 'Pinning address on map...'.obs;

  /// Indicates active reverse geocoding request.
  final isLoadingAddress = false.obs;

  /// Flag indicating whether the map is currently opened in read-only branch viewing mode.
  final isViewingBranch = false.obs;

  /// Name of the branch currently being viewed (if [isViewingBranch] is true).
  final viewedBranchName = ''.obs;

  /// Display text showing the nearest store branch and distance (in KM).
  final nearestStoreInfo = ''.obs;

  /// Active pin latitude coordinate.
  double currentLat = AppConstants.lahoreLat;

  /// Active pin longitude coordinate.
  double currentLng = AppConstants.lahoreLng;

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
  }

  /// Parses incoming route arguments to inspect if opening a specific store branch.
  void _handleArguments() {
    if (Get.arguments is LocationModel) {
      final branch = Get.arguments as LocationModel;
      currentLat = branch.latitude;
      currentLng = branch.longitude;
      isViewingBranch.value = true;
      viewedBranchName.value = branch.name;
      selectedAddress.value = branch.address;
    }
  }

  /// Callback executed once the GoogleMap widget is fully created and rendered.
  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    _setupMarkers();
    if (isViewingBranch.value) {
      _focusCamera(currentLat, currentLng);
    } else {
      _loadUserInitialLocation();
    }
  }

  /// Loads stored user location or falls back to GPS acquisition.
  Future<void> _loadUserInitialLocation() async {
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser != null && currentUser.latitude != 0.0) {
      currentLat = currentUser.latitude;
      currentLng = currentUser.longitude;
      selectedAddress.value = currentUser.address;
      _focusCamera(currentLat, currentLng);
      _detectNearestBranch(currentLat, currentLng);
    } else {
      await moveToUserLocation();
    }
  }

  /// Requests current device GPS location and moves camera to the user's position.
  Future<void> moveToUserLocation() async {
    isLoadingAddress.value = true;
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      currentLat = position.latitude;
      currentLng = position.longitude;
      _focusCamera(currentLat, currentLng);
      await _reverseGeocode(currentLat, currentLng);
      _detectNearestBranch(currentLat, currentLng);
    } else {
      // Permission denied or GPS disabled fallback
      _focusCamera(currentLat, currentLng);
      await _reverseGeocode(currentLat, currentLng);
      nearestStoreInfo.value = 'GPS Denied. Pin branch manually.';
    }
    isLoadingAddress.value = false;
  }

  /// Calculates the nearest store branch to the target coordinates and updates [nearestStoreInfo].
  Future<void> _detectNearestBranch(double userLat, double userLng) async {
    try {
      final branchesList = await _burgerRepository.getBranches();
      final nearest = _locationService.findNearestBranch(userLat, userLng, branchesList);
      if (nearest != null) {
        final dist = nearest.distanceInKm ?? 0.0;
        nearestStoreInfo.value = 'Nearest: ${nearest.name} (${dist.toStringAsFixed(1)} km away)';
      }
    } catch (_) {
      nearestStoreInfo.value = '';
    }
  }

  /// Animates the Google Map camera smoothly to a specified (latitude, longitude) coordinate.
  void _focusCamera(double lat, double lng) {
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15.5),
      ),
    );
  }

  /// Updates current coordinates as the user drags/moves the map center.
  void onCameraMove(CameraPosition position) {
    if (!isViewingBranch.value) {
      currentLat = position.target.latitude;
      currentLng = position.target.longitude;
    }
  }

  /// Triggered when camera movement halts; resolves address via reverse geocoding and updates nearest store info.
  Future<void> onCameraIdle() async {
    if (!isViewingBranch.value) {
      await _reverseGeocode(currentLat, currentLng);
      _detectNearestBranch(currentLat, currentLng);
    }
  }

  /// Resolves human-readable street address for given latitude/longitude coordinates.
  Future<void> _reverseGeocode(double lat, double lng) async {
    isLoadingAddress.value = true;
    try {
      final address = await _locationService.getAddressFromCoordinates(lat, lng);
      selectedAddress.value = address;
    } catch (_) {
      selectedAddress.value = 'Failed to fetch address details.';
    } finally {
      isLoadingAddress.value = false;
    }
  }

  /// Populates the map with markers for all physical MUSTAV store branches across Pakistan.
  void _setupMarkers() {
    markers.clear();
    
    // 1. Lahore Flagship Kitchen marker
    markers.add(
      const Marker(
        markerId: MarkerId('br_lh'),
        position: LatLng(31.4704, 74.4087),
        infoWindow: InfoWindow(title: 'MUSTAV Lahore Flagship Kitchen'),
      ),
    );
    // 2. Islamabad Hub marker
    markers.add(
      const Marker(
        markerId: MarkerId('br_isb'),
        position: LatLng(AppConstants.islamabadLat, AppConstants.islamabadLng),
        infoWindow: InfoWindow(title: 'MUSTAV Islamabad Hub'),
      ),
    );
    // 3. Rawalpindi Saddar marker
    markers.add(
      const Marker(
        markerId: MarkerId('br_rwp'),
        position: LatLng(AppConstants.rawalpindiLat, AppConstants.rawalpindiLng),
        infoWindow: InfoWindow(title: 'MUSTAV Rawalpindi Saddar'),
      ),
    );
    // 4. Multan Gulgasht marker
    markers.add(
      const Marker(
        markerId: MarkerId('br_mul'),
        position: LatLng(AppConstants.multanLat, AppConstants.multanLng),
        infoWindow: InfoWindow(title: 'MUSTAV Multan Gulgasht'),
      ),
    );
  }

  /// Confirms selected map address pin and persists updated delivery address to user session.
  Future<void> confirmAddressSelection() async {
    if (isViewingBranch.value) {
      Get.back();
      return;
    }

    isLoadingAddress.value = true;
    try {
      final success = await _authRepository.updateAddress(
        selectedAddress.value,
        currentLat,
        currentLng,
      );
      if (success) {
        Get.back();
      } else {
        Get.snackbar('Error', 'Failed to update address.');
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to save address.');
    } finally {
      isLoadingAddress.value = false;
    }
  }
}
