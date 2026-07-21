import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../models/order_model.dart';
import '../../repository/auth_repository.dart';
import '../../repository/order_repository.dart';
import '../../services/cart_service.dart';
import '../../services/notification_service.dart';
import '../../services/connectivity_service.dart';
import '../../routes/app_pages.dart';

/// View Controller for the Cart and Checkout Screen.
/// 
/// Manages delivery address selection, payment methods, checkout validation (empty cart, address checks, offline guard),
/// network failure simulation and cart preservation, order persistence via [OrderRepository], and notification triggering.
class CartController extends GetxController {
  final CartService cartService = Get.find<CartService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  final ConnectivityService connectivityService = Get.find<ConnectivityService>();

  /// Selected delivery address text.
  final userAddress = 'Select delivery address...'.obs;

  /// Selected payment method (default: Cash on Delivery).
  final paymentMethod = 'Cash on Delivery'.obs;
  
  /// Processing state for checkout submit button loading indicator.
  final isLoading = false.obs;

  /// Indicates a checkout error (simulated network glitch) to show retry state in UI.
  final isCheckoutError = false.obs;
  
  /// Saved latitude coordinate of delivery location.
  double userLat = 0.0;

  /// Saved longitude coordinate of delivery location.
  double userLng = 0.0;

  /// Counter tracking checkout attempts to simulate first-attempt network failure.
  int _checkoutAttempts = 0;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// Loads delivery address and coordinate details from the user profile.
  Future<void> loadUserData() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      userAddress.value = user.address;
      userLat = user.latitude;
      userLng = user.longitude;
    }
  }

  /// Sets the selected payment method.
  void setPaymentMethod(String method) {
    paymentMethod.value = method;
  }

  /// Clears checkout error state for retry attempt.
  void resetError() {
    isCheckoutError.value = false;
  }

  /// Initiates order checkout validation, error handling, order creation, and navigation.
  Future<void> checkout() async {
    // Validation 1: Ensure cart contains items
    if (cartService.cartItems.isEmpty) {
      Get.snackbar('Cart Empty', 'Please add some items to your cart.');
      return;
    }

    // Validation 2: Ensure valid delivery address is selected
    if (userAddress.value == 'Select delivery address...' || userAddress.value.isEmpty) {
      Get.snackbar('Select Address', 'Please select a delivery address to proceed.');
      return;
    }

    // Validation 3: Block submission if device is offline
    if (connectivityService.isOffline.value) {
      Get.snackbar('Checkout Offline', 'Please connect to the internet to submit order.');
      return;
    }

    isLoading.value = true;
    isCheckoutError.value = false;
    
    try {
      _checkoutAttempts++;
      
      // Simulation: Trigger network glitch on 1st attempt to test "cart preservation and retry" logic
      if (_checkoutAttempts == 1) {
        await Future.delayed(const Duration(milliseconds: 1000));
        throw Exception("Network SocketException: Connection Timeout");
      }

      // Successful Order Creation Path
      final order = OrderModel(
        id: 'ord_${const Uuid().v4().substring(0, 8)}',
        items: List.from(cartService.cartItems),
        totalAmount: cartService.grandTotal,
        address: userAddress.value,
        latitude: userLat,
        longitude: userLng,
        status: 'Received',
        createdAt: DateTime.now(),
        paymentMethod: paymentMethod.value,
      );

      // 1. Persist order to local Hive database via OrderRepository
      await _orderRepository.placeOrder(order);

      // 2. Dispatch local notification alert
      await _notificationService.showOrderNotification(
        id: 100,
        title: '🔥 MUSTAV Order Placed!',
        body: 'Your order #${order.id} is received. Firing up the grill!',
      );

      // 3. Clear cart and reset attempts on successful order
      cartService.clearCart();
      _checkoutAttempts = 0;

      // 4. Redirect user to live tracking view
      Get.offNamed(AppRoutes.tracking, arguments: order);
    } catch (_) {
      // Handle network exception while keeping cart items intact
      isCheckoutError.value = true;
      Get.snackbar(
        'Checkout Failed',
        'Connection timeout. Your cart is preserved. Please retry.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
