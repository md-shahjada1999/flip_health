import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/data/repositories/mental_wellness_repository.dart';
import 'package:flip_health/routes/app_routes.dart';

class MentalWellnessController extends GetxController {
  final MentalWellnessRepository _repository;

  MentalWellnessController({required MentalWellnessRepository repository})
      : _repository = repository;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final service = ''.obs;
  final consultation = ''.obs;
  final language = ''.obs;
  final isLoading = false.obs;
  final connectEnabled = false.obs;

  final categories = <String>[].obs;

  static const List<String> availableLanguages = [
    'English',
    'Hindi',
    'Telugu',
    'Tamil',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Marathi',
    'Gujarati',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
    _loadCategories();
    nameController.addListener(_validateFields);
    phoneController.addListener(_validateFields);
    emailController.addListener(_validateFields);
  }

  Future<void> _loadProfileData() async {
    final data = await _repository.getProfileData();
    nameController.text = data['name'] ?? '';
    phoneController.text = data['phone'] ?? '';
    emailController.text = data['email'] ?? '';
    language.value = data['language'] ?? '';
    service.value = data['service'] ?? '';
  }

  Future<void> _loadCategories() async {
    categories.value = await _repository.getCategories();
  }

  void setService(String value) {
    service.value = value;
    if (value != 'Mental Wellness') {
      consultation.value = '';
    }
    _validateFields();
  }

  void setConsultation(String value) {
    consultation.value = value;
    _validateFields();
  }

  void setLanguage(String value) {
    language.value = value;
    _validateFields();
  }

  void _validateFields() {
    final nameOk = nameController.text.trim().isNotEmpty;
    final phoneOk = phoneController.text.trim().length == 10;
    final emailOk = GetUtils.isEmail(emailController.text.trim());
    final serviceOk = service.value.isNotEmpty;
    final langOk = language.value.isNotEmpty;
    final consultOk = service.value != 'Mental Wellness' || consultation.value.isNotEmpty;

    connectEnabled.value = nameOk && phoneOk && emailOk && serviceOk && langOk && consultOk;
  }

  Future<void> submitRequest() async {
    if (!connectEnabled.value) return;

    isLoading.value = true;

    try {
      await _repository.submitRequest(data: {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'service': service.value,
        'consultation': consultation.value,
        'language': language.value,
      });

      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;
      Get.dialog(
        _buildSuccessDialog(),
        barrierDismissible: false,
      );
    } catch (_) {
      isLoading.value = false;
    }
  }

  Widget _buildSuccessDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Thank you for your request!\n\nOur team will call you within 20 minutes to schedule your session.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed(AppRoutes.dashboard);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
