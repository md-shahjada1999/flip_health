import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/routes/app_routes.dart';

/// After health checkup booking (wallet / zero pay / post-Razorpay confirm).
class HealthCheckupBookingSuccessScreen extends StatelessWidget {
  final String? invoiceId;
  final String summaryLine;

  const HealthCheckupBookingSuccessScreen({
    super.key,
    this.invoiceId,
    this.summaryLine = '',
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return PopScope(
      canPop: false,
      child: SafeScreenWrapper(
        bottomSafe: false,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.rs),
                child: Column(
                  children: [
                    SizedBox(height: 48.rh),
                    Icon(Icons.check_circle_rounded,
                        size: 72.rs, color: AppColors.success),
                    SizedBox(height: 20.rh),
                    CommonText(
                      'Booking confirmed',
                      fontSize: 22.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.rh),
                    CommonText(
                      summaryLine.isNotEmpty
                          ? summaryLine
                          : 'Your health checkup order has been placed successfully.',
                      fontSize: 14.rf,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                      height: 1.35,
                    ),
                    if (invoiceId != null && invoiceId!.isNotEmpty) ...[
                      SizedBox(height: 20.rh),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.rs),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(12.rs),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              'Order reference',
                              fontSize: 11.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 4.rh),
                            CommonText(
                              invoiceId!,
                              fontSize: 15.rf,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SafeBottomPadding(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.rs, 0, 20.rs, 20.rh),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50.rh,
                      child: ElevatedButton(
                        onPressed: () =>
                            Get.offAllNamed(AppRoutes.orders),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.rs),
                          ),
                        ),
                        child: CommonText(
                          'View order details',
                          fontSize: 15.rf,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.rh),
                    SizedBox(
                      width: double.infinity,
                      height: 50.rh,
                      child: OutlinedButton(
                        onPressed: () =>
                            Get.offAllNamed(AppRoutes.dashboard),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.rs),
                          ),
                        ),
                        child: CommonText(
                          'Done',
                          fontSize: 15.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
