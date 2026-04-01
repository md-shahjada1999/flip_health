import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HealthScoreController extends GetxController
    with GetTickerProviderStateMixin {
  final pageController = PageController();
  final currentPage = 0.obs;

  // Page 1: Personal Info + Health conditions
  final nameController = TextEditingController();
  final nameText = ''.obs;
  final dob = Rxn<DateTime>();
  final language = ''.obs;
  final isDiabetic = RxnBool();
  final hasBloodPressure = RxnBool();

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() => nameText.value = nameController.text);
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

  void calculateBMI() {
    final heightM = bmiHeightCm.value / 100;
    if (heightM <= 0 || bmiWeightKg.value <= 0) return;

    bmiValue.value = bmiWeightKg.value / pow(heightM, 2);

    if (bmiValue.value < 18.5) {
      bmiCategory.value = 'Underweight';
      bmiColor.value = const Color(0xFF42A5F5);
    } else if (bmiValue.value < 25) {
      bmiCategory.value = 'Healthy';
      bmiColor.value = const Color(0xFF4CAF50);
    } else if (bmiValue.value < 30) {
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
