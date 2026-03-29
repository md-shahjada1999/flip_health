import 'package:get/get.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class PharmacyController extends GetxController {
  final isLoading = false.obs;
  final prescriptionSource = ''.obs;

  // Uploaded files
  final selectedFiles = <Map<String, dynamic>>[].obs;
  final prescriptionsDataFetched = false.obs;
  final flipHealthPrescriptions = <Map<String, dynamic>>[].obs;

  // FAQs
  final faqItems = <FAQItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFAQs();
    _loadFlipHealthPrescriptions();
  }

  void _loadFAQs() {
    faqItems.value = [
      FAQItem(
        question: 'Do I need to order all the medicine in the prescription?',
        answer:
            'No, you don\'t need to order all medicines. Our medicine partner will contact you to confirm the required medicines.',
      ),
      FAQItem(
        question: 'Can I change the quantity of medicines?',
        answer:
            'Yes, our medicine partner will contact you to confirm the medicines and quantities before delivery.',
      ),
      FAQItem(
        question: 'How do I know the price of medicines?',
        answer:
            'Once the order is confirmed, our medicine partner will share the price details with you before delivery.',
      ),
    ];
  }

  void _loadFlipHealthPrescriptions() {
    prescriptionsDataFetched.value = true;
    flipHealthPrescriptions.value = [
      {
        'id': 'rx_1',
        'name': 'Prescription - Dr. Sharma',
        'date': '12 Mar 2024',
      },
      {
        'id': 'rx_2',
        'name': 'Prescription - Dr. Reddy',
        'date': '28 Feb 2024',
      },
    ];
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
