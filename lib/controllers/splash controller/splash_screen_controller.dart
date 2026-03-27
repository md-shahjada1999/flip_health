import 'package:get/get.dart';
import 'dart:async';

import 'package:flip_health/routes/app_routes.dart';

class SplashScreenController extends GetxController {
  final RxInt count = 0.obs;
  final RxDouble progress = 0.0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startSplashTimer();
  }

  void startSplashTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (progress.value >= 1.0) {
        _timer?.cancel();
        navigateToOnboarding();
      } else {
        progress.value += 0.02; // Increment progress
        count.value = (progress.value * 100).toInt();
      }
    });
  }

  void navigateToOnboarding() {
    // Check if user has seen onboarding before
    // You can use SharedPreferences here
    Get.offNamed(AppRoutes.onboarding);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}