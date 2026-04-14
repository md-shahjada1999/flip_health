import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/common_pdf_viewer.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/pharmacy_order_detail_controller.dart';
import 'package:flip_health/views/pharmacy/pharmacy_order_invoice_table.dart';

class PharmacyOrderDetailScreen extends StatelessWidget {
  const PharmacyOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PharmacyOrderDetailController>();

    return Obx(() {
      final showPayBar = c.showCompletePaymentBar;
      return SafeScreenWrapper(
        bottomSafe: !showPayBar,
        appBar: CommonAppBar.build(
          title: c.detailsFetched.value
              ? c.screenTitle()
              : AppString.kOrderDetails,
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
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1F6FE5), Color(0xFF0B4FC2)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14.rs),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B4FC2).withAlpha(90),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openPharmacyBookingPaymentSheet(c),
                          borderRadius: BorderRadius.circular(14.rs),
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
                'Could not load order',
                fontSize: 14.rf,
                color: AppColors.textSecondary,
              ),
            );
          }

          final invMap = c.invoice.value!.raw;
          final info = c.invoice.value!.info ?? {};
          final visitType = info['visit_type']?.toString() ?? '';
          final status = c.infoStatus;
          final addInfo = info['additional_info'];
          final addMap = addInfo is Map
              ? Map<String, dynamic>.from(addInfo)
              : <String, dynamic>{};

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12.rw, 12.rh, 12.rw, 24.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OrderOverviewCard(
                  orderId: info['id']?.toString(),
                  visitType: visitType,
                  status: status,
                  createdAt: _resolveInvoiceCreatedAt(invMap, info),
                  cancellationReason: info['cancellation_reason']?.toString(),
                ),
                SizedBox(height: 12.rh),
                if (visitType != 'SELF_PICKUP') ...[
                  _Section(
                    title: 'Delivery address',
                    child: _AddressBlock(
                      address: info['address'] is Map
                          ? Map<String, dynamic>.from(info['address'] as Map)
                          : null,
                    ),
                  ),
                ],
                if (_showSelfPickupClinic(status, visitType, addMap)) ...[
                  SizedBox(height: 16.rh),
                  _SelfPickupClinicCard(
                    center: addMap['center'],
                    orderStatus: status,
                    onConfirm: c.confirmOrder,
                  ),
                ],
                if (c.showAttachmentsSection) ...[
                  SizedBox(height: 16.rh),
                  _AttachmentsSection(attachments: c.attachments.toList()),
                ],
                if (_showRider(status, visitType, addMap)) ...[
                  SizedBox(height: 16.rh),
                  _RiderCard(visitor: addMap['visitor_info']),
                ],
                if (c.showChronicStepper) ...[
                  SizedBox(height: 16.rh),
                  _ChronicStepperBlock(controller: c),
                ],
                if (c.showInvoiceSection) ...[
                  SizedBox(height: 16.rh),
                  PharmacyOrderInvoiceTable(
                    lines: c.invoiceLinesForTable,
                    invoice: invMap,
                  ),
                ],
                if (c.showPaymentsSection) ...[
                  SizedBox(height: 16.rh),
                  _PaymentSection(payments: c.invoice.value!.payments),
                ],
                if (c.showCompletePaymentBar &&
                    c.invoice.value!.netAmount != null)
                  // Padding(
                  //   padding: EdgeInsets.only(top: 8.rh),
                  //   child: Row(
                  //     children: [
                  //       Checkbox(
                  //         value: c.useFlipCash.value,
                  //         onChanged: (v) => c.useFlipCash.value = v ?? true,
                  //       ),
                  //       Expanded(
                  //         child: CommonText(
                  //           'Use Flip Cash / wallet when confirming',
                  //           fontSize: 12.rf,
                  //           color: AppColors.textSecondary,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  if (c.canCancelOrder) ...[
                    SizedBox(height: 16.rh),
                    OutlinedButton(
                      onPressed: () => _openCancelSheet(context, c),
                      child: const Text('Cancel order'),
                    ),
                  ],
              ],
            ),
          );
        }(),
      );
    });
  }

  static bool _showSelfPickupClinic(
    int status,
    String visitType,
    Map<String, dynamic> addMap,
  ) {
    if (status == 0) return false;
    if (visitType != 'SELF_PICKUP') return false;
    return addMap['center'] != null;
  }

  static bool _showRider(
    int status,
    String visitType,
    Map<String, dynamic> addMap,
  ) {
    if ([0, 1, 2, 3, 4].contains(status)) return false;
    if (visitType != 'HOME_DELIVERY') return false;
    final v = addMap['visitor_info'];
    if (v is! Map) return false;
    final name = v['name']?.toString();
    final contact = v['contact']?.toString();
    return name != null &&
        name.isNotEmpty &&
        contact != null &&
        contact.isNotEmpty;
  }

  static void _openCancelSheet(
    BuildContext context,
    PharmacyOrderDetailController c,
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
                if (c.cancellationController.text.trim().isEmpty) {
                  Get.snackbar('Reason required', 'Please enter a reason');
                  return;
                }
                Get.back();
                Get.dialog<void>(
                  AlertDialog(
                    title: const Text('Cancel order?'),
                    content: const Text(
                      'Are you sure you want to cancel this pharmacy order?',
                    ),
                    actions: [
                      TextButton(onPressed: Get.back, child: const Text('No')),
                      FilledButton(
                        onPressed: () {
                          Get.back();
                          c.cancelOrder();
                        },
                        child: const Text('Yes, cancel'),
                      ),
                    ],
                  ),
                );
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

class _OrderOverviewCard extends StatelessWidget {
  const _OrderOverviewCard({
    required this.orderId,
    required this.visitType,
    required this.status,
    required this.createdAt,
    this.cancellationReason,
  });

  final String? orderId;
  final String visitType;
  final int status;
  final String? createdAt;
  final String? cancellationReason;

  @override
  Widget build(BuildContext context) {
    final label = _pharmacyStatusLabel(status);
    final style = _pharmacyStatusStyle(status);
    final reason = (label == 'Cancelled' && cancellationReason != null)
        ? cancellationReason!.trim()
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PharmacyStatusBanner(label: label, style: style),
        SizedBox(height: 12.rh),
        _Section(
          title: 'Order summary',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Order ID', orderId == null ? '—' : '#$orderId'),
              SizedBox(height: 8.rh),
              _summaryRow(
                'Visit type',
                visitType.isEmpty ? '—' : visitType.replaceAll('_', ' '),
              ),
              SizedBox(height: 8.rh),
              _summaryRow('Created at', _formatCreatedAt(createdAt)),
              if (reason.isNotEmpty) ...[
                SizedBox(height: 8.rh),
                _summaryRow('Reason', reason),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Same layout as [consultation_order_detail_screen] `_ConsultationStatusBanner`.
class _PharmacyStatusBanner extends StatelessWidget {
  const _PharmacyStatusBanner({required this.label, required this.style});

  final String label;
  final _PharmacyStatusStyle style;

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

String _pharmacyStatusLabel(int status) {
  const map = {
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

class _PharmacyStatusStyle {
  const _PharmacyStatusStyle({
    required this.fg,
    required this.bg,
    required this.icon,
  });

  final Color fg;
  final Color bg;
  final IconData icon;
}

_PharmacyStatusStyle _pharmacyStatusStyle(int status) {
  switch (status) {
    case 1:
    case 6:
      return _PharmacyStatusStyle(
        fg: AppColors.success,
        bg: AppColors.successLight,
        icon: Icons.check_circle_rounded,
      );
    case 2:
    case 9:
      return _PharmacyStatusStyle(
        fg: AppColors.error,
        bg: AppColors.errorLight,
        icon: Icons.cancel_rounded,
      );
    case 4:
      return _PharmacyStatusStyle(
        fg: AppColors.warning,
        bg: AppColors.warningLight,
        icon: Icons.payment_rounded,
      );
    case 5:
      return _PharmacyStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.event_rounded,
      );
    case 0:
    case 3:
      return _PharmacyStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.schedule_rounded,
      );
    default:
      return _PharmacyStatusStyle(
        fg: AppColors.textSecondary,
        bg: AppColors.backgroundSecondary,
        icon: Icons.info_outline_rounded,
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

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({required this.address});

  final Map<String, dynamic>? address;

  @override
  Widget build(BuildContext context) {
    if (address == null || address!.isEmpty) {
      return CommonText(
        'No address on file',
        fontSize: 12.rf,
        color: AppColors.textSecondary,
      );
    }
    final m = Map<String, dynamic>.from(address!);
    final line1 = m['line_1']?.toString() ?? '';
    final landmark = m['landmark']?.toString() ?? '';
    final city = m['city']?.toString() ?? '';
    final pin = m['pincode']?.toString() ?? '';
    final parts = <String>[
      [line1, landmark].where((e) => e.isNotEmpty).join(', '),
      [city, pin].where((e) => e.isNotEmpty).join(', '),
    ].where((e) => e.isNotEmpty).join('\n');
    final text = parts.isEmpty ? '—' : parts;
    final showDirections = _hasMapsTarget(m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CommonText(
            text,
            fontSize: 13.rf,
            color: AppColors.textSecondary,
          ),
        ),
        if (showDirections) ...[
          SizedBox(width: 8.rw),
          _DirectionsMapButton(onPressed: () => _openMapsFromAddressMap(m)),
        ],
      ],
    );
  }
}

class _SelfPickupClinicCard extends StatelessWidget {
  const _SelfPickupClinicCard({
    required this.center,
    required this.orderStatus,
    required this.onConfirm,
  });

  final dynamic center;
  final int orderStatus;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    if (center is! Map) return const SizedBox.shrink();
    final c = Map<String, dynamic>.from(center);
    final name = c['name']?.toString() ?? '—';
    final addr = c['address'];
    String addrText = '';
    if (addr is Map) {
      final a = Map<String, dynamic>.from(addr);
      addrText = [
        a['line_1'],
        a['line_2'],
        '${a['city'] ?? ''}, ${a['state'] ?? ''}',
      ].where((e) => e != null && '$e'.trim().isNotEmpty).join('\n');
    }
    final phone = c['phone']?.toString();

    final addrMap = addr is Map ? Map<String, dynamic>.from(addr) : null;
    final showDirections = _hasMapsTarget(addrMap);

    return _Section(
      title: 'Pickup center',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CommonText(
                  name,
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showDirections && addrMap != null) ...[
                SizedBox(width: 8.rw),
                _DirectionsMapButton(
                  onPressed: () => _openMapsFromAddressMap(addrMap),
                ),
              ],
            ],
          ),
          if (addrText.isNotEmpty) ...[
            SizedBox(height: 6.rh),
            CommonText(
              addrText,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ],
          if (phone != null && phone.isNotEmpty)
            CommonText('Phone: $phone', fontSize: 12.rf),
          if (orderStatus == 3) ...[
            SizedBox(height: 12.rh),
            FilledButton(
              onPressed: () async {
                Get.dialog<void>(
                  AlertDialog(
                    title: const Text('Confirm details'),
                    content: const Text(
                      'Confirm that your pickup details are correct?',
                    ),
                    actions: [
                      TextButton(onPressed: Get.back, child: const Text('No')),
                      FilledButton(
                        onPressed: () {
                          Get.back();
                          onConfirm();
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Confirm details'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttachmentsSection extends StatelessWidget {
  const _AttachmentsSection({required this.attachments});

  final List<dynamic> attachments;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Attachments',
      child: attachments.isEmpty
          ? CommonText(
              'No attachments',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            )
          : Wrap(
              spacing: 8.rw,
              runSpacing: 8.rh,
              children: [
                for (final a in attachments)
                  if (a is Map && a['path'] != null)
                    _AttThumb(path: a['path'].toString()),
              ],
            ),
    );
  }
}

class _AttThumb extends StatelessWidget {
  const _AttThumb({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final url = ApiUrl.publicFileUrl(path);
    if (url == null) return const SizedBox.shrink();
    final lower = path.toLowerCase();
    final isPdf = lower.endsWith('.pdf');
    return GestureDetector(
      onTap: () {
        if (isPdf) {
          Get.to(() => CommonPdfViewer(
                url: url,
                title: path.split('/').last,
              ));
          return;
        }
        Get.dialog(
          _FullImageDialog(url: url, title: path.split('/').last),
          barrierColor: Colors.black87,
          useSafeArea: false,
        );
      },
      child: Container(
        width: 72.rw,
        height: 72.rh,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.rs),
          border: Border.all(color: AppColors.borderLight),
          color: AppColors.backgroundSecondary,
        ),
        clipBehavior: Clip.antiAlias,
        child: isPdf
            ? Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 24.rs)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Icon(Icons.broken_image_outlined, size: 22.rs),
              ),
      ),
    );
  }
}

class _FullImageDialog extends StatelessWidget {
  const _FullImageDialog({required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                    size: 48.rs,
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.rh,
              left: 12.rw,
              right: 12.rw,
              child: Row(
                children: [
                  _previewHeaderButton(
                    icon: Icons.close_rounded,
                    onTap: () => Get.back(),
                  ),
                  SizedBox(width: 10.rw),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.rw,
                        vertical: 8.rh,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10.rs),
                      ),
                      child: CommonText(
                        title,
                        fontSize: 12.rf,
                        color: Colors.white70,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _previewHeaderButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40.rs,
      height: 40.rs,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12.rs),
      ),
      child: Icon(icon, size: 22.rs, color: Colors.white),
    ),
  );
}

class _RiderCard extends StatelessWidget {
  const _RiderCard({required this.visitor});

  final dynamic visitor;

  @override
  Widget build(BuildContext context) {
    if (visitor is! Map) return const SizedBox.shrink();
    final v = Map<String, dynamic>.from(visitor);
    return _Section(
      title: 'Rider details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Name', v['name']?.toString() ?? '—'),
          _row('Contact', v['contact']?.toString() ?? '—'),
        ],
      ),
    );
  }

  Widget _row(String k, String val) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.rw,
            child: CommonText(
              k,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: CommonText(
              val,
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChronicStepperBlock extends StatelessWidget {
  const _ChronicStepperBlock({required this.controller});

  final PharmacyOrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    final inv = controller.invoice.value;
    if (inv == null) return const SizedBox.shrink();
    final batches = inv.additionalInfo?['batches'];
    if (batches is! List || batches.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      final idx = controller.stepperIndex.value - 1;
      final current = controller.stepperIndex.value;
      final maxBatch = controller.batchNo.value;

      return _Section(
        title: 'Shipment batches',
        child: SizedBox(
          height: 220.rh,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: idx.clamp(0, batches.length - 1),
            onStepTapped: (i) {
              if (i + 1 <= maxBatch) {
                controller.stepperIndex.value = i + 1;
              }
            },
            controlsBuilder: (_, __) => const SizedBox.shrink(),
            steps: [
              for (var i = 0; i < batches.length; i++)
                Step(
                  state: i + 1 < maxBatch
                      ? StepState.complete
                      : StepState.indexed,
                  isActive: i + 1 == current,
                  title: Text(
                    '${i + 1}${_ordinal(i + 1)} batch',
                    style: TextStyle(fontSize: 11.rf),
                  ),
                  content: _BatchContent(batch: batches[i]),
                ),
            ],
          ),
        ),
      );
    });
  }

  static String _ordinal(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}

class _BatchContent extends StatelessWidget {
  const _BatchContent({required this.batch});

  final dynamic batch;

  @override
  Widget build(BuildContext context) {
    if (batch is! Map) return const SizedBox.shrink();
    final b = Map<String, dynamic>.from(batch);
    final status = b['status'];
    final date = b['batch_order_date']?.toString();
    String dateFmt = date ?? '—';
    if (date != null && date.isNotEmpty) {
      try {
        dateFmt = DateFormat('dd MMM yyyy').format(DateTime.parse(date));
      } catch (_) {}
    }
    final delivery = b['delivery'];
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText('Status: ${_batchStatus(status)}', fontSize: 11.rf),
          CommonText('Shipment on: $dateFmt', fontSize: 11.rf),
          if (delivery is Map)
            _DeliveryLinks(delivery: Map<String, dynamic>.from(delivery)),
        ],
      ),
    );
  }
}

String _batchStatus(dynamic status) {
  if (status is int) {
    const map = {
      0: 'Waiting for confirmation',
      1: 'Order processing',
      3: 'Ready to ship',
      4: 'Out for delivery',
      5: 'Delivered',
    };
    return map[status] ?? '$status';
  }
  return status?.toString() ?? '—';
}

class _DeliveryLinks extends StatelessWidget {
  const _DeliveryLinks({required this.delivery});

  final Map<String, dynamic> delivery;

  @override
  Widget build(BuildContext context) {
    final track = delivery['track_link']?.toString();
    final isLink = delivery['isTrackLink'] == true;
    if (isLink && track != null && track.isNotEmpty) {
      return TextButton(
        onPressed: () async {
          final u = Uri.tryParse(track);
          if (u != null && await canLaunchUrl(u)) {
            await launchUrl(u, mode: LaunchMode.externalApplication);
          }
        },
        child: const Text('Track order'),
      );
    }
    final src = delivery['source']?.toString();
    if (src != null || track != null) {
      return Padding(
        padding: EdgeInsets.only(top: 4.rh),
        child: CommonText(
          'Ref: ${track ?? src}',
          fontSize: 11.rf,
          color: AppColors.primary,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.payments});

  final List<dynamic> payments;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: AppString.kPaymentDetails,
      child: payments.isEmpty
          ? CommonText(
              'No payment records',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in payments)
                  if (p is Map)
                    _PharmacyPaymentEntryCard(
                      entry: Map<String, dynamic>.from(p),
                    ),
              ],
            ),
    );
  }
}

/// Mirrors [consultation_order_detail_screen] `_PaymentEntryCard`.
class _PharmacyPaymentEntryCard extends StatelessWidget {
  const _PharmacyPaymentEntryCard({required this.entry});

  final Map<String, dynamic> entry;

  Color _amountColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s == 'success' || s == 'completed') return AppColors.success;
    if (s == 'refunded') return AppColors.warning;
    if (s == 'failed' || s == 'failure') return AppColors.error;
    return AppColors.textPrimary;
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
                  _paymentDetailRow('Method', '${mode ?? '—'}'),
                  if (src != null && '$src'.isNotEmpty)
                    _paymentDetailRow('Source', '$src'),
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
                  '₹$amount',
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: _amountColor(status),
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

Widget _paymentDetailRow(String label, String value) {
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

Future<void> _openPharmacyBookingPaymentSheet(
  PharmacyOrderDetailController c,
) async {
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );
  await c.refreshPaymentQuote();
  Get.back();
  if (c.paymentQuote.value == null) return;
  await Get.bottomSheet(
    _PharmacyBookingPaymentSheet(controller: c),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _PharmacyBookingPaymentSheet extends StatelessWidget {
  const _PharmacyBookingPaymentSheet({required this.controller});

  final PharmacyOrderDetailController controller;

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
          padding: EdgeInsets.fromLTRB(
            16.rw,
            12.rh,
            16.rw,
            12.rh,
          ),
          child: Obx(() {
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
            final note = _pharmacyBookingPaymentNote(data);

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
                        controller.confirmBookingPayment();
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

String _pharmacyBookingPaymentNote(Map<String, dynamic> data) {
  final opd = data['opdWallet'];
  if (opd is Map) {
    final a = _sheetNum(opd['available']);
    final m = _sheetNum(opd['module_available']);
    if (a > 0 && m > 0) {
      return 'Note: Amount will be deducted from your Flip Health Wallet first. Any remaining amount will be charged from your pocket.';
    }
  }
  return 'Note: Your available pharmacy wallet balance has exhausted. Please proceed to pay from your pocket to continue.';
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

Widget _summaryRow(String label, String value) {
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

String _formatCreatedAt(String? createdAt) {
  if (createdAt == null || createdAt.trim().isEmpty) return '—';
  try {
    final dt = DateTime.parse(createdAt).toLocal();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  } catch (_) {
    return createdAt;
  }
}

/// Opens Google Maps from address `location` ("lat,lng"), `coordinates`, or link (patient_app pickup).
Future<void> _openMapsFromAddressMap(Map<String, dynamic> address) async {
  final coords = address['coordinates'];

  if (coords is List && coords.length >= 2) {
    final lat = _coordToDouble(coords[0]);
    final lng = _coordToDouble(coords[1]);
    if (lat != null && lng != null) {
      await _openGoogleMapsLatLng(lat, lng);
      return;
    }
  }

  final isLink = address['isLink'];
  final raw = _addressGeoString(address);
  if (raw == null || raw.isEmpty) return;

  if (isLink == 1) {
    var url = raw;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final u = Uri.tryParse(url);
    if (u != null && await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
    return;
  }

  final parts = raw.split(',');
  if (parts.length >= 2) {
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat != null && lng != null) {
      await _openGoogleMapsLatLng(lat, lng);
    }
  }
}

/// Delivery addresses use `location` for "lat,lng"; pickup centers may use `coordinates`.
String? _addressGeoString(Map<String, dynamic> address) {
  final loc = address['location']?.toString().trim();
  if (loc != null && loc.isNotEmpty) return loc;
  final c = address['coordinates'];
  if (c == null || c is List) return null;
  final s = c.toString().trim();
  return s.isEmpty ? null : s;
}

bool _hasMapsTarget(Map<String, dynamic>? address) {
  if (address == null) return false;
  final coords = address['coordinates'];

  if (coords is List && coords.length >= 2) {
    return _coordToDouble(coords[0]) != null &&
        _coordToDouble(coords[1]) != null;
  }

  final isLink = address['isLink'];
  final raw = _addressGeoString(address);
  if (raw == null || raw.isEmpty) return false;

  if (isLink == 1) {
    var url = raw;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return Uri.tryParse(url) != null;
  }

  final parts = raw.split(',');
  if (parts.length < 2) return false;
  return double.tryParse(parts[0].trim()) != null &&
      double.tryParse(parts[1].trim()) != null;
}

/// Prefer `info.createdAt`, then invoice root `createdAt` / `invoice_date` (sample API).
String? _resolveInvoiceCreatedAt(
  Map<String, dynamic> inv,
  Map<String, dynamic> info,
) {
  final a = info['createdAt']?.toString();
  if (a != null && a.trim().isNotEmpty) return a;
  final b = inv['createdAt']?.toString();
  if (b != null && b.trim().isNotEmpty) return b;
  return inv['invoice_date']?.toString();
}

double? _coordToDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

Future<void> _openGoogleMapsLatLng(double latitude, double longitude) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _DirectionsMapButton extends StatelessWidget {
  const _DirectionsMapButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8.rs),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.rs),
        child: Padding(
          padding: EdgeInsets.all(8.rs),
          child: Icon(
            Icons.directions_rounded,
            color: Colors.white,
            size: 22.rs,
          ),
        ),
      ),
    );
  }
}
