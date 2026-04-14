import 'package:flip_health/controllers/service_request_order_detail_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/service_request_repository.dart';
import 'package:get/get.dart';

class ServiceRequestOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<ServiceRequestRepository>(
      () => ServiceRequestRepository(apiService: Get.find()),
    );
    Get.lazyPut<ServiceRequestOrderDetailController>(
      () => ServiceRequestOrderDetailController(repository: Get.find()),
    );
  }
}
