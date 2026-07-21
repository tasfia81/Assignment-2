import 'dart:async';
import 'package:get/get.dart';
import '../../repository/auth_repository.dart';
import '../../routes/app_pages.dart';

class SplashController extends GetxController {
  final RxString loadingText = 'Heating the flat top...'.obs;
  final RxDouble progress = 0.0.obs;

  final List<String> _cookingPhrases = [
    'Heating the flat top...',
    'Double smashing beef patties...',
    'Drizzling chili honey glaze...',
    'Melting organic cheddar...',
    'Toasting soft brioche buns...',
    'Ready! Firing up MUSTAV...',
  ];

  @override
  void onInit() {
    super.onInit();
    _startLoadingSequence();
  }

  void _startLoadingSequence() {
    const textInterval = Duration(milliseconds: 600);
    const progressInterval = Duration(milliseconds: 36);

    int textIndex = 0;
    Timer.periodic(textInterval, (timer) {
      if (textIndex < _cookingPhrases.length - 1) {
        textIndex++;
        loadingText.value = _cookingPhrases[textIndex];
      } else {
        timer.cancel();
      }
    });

    Timer.periodic(progressInterval, (timer) {
      if (progress.value < 1.0) {
        progress.value += 0.01;
      } else {
        timer.cancel();
        _navigateNext();
      }
    });
  }

  Future<void> _navigateNext() async {
    final authRepository = Get.find<AuthRepository>();
    final currentUser = await authRepository.getCurrentUser();

    if (currentUser != null) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.auth);
    }
  }
}
