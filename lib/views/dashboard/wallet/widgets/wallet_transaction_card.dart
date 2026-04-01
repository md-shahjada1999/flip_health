import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:intl/intl.dart';

class WalletTransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final int index;
  final Animation<double>? animation;

  const WalletTransactionCard({
    Key? key,
    required this.transaction,
    this.index = 0,
    this.animation,
  }) : super(key: key);

  Color get _statusColor {
    switch (transaction['status']) {
      case 'success':
        return transaction['type'] == 'CREDIT'
            ? AppColors.success
            : AppColors.primary;
      case 'refunded':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _statusIcon {
    switch (transaction['status']) {
      case 'success':
        return transaction['type'] == 'CREDIT'
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded;
      case 'refunded':
        return Icons.replay_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  String get _statusLabel {
    switch (transaction['status']) {
      case 'success':
        return AppString.kSuccess;
      case 'refunded':
        return AppString.kRefunded;
      default:
        return transaction['status'] ?? '';
    }
  }

  String get _formattedDate {
    try {
      final dt = DateTime.parse(transaction['payment_date']);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return transaction['payment_date'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: EdgeInsets.only(bottom: 10.rh),
      padding: EdgeInsets.all(12.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.rs,
            height: 40.rs,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.rs),
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 18.rs),
          ),
          SizedBox(width: 10.rs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  transaction['ref_type'] ?? '',
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  _formattedDate,
                  fontSize: 10.rf,
                  color: AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.rs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CommonText(
                '${transaction['type'] == 'CREDIT' ? '+' : '-'} ₹${transaction['amount']}',
                fontSize: 13.rf,
                fontWeight: FontWeight.w700,
                color: transaction['type'] == 'CREDIT'
                    ? AppColors.success
                    : AppColors.textPrimary,
              ),
              SizedBox(height: 2.rh),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 6.rs, vertical: 2.rs),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.rs),
                ),
                child: CommonText(
                  _statusLabel,
                  fontSize: 9.rf,
                  fontWeight: FontWeight.w500,
                  color: _statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation!, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation!, curve: Curves.easeOutCubic)),
          child: card,
        ),
      );
    }

    return card;
  }
}
