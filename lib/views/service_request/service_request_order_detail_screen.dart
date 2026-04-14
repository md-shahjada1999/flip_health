import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flip_health/controllers/service_request_order_detail_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/service_request_order_utils.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/orders/widgets/order_invoice_table.dart';
import 'package:flip_health/views/orders/widgets/order_patient_details_card.dart';
import 'package:flip_health/views/orders/widgets/order_payment_details_section.dart';

class ServiceRequestOrderDetailScreen extends StatelessWidget {
  const ServiceRequestOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ServiceRequestOrderDetailController>();
    return Obx(() {
      final showPayBar = c.showCompletePaymentBar;
      return SafeScreenWrapper(
        bottomSafe: !showPayBar,
        appBar: CommonAppBar.build(
          title: c.detailsFetched.value ? c.screenTitle : 'Service request',
        ),
        // Scaffold gives bottomNavigationBar unbounded max height; without a fixed
        // height, [Material] expands and can fill the screen.
        bottomNavigationBar: showPayBar
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.rw, 8.rh, 12.rw, 10.rh),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54.rh,
                    child: Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14.rs),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.rs),
                        onTap: () => _openPaymentSheet(c),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                size: 18.rs,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.rw),
                              CommonText(
                                'Complete payment',
                                fontSize: 16.rf,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ],
                          ),
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
          final invMap = c.invoice.value!.raw;
          final createdRaw = _resolveServiceRequestCreatedAt(invMap, info);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12.rw, 12.rh, 12.rw, 24.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ServiceRequestOrderOverview(
                  status: status,
                  serviceTitle: c.screenTitle,
                  orderId: info['id']?.toString(),
                  invoiceId: invMap['id']?.toString(),
                  visitType: info['visit_type']?.toString(),
                  preferredSlotDisplay: formatServiceRequestPreferredSlot(
                    detailsMap,
                  ),
                  createdAtRaw: createdRaw,
                  cancellationReason: info['cancellation_reason']?.toString(),
                ),
                SizedBox(height: 12.rh),
                OrderPatientDetailsCard(
                  invoiceDetail: c.invoice.value!.raw,
                  infoMap: Map<String, dynamic>.from(info),
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
                        'Preferred slot',
                        formatServiceRequestPreferredSlot(detailsMap),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CommonText(
                          _formatAddress(address),
                          fontSize: 12.rf,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_serviceAddressHasMapsTarget(address)) ...[
                        SizedBox(width: 4.rw),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 40.rs,
                            minHeight: 40.rs,
                          ),
                          icon: Icon(
                            Icons.directions_rounded,
                            color: AppColors.primary,
                            size: 24.rs,
                          ),
                          tooltip: 'Directions',
                          onPressed: () => _openMapFromServiceAddress(address),
                        ),
                      ],
                    ],
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
                  OrderInvoiceTable(
                    lines: c.invoice.value!.details,
                    invoice: c.invoice.value!.raw,
                  ),
                ],
                if (c.showPaymentsSection) ...[
                  SizedBox(height: 12.rh),
                  OrderPaymentDetailsSection(
                    payments: c.invoice.value!.payments,
                  ),
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
    if (c.paymentQuote.value == null) return;
    await Get.bottomSheet(
      _ServiceRequestBookingPaymentSheet(controller: c),
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

class _ServiceRequestBookingPaymentSheet extends StatelessWidget {
  const _ServiceRequestBookingPaymentSheet({required this.controller});

  final ServiceRequestOrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.rw, 12.rh, 16.rw, 12.rh),
          child: Obx(() {
            controller.useFlipCash.value;
            final data = controller.paymentQuote.value;
            if (data == null) {
              return SizedBox(
                height: 120.rh,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final pending = _sheetNum(data['pending_amount']);
            final total = _sheetMoney(data['price']);
            final pendingStr = _sheetMoney(data['pending_amount']);
            final opd = data['opdWallet'];
            final showOpd = _hasOpdWalletData(data);
            final note = _serviceBookingPaymentNote(data);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    'Booking confirmation',
                    fontSize: 18.rf,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 16.rh),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Checkbox(
                  //       value: controller.useFlipCash.value,
                  //       onChanged: (v) async {
                  //         controller.useFlipCash.value = v ?? true;
                  //         await controller.refreshPaymentQuote();
                  //       },
                  //     ),
                  //     Expanded(
                  //       child: Padding(
                  //         padding: EdgeInsets.only(top: 8.rh),
                  //         child: CommonText(
                  //           'Use Flip Health wallet when paying',
                  //           fontSize: 11.rf,
                  //           color: AppColors.textSecondary,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 8.rh),
                  _sheetPayRow('Total amount', '₹ $total'),
                  if (showOpd && opd is Map) ...[
                    SizedBox(height: 12.rh),
                    _bookingPaymentSheetSection(
                      title: AppString.kOPDWallet,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sheetPayRow(
                            'Using from OPD wallet',
                            '- ₹ ${_sheetMoney(opd['used_amount'])}',
                          ),
                          SizedBox(height: 4.rh),
                          CommonText(
                            'Available balance: ₹ ${_sheetMoney(opd['available'])}',
                            fontSize: 10.rf,
                            color: AppColors.textSecondary,
                          ),
                          CommonText(
                            'Limit available: ₹ ${_sheetMoney(opd['module_available'])}',
                            fontSize: 10.rf,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 10.rh),
                  _sheetPayRow('From pocket', '₹ $pendingStr'),
                  _sheetPayRow('Total payable', '₹ $pendingStr'),
                  SizedBox(height: 12.rh),
                  Divider(height: 1, color: AppColors.divider),
                  SizedBox(height: 12.rh),
                  CommonText(
                    note,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                  SizedBox(height: 20.rh),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Get.back();
                        controller.confirmServiceRequestPayment();
                      },
                      child: Text(
                        pending <= 0
                            ? 'Proceed to confirm'
                            : 'Proceed to pay ₹ ${_sheetMoney(data['pending_amount'])}',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Status chip row + order summary card (aligned with pharmacy / consultation).
class _ServiceRequestOrderOverview extends StatelessWidget {
  const _ServiceRequestOrderOverview({
    required this.status,
    required this.serviceTitle,
    required this.preferredSlotDisplay,
    this.orderId,
    this.invoiceId,
    this.visitType,
    this.createdAtRaw,
    this.cancellationReason,
  });

  final int status;
  final String serviceTitle;
  final String? orderId;
  final String? invoiceId;
  final String? visitType;
  final String preferredSlotDisplay;
  final String? createdAtRaw;
  final String? cancellationReason;

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(status);
    final style = _serviceRequestStatusStyle(status);
    final reason =
        (label == 'Cancelled' &&
            cancellationReason != null &&
            cancellationReason!.trim().isNotEmpty)
        ? cancellationReason!.trim()
        : '';

    final oid = orderId?.trim() ?? '';
    final iid = invoiceId?.trim() ?? '';
    final showInvoiceId = iid.isNotEmpty && iid != oid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ServiceRequestStatusBanner(label: label, style: style),
        SizedBox(height: 12.rh),
        _Section(
          title: 'Order summary',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _orderSummaryRow(
                'Service',
                serviceTitle.isEmpty ? '—' : serviceTitle,
              ),
              SizedBox(height: 8.rh),
              _orderSummaryRow('Order ID', oid.isEmpty ? '—' : '#$oid'),
              if (showInvoiceId) ...[
                SizedBox(height: 8.rh),
                _orderSummaryRow('Invoice ID', '#$iid'),
              ],
              SizedBox(height: 8.rh),
              _orderSummaryRow(
                'Created at',
                _formatOrderCreatedAt(createdAtRaw),
              ),
              SizedBox(height: 8.rh),
              _orderSummaryRow('Visit type', _visitTypeDisplay(visitType)),
              SizedBox(height: 8.rh),
              _orderSummaryRow('Preferred slot', preferredSlotDisplay),
              if (reason.isNotEmpty) ...[
                SizedBox(height: 8.rh),
                _orderSummaryRow('Reason', reason),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceRequestStatusBanner extends StatelessWidget {
  const _ServiceRequestStatusBanner({required this.label, required this.style});

  final String label;
  final _ServiceRequestStatusStyle style;

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

class _ServiceRequestStatusStyle {
  const _ServiceRequestStatusStyle({
    required this.fg,
    required this.bg,
    required this.icon,
  });

  final Color fg;
  final Color bg;
  final IconData icon;
}

_ServiceRequestStatusStyle _serviceRequestStatusStyle(int status) {
  switch (status) {
    case 1:
    case 6:
      return _ServiceRequestStatusStyle(
        fg: AppColors.success,
        bg: AppColors.successLight,
        icon: Icons.check_circle_rounded,
      );
    case 2:
    case 9:
      return _ServiceRequestStatusStyle(
        fg: AppColors.error,
        bg: AppColors.errorLight,
        icon: Icons.cancel_rounded,
      );
    case 4:
      return _ServiceRequestStatusStyle(
        fg: AppColors.warning,
        bg: AppColors.warningLight,
        icon: Icons.payment_rounded,
      );
    case 5:
      return _ServiceRequestStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.event_rounded,
      );
    case 0:
    case 3:
      return _ServiceRequestStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.schedule_rounded,
      );
    default:
      return _ServiceRequestStatusStyle(
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

String? _resolveServiceRequestCreatedAt(
  Map<String, dynamic> inv,
  Map<String, dynamic> info,
) {
  final a = info['createdAt']?.toString();
  if (a != null && a.trim().isNotEmpty) return a;
  final b = inv['createdAt']?.toString();
  if (b != null && b.trim().isNotEmpty) return b;
  final d = inv['invoice_date']?.toString();
  if (d != null && d.trim().isNotEmpty) return d;
  return null;
}

String _formatOrderCreatedAt(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  try {
    final dt = DateTime.parse(raw).toLocal();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  } catch (_) {
    return raw;
  }
}

String _visitTypeDisplay(String? raw) {
  final v = raw?.trim() ?? '';
  if (v.isEmpty) return '—';
  return v.replaceAll('_', ' ');
}

/// Vision / dental / vaccine: `center.display_address`, else concat `center.address`.
String _formatCenterAddress(Map<String, dynamic> center) {
  final disp = center['display_address']?.toString().trim();
  if (disp != null && disp.isNotEmpty) return disp;
  return _formatAddress(center['address']);
}

String? _locationStringFromAddressMap(Map<String, dynamic> m) {
  final loc = m['location']?.toString().trim();
  if (loc != null && loc.contains(',')) return loc;
  final c = m['coordinates'];
  if (c is List && c.length >= 2) {
    return '${c[0]},${c[1]}';
  }
  return null;
}

bool _serviceAddressHasMapsTarget(dynamic address) {
  if (address is! Map) return false;
  final m = Map<String, dynamic>.from(address);
  if (_locationStringFromAddressMap(m) != null) return true;
  return _formatAddress(m).trim().isNotEmpty;
}

Future<void> _openMapFromServiceAddress(dynamic address) async {
  if (address is! Map) return;
  final m = Map<String, dynamic>.from(address);
  final coords = _locationStringFromAddressMap(m);
  final fallback = _formatAddress(m);
  await _openMap(coords, fallback);
}

String? _centerLocationForMaps(Map<String, dynamic> center) {
  final a = center['address'];
  if (a is Map) {
    return _locationStringFromAddressMap(Map<String, dynamic>.from(a));
  }
  return null;
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
    final addr = _formatCenterAddress(center);
    final coords = _centerLocationForMaps(center);

    return _Section(
      title: 'Center details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(name, fontSize: 14.rf, fontWeight: FontWeight.w600),
          SizedBox(height: 6.rh),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CommonText(
                  addr,
                  fontSize: 12.rf,
                  color: AppColors.textSecondary,
                ),
              ),
              if (addr != '—' && addr.trim().isNotEmpty) ...[
                SizedBox(width: 4.rw),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 40.rs,
                    minHeight: 40.rs,
                  ),
                  icon: Icon(
                    Icons.directions_rounded,
                    color: AppColors.primary,
                    size: 24.rs,
                  ),
                  tooltip: 'Directions',
                  onPressed: () => _openMap(coords, addr),
                ),
              ],
            ],
          ),
          if (phone != null && phone.isNotEmpty) ...[
            SizedBox(height: 6.rh),
            CommonText('Phone: $phone', fontSize: 12.rf),
          ],
          SizedBox(height: 10.rh),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _openMap(coords, addr),
                icon: const Icon(Icons.directions_rounded),
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

Widget _sheetPayRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: 6.rh),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CommonText(
            label,
            fontSize: 13.rf,
            color: AppColors.textPrimary,
          ),
        ),
        CommonText(value, fontSize: 13.rf, fontWeight: FontWeight.w600),
      ],
    ),
  );
}

Widget _bookingPaymentSheetSection({
  required String title,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(14.rs),
    decoration: BoxDecoration(
      color: AppColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(14.rs),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          title,
          fontSize: 13.rf,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 10.rh),
        child,
      ],
    ),
  );
}

bool _hasOpdWalletData(Map<String, dynamic> data) {
  final opd = data['opdWallet'];
  if (opd is! Map) return false;
  final a = _sheetNum(opd['available']);
  final m = _sheetNum(opd['module_available']);
  return a > 0 && m > 0;
}

String _serviceBookingPaymentNote(Map<String, dynamic> data) {
  final opd = data['opdWallet'];
  if (opd is Map) {
    final a = _sheetNum(opd['available']);
    final m = _sheetNum(opd['module_available']);
    if (a > 0 && m > 0) {
      return 'Note: Amount will be deducted from your Flip Health Wallet first. Any remaining amount will be charged from your pocket.';
    }
  }
  return 'Note: Your available wallet balance has exhausted. Please proceed to pay from your pocket to continue.';
}

double _sheetNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

String _sheetMoney(dynamic v) {
  final n = _sheetNum(v);
  if (n % 1 == 0) return n.toInt().toString();
  return n.toStringAsFixed(2);
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
