import 'dart:async';
import 'package:get/get.dart';
import '../../models/order_model.dart';
import '../../repository/order_repository.dart';
import '../../services/notification_service.dart';

/// View Controller for Real-Time Order Tracking Screen.
/// 
/// Simulates live order status progression across 5 stages:
/// 1. Received (0s)
/// 2. Preparing (5s) -> Triggers sizzle notification
/// 3. Ready (10s) -> Triggers packaging notification
/// 4. Out For Delivery (15s) -> Triggers rider dispatch notification
/// 5. Delivered (20s) -> Triggers arrival notification
/// 
/// Automatically updates order state in [OrderRepository] and dispatches system notifications via [NotificationService].
class TrackingController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  /// Active order model received via navigation arguments.
  late OrderModel order;

  /// Observable order status string ('Received', 'Preparing', 'Ready', 'Out For Delivery', 'Delivered').
  final status = 'Received'.obs;

  /// Estimated delivery countdown in minutes.
  final minutesRemaining = 30.obs;
  
  Timer? _statusTimer;
  Timer? _timeTimer;

  @override
  void onInit() {
    super.onInit();
    order = Get.arguments as OrderModel;
    status.value = order.status;
    _startSimulations();
  }

  /// Starts timers simulating delivery countdown and status phase transitions.
  void _startSimulations() {
    // 1. Countdown simulation timer (reduces 3 mins every 4 seconds)
    _timeTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (minutesRemaining.value > 2) {
        minutesRemaining.value -= 3;
      } else {
        minutesRemaining.value = 0;
        timer.cancel();
      }
    });

    // 2. Status progression timer: Received -> Preparing -> Ready -> Out For Delivery -> Delivered
    int phase = 0;
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      phase++;
      if (phase == 1) {
        status.value = 'Preparing';
        await _orderRepository.updateOrderStatus(order.id, 'Preparing');
        await _notificationService.showOrderNotification(
          id: 101,
          title: '🔥 Sizzling preparation!',
          body: 'MUSTAV grill is hot. Patties are smashed thin and melting cheddar cheese!',
        );
      } else if (phase == 2) {
        status.value = 'Ready';
        await _orderRepository.updateOrderStatus(order.id, 'Ready');
        await _notificationService.showOrderNotification(
          id: 102,
          title: '🍔 Order is Ready!',
          body: 'Artisan burgers are bagged fresh with toasted buns, waiting for dispatch.',
        );
      } else if (phase == 3) {
        status.value = 'Out For Delivery';
        await _orderRepository.updateOrderStatus(order.id, 'Out For Delivery');
        await _notificationService.showOrderNotification(
          id: 103,
          title: '🏍️ Out for Delivery!',
          body: 'Your rider has dispatched the meal and is heading towards your location.',
        );
      } else if (phase == 4) {
        status.value = 'Delivered';
        minutesRemaining.value = 0;
        await _orderRepository.updateOrderStatus(order.id, 'Delivered');
        await _notificationService.showOrderNotification(
          id: 104,
          title: '🎉 Burgers Delivered!',
          body: 'Delivered hot, fresh and zero guilt. Time to enjoy the smash!',
        );
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    // Cancel active periodic timers on controller destruction to prevent memory leaks
    _statusTimer?.cancel();
    _timeTimer?.cancel();
    super.onClose();
  }
}
