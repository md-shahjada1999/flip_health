import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

/// Payment history card used on order detail screens (pharmacy, consultation, service request, etc.).
class OrderPaymentDetailsSection extends StatelessWidget {
  const OrderPaymentDetailsSection({
    super.key,
    required this.payments,
    this.title,
    this.emptyMessage = 'No payment records',
  });

  final List<dynamic> payments;
  final String? title;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final heading = title ?? AppString.kPaymentDetails;
    return _OrderPaymentSectionCard(
      title: heading,
      child: payments.isEmpty
          ? CommonText(
              emptyMessage,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in payments)
                  if (p is Map)
                    OrderPaymentEntryCard(
                      entry: Map<String, dynamic>.from(p),
                    ),
              ],
            ),
    );
  }
}

/// Single payment row: method, optional source, amount (tinted by status), refund note.
class OrderPaymentEntryCard extends StatelessWidget {
  const OrderPaymentEntryCard({super.key, required this.entry});

  final Map<String, dynamic> entry;

  static Color amountColorForStatus(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s == 'success' || s == 'completed') return AppColors.success;
    if (s == 'refunded') return AppColors.warning;
    if (s == 'failed' || s == 'failure') return AppColors.error;
    return AppColors.textPrimary;
  }

  static String formatAmount(dynamic amount) {
    if (amount == null) return '—';
    if (amount is num) {
      if (amount % 1 == 0) return '₹${amount.toInt()}';
      return '₹${amount.toStringAsFixed(2)}';
    }
    final t = amount.toString().trim();
    if (t.isEmpty) return '—';
    return t.startsWith('₹') ? t : '₹$t';
  }

  @override
  Widget build(BuildContext context) {
    final id = entry['id'];
    final mode = entry['payment_mode'] ?? entry['mode'] ?? entry['type'];
    final src = entry['payment_src'] ?? entry['source'];
    final amount = entry['amount'];
    final status = entry['status']?.toString();
    final note = entry['note']?.toString();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.rh),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.rs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.rs),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (id != null)
                    CommonText(
                      '#$id',
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                    ),
                  SizedBox(height: 4.rh),
                  _detailRow('Method', '${mode ?? '—'}'),
                  if (src != null && '$src'.isNotEmpty)
                    _detailRow('Source', '$src'),
                  if (status == 'refunded' &&
                      note != null &&
                      note.isNotEmpty) ...[
                    SizedBox(height: 6.rh),
                    CommonText(
                      'Note: $note',
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommonText(
                  formatAmount(amount),
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: amountColorForStatus(status),
                ),
                if (status != null && status.isNotEmpty)
                  CommonText(
                    status,
                    fontSize: 11.rf,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: 4.rh),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72.rw,
          child: CommonText(
            label,
            fontSize: 11.rf,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: CommonText(
            value,
            fontSize: 12.rf,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _OrderPaymentSectionCard extends StatelessWidget {
  const _OrderPaymentSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          Divider(height: 16.rh, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}
