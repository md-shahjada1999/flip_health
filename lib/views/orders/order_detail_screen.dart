import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/controllers/orders%20controllers/orders_controller.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final order = controller.selectedOrder.value;

    if (order == null) {
      return Scaffold(
        appBar: CommonAppBar.build(title: AppString.kOrderDetails),
        body: Center(
          child: CommonText(
            AppString.kNoOrdersFound,
            fontSize: 14.rf,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.date);
    final subtotal = order.items.fold<double>(0, (s, i) => s + i.price);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: AppString.kOrderDetails),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
        child: Column(
          children: [
            _AnimatedSection(
              animation: _animController,
              intervalStart: 0.0,
              intervalEnd: 0.25,
              child: _StatusBanner(status: order.status),
            ),
            SizedBox(height: 16.rh),

            _AnimatedSection(
              animation: _animController,
              intervalStart: 0.15,
              intervalEnd: 0.45,
              child: _SectionCard(
                title: AppString.kOrderInfo,
                child: Column(
                  children: [
                    _InfoRow(
                      label: AppString.kOrderId,
                      value: order.id,
                    ),
                    _InfoRow(
                      label: AppString.kServiceType,
                      value: order.type,
                      trailing: SvgPicture.asset(
                        controller.iconForType(order.type),
                        width: 20.rs,
                        height: 20.rs,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    _InfoRow(
                      label: AppString.kOrderDate,
                      value: dateStr,
                    ),
                    _InfoRow(
                      label: AppString.kOrderStatus,
                      value: order.status,
                      valueColor: _statusColor(order.status),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.rh),

            _AnimatedSection(
              animation: _animController,
              intervalStart: 0.3,
              intervalEnd: 0.6,
              child: _SectionCard(
                title: AppString.kPatientDetails,
                child: Column(
                  children: [
                    _InfoRow(
                      label: AppString.kPatientName,
                      value: order.patientName,
                    ),
                    _InfoRow(
                      label: AppString.kVendor,
                      value: order.vendorName,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.rh),

            _AnimatedSection(
              animation: _animController,
              intervalStart: 0.45,
              intervalEnd: 0.75,
              child: _SectionCard(
                title: AppString.kServiceDetails,
                child: Column(
                  children: [
                    for (int i = 0; i < order.items.length; i++)
                      _InfoRow(
                        label: order.items[i].name,
                        value: order.items[i].price > 0
                            ? '₹${order.items[i].price.toStringAsFixed(0)}'
                            : 'FREE',
                        isLast: i == order.items.length - 1,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.rh),

            _AnimatedSection(
              animation: _animController,
              intervalStart: 0.6,
              intervalEnd: 0.9,
              child: _SectionCard(
                title: AppString.kPaymentSummary,
                child: Column(
                  children: [
                    _PaymentRow(
                      label: AppString.kSubTotal,
                      value: subtotal > 0
                          ? '₹${subtotal.toStringAsFixed(0)}'
                          : 'FREE',
                    ),
                    _PaymentRow(
                      label: AppString.kFromWallet,
                      value: subtotal > 0
                          ? '- ₹${subtotal.toStringAsFixed(0)}'
                          : '₹0',
                      valueColor: AppColors.success,
                    ),
                    Divider(height: 16.rh, color: AppColors.divider),
                    _PaymentRow(
                      label: AppString.kNetPay,
                      value: '₹0',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.rh),
          ],
        ),
      ),
    );
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
}

class _StatusBanner extends StatelessWidget {
  final String status;

  const _StatusBanner({required this.status});

  Color _bgColor() {
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

  Color _fgColor() {
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

  IconData _icon() {
    switch (status) {
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'Pending':
        return Icons.schedule_rounded;
      case 'Processing':
        return Icons.sync_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(14.rs),
      ),
      child: Row(
        children: [
          Icon(_icon(), color: _fgColor(), size: 28.rs),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Order $status',
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: _fgColor(),
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  _subtitle(),
                  fontSize: 12.rf,
                  color: _fgColor(),
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    switch (status) {
      case 'Completed':
        return 'This order has been completed successfully';
      case 'Pending':
        return 'Awaiting confirmation from the provider';
      case 'Processing':
        return 'Your order is being processed';
      case 'Cancelled':
        return 'This order has been cancelled';
      default:
        return '';
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

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
          Divider(height: 20.rh, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.rh),
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
              fontSize: 12.rf,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _PaymentRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rh),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            label,
            fontSize: isBold ? 14.rf : 12.rf,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          CommonText(
            value,
            fontSize: isBold ? 14.rf : 12.rf,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? (isBold ? AppColors.primary : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final Animation<double> animation;
  final double intervalStart;
  final double intervalEnd;
  final Widget child;

  const _AnimatedSection({
    required this.animation,
    required this.intervalStart,
    required this.intervalEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
