import 'package:get/get.dart';
import 'package:flip_health/controllers/splash%20controller/on_boarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<OnboardingController>(OnboardingController());
  }
}