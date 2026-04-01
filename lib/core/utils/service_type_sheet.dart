import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class ServiceOption {
  final String title;
  final String subtitle;
  final String svgPath;
  final VoidCallback onTap;

  const ServiceOption({
    required this.title,
    required this.subtitle,
    required this.svgPath,
    required this.onTap,
  });
}

class ServiceTypeSheet {
  static void show({
    required String title,
    required List<ServiceOption> options,
  }) {
    Get.bottomSheet(
      Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(20.rs, 12.rs, 20.rs, 24.rs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.rw,
                  height: 4.rh,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2.rs),
                  ),
                ),
                SizedBox(height: 20.rh),
                CommonText(
                  title,
                  fontSize: 18.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 20.rh),
                Row(
                  children: options.map((option) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.rw),
                        child: _ServiceOptionCard(option: option),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.rh),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _ServiceOptionCard extends StatelessWidget {
  final ServiceOption option;

  const _ServiceOptionCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
        option.onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.rh, horizontal: 12.rw),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.rs,
              height: 56.rs,
              padding: EdgeInsets.all(12.rs),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                option.svgPath,
                width: 28.rs,
                height: 28.rs,
              ),
            ),
            SizedBox(height: 14.rh),
            CommonText(
              option.title,
              fontSize: 14.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.rh),
            CommonText(
              option.subtitle,
              fontSize: 11.rf,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
