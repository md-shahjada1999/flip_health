import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/wallet_repository.dart';
import 'package:flip_health/controllers/dashboard%20controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    Get.lazyPut<WalletRepository>(
        () => WalletRepository(apiService: Get.find()));
    Get.lazyPut<WalletController>(
        () => WalletController(repository: Get.find()));
  }
}
