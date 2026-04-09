import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/global_error_controller.dart';
import 'package:flip_health/core/utils/common_text.dart';

class ServerErrorScreen extends StatelessWidget {
  const ServerErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = Get.find<GlobalErrorController>();

    final String title;
    final String subtitle;
    final IconData icon;
    final Color iconColor;

    switch (ec.errorType.value) {
      case GlobalErrorType.notFound:
        title = 'Page Not Found';
        subtitle = 'The page you are looking for\ndoesn\'t exist or has been moved.';
        icon = Icons.search_off_rounded;
        iconColor = const Color(0xFFF57C00);
        break;
      case GlobalErrorType.timeout:
        title = 'Request Timed Out';
        subtitle = 'The server took too long to respond.\nPlease try again.';
        icon = Icons.hourglass_disabled_rounded;
        iconColor = const Color(0xFFE65100);
        break;
      default:
        title = 'Something Went Wrong';
        subtitle = 'Our server failed to respond.\nPlease try again later.';
        icon = Icons.cloud_off_rounded;
        iconColor = Colors.redAccent;
    }

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.rw),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ServerIllustration(icon: icon, iconColor: iconColor),
                SizedBox(height: 40.rh),
                CommonText(
                  title,
                  fontSize: 20.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.rh),
                CommonText(
                  subtitle,
                  fontSize: 14.rf,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                  height: 1.5,
                ),
                if (ec.errorMessage.value.isNotEmpty) ...[
                  SizedBox(height: 8.rh),
                  CommonText(
                    ec.errorMessage.value,
                    fontSize: 11.rf,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 36.rh),
                SizedBox(
                  width: 180.rw,
                  height: 48.rh,
                  child: ElevatedButton.icon(
                    onPressed: ec.clearError,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: CommonText(
                      'Try Again',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.rs),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServerIllustration extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _ServerIllustration({required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    final size = 160.rs;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.06),
            ),
          ),
          Container(
            width: size * 0.65,
            height: size * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.1),
            ),
          ),
          Icon(icon, size: size * 0.35, color: iconColor),
          Positioned(
            bottom: size * 0.08,
            right: size * 0.12,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 2),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  size: size * 0.1, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}
