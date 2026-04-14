import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/wellness_order_detail_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/pharmacy/pharmacy_order_invoice_table.dart';

class WellnessOrderDetailScreen extends StatelessWidget {
  const WellnessOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WellnessOrderDetailController>();

    return Obx(() {
      return SafeScreenWrapper(
        appBar: CommonAppBar.build(
          title: c.detailsFetched.value ? c.serviceTitle : AppString.kOrderDetails,
        ),
        body: () {
          if (c.isLoading.value && !c.detailsFetched.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!c.detailsFetched.value || c.invoice.value == null) {
            return Center(
              child: CommonText(
                'Could not load order',
                fontSize: 14.rf,
                color: AppColors.textSecondary,
              ),
            );
          }

          final info = c.info ?? <String, dynamic>{};
          final details = c.serviceDetails ?? <String, dynamic>{};
          final cancellationReason = info['cancellation_reason']?.toString();

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12.rw, 12.rh, 12.rw, 24.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusBanner(
                  orderId: info['id']?.toString(),
                  status: c.statusLabel,
                  cancellationReason: cancellationReason,
                ),
                SizedBox(height: 16.rh),
                _SectionCard(
                  title: AppString.kServiceDetails,
                  child: _ServiceDetails(details: details),
                ),
                if (c.showInvoiceSection) ...[
                  SizedBox(height: 16.rh),
                  PharmacyOrderInvoiceTable(
                    lines: c.lineItems,
                    invoice: c.invoice.value!.raw,
                  ),
                ],
                if (c.showPaymentsSection) ...[
                  SizedBox(height: 16.rh),
                  _PaymentSection(payments: c.paymentItems),
                ],
                if (c.canCancel) ...[
                  SizedBox(height: 16.rh),
                  OutlinedButton(
                    onPressed: () => _openCancelSheet(context, c),
                    child: const Text('Cancel session'),
                  ),
                ],
              ],
            ),
          );
        }(),
      );
    });
  }

  static void _openCancelSheet(
    BuildContext context,
    WellnessOrderDetailController c,
  ) {
    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.all(16.rs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonText(
              'Cancellation reason',
              fontSize: 16.rf,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 8.rh),
            TextField(
              controller: c.cancellationController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 12.rh),
            FilledButton(
              onPressed: () {
                Get.back();
                c.cancelOrder();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.orderId,
    required this.status,
    this.cancellationReason,
  });

  final String? orderId;
  final String status;
  final String? cancellationReason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF5E7),
        borderRadius: BorderRadius.circular(12.rs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            'Order ID: ${orderId ?? '—'}',
            fontSize: 12.rf,
            color: AppColors.success,
          ),
          SizedBox(height: 8.rh),
          CommonText(
            'Status: $status',
            fontSize: 13.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
          if (cancellationReason != null && cancellationReason!.isNotEmpty) ...[
            SizedBox(height: 6.rh),
            CommonText(
              'Reason: $cancellationReason',
              fontSize: 12.rf,
              color: AppColors.success,
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceDetails extends StatelessWidget {
  const _ServiceDetails({required this.details});

  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    final contact = details['contact_details'];
    final cMap = contact is Map ? Map<String, dynamic>.from(contact) : <String, dynamic>{};
    final service = details['service']?.toString() ?? '—';
    final serviceArea = details['service_area']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _line(AppString.kPatientName, cMap['name']?.toString() ?? '—'),
        _line(AppString.kPhone, cMap['phone']?.toString() ?? '—'),
        _line(AppString.kEmail, cMap['email']?.toString() ?? '—'),
        Divider(height: 18.rh, color: AppColors.divider),
        _line(AppString.kServiceType, service),
        if (service != 'Diet & Nutrition' &&
            serviceArea != null &&
            serviceArea.trim().isNotEmpty)
          _line('Consultation type', serviceArea),
      ],
    );
  }

  Widget _line(String key, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.rw,
            child: CommonText(
              key,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: CommonText(
              value,
              fontSize: 12.rf,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.payments});

  final List<dynamic> payments;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: AppString.kPaymentDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final p in payments)
            if (p is Map) _PaymentTile(entry: Map<String, dynamic>.from(p)),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.entry});

  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final mode = entry['payment_mode'] ?? entry['mode'] ?? entry['type'];
    final amount = entry['amount'];
    final status = entry['status']?.toString();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.rh),
      child: Container(
        padding: EdgeInsets.all(12.rs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.rs),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CommonText(
                '${mode ?? '—'}',
                fontSize: 13.rf,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommonText(
                  '₹$amount',
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w700,
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
          Divider(height: 20.rh, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}
