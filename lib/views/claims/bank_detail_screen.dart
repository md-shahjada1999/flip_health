import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/claims%20models/bank_account_model.dart';

/// Read-only bank details (patient_app: [ShowSelectedBankDetailsView]) — not used for `verify_status == 2`.
class BankDetailScreen extends StatelessWidget {
  const BankDetailScreen({Key? key, required this.account}) : super(key: key);

  final BankAccount account;

  String _statusLabel() {
    switch (account.verifyStatus) {
      case 1:
        return AppString.kStatusVerified;
      case 2:
        return AppString.kStatusRejected;
      default:
        return AppString.kStatusPending;
    }
  }

  Color _statusColor() {
    switch (account.verifyStatus) {
      case 1:
        return const Color(0xFF43A047);
      case 2:
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chequeUrl = ApiUrl.publicFileUrl(account.chequeImagePath);
    final isPdf = (account.chequeImagePath ?? '').toLowerCase().endsWith('.pdf');

    return SafeScreenWrapper(
      appBar: CommonAppBar.build(title: AppString.kBankDetails),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.rs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.rs),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.rs),
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
                  Row(
                    children: [
                      CommonText(
                        AppString.kVerificationStatus,
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
                        decoration: BoxDecoration(
                          color: _statusColor().withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.rs),
                        ),
                        child: CommonText(
                          _statusLabel(),
                          fontSize: 12.rf,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(),
                        ),
                      ),
                    ],
                  ),
                  if (account.verifyStatus == 2 &&
                      (account.verifyReason ?? '').isNotEmpty) ...[
                    SizedBox(height: 10.rh),
                    CommonText(
                      'Note: ${account.verifyReason}',
                      fontSize: 12.rf,
                      color: AppColors.error,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16.rh),
            CommonText(AppString.kBankDetailReadOnlyHint, fontSize: 12.rf, color: AppColors.textSecondary),
            SizedBox(height: 20.rh),
            _field(AppString.kBankName, account.bankName),
            _field(AppString.kAccountHolderName, account.holderName),
            _field(AppString.kIFSCCode, account.ifscCode),
            _field(AppString.kBranch, account.branch),
            _field(AppString.kAccountNumber, account.maskedAccountNumber),
            SizedBox(height: 20.rh),
            CommonText(AppString.kCancelledCheque, fontSize: 13.rf, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            SizedBox(height: 10.rh),
            if (chequeUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.rs),
                child: isPdf
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.rs),
                        color: AppColors.backgroundTertiary,
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 32.rs),
                            SizedBox(width: 12.rw),
                            Expanded(
                              child: CommonText(
                                'PDF document',
                                fontSize: 13.rf,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.network(
                        chequeUrl,
                        height: 180.rh,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.rs),
                              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          padding: EdgeInsets.all(16.rs),
                          color: AppColors.backgroundTertiary,
                          child: CommonText('Could not load image', fontSize: 12.rf, color: AppColors.textSecondary),
                        ),
                      ),
              )
            else
              CommonText('—', fontSize: 14.rf, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.rh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(label, fontSize: 12.rf, color: AppColors.textSecondary),
          SizedBox(height: 6.rh),
          CommonText(value.isEmpty ? '—' : value, fontSize: 15.rf, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
