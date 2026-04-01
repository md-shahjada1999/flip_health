import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health_score%20controllers/health_score_controller.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;

  ProfileController({required ProfileRepository repository})
      : _repository = repository;

  final firstName = ''.obs;
  final lastName = ''.obs;
  final phone = ''.obs;
  final email = ''.obs;
  final profileImagePath = ''.obs;

  final bmiValue = 0.0.obs;
  final bmiCategory = ''.obs;
  final bmiColor = Rx<Color>(const Color(0xFF4CAF50));

  String get fullName {
    final first = firstName.value.trim();
    final last = lastName.value.trim();
    if (first.isEmpty && last.isEmpty) return 'User';
    return '$first $last'.trim();
  }

  String get initials {
    final first = firstName.value.trim();
    final last = lastName.value.trim();
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : 'U';
  }

  bool get hasProfileImage =>
      profileImagePath.value.isNotEmpty &&
      File(profileImagePath.value).existsSync();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadBMIData();
  }

  Future<void> _loadUserData() async {
    final data = await _repository.getUserData();
    firstName.value = data['firstName'] ?? '';
    lastName.value = data['lastName'] ?? '';
    phone.value = data['phone'] ?? '';
    email.value = data['email'] ?? '';
    profileImagePath.value = data['profileImage'] ?? '';
  }

  void _loadBMIData() {
    if (Get.isRegistered<HealthScoreController>()) {
      final hsc = Get.find<HealthScoreController>();
      bmiValue.value = hsc.bmiValue.value;
      bmiCategory.value = hsc.bmiCategory.value;
      bmiColor.value = hsc.bmiColor.value;
    }
  }

  void pickProfilePhoto() {
    FilePickerHelper.showPickerBottomSheet(
      showFilePicker: false,
      onFilePicked: (file) async {
        profileImagePath.value = file.path;
        await _repository.updateProfileImage(path: file.path);
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    Get.offAllNamed('/login');
  }
}
