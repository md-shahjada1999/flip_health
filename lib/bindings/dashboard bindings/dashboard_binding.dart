import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/address_repository.dart';
import 'package:flip_health/data/repositories/dashboard_repository.dart';
import 'package:flip_health/data/repositories/wallet_repository.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/dashboard%20controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(
          () => AddressRepository(apiService: Get.find()),
          fenix: true);
    }
    if (!Get.isRegistered<DashboardRepository>()) {
      Get.lazyPut<DashboardRepository>(
          () => DashboardRepository(apiService: Get.find()),
          fenix: true);
    }
    if (!Get.isRegistered<WalletRepository>()) {
      Get.lazyPut<WalletRepository>(
          () => WalletRepository(apiService: Get.find()),
          fenix: true);
    }
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        dashboardRepository: Get.find(),
        walletRepository: Get.find(),
      ),
    );
    if (!Get.isRegistered<AddressController>()) {
      Get.lazyPut<AddressController>(
          () => AddressController(repository: Get.find()),
          fenix: true);
    }
  }
}
