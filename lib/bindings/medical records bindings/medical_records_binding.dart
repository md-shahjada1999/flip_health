import 'package:get/get.dart';
import 'package:flip_health/controllers/medical%20records%20controllers/medical_records_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/medical_records_repository.dart';

class MedicalRecordsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<MedicalRecordsRepository>(
        () => MedicalRecordsRepository(apiService: Get.find()));
    Get.lazyPut<MedicalRecordsController>(
        () => MedicalRecordsController(repository: Get.find()));
  }
}
