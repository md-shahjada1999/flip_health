import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/routes/app_routes.dart';

class GymMembershipPaymentSuccessScreen extends StatelessWidget {
  const GymMembershipPaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final m = args is Map
        ? Map<String, dynamic>.from(args)
        : <String, dynamic>{};

    final invoiceId = (m['invoice_id'] ?? '').toString().trim();

    final rows = <MapEntry<String, String>>[
      if (invoiceId.isNotEmpty) MapEntry('Invoice ID', '#$invoiceId'),
      if ((m['name'] ?? '').toString().isNotEmpty)
        MapEntry('Name', m['name'].toString()),
      if ((m['email'] ?? '').toString().isNotEmpty)
        MapEntry('Email', m['email'].toString()),
      if ((m['phone'] ?? '').toString().isNotEmpty)
        MapEntry('Phone', m['phone'].toString()),
      if ((m['location'] ?? '').toString().isNotEmpty)
        MapEntry('Location', m['location'].toString()),
      if ((m['start_date'] ?? '').toString().isNotEmpty)
        MapEntry('Start date', m['start_date'].toString()),
      if ((m['end_date'] ?? '').toString().isNotEmpty)
        MapEntry('End date', m['end_date'].toString()),
    ];

    return SafeScreenWrapper(
      bottomSafe: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.rw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 24.rh),
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 88.rs,
                    ),
                    SizedBox(height: 24.rh),
                    CommonText(
                      'Gym membership purchase successful',
                      fontSize: 22.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.rh),
                    CommonText(
                      'Activation takes up to 15 working days. You will be notified once your membership is active.',
                      fontSize: 15.rf,
                      height: 1.45,
                      color: AppColors.textTertiary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 28.rh),
                    if (rows.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.rs),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14.rs),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              'Membership details',
                              fontSize: 14.rf,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            Divider(height: 20.rh, color: AppColors.divider),
                            for (var i = 0; i < rows.length; i++)
                              _SummaryRow(
                                label: rows[i].key,
                                value: rows[i].value,
                                isLast: i == rows.length - 1,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SafeBottomPadding(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (invoiceId.isNotEmpty) ...[
                    OutlinedButton(
                      onPressed: () => Get.offNamed(
                        AppRoutes.gymMembershipOrderDetail,
                        arguments: {'invoiceId': invoiceId},
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(vertical: 14.rh),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.rs),
                        ),
                      ),
                      child: CommonText(
                        'View order details',
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12.rh),
                  ],
                  ActionButton(
                    text: AppString.kDone,
                    backgroundColor: AppColors.textPrimary,
                    icon: Icons.done_rounded,
                    onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.rw,
            child: CommonText(
              label,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: CommonText(
              value,
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
