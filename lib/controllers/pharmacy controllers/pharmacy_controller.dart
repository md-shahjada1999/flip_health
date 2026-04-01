import 'package:get/get.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/data/repositories/pharmacy_repository.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class PharmacyController extends GetxController {
  final PharmacyRepository _repository;

  PharmacyController({required PharmacyRepository repository})
      : _repository = repository;

  final isLoading = false.obs;
  final prescriptionSource = ''.obs;

  final selectedFiles = <Map<String, dynamic>>[].obs;
  final prescriptionsDataFetched = false.obs;
  final flipHealthPrescriptions = <Map<String, dynamic>>[].obs;

  final faqItems = <FAQItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFAQs();
    _loadFlipHealthPrescriptions();
  }

  Future<void> _loadFAQs() async {
    faqItems.value = await _repository.getFAQs();
  }

  Future<void> _loadFlipHealthPrescriptions() async {
    flipHealthPrescriptions.value =
        await _repository.getFlipHealthPrescriptions();
    prescriptionsDataFetched.value = true;
  }

  Future<void> pickFromGallery() async {
    final file = await FilePickerHelper.pickFromGallery();
    if (file != null) selectedFiles.add(file.toMap());
  }

  Future<void> pickFromCamera() async {
    final file = await FilePickerHelper.pickFromCamera();
    if (file != null) selectedFiles.add(file.toMap());
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
  }

  void toggleFlipHealthPrescription(String id) {
    final idx = selectedFiles.indexWhere((f) => f['id'] == id);
    if (idx != -1) {
      selectedFiles.removeAt(idx);
    } else {
      final prescription = flipHealthPrescriptions.firstWhere((p) => p['id'] == id);
      selectedFiles.add(prescription);
    }
  }

  bool isPrescriptionSelected(String id) {
    return selectedFiles.any((f) => f['id'] == id);
  }

  void placeOrder() {
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void navigateToOTC() {
    // Placeholder for OTC flow
  }
}
