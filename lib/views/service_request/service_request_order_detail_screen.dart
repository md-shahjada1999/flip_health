import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flip_health/controllers/service_request_order_detail_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/pharmacy/pharmacy_order_invoice_table.dart';

class ServiceRequestOrderDetailScreen extends StatelessWidget {
  const ServiceRequestOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ServiceRequestOrderDetailController>();
    return Obx(() {
      return SafeScreenWrapper(
        appBar: CommonAppBar.build(
          title: c.detailsFetched.value ? c.screenTitle : 'Service request',
        ),
        bottomNavigationBar: c.showCompletePaymentBar
            ? SafeArea(
                child: Material(
                  color: AppColors.primary,
                  child: InkWell(
                    onTap: () => _openPaymentSheet(c),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.rh),
                      child: Center(
                        child: CommonText(
                          'Complete payment',
                          fontSize: 16.rf,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
                'Could not load service request',
                fontSize: 14.rf,
                color: AppColors.textSecondary,
              ),
            );
          }

          final info = c.info ?? <String, dynamic>{};
          final detailsMap = info['details'] is Map
              ? Map<String, dynamic>.from(info['details'] as Map)
              : <String, dynamic>{};
          final address = detailsMap['address'];
          final center = detailsMap['center'];
          final rider = detailsMap['visitor_info'];
          final status = c.infoStatus;
          final requestList = detailsMap['request'];

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12.rw, 12.rh, 12.rw, 24.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusBanner(
                  requestId: info['id']?.toString(),
                  status: status,
                  requestedAt: detailsMap['preferred_date_time']?.toString(),
                ),
                SizedBox(height: 12.rh),
                _Section(
                  title: 'Requested details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (requestList is List && requestList.isNotEmpty) ...[
                        for (final item in requestList)
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.rh),
                            child: CommonText(
                              '• ${item.toString()}',
                              fontSize: 12.rf,
                              color: AppColors.textPrimary,
                            ),
                          ),
                      ] else
                        CommonText(
                          center is Map
                              ? (center['name']?.toString() ?? '—')
                              : '—',
                          fontSize: 13.rf,
                          fontWeight: FontWeight.w600,
                        ),
                      SizedBox(height: 8.rh),
                      _line(
                        'Preferred date',
                        _displayDate(
                          detailsMap['preferred_date_time']?.toString(),
                        ),
                      ),
                      _line(
                        'Visit type',
                        info['visit_type']?.toString() ?? '—',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.rh),
                _Section(
                  title: 'Address',
                  child: CommonText(
                    _formatAddress(address),
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (c.showSelfVisitCenterCard && center is Map) ...[
                  SizedBox(height: 12.rh),
                  _SelfVisitCenterCard(
                    center: Map<String, dynamic>.from(center),
                    status: status,
                    onConfirm: c.confirmCenterDetails,
                  ),
                ],
                if (c.attachments.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _AttachmentSection(
                    title: 'Attachments',
                    items: c.attachments.toList(),
                  ),
                ],
                if (c.reports.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _AttachmentSection(
                    title: 'Reports',
                    items: c.reports.toList(),
                  ),
                ],
                if (c.showRiderCard && rider is Map) ...[
                  SizedBox(height: 12.rh),
                  _Section(
                    title: 'Rider details',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _line('Name', rider['name']?.toString() ?? '—'),
                        _line('Contact', rider['contact']?.toString() ?? '—'),
                      ],
                    ),
                  ),
                ],
                if (c.showInvoiceSection) ...[
                  SizedBox(height: 12.rh),
                  PharmacyOrderInvoiceTable(
                    lines: c.invoice.value!.details,
                    invoice: c.invoice.value!.raw,
                  ),
                ],
                if (c.showPaymentsSection) ...[
                  SizedBox(height: 12.rh),
                  _PaymentSection(payments: c.invoice.value!.payments),
                ],
                if (c.canCancelRequest) ...[
                  SizedBox(height: 12.rh),
                  OutlinedButton(
                    onPressed: () => _openCancelSheet(c),
                    child: const Text('Cancel request'),
                  ),
                ],
              ],
            ),
          );
        }(),
      );
    });
  }

  static Future<void> _openPaymentSheet(
    ServiceRequestOrderDetailController c,
  ) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    await c.refreshPaymentQuote();
    Get.back();
    final data = c.paymentQuote.value;
    if (data == null) return;
    await Get.bottomSheet(
      _ServicePaymentSheet(controller: c, data: data),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static void _openCancelSheet(ServiceRequestOrderDetailController c) {
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
                c.cancelRequest();
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

class _ServicePaymentSheet extends StatelessWidget {
  const _ServicePaymentSheet({required this.controller, required this.data});

  final ServiceRequestOrderDetailController controller;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final pending = _num(data['pending_amount']);
    final total = _num(data['price']);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.rw, 16.rh, 16.rw, 16.rh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonText(
                'Booking confirmation',
                fontSize: 18.rf,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: 12.rh),
              _line('Total amount', '₹ ${_money(total)}'),
              _line('Total payable', '₹ ${_money(pending)}'),
              SizedBox(height: 12.rh),
              CommonText(
                'Note: Wallet usage and payable amount follow the same backend calculation used in patient_app service request flow.',
                fontSize: 11.rf,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16.rh),
              FilledButton(
                onPressed: () {
                  Get.back();
                  controller.confirmServiceRequestPayment();
                },
                child: Text(
                  pending <= 0
                      ? 'Proceed to confirm'
                      : 'Proceed to pay ₹ ${_money(pending)}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.requestId,
    required this.status,
    this.requestedAt,
  });

  final String? requestId;
  final int status;
  final String? requestedAt;

  @override
  Widget build(BuildContext context) {
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
            'Request ID: ${requestId ?? '—'}',
            fontSize: 12.rf,
            color: const Color(0xFFF15A3D),
          ),
          SizedBox(height: 6.rh),
          CommonText(
            'Status: ${_statusLabel(status)}',
            fontSize: 13.rf,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF15A3D),
          ),
          if (requestedAt != null && requestedAt!.isNotEmpty) ...[
            SizedBox(height: 6.rh),
            CommonText(
              _displayDate(requestedAt),
              fontSize: 12.rf,
              color: const Color(0xFFF15A3D),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelfVisitCenterCard extends StatelessWidget {
  const _SelfVisitCenterCard({
    required this.center,
    required this.status,
    required this.onConfirm,
  });

  final Map<String, dynamic> center;
  final int status;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final name = center['name']?.toString() ?? '—';
    final phone = center['phone']?.toString();
    final addr = _formatAddress(center['address']);
    final coords = center['address'] is Map
        ? (center['address'] as Map)['coordinates']?.toString()
        : null;

    return _Section(
      title: 'Center details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(name, fontSize: 14.rf, fontWeight: FontWeight.w600),
          SizedBox(height: 6.rh),
          CommonText(addr, fontSize: 12.rf, color: AppColors.textSecondary),
          if (phone != null && phone.isNotEmpty) ...[
            SizedBox(height: 6.rh),
            CommonText('Phone: $phone', fontSize: 12.rf),
          ],
          SizedBox(height: 10.rh),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _openMap(coords, addr),
                icon: const Icon(Icons.directions),
                label: const Text('Directions'),
              ),
              SizedBox(width: 8.rw),
              if (status == 3)
                FilledButton(
                  onPressed: onConfirm,
                  child: const Text('Confirm details'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttachmentSection extends StatelessWidget {
  const _AttachmentSection({required this.title, required this.items});

  final String title;
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      child: Wrap(
        spacing: 8.rw,
        runSpacing: 8.rh,
        children: [
          for (final item in items)
            if (item is Map && item['path'] != null)
              _AttachmentThumb(path: item['path'].toString()),
        ],
      ),
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  const _AttachmentThumb({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final url = ApiUrl.publicFileUrl(path);
    if (url == null) return const SizedBox.shrink();
    final isPdf = path.toLowerCase().endsWith('.pdf');
    return GestureDetector(
      onTap: () async {
        final u = Uri.tryParse(url);
        if (u != null && await canLaunchUrl(u)) {
          await launchUrl(u, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 84.rw,
        height: 84.rh,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.rs),
          border: Border.all(color: AppColors.borderLight),
          color: AppColors.backgroundSecondary,
        ),
        clipBehavior: Clip.antiAlias,
        child: isPdf
            ? Icon(Icons.picture_as_pdf, size: 34.rs, color: AppColors.primary)
            : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.payments});

  final List<dynamic> payments;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Payment details',
      child: Column(
        children: [
          for (final p in payments)
            if (p is Map)
              _line(
                p['payment_mode']?.toString() ?? '—',
                '₹${p['amount'] ?? '0'} (${p['status'] ?? 'pending'})',
              ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

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

Widget _line(String label, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: 6.rh),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.rw,
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

String _statusLabel(int status) {
  const map = {
    0: 'Waiting for confirmation',
    1: 'Completed',
    2: 'Cancelled',
    3: 'Confirm details',
    4: 'Payment pending',
    5: 'Booked',
    6: 'In progress',
    9: 'Expired',
  };
  return map[status] ?? 'Pending';
}

String _displayDate(String? value) {
  if (value == null || value.trim().isEmpty) return '—';
  final d = DateTime.tryParse(value);
  if (d == null) return value;
  final local = d.toLocal();
  final m = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '$day/$m/${local.year} $hour:$min';
}

String _formatAddress(dynamic raw) {
  if (raw is! Map) return '—';
  final m = Map<String, dynamic>.from(raw);
  final parts = [
    m['line_1'],
    m['landmark'],
    m['area'],
    m['city'],
    m['state'],
    m['pincode'],
  ].where((e) => e != null && e.toString().trim().isNotEmpty).toList();
  if (parts.isEmpty && m['display_address'] != null) {
    return m['display_address'].toString();
  }
  return parts.join(', ');
}

double _num(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

String _money(double v) {
  if (v % 1 == 0) return v.toInt().toString();
  return v.toStringAsFixed(2);
}

Future<void> _openMap(String? coordinates, String fallbackAddress) async {
  Uri? uri;
  final c = coordinates?.trim();
  if (c != null && c.contains(',')) {
    final parts = c.split(',').map((e) => e.trim()).toList();
    if (parts.length >= 2) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${parts[0]},${parts[1]}',
      );
    }
  }
  if (uri == null && fallbackAddress.trim().isNotEmpty) {
    uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(fallbackAddress)}',
    );
  }
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
