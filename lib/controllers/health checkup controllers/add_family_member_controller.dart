import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/data/repositories/family_member_repository.dart';

/// Add dependent — matches patient_app member create + POST body fields.
/// OTP: `POST /patient/otp` `{ key, action: MEMBER }` when phone is provided; `code` only then.
class AddFamilyMemberController extends GetxController {
  AddFamilyMemberController({required FamilyMemberRepository repository})
      : _repository = repository;

  final FamilyMemberRepository _repository;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final weightController = TextEditingController();

  final RxString selectedRelationship = ''.obs;
  /// UI labels: Male, Female, Other → API: male, female, other
  final RxString selectedGender = ''.obs;
  final Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);

  final RxString selectedHeightFeet = ''.obs;
  final RxString selectedHeightInches = ''.obs;
  /// Yes / No (display); API: yes, no
  final RxString selectedBloodPressure = ''.obs;
  final RxString selectedDiabetes = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool otpSending = false.obs;
  final RxBool otpSent = false.obs;
  final RxInt resendSeconds = 0.obs;
  final RxList<String> relationshipOptions = <String>[].obs;

  /// Drives Obx for OTP section visibility (TextEditingController is not reactive).
  final RxString phoneForUi = ''.obs;

  /// Bumps when any field changes so [canSave] re-evaluates in [Obx].
  final RxInt formStateTick = 0.obs;

  final List<String> heightFeetOptions =
      List<String>.generate(7, (i) => '${i + 1}');
  final List<String> heightInchOptions = [
    '00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12',
  ];
  static const List<String> yesNoDisplay = ['Yes', 'No'];

  Timer? _resendTimer;
  String? _phoneWhenOtpSent;

  @override
  void onInit() {
    super.onInit();
    relationshipOptions.assignAll(AppString.kRelationships);
    phoneController.addListener(_onPhoneChanged);
    nameController.addListener(_touchForm);
    weightController.addListener(_touchForm);
    otpController.addListener(_touchForm);
    phoneForUi.value = phoneController.text;
    _loadRelationships();
  }

  void _touchForm() {
    formStateTick.value++;
  }

  void _onPhoneChanged() {
    phoneForUi.value = phoneController.text;
    if (!otpSent.value || _phoneWhenOtpSent == null) {
      _touchForm();
      return;
    }
    if (phoneController.text.trim() != _phoneWhenOtpSent) {
      otpSent.value = false;
      otpController.clear();
      _phoneWhenOtpSent = null;
      _resendTimer?.cancel();
      resendSeconds.value = 0;
    }
    _touchForm();
  }

  Future<void> _loadRelationships() async {
    try {
      final names = await _repository.getDependentTypes();
      if (names.isNotEmpty) {
        relationshipOptions.assignAll(names);
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    phoneController.removeListener(_onPhoneChanged);
    nameController.removeListener(_touchForm);
    weightController.removeListener(_touchForm);
    otpController.removeListener(_touchForm);
    _resendTimer?.cancel();
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    weightController.dispose();
    super.onClose();
  }

  bool get _hasPhoneForOtp {
    final p = phoneController.text.trim();
    return p.length == 10 && RegExp(r'^\d{10}$').hasMatch(p);
  }

  String? validateRelationship(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.kRelationshipRequired;
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppString.kNameRequired;
    }
    if (value.trim().length < 3) {
      return AppString.kNameMinThreeChars;
    }
    return null;
  }

  String? validateDateOfBirth(String? value) {
    if (selectedDateOfBirth.value == null) {
      return AppString.kDateOfBirthRequired;
    }
    return null;
  }

  String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.kGenderRequired;
    }
    return null;
  }

  /// Optional: empty ok, else 10 digits.
  String? validatePhoneOptional(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length != 10 || !RegExp(r'^\d{10}$').hasMatch(v)) {
      return AppString.kInvalidPhoneNumber;
    }
    return null;
  }

  String? validateHeightFeet(String? value) {
    if (selectedHeightFeet.value.isEmpty) {
      return AppString.kHeightRequired;
    }
    return null;
  }

  String? validateHeightInches(String? value) {
    if (selectedHeightInches.value.isEmpty) {
      return AppString.kHeightRequired;
    }
    return null;
  }

  String? validateWeight(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppString.kWeightRequired;
    final n = double.tryParse(v);
    if (n == null || n <= 0 || n > 500) {
      return AppString.kWeightInvalid;
    }
    return null;
  }

  String? validateBloodPressure(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.kBloodPressureRequired;
    }
    return null;
  }

  String? validateDiabetes(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.kDiabetesRequired;
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (!_hasPhoneForOtp) return null;
    if (!otpSent.value) return null;
    final v = value?.trim() ?? '';
    if (v.length != 6 || !RegExp(r'^\d{6}$').hasMatch(v)) {
      return AppString.kEnterValidOtp;
    }
    return null;
  }

  /// Save enabled when all required fields are valid; if phone is 10 digits, OTP sent + 6-digit code required.
  bool canSave() {
    if (selectedRelationship.value.isEmpty) return false;
    final name = nameController.text.trim();
    if (name.length < 3) return false;
    if (selectedDateOfBirth.value == null) return false;
    if (selectedGender.value.isEmpty) return false;
    if (selectedHeightFeet.value.isEmpty || selectedHeightInches.value.isEmpty) {
      return false;
    }
    final w = weightController.text.trim();
    final weightNum = double.tryParse(w);
    if (w.isEmpty || weightNum == null || weightNum <= 0 || weightNum > 500) {
      return false;
    }
    if (selectedBloodPressure.value.isEmpty || selectedDiabetes.value.isEmpty) {
      return false;
    }

    final phone = phoneController.text.trim();
    if (phone.isNotEmpty && phone.length != 10) return false;
    if (_hasPhoneForOtp) {
      if (!otpSent.value) return false;
      final otp = otpController.text.trim();
      if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
        return false;
      }
    }
    return true;
  }

  void selectRelationship(String? relationship) {
    if (relationship != null) selectedRelationship.value = relationship;
    _touchForm();
  }

  void selectGender(String? gender) {
    if (gender != null) selectedGender.value = gender;
    _touchForm();
  }

  void selectHeightFeet(String? v) {
    if (v != null) selectedHeightFeet.value = v;
    _touchForm();
  }

  void selectHeightInches(String? v) {
    if (v != null) selectedHeightInches.value = v;
    _touchForm();
  }

  void selectBloodPressure(String? v) {
    if (v != null) selectedBloodPressure.value = v;
    _touchForm();
  }

  void selectDiabetes(String? v) {
    if (v != null) selectedDiabetes.value = v;
    _touchForm();
  }

  Future<void> selectDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDateOfBirth.value = picked;
      _touchForm();
    }
  }

  String getFormattedDate() {
    if (selectedDateOfBirth.value == null) {
      return AppString.kDateOfBirthHint;
    }
    final date = selectedDateOfBirth.value!;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// API `height`: `ft.in` (e.g. `5.08`) — same pattern as patient_app.
  String _heightApiString() {
    return '${selectedHeightFeet.value}.${selectedHeightInches.value}';
  }

  /// `male` | `female` | `other`
  String _genderApi() {
    switch (selectedGender.value) {
      case 'Male':
        return 'male';
      case 'Female':
        return 'female';
      case 'Other':
        return 'other';
      default:
        return selectedGender.value.toLowerCase();
    }
  }

  /// `yes` | `no`
  String _yesNoApi(String displayYesNo) {
    return displayYesNo.toLowerCase();
  }

  String _dobApiFormat() {
    final d = selectedDateOfBirth.value!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    resendSeconds.value = 30;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        t.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone)) {
      AppToast.error(
        title: 'Invalid number',
        message: AppString.kInvalidPhoneNumber,
      );
      return;
    }
    if (otpSending.value) return;
    otpSending.value = true;
    try {
      await _repository.sendMemberOtp(phone);
      otpSent.value = true;
      _phoneWhenOtpSent = phone;
      otpController.clear();
      _touchForm();
      _startResendCooldown();
      AppToast.success(
        title: AppString.kOtpSentTitle,
        message: AppString.kOtpSentSuccess,
      );
    } on AppException catch (e) {
      AppToast.error(title: 'OTP', message: e.message);
    } catch (e) {
      AppToast.error(title: 'OTP', message: e.toString());
    } finally {
      otpSending.value = false;
    }
  }

  Future<void> saveAndContinue() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (selectedDateOfBirth.value == null) {
      AppToast.error(
        title: 'Validation',
        message: AppString.kDateOfBirthRequired,
      );
      return;
    }

    if (_hasPhoneForOtp) {
      if (!otpSent.value) {
        AppToast.error(
          title: 'OTP required',
          message: AppString.kSendOtpFirst,
        );
        return;
      }
      final otp = otpController.text.trim();
      if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
        AppToast.error(
          title: 'OTP',
          message: AppString.kEnterValidOtp,
        );
        return;
      }
    }

    isLoading.value = true;
    try {
      final phone = phoneController.text.trim();
      final payload = <String, dynamic>{
        'name': nameController.text.trim(),
        'gender': _genderApi(),
        'dob': _dobApiFormat(),
        'height': _heightApiString(),
        'weight': weightController.text.trim(),
        'isBloodPressure': _yesNoApi(selectedBloodPressure.value),
        'isDiabetic': _yesNoApi(selectedDiabetes.value),
        'relationship': selectedRelationship.value,
        'phone': phone.isEmpty ? '' : phone,
      };

      if (_hasPhoneForOtp) {
        payload['code'] = otpController.text.trim();
      }

      await _repository.addFamilyMember(data: payload);

      if (Get.isRegistered<MemberController>()) {
        await Get.find<MemberController>().loadMembers();
      }

      Get.offNamed(AppRoutes.addFamilyMemberSuccess);
    } on AppException catch (e) {
      AppToast.error(title: 'Error', message: e.message);
    } catch (e) {
      AppToast.error(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
