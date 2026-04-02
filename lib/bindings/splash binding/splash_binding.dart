import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/splash_repository.dart';
import 'package:flip_health/controllers/splash%20controller/splash_screen_controller.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService());
    }
    Get.lazyPut<SplashRepository>(
      () => SplashRepository(apiService: Get.find()),
    );
    Get.put<SplashScreenController>(
      SplashScreenController(repository: Get.find()),
    );
  }
}
