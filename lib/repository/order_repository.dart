import 'dart:convert';
import 'package:hive/hive.dart';
import '../core/values/constants.dart';
import '../models/order_model.dart';

/// Abstract contract for order history storage and status tracking.
abstract class OrderRepository {
  /// Fetches historical orders placed by the user.
  Future<List<OrderModel>> getOrders();

  /// Submits and persists a new order into storage (`orderBox`).
  Future<OrderModel> placeOrder(OrderModel order);

  /// Looks up a specific order by its unique order ID.
  Future<OrderModel?> getOrderById(String orderId);

  /// Updates status string for a specific order (e.g. 'Preparing', 'Ready', 'Out For Delivery', 'Delivered').
  Future<void> updateOrderStatus(String orderId, String newStatus);
}

/// Production implementation of [OrderRepository] persisting order history in local Hive storage.
class OrderRepositoryImpl implements OrderRepository {
  final Box _orderBox;

  OrderRepositoryImpl(this._orderBox);

  /// Retrieves list of orders stored in Hive (`orderBox`).
  @override
  Future<List<OrderModel>> getOrders() async {
    final List<dynamic>? rawList = _orderBox.get(AppConstants.keyOrdersList) as List<dynamic>?;
    if (rawList == null) return [];

    try {
      return rawList
          .map((item) => OrderModel.fromJson(jsonDecode(item as String) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists a newly created order into local storage after network delay.
  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    // Add latency to simulate placing order online
    await Future.delayed(const Duration(milliseconds: 1200));

    final orders = await getOrders();
    orders.add(order);

    // Serialize and save updated list to Hive
    final serializedList = orders.map((o) => jsonEncode(o.toJson())).toList();
    await _orderBox.put(AppConstants.keyOrdersList, serializedList);

    return order;
  }

  /// Retrieves a specific order by ID from local storage.
  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final orders = await getOrders();
    try {
      return orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  /// Modifies order status in local storage for real-time tracking updates.
  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      orders[index] = orders[index].copyWith(status: newStatus);
      final serializedList = orders.map((o) => jsonEncode(o.toJson())).toList();
      await _orderBox.put(AppConstants.keyOrdersList, serializedList);
    }
  }
}
