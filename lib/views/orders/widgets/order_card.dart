import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/order_models.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final String iconPath;
  final VoidCallback onTap;
  final int index;

  const OrderCard({
    super.key,
    required this.order,
    required this.iconPath,
    required this.onTap,
    required this.index,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final delay = (widget.index * 0.12).clamp(0.0, 0.6);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(curved);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(curved);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      case 'Processing':
        return AppColors.info;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.successLight;
      case 'Pending':
        return AppColors.warningLight;
      case 'Processing':
        return AppColors.infoLight;
      case 'Cancelled':
        return AppColors.errorLight;
      default:
        return AppColors.backgroundSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final dateStr = DateFormat('dd MMM yyyy').format(order.date);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.rh),
            padding: EdgeInsets.all(14.rs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.rs),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46.rs,
                  height: 46.rs,
                  padding: EdgeInsets.all(10.rs),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12.rs),
                  ),
                  child: SvgPicture.asset(
                    widget.iconPath,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: 12.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CommonText(
                              order.type,
                              fontSize: 14.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.rw,
                              vertical: 3.rh,
                            ),
                            decoration: BoxDecoration(
                              color: _statusBgColor(order.status),
                              borderRadius: BorderRadius.circular(20.rs),
                            ),
                            child: CommonText(
                              order.status,
                              fontSize: 10.rf,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(order.status),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.rh),
                      CommonText(
                        '${AppString.kOrderId}: ${order.id}',
                        fontSize: 11.rf,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(height: 4.rh),
                      Row(
                        children: [
                          Expanded(
                            child: CommonText(
                              '${order.patientName}  •  $dateStr',
                              fontSize: 11.rf,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w400,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (order.amount > 0)
                            CommonText(
                              '₹${order.amount.toStringAsFixed(0)}',
                              fontSize: 14.rf,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          if (order.amount == 0)
                            CommonText(
                              'FREE',
                              fontSize: 12.rf,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.rw),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.rs,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
