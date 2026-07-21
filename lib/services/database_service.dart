import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/values/constants.dart';

/// Local Persistence Database Service using Hive.
/// 
/// Manages asynchronous initialization and provides global box handles for:
/// - [userBox]: Stores user authentication profile, address, and session tokens.
/// - [cartBox]: Persists active cart items across app restarts.
/// - [orderBox]: Saves historical orders placed by the user.
/// - [appSettingsBox]: Holds cached product data for offline mode support.
class DatabaseService extends GetxService {
  late Box userBox;
  late Box cartBox;
  late Box orderBox;
  late Box appSettingsBox;

  /// Initializes Flutter Hive binding and opens all required storage boxes.
  Future<DatabaseService> init() async {
    await Hive.initFlutter();
    
    userBox = await Hive.openBox(AppConstants.userBox);
    cartBox = await Hive.openBox(AppConstants.cartBox);
    orderBox = await Hive.openBox(AppConstants.orderBox);
    appSettingsBox = await Hive.openBox(AppConstants.appSettingsBox);

    return this;
  }
}
