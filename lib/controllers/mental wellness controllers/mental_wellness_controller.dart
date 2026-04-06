
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/data/repositories/member_repository.dart';
import 'package:flip_health/data/repositories/mental_wellness_repository.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/routes/app_routes.dart';

/// `from`: `wellness` (default) | `nutritionist` — matches patient_app TRIJOG arguments.
class MentalWellnessController extends GetxController {
  final MentalWellnessRepository _repository;
  final MemberRepository _memberRepository;

  MentalWellnessController({
    required MentalWellnessRepository repository,
    required MemberRepository memberRepository,
  })  : _repository = repository,
        _memberRepository = memberRepository;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  /// Dashboard / search entry: `wellness` or `nutritionist`.
  final fromWhere = 'wellness'.obs;

  final service = ''.obs;
  final consultation = ''.obs;
  final language = ''.obs;
  final isSubmitting = false.obs;
  final connectEnabled = false.obs;

  final categories = <String>[].obs;

  final members = <FamilyMember>[].obs;
  final membersLoading = true.obs;
  final selectedMemberId = ''.obs;

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

  static const String kFromNutritionist = 'nutritionist';
  static const String kFromWellness = 'wellness';

  bool get isNutritionEntry => fromWhere.value == kFromNutritionist;

  /// Trijog mental wellness flow (categories + `service_area`); not nutrition.
  bool get isMentalWellnessEntry => fromWhere.value == kFromWellness;

  static String normalizePhone10(String? raw) {
    final d = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (d.length >= 10) return d.substring(d.length - 10);
    return d;
  }

  @override
  void onInit() {
    super.onInit();
    _readRouteArguments();
    if (isNutritionEntry) {
      service.value = 'Diet & Nutrition';
    } else {
      service.value = 'Mental Wellness';
    }
    nameController.addListener(_validateFields);
    phoneController.addListener(_validateFields);
    emailController.addListener(_validateFields);
    _bootstrapMembersAndCategories();
  }

  Future<void> _bootstrapMembersAndCategories() async {
    await _loadMembers();
    _loadCategoriesIfNeeded();
  }

  Future<void> _loadMembers() async {
    membersLoading.value = true;
    try {
      final list = await _memberRepository.getMembers();
      members.assignAll(list);
      if (list.isNotEmpty) {
        FamilyMember pick = list.first;
        for (final m in list) {
          if ((m.relationship ?? '').toLowerCase() == 'self') {
            pick = m;
            break;
          }
        }
        selectMember(pick);
      } else {
        _loadProfileFieldsFallback();
      }
    } catch (_) {
      _loadProfileFieldsFallback();
    } finally {
      membersLoading.value = false;
      _validateFields();
    }
  }

 void selectMember(FamilyMember m) {
  selectedMemberId.value = m.id;
  nameController.text = m.name;
  
  final phone = normalizePhone10(m.phone);
  if (phone.isNotEmpty) {
    phoneController.text = phone;
  } else {
    phoneController.clear();
  }

  final email = (m.email ?? '').trim();
  if (email.isNotEmpty) {
    emailController.text = email;
  } else {
    emailController.clear();
  }

  _validateFields();
}
  void _loadProfileFieldsFallback() {
    final user = AppSecureStorage.getSavedUser();
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = normalizePhone10(user.phone);
      emailController.text = user.email;
      if (user.language != null && user.language!.isNotEmpty) {
        language.value = user.language!;
      }
    } else {
      nameController.text =
          AppSecureStorage.getStringFromSharedPref(
                variableName: AppSecureStorage.kUserName,
              ) ??
              '';
      phoneController.text = normalizePhone10(
        AppSecureStorage.getStringFromSharedPref(
          variableName: AppSecureStorage.kUserPhone,
        ),
      );
      emailController.text =
          AppSecureStorage.getStringFromSharedPref(
                variableName: AppSecureStorage.kUserEmail,
              ) ??
              '';
      final lang = AppSecureStorage.getStringFromSharedPref(
        variableName: AppSecureStorage.kUserLanguage,
      );
      if (lang != null && lang.isNotEmpty) {
        language.value = lang;
      }
    }
  }

  void _readRouteArguments() {
    final args = Get.arguments;
    if (args is Map) {
      final f = args['from']?.toString();
      if (f == kFromNutritionist) {
        fromWhere.value = kFromNutritionist;
      } else {
        fromWhere.value = kFromWellness;
      }
    } else {
      fromWhere.value = kFromWellness;
    }
  }

  Future<void> _loadCategoriesIfNeeded() async {
    if (isNutritionEntry) return;

    try {
      final list = await _repository.fetchMentalWellnessCategories();
      categories.assignAll(list.map((e) => e.value).toList());
    } on AppException catch (e) {
      AppToast.error(title: 'Could not load categories', message: e.message);
      categories.clear();
    } catch (_) {
      AppToast.error(
        title: 'Error',
        message: 'Could not load categories. Please try again.',
      );
      categories.clear();
    }
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
    final memberOk =
        members.isEmpty || selectedMemberId.value.isNotEmpty;
    final consultOk = service.value != 'Mental Wellness' ||
        consultation.value.isNotEmpty;

    connectEnabled.value = nameOk &&
        phoneOk &&
        emailOk &&
        serviceOk &&
        langOk &&
        memberOk &&
        consultOk;
  }

  Future<void> onConnectPressed() async {
    if (isSubmitting.value) return;

    if (members.isNotEmpty && selectedMemberId.value.isEmpty) {
      AppToast.warning(
        title: 'Required',
        message: 'Please select a family member',
      );
      return;
    }
    if (nameController.text.trim().isEmpty) {
      AppToast.warning(title: 'Required', message: 'Please enter your name');
      return;
    }
    if (phoneController.text.trim().length != 10) {
      AppToast.warning(
        title: 'Required',
        message: 'Please enter a valid 10-digit mobile number',
      );
      return;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      AppToast.warning(
        title: 'Required',
        message: 'Please enter a valid email address',
      );
      return;
    }
    if (language.value.isEmpty) {
      AppToast.warning(title: 'Required', message: 'Please select a language');
      return;
    }
    if (service.value == 'Mental Wellness' && consultation.value.isEmpty) {
      AppToast.warning(
        title: 'Required',
        message: 'Please select a consultation category',
      );
      return;
    }

    await submitRequest();
  }

  Future<void> submitRequest() async {
    if (!connectEnabled.value || isSubmitting.value) return;

    if (service.value == 'Mental Wellness' && categories.isEmpty) {
      AppToast.warning(
        title: 'Categories unavailable',
        message:
            'Please try again after categories load, or open the screen again.',
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm'),
        content: Text(
          isNutritionEntry
              ? 'You want to raise a request with our Nutritionist?'
              : 'You want to raise a request with our specialist for ${service.value}?',
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false), child: const Text('No')),
          TextButton(
              onPressed: () => Get.back(result: true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirmed != true) return;

    isSubmitting.value = true;
    try {
      await _repository.submitWellnessSession(
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        service: service.value,
        language: language.value,
        serviceArea:
            service.value == 'Mental Wellness' ? consultation.value : null,
        patient_id:
            selectedMemberId.value.isNotEmpty ?  selectedMemberId.value : null,
      );

      Get.offNamed(
        AppRoutes.wellnessRequestSuccess,
        arguments: {
          'service': service.value,
          'nutrition': isNutritionEntry || service.value == 'Diet & Nutrition',
        },
      );
    }  catch (_) {
      AppToast.error(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
