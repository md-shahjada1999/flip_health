import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/controllers/splash%20controller/on_boarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class OnboardingView extends GetView<OnboardingController> {
  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      backgroundColor: Colors.white,
      bottomSafe: false,
      body: Column(
        children: [
          // Skip Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.skipOnboarding,
                child: CommonText(
                  'Skip',
                  color: AppColors.textTertiary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // PageView
          Expanded(
            child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) => controller.currentPage.value = index,
                itemCount: controller.onboardingData.length,
                itemBuilder: (context, index) {
                  final item = controller.onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            child: SvgPicture.asset(
                              item.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Title
                        CommonText(
                          item.title,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Subtitle
                        CommonText(
                          item.subtitle,
                          fontSize: 16,
                          color: AppColors.textTertiary,
                          height: 1.5,
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 60),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Bottom Section
          SafeBottomPadding(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  // Page Indicators
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: controller.currentPage.value == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )),
                  
                  const SizedBox(height: 30),
                  
                  // Get Started Button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonText(
                            controller.currentPage.value == controller.onboardingData.length - 1
                                ? 'Get Started'
                                : 'Next',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}