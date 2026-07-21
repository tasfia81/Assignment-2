import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../modules/home/home_controller.dart';

/// Real-Time Network Connectivity Monitor Service.
/// 
/// Listens to device network changes using [Connectivity], updates the global [isOffline] reactive flag,
/// and automatically triggers catalog data refreshes in [HomeController] when re-establishing an online connection.
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  /// Observable boolean indicating whether the device is currently offline.
  final RxBool isOffline = false.obs;

  /// Initializes connectivity listener and inspects initial network state.
  Future<ConnectivityService> init() async {
    // 1. Initial network state check
    final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _updateState(result);

    // 2. Stream listener for real-time network state changes
    _connectivity.onConnectivityChanged.listen(_updateState);

    return this;
  }

  /// Internal handler called on connectivity stream state updates.
  void _updateState(List<ConnectivityResult> results) {
    final bool offline = results.contains(ConnectivityResult.none);
    
    // Detect transition from offline to online state
    if (isOffline.value && !offline) {
      Get.snackbar(
        'Back Online',
        'Your internet connection was restored. Refreshing menu...',
        snackPosition: SnackPosition.TOP,
      );
      // Auto-refresh Home catalog data if HomeController is active
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadData();
      }
    }

    isOffline.value = offline;
  }
}
