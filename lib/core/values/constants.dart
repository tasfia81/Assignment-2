class AppConstants {
  AppConstants._();

  // App Name
  static const String appName = 'MUSTAV';

  // API Configuration (Simulated)
  static const String baseUrl = 'https://api.mustav.shop/v1';
  static const int apiTimeout = 10000; // 10 seconds

  // Local Storage Box Names
  static const String userBox = 'user_box';
  static const String cartBox = 'cart_box';
  static const String orderBox = 'order_box';
  static const String appSettingsBox = 'app_settings_box';

  // Hive Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserData = 'user_data';
  static const String keyCartItems = 'cart_items';
  static const String keyOrdersList = 'orders_list';

  // Pakistani Branch Coordinates for MUSTAV
  static const double lahoreLat = 31.5204;
  static const double lahoreLng = 74.3587;

  static const double islamabadLat = 33.6844;
  static const double islamabadLng = 73.0479;

  static const double rawalpindiLat = 33.5984;
  static const double rawalpindiLng = 73.0441;

  static const double multanLat = 30.1575;
  static const double multanLng = 71.5249;
}
