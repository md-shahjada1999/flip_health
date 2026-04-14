import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/controllers/gym_membership_order_detail_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';

class GymMembershipOrderDetailScreen extends StatelessWidget {
  const GymMembershipOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GymMembershipOrderDetailController>();
    return Obx(() {
      return SafeScreenWrapper(
        appBar: CommonAppBar.build(title: 'Gym membership'),
        bottomNavigationBar: c.showContinuePayment
            ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.rw, 0, 12.rw, 12.rh),
                  child: FilledButton(
                    onPressed: c.isSubmitting.value ? null : c.continuePayment,
                    child: c.isSubmitting.value
                        ? SizedBox(
                            width: 20.rs,
                            height: 20.rs,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Continue with payment'),
                  ),
                ),
              )
            : null,
        body: () {
          if (c.isLoading.value && !c.detailsFetched.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!c.detailsFetched.value || c.invoice.value == null) {
            return Center(
              child: CommonText(
                'Could not load gym membership',
                fontSize: 14.rf,
                color: AppColors.textSecondary,
              ),
            );
          }

          final inv = c.invoice.value!;
          final info = c.info;
          final details = info['details'] is Map
              ? Map<String, dynamic>.from(info['details'] as Map)
              : <String, dynamic>{};
          final memberInfo = details['info'] is Map
              ? Map<String, dynamic>.from(details['info'] as Map)
              : <String, dynamic>{};

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12.rw, 12.rh, 12.rw, 24.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusBanner(
                  orderId: info['id']?.toString(),
                  statusText: _serviceStatusText(c.infoStatus),
                  cancellationReason: info['cancellation_reason']?.toString(),
                ),
                SizedBox(height: 12.rh),
                _SectionCard(
                  title: AppString.kPatientDetails,
                  child: Column(
                    children: [
                      _row('Name', memberInfo['name']?.toString() ?? '—'),
                      _row('Email', memberInfo['email']?.toString() ?? '—'),
                      _row('Phone', memberInfo['phone']?.toString() ?? '—'),
                      _row(
                        'Location',
                        details['location']?.toString() ??
                            info['location']?.toString() ??
                            '—',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.rh),
                _SectionCard(
                  title: 'Membership details',
                  child: Column(
                    children: [
                      _row(
                        'Start date',
                        _formatDate(details['start_date']?.toString()),
                      ),
                      _row(
                        'End date',
                        _formatDate(details['end_date']?.toString()),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                if (inv.details.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _SectionCard(
                    title: 'Invoice details',
                    child: Column(
                      children: [
                        for (int i = 0; i < inv.details.length; i++)
                          _detailLine(
                            inv.details[i],
                            isLast: i == inv.details.length - 1,
                          ),
                      ],
                    ),
                  ),
                ],
                if (inv.payments.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _SectionCard(
                    title: AppString.kPaymentDetails,
                    child: Column(
                      children: [
                        for (int i = 0; i < inv.payments.length; i++)
                          _paymentTile(
                            inv.payments[i],
                            isLast: i == inv.payments.length - 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }(),
      );
    });
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.orderId,
    required this.statusText,
    this.cancellationReason,
  });

  final String? orderId;
  final String statusText;
  final String? cancellationReason;

  @override
  Widget build(BuildContext context) {
    final reason = statusText == 'Cancelled' && cancellationReason != null
        ? ' ($cancellationReason)'
        : '';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE2B8),
        borderRadius: BorderRadius.circular(12.rs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            'Order ID: ${orderId ?? '—'}',
            fontSize: 12.rf,
            color: const Color(0xFFF15A3D),
          ),
          SizedBox(height: 8.rh),
          CommonText(
            'Status: $statusText$reason',
            fontSize: 13.rf,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF15A3D),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

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

Widget _row(String label, String value, {bool isLast = false}) {
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 8.rh),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90.rw,
          child: CommonText(
            label,
            fontSize: 12.rf,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: CommonText(
            value,
            fontSize: 12.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

Widget _detailLine(dynamic line, {bool isLast = false}) {
  if (line is! Map) {
    return _row('Item', line?.toString() ?? '—', isLast: isLast);
  }
  final m = Map<String, dynamic>.from(line);
  final name =
      m['product_name']?.toString() ?? m['name']?.toString() ?? 'Membership';
  final qty = _num(m['qty']);
  final price = _num(m['offer_price'] ?? m['price']);
  final amount = (qty == null || price == null) ? null : qty * price;
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 10.rh),
    child: Row(
      children: [
        Expanded(
          child: CommonText(
            name,
            fontSize: 12.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        CommonText(
          amount == null ? '—' : _money(amount),
          fontSize: 12.rf,
          color: AppColors.textSecondary,
        ),
      ],
    ),
  );
}

Widget _paymentTile(dynamic payment, {bool isLast = false}) {
  if (payment is! Map) {
    return _row('Payment', payment?.toString() ?? '—', isLast: isLast);
  }
  final p = Map<String, dynamic>.from(payment);
  final mode = p['payment_mode'] ?? p['mode'] ?? p['type'] ?? '—';
  final amount = _num(p['amount']);
  final status = p['status']?.toString() ?? '';
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 10.rh),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                mode.toString(),
                fontSize: 12.rf,
                fontWeight: FontWeight.w600,
              ),
              if (status.isNotEmpty)
                CommonText(
                  status,
                  fontSize: 11.rf,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
        CommonText(
          amount == null ? '—' : _money(amount),
          fontSize: 13.rf,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ],
    ),
  );
}

String _serviceStatusText(int status) {
  const map = <int, String>{
    0: 'Waiting for confirmation',
    1: 'Completed',
    2: 'Cancelled',
    3: 'Confirm changes',
    4: 'Payment pending',
    5: 'Booking confirmed',
    9: 'Expired',
  };
  return map[status] ?? 'Waiting for confirmation';
}

String _formatDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final parsed = DateTime.tryParse(raw.trim());
  if (parsed == null) return raw;
  return DateFormat('MMM dd, yyyy').format(parsed.toLocal());
}

double? _num(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '');
}

String _money(double n) {
  if (n % 1 == 0) return '₹${n.toInt()}';
  return '₹${n.toStringAsFixed(2)}';
}
