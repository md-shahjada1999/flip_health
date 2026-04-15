import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/wellness_order_detail_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/orders/widgets/order_invoice_table.dart';
import 'package:flip_health/views/orders/widgets/order_patient_details_card.dart';
import 'package:flip_health/views/orders/widgets/order_payment_details_section.dart';

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

          final infoForPatient = Map<String, dynamic>.from(info);
          final contact = details['contact_details'];
          if (contact is Map) {
            final cm = Map<String, dynamic>.from(contact);
            for (final e in cm.entries) {
              final existing = infoForPatient[e.key];
              if (existing == null || existing.toString().trim().isEmpty) {
                infoForPatient[e.key] = e.value;
              }
            }
          }

          final orderId = info['id']?.toString();
          final statusStyle = _wellnessStatusStyle(c.infoStatus);
          final cancelReason = cancellationReason?.trim() ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12.rw, 12.rh, 12.rw, 24.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WellnessStatusBanner(
                  label: c.statusLabel,
                  style: statusStyle,
                ),
                SizedBox(height: 12.rh),
                _SectionCard(
                  title: 'Order summary',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _orderSummaryRow(
                        'Order ID',
                        orderId == null || orderId.isEmpty ? '—' : '#$orderId',
                      ),
                      if (cancelReason.isNotEmpty) ...[
                        SizedBox(height: 8.rh),
                        _orderSummaryRow('Reason', cancelReason),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16.rh),
                OrderPatientDetailsCard(
                  invoiceDetail: c.invoice.value!.raw,
                  infoMap: infoForPatient,
                ),
                SizedBox(height: 16.rh),
                _SectionCard(
                  title: AppString.kServiceDetails,
                  child: _ServiceDetails(details: details),
                ),
                if (c.showInvoiceSection) ...[
                  SizedBox(height: 16.rh),
                  OrderInvoiceTable(
                    lines: c.lineItems,
                    invoice: c.invoice.value!.raw,
                  ),
                ],
                if (c.showPaymentsSection) ...[
                  SizedBox(height: 16.rh),
                  OrderPaymentDetailsSection(payments: c.paymentItems),
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

/// Same layout as pharmacy / consultation / service-request status chip.
class _WellnessStatusBanner extends StatelessWidget {
  const _WellnessStatusBanner({
    required this.label,
    required this.style,
  });

  final String label;
  final _WellnessStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(14.rs),
      ),
      child: Row(
        children: [
          Icon(style.icon, color: style.fg, size: 28.rs),
          SizedBox(width: 12.rw),
          Expanded(
            child: CommonText(
              '${AppString.kStatusLabel}: $label',
              fontSize: 16.rf,
              fontWeight: FontWeight.w700,
              color: style.fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _WellnessStatusStyle {
  const _WellnessStatusStyle({
    required this.fg,
    required this.bg,
    required this.icon,
  });

  final Color fg;
  final Color bg;
  final IconData icon;
}

_WellnessStatusStyle _wellnessStatusStyle(int status) {
  switch (status) {
    case 1:
    case 6:
      return _WellnessStatusStyle(
        fg: AppColors.success,
        bg: AppColors.successLight,
        icon: Icons.check_circle_rounded,
      );
    case 2:
    case 9:
      return _WellnessStatusStyle(
        fg: AppColors.error,
        bg: AppColors.errorLight,
        icon: Icons.cancel_rounded,
      );
    case 4:
      return _WellnessStatusStyle(
        fg: AppColors.warning,
        bg: AppColors.warningLight,
        icon: Icons.payment_rounded,
      );
    case 5:
      return _WellnessStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.event_rounded,
      );
    case 0:
    case 3:
      return _WellnessStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.schedule_rounded,
      );
    default:
      return _WellnessStatusStyle(
        fg: AppColors.textSecondary,
        bg: AppColors.backgroundSecondary,
        icon: Icons.info_outline_rounded,
      );
  }
}

Widget _orderSummaryRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 92.rw,
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
  );
}

class _ServiceDetails extends StatelessWidget {
  const _ServiceDetails({required this.details});

  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    final service = details['service']?.toString() ?? '—';
    final serviceArea = details['service_area']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
