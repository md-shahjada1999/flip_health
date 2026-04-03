import 'dart:math';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/health_score_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HealthScoreController extends GetxController
    with GetTickerProviderStateMixin {
  final HealthScoreRepository repository;

  HealthScoreController({required this.repository});
  final pageController = PageController();
  final currentPage = 0.obs;

  // Page 1: Personal Info + Health conditions
  final nameController = TextEditingController();
  final nameText = ''.obs;
  final dob = Rxn<DateTime>();
  final language = ''.obs;
  final isDiabetic = RxnBool();
  final hasBloodPressure = RxnBool();

  // Lock flags -- true when field is pre-filled from saved user data
  final isNameLocked = false.obs;
  final isDobLocked = false.obs;
  final isLanguageLocked = false.obs;
  final isDiabeticLocked = false.obs;
  final isBPLocked = false.obs;
  final isGenderLocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() => nameText.value = nameController.text);
    _prefillFromUser();
  }

  void _prefillFromUser() {
    final user = AppSecureStorage.getSavedUser();
    if (user == null) return;

    // Name
    if (user.name.isNotEmpty) {
      nameController.text = user.name;
      nameText.value = user.name;
      isNameLocked.value = true;
    }

    // DOB (format: "1995-10-04")
    if (user.dob != null && user.dob!.isNotEmpty) {
      final parsed = DateTime.tryParse(user.dob!);
      if (parsed != null) {
        dob.value = parsed;
        isDobLocked.value = true;
      }
    }

    // Language
    if (user.language != null && user.language!.isNotEmpty) {
      language.value = user.language!;
      isLanguageLocked.value = true;
    }

    // Diabetic ("yes" / "no")
    if (user.isDiabetic != null && user.isDiabetic!.isNotEmpty) {
      final val = user.isDiabetic!.toLowerCase();
      if (val == 'yes' || val == 'no') {
        isDiabetic.value = val == 'yes';
        isDiabeticLocked.value = true;
      }
    }

    // Blood Pressure ("yes" / "no")
    if (user.isBloodPressure != null && user.isBloodPressure!.isNotEmpty) {
      final val = user.isBloodPressure!.toLowerCase();
      if (val == 'yes' || val == 'no') {
        hasBloodPressure.value = val == 'yes';
        isBPLocked.value = true;
      }
    }

    // Gender ("male" -> 0, "female" -> 1)
    if (user.gender != null && user.gender!.isNotEmpty) {
      final g = user.gender!.toLowerCase();
      if (g == 'male' || g == 'female') {
        selectedGender.value = g == 'male' ? 0 : 1;
        isGenderLocked.value = true;
      }
    }

    // Height & Weight from health_score details
    if (user.healthScore?.details != null) {
      final details = user.healthScore!.details!;
      final h = _parseDouble(details['height']);
      final w = _parseDouble(details['weight']);
      if (h != null && h > 0) bmiHeightCm.value = h;
      if (w != null && w > 0) bmiWeightKg.value = w;
    }
  }

  static double? _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static const List<String> availableLanguages = [
    'English',
    'Hindi',
    'Telugu',
    'Tamil',
    'Kannada',
    'Marathi',
    'Malayalam',
    'Gujarati',
  ];

  // Page 2 (BMI): Full BMI calculator
  final selectedGender = 0.obs;
  final bmiHeightCm = 170.0.obs;
  final isHeightInCm = true.obs;
  final bmiWeightKg = 70.0.obs;
  final isWeightInKg = true.obs;

  // Result
  final bmiValue = 0.0.obs;
  final bmiCategory = ''.obs;
  final bmiColor = const Color(0xFF4CAF50).obs;
  final nutritionSuggestion = false.obs;

  // API state
  final isSubmitting = false.obs;
  final apiError = ''.obs;

  // Auto-calculated age from DOB
  int get calculatedAge {
    if (dob.value == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.value!.year;
    if (now.month < dob.value!.month ||
        (now.month == dob.value!.month && now.day < dob.value!.day)) {
      age--;
    }
    return age;
  }

  // BMI page helpers
  void selectGenderInt(int gender) => selectedGender.value = gender;

  void setHeight(double val) {
    if (isHeightInCm.value) {
      bmiHeightCm.value = val;
    } else {
      bmiHeightCm.value = val * 30.48;
    }
  }

  void toggleHeightUnit(bool useCm) => isHeightInCm.value = useCm;

  void setWeight(double val) {
    if (isWeightInKg.value) {
      bmiWeightKg.value = val;
    } else {
      bmiWeightKg.value = val * 0.453592;
    }
  }

  void toggleWeightUnit(bool useKg) => isWeightInKg.value = useKg;

  double get heightDisplay =>
      isHeightInCm.value ? bmiHeightCm.value : bmiHeightCm.value / 30.48;

  double get weightDisplay =>
      isWeightInKg.value ? bmiWeightKg.value : bmiWeightKg.value / 0.453592;

  double get heightMax => isHeightInCm.value ? 300 : 10;
  double get weightMax => isWeightInKg.value ? 300 : 660;

  String get heightUnitLabel => isHeightInCm.value ? 'cm' : 'ft';
  String get weightUnitLabel => isWeightInKg.value ? 'kg' : 'lbs';

  String get dobFormatted {
    if (dob.value == null) return '';
    final d = dob.value!;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }

  bool get isPage1Valid =>
      nameText.value.trim().length >= 3 &&
      dob.value != null &&
      language.value.isNotEmpty &&
      isDiabetic.value != null &&
      hasBloodPressure.value != null;

  void nextPage() {
    if (currentPage.value < 1) {
      pageController.animateToPage(
        currentPage.value + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.animateToPage(
        currentPage.value - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      currentPage.value--;
    }
  }

  void setDiabetic(bool val) => isDiabetic.value = val;
  void setBP(bool val) => hasBloodPressure.value = val;

  /// Submit health score to backend and receive BMI from API response
  Future<bool> submitHealthScore() async {
    try {
      isSubmitting.value = true;
      apiError.value = '';

      final dobStr = dob.value != null
          ? '${dob.value!.year}-${dob.value!.month.toString().padLeft(2, '0')}-${dob.value!.day.toString().padLeft(2, '0')}'
          : '';

      final result = await repository.submitHealthScore(
        name: nameText.value.trim(),
        gender: selectedGender.value == 0 ? 'male' : 'female',
        dob: dobStr,
        height: _heightInFeetInches(),
        weight: bmiWeightKg.value,
        isDiabetic: isDiabetic.value == true ? 'yes' : 'no',
        language: language.value,
        isBloodPressure: hasBloodPressure.value == true ? 'yes' : 'no',
      );

      PrintLog.printLog('HealthScore API BMI: ${result.healthScore.bmi}');

      bmiValue.value = result.healthScore.bmi;
      nutritionSuggestion.value = result.healthScore.nutritionSuggestion;
      _setCategoryFromBmi(result.healthScore.bmi);

      await AppSecureStorage.setHealthStatus(1);

      return true;
    } catch (e) {
      PrintLog.printLog('submitHealthScore error: $e');
      apiError.value = e.toString();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Convert internal height (cm) to "feet.inches" format, e.g. "5.7"
  String _heightInFeetInches() {
    final totalInches = bmiHeightCm.value / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return '$feet.$inches';
  }

  void _setCategoryFromBmi(double bmi) {
    if (bmi < 18.5) {
      bmiCategory.value = 'Underweight';
      bmiColor.value = const Color(0xFF42A5F5);
    } else if (bmi < 25) {
      bmiCategory.value = 'Healthy';
      bmiColor.value = const Color(0xFF4CAF50);
    } else if (bmi < 30) {
      bmiCategory.value = 'Overweight';
      bmiColor.value = const Color(0xFFFF9800);
    } else {
      bmiCategory.value = 'Obese';
      bmiColor.value = const Color(0xFFF44336);
    }
  }


  String get idealWeightRange {
    final heightM = bmiHeightCm.value / 100;
    if (heightM <= 0) return '--';
    final low = (18.5 * pow(heightM, 2)).toStringAsFixed(1);
    final high = (24.9 * pow(heightM, 2)).toStringAsFixed(1);
    return '$low - $high kg';
  }

  @override
  void onClose() {
    nameController.dispose();
    pageController.dispose();
    super.onClose();
  }
}
