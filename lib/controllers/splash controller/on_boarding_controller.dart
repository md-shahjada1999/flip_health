import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/model/onboarding%20models/onboarding_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  
  final List<OnboardingModel> onboardingData = [
    OnboardingModel(
      image: AppString.OnboardingScreen1Image, // Your diagnostic illustration
      title: AppString.kOnboardingScreen1Title,
      subtitle: AppString.kOnboardingScreen1Subtitle,
    ),
    OnboardingModel(
      image: AppString.OnboardingScreen2Image, // Your medication illustration
      title: AppString.kOnboardingScreen2Title,
      subtitle: AppString.kOnboardingScreen2Subtitle,
    ),
    OnboardingModel(
      image: AppString.OnboardingScreen3Image, // Your health checkup illustration
      title: AppString.kOnboardingScreen3Title,
      subtitle: AppString.kOnboardingScreen3Subtitle,
    ),
  ];

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      currentPage.value++;
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to next screen (login/home)
      completeOnboarding();
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  void completeOnboarding() {
    // Save onboarding completion status
    // SharedPreferences or GetStorage
    Get.offNamed(AppRoutes.login); // Replace with your next route
  }

  void goToPage(int page) {
    currentPage.value = page;
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
