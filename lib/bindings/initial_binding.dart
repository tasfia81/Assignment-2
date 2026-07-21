import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../core/network/network_info.dart';
import '../repository/auth_repository.dart';
import '../repository/burger_repository.dart';
import '../repository/order_repository.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/cart_service.dart';

/// Global Dependency Injection Binding.
/// 
/// Instantiates application-wide singletons, repositories, and services using GetX lazy loading.
/// The `fenix: true` parameter guarantees that if a dependency is ever evicted from memory,
/// GetX will automatically recreate it upon subsequent lookup attempts.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core network connectivity monitor and network info wrapper
    Get.lazyPut<Connectivity>(() => Connectivity(), fenix: true);
    Get.lazyPut<NetworkInfo>(() => NetworkInfoImpl(Get.find<Connectivity>()), fenix: true);

    // 2. Local Hive Database reference (pre-initialized in main())
    final db = Get.find<DatabaseService>();

    // 3. Application Data Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(db.userBox), fenix: true);
    Get.lazyPut<BurgerRepository>(() => BurgerRepositoryImpl(), fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepositoryImpl(db.orderBox), fenix: true);

    // 4. Core Application Services
    Get.lazyPut<LocationService>(() => LocationService(), fenix: true);
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    Get.lazyPut<CartService>(() => CartService(db.cartBox), fenix: true);
  }
}
