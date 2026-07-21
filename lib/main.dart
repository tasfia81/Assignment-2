import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'bindings/initial_binding.dart';
import 'core/theme/colors.dart';
import 'routes/app_pages.dart';
import 'services/database_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';

/// Application Entry Point.
/// Initializes essential asynchronous services before mounting the root widget:
/// - [DatabaseService]: Opens local Hive boxes for user sessions, cart, orders, and app settings.
/// - [NotificationService]: Sets up platform-specific notification channels for order updates.
/// - [LocationService]: Prepares GPS location utilities for store finder and address pinning.
/// - [ConnectivityService]: Monitors internet connection changes for offline resilience.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Local Hive Databases
  final dbService = await DatabaseService().init();
  Get.put<DatabaseService>(dbService);

  // 2. Initialize Platform Notification services
  final notificationService = await NotificationService().init();
  Get.put<NotificationService>(notificationService);

  // 3. Initialize Location Services
  final locationService = await LocationService().init();
  Get.put<LocationService>(locationService);

  // 4. Initialize Connectivity monitor services
  final connectivityService = await ConnectivityService().init();
  Get.put<ConnectivityService>(connectivityService);

  runApp(const MyApp());
}

/// [MyApp] serves as the root widget for the MUSTAV Artisan Smashed Burgers application.
/// 
/// It configures:
/// - Screen responsiveness using [ScreenUtilInit] based on a standard 390x844 canvas.
/// - The global app theme (Material 3 with custom dark color scheme & Gold accents).
/// - Navigation routing and global dependency bindings managed by [GetMaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with ScreenUtilInit for responsive screen sizes across various devices
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 13/14 standard design dimensions
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'MUSTAV Artisan Smashed Burgers',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              surface: AppColors.surface,
            ),
            scaffoldBackgroundColor: AppColors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.white),
            ),
          ),
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          initialBinding: InitialBinding(),
        );
      },
    );
  }
}

