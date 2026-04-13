import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/consultation_order_repository.dart';
import 'package:flip_health/data/repositories/upload_repository.dart';
import 'package:get/get.dart';

class VideoCallBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<ConsultationOrderRepository>()) {
      Get.lazyPut<ConsultationOrderRepository>(
        () => ConsultationOrderRepository(apiService: Get.find()),
      );
    }
    if (!Get.isRegistered<UploadRepository>()) {
      Get.lazyPut<UploadRepository>(
        () => UploadRepository(apiService: Get.find()),
      );
    }
  }
}
