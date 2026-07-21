import 'package:get/get.dart';
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/auth/auth_view.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/details/details_view.dart';
import '../modules/details/details_binding.dart';
import '../modules/cart/cart_view.dart';
import '../modules/cart/cart_binding.dart';
import '../modules/map/map_view.dart';
import '../modules/map/map_binding.dart';
import '../modules/tracking/tracking_view.dart';
import '../modules/tracking/tracking_binding.dart';

/// Centralized Named Route Constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String details = '/details';
  static const String cart = '/cart';
  static const String map = '/map';
  static const String tracking = '/tracking';
}

/// Router Configuration Table mapping routes to views, bindings, and custom page transitions.
class AppPages {
  AppPages._();

  /// Initial route loaded when application launches.
  static const initial = AppRoutes.splash;

  /// Register of all GetPage definitions with page factories and transition effects.
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.details,
      page: () => const DetailsView(),
      binding: DetailsBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.map,
      page: () => const MapView(),
      binding: MapBinding(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.tracking,
      page: () => const TrackingView(),
      binding: TrackingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
