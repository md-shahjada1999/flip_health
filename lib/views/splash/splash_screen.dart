import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/controllers/splash%20controller/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        return Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Logo with subtle animation
                    AnimatedScale(
                      scale: controller.progress.value > 0.1 ? 1.0 : 0.9,
                      duration: const Duration(milliseconds: 300),
                      child: Image.asset(
                        "assets/png/fliphealth_name_pdf.png",
                        width: 300,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Optional: Loading text
                    AnimatedOpacity(
                      opacity: controller.progress.value > 0.3 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: CommonText(
                        'Loading...',
                        color: AppColors.textTertiary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.border,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: controller.progress.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
        );
      }),
    );
  }
}