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
import 'package:flip_health/core/utils/common_pdf_viewer.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/lab_order_detail_controller.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/orders/widgets/order_invoice_table.dart';
import 'package:flip_health/views/orders/widgets/order_payment_details_section.dart';
import 'package:flip_health/views/orders/widgets/order_patient_details_card.dart';

class LabOrderDetailScreen extends StatelessWidget {
  const LabOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LabOrderDetailController>();

    return Obx(() {
      final showPayBar = c.showCompletePaymentBar;
      return SafeScreenWrapper(
        bottomSafe: !showPayBar,
        appBar: CommonAppBar.build(
          title: c.detailsFetched.value
              ? AppString.kLabOrderDetails
              : AppString.kOrderDetails,
        ),
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
                        onTap: () => _openLabDetailPaymentSheet(c),
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
                _LabOverviewCard(
                  invoice: invMap,
                  info: Map<String, dynamic>.from(info),
                  visitType: visitType,
                  status: status,
                  collectionDate: addMap['collection_date']?.toString(),
                  collectionSlot:
                      addMap['collection_slot_time']?.toString() ??
                      addMap['collection_slot']?.toString(),
                  labBookingId: c
                      .invoice
                      .value
                      ?.additionalInfo?['lab_booking_id']
                      ?.toString(),
                  createdAt: _resolveInvoiceCreatedAt(invMap, info),
                  cancellationReason: info['cancellation_reason']?.toString(),
                ),
                SizedBox(height: 12.rh),
                OrderPatientDetailsCard(
                  invoiceDetail: invMap,
                  infoMap: Map<String, dynamic>.from(info),
                ),
                if (_showCollectionAddress(visitType)) ...[
                  SizedBox(height: 12.rh),
                  _SectionCard(
                    title: 'Collection address',
                    child: _LabAddressBlock(
                      address: info['address'] is Map
                          ? Map<String, dynamic>.from(info['address'] as Map)
                          : null,
                    ),
                  ),
                ],
                ..._buildOrderSubCards(invMap, c),
                if (c.patientLineGroups.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _PatientTestsSection(groups: c.patientLineGroups),
                ],
                if (c.prescriptions.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _PrescriptionThumbSection(items: c.prescriptions.toList()),
                ],
                if (c.attachments.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _FileThumbSection(
                    title: 'Attachments',
                    items: c.attachments.toList(),
                  ),
                ],
                if (c.reports.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _FileThumbSection(
                    title: 'Reports',
                    items: c.reports.toList(),
                  ),
                ],
                if (c.showInvoiceSection) ...[
                  SizedBox(height: 12.rh),
                  OrderInvoiceTable(
                    lines: List<dynamic>.from(c.invoice.value!.details),
                    invoice: invMap,
                  ),
                ],
                if (c.showPaymentsSection) ...[
                  SizedBox(height: 12.rh),
                  OrderPaymentDetailsSection(
                    payments: c.invoice.value!.payments,
                  ),
                ],
                if (_hasUrl(info['trackingUrl'])) ...[
                  SizedBox(height: 12.rh),
                  OutlinedButton.icon(
                    onPressed: () => _openExternal(info['trackingUrl']),
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Track collection'),
                  ),
                ],
                if (_hasUrl(info['reportUrl'])) ...[
                  SizedBox(height: 8.rh),
                  OutlinedButton.icon(
                    onPressed: () => _openExternal(info['reportUrl']),
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('View report link'),
                  ),
                ],
                if (c.canCancelRequest) ...[
                  SizedBox(height: 12.rh),
                  OutlinedButton.icon(
                    onPressed: c.isCancellingOrder.value
                        ? null
                        : () => _showLabCancelBottomSheet(c),
                    icon: c.isCancellingOrder.value
                        ? SizedBox(
                            width: 16.rs,
                            height: 16.rs,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cancel_outlined),
                    label: const Text('Click to cancel booking'),
                  ),
                ],
              ],
            ),
          );
        }(),
      );
    });
  }

  static bool _showCollectionAddress(String visitType) {
    final v = visitType.toUpperCase();
    if (v == 'SELF_VISIT' || v == 'AT_CENTER') return false;
    return true;
  }

  static List<Widget> _buildOrderSubCards(
    Map<String, dynamic> invMap,
    LabOrderDetailController c,
  ) {
    final raw = invMap['orders'];
    if (raw is! List || raw.isEmpty) return [];
    final widgets = <Widget>[SizedBox(height: 12.rh)];
    widgets.add(
      CommonText(
        'Collection schedule',
        fontSize: 13.rf,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
    widgets.add(SizedBox(height: 8.rh));
    for (final o in raw) {
      if (o is! Map) continue;
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 10.rh),
          child: _LabSubOrderCard(
            data: Map<String, dynamic>.from(o),
            controller: c,
          ),
        ),
      );
    }
    return widgets;
  }
}

bool _hasUrl(dynamic u) {
  final s = u?.toString().trim() ?? '';
  return s.isNotEmpty && (s.startsWith('http://') || s.startsWith('https://'));
}

Future<void> _openExternal(dynamic raw) async {
  final u = Uri.tryParse(raw?.toString() ?? '');
  if (u != null && await canLaunchUrl(u)) {
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }
}

class _LabOverviewCard extends StatelessWidget {
  const _LabOverviewCard({
    required this.invoice,
    required this.info,
    required this.visitType,
    required this.status,
    this.collectionDate,
    this.collectionSlot,
    this.labBookingId,
    this.createdAt,
    this.cancellationReason,
  });

  final Map<String, dynamic> invoice;
  final Map<String, dynamic> info;
  final String visitType;
  final int status;
  final String? collectionDate;
  final String? collectionSlot;
  final String? labBookingId;
  final String? createdAt;
  final String? cancellationReason;

  @override
  Widget build(BuildContext context) {
    final label = _labStatusLabel(status);
    final style = _labStatusStyle(status);
    final reason = (label == 'Cancelled' && cancellationReason != null)
        ? cancellationReason!.trim()
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabStatusBanner(label: label, style: style),
        SizedBox(height: 12.rh),
        _SectionCard(
          title: 'Order summary',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(
                'Invoice ID',
                _hashOrDash(invoice['invoice_id'] ?? invoice['id']),
              ),
              if (labBookingId != null && labBookingId!.isNotEmpty) ...[
                SizedBox(height: 8.rh),
                _row('Booking ID', '#$labBookingId'),
              ],
              SizedBox(height: 8.rh),
              _row(
                'Visit type',
                visitType.isEmpty ? '—' : visitType.replaceAll('_', ' '),
              ),
              if (collectionDate != null && collectionDate!.isNotEmpty) ...[
                SizedBox(height: 8.rh),
                _row('Collection date', _formatDateHint(collectionDate!)),
              ],
              if (collectionSlot != null && collectionSlot!.isNotEmpty) ...[
                SizedBox(height: 8.rh),
                _row('Slot', collectionSlot!),
              ],
              SizedBox(height: 8.rh),
              _row('Created at', _formatCreatedAt(createdAt)),
              if (info['statusText'] != null &&
                  info['statusText'].toString().isNotEmpty) ...[
                SizedBox(height: 8.rh),
                _row('Order status', info['statusText'].toString()),
              ],
              if (reason.isNotEmpty) ...[
                SizedBox(height: 8.rh),
                _row('Reason', reason),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LabStatusBanner extends StatelessWidget {
  const _LabStatusBanner({required this.label, required this.style});

  final String label;
  final _LabStatusStyle style;

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

class _LabStatusStyle {
  const _LabStatusStyle({
    required this.fg,
    required this.bg,
    required this.icon,
  });

  final Color fg;
  final Color bg;
  final IconData icon;
}

String _labStatusLabel(int status) {
  const map = {
    0: 'Waiting for confirmation',
    1: 'Completed',
    2: 'Cancelled',
    3: 'Confirm changes',
    4: 'Payment pending',
    5: 'Booking confirmed',
    6: 'Phlebotomist assigned',
    7: 'Sample collected',
    8: 'Waiting for report',
    9: 'Expired',
  };
  return map[status] ?? 'In progress';
}

_LabStatusStyle _labStatusStyle(int status) {
  switch (status) {
    case 1:
    case 6:
      return _LabStatusStyle(
        fg: AppColors.success,
        bg: AppColors.successLight,
        icon: Icons.check_circle_rounded,
      );
    case 2:
    case 9:
      return _LabStatusStyle(
        fg: AppColors.error,
        bg: AppColors.errorLight,
        icon: Icons.cancel_rounded,
      );
    case 4:
      return _LabStatusStyle(
        fg: AppColors.warning,
        bg: AppColors.warningLight,
        icon: Icons.payment_rounded,
      );
    case 5:
      return _LabStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.event_rounded,
      );
    case 0:
    case 3:
      return _LabStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.schedule_rounded,
      );
    default:
      return _LabStatusStyle(
        fg: AppColors.textSecondary,
        bg: AppColors.backgroundSecondary,
        icon: Icons.info_outline_rounded,
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

Widget _row(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 108.rw,
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

String _hashOrDash(dynamic id) {
  final s = id?.toString() ?? '';
  if (s.isEmpty) return '—';
  return s.startsWith('#') ? s : '#$s';
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

String _formatDateHint(String raw) {
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}

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

class _LabAddressBlock extends StatelessWidget {
  const _LabAddressBlock({required this.address});

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
    final tag = m['tag']?.toString();
    final display = m['display_address']?.toString();
    final line1 = m['line_1']?.toString() ?? '';
    final city = m['city']?.toString() ?? '';
    final pin = m['pincode']?.toString() ?? '';
    final state = m['state']?.toString() ?? '';

    final body = display != null && display.isNotEmpty
        ? display
        : [
            line1,
            [city, pin].where((e) => e.isNotEmpty).join(', '),
            state,
          ].where((e) => e.isNotEmpty).join('\n');

    final showDirections = _hasCoords(m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tag != null && tag.isNotEmpty)
                CommonText(
                  tag,
                  fontSize: 12.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              if (tag != null && tag.isNotEmpty) SizedBox(height: 4.rh),
              CommonText(
                body.isEmpty ? '—' : body,
                fontSize: 13.rf,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (showDirections) ...[
          SizedBox(width: 8.rw),
          _DirectionsChip(onPressed: () => _openMapsFromLabAddress(m)),
        ],
      ],
    );
  }
}

bool _hasCoords(Map<String, dynamic> m) {
  final c = m['coordinates'];
  if (c is String && c.contains(',')) {
    final p = c.split(',');
    return p.length >= 2 &&
        double.tryParse(p[0].trim()) != null &&
        double.tryParse(p[1].trim()) != null;
  }
  if (c is List && c.length >= 2) {
    return double.tryParse(c[0].toString()) != null &&
        double.tryParse(c[1].toString()) != null;
  }
  return false;
}

Future<void> _openMapsFromLabAddress(Map<String, dynamic> address) async {
  final c = address['coordinates'];
  if (c is List && c.length >= 2) {
    final lat = double.tryParse(c[0].toString());
    final lng = double.tryParse(c[1].toString());
    if (lat != null && lng != null) {
      await _openGoogleMapsLatLng(lat, lng);
      return;
    }
  }
  if (c is String && c.contains(',')) {
    final p = c.split(',');
    if (p.length >= 2) {
      final lat = double.tryParse(p[0].trim());
      final lng = double.tryParse(p[1].trim());
      if (lat != null && lng != null) {
        await _openGoogleMapsLatLng(lat, lng);
      }
    }
  }
}

Future<void> _openGoogleMapsLatLng(double latitude, double longitude) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _DirectionsChip extends StatelessWidget {
  const _DirectionsChip({required this.onPressed});

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

class _LabSubOrderCard extends StatelessWidget {
  const _LabSubOrderCard({required this.data, required this.controller});

  final Map<String, dynamic> data;
  final LabOrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    final id = data['id']?.toString() ?? '—';
    final cat = data['category']?.toString() ?? '';
    final st = data['status'];
    final statusInt = st is int ? st : int.tryParse(st?.toString() ?? '') ?? -1;
    final date = data['date']?.toString();
    final slot = data['slot_time']?.toString() ?? '';
    final label = _labStatusLabel(statusInt);
    final visitType = data['visit_type']?.toString() ?? '';
    final addInfo = data['additional_info'];
    final addMap = addInfo is Map
        ? Map<String, dynamic>.from(addInfo)
        : <String, dynamic>{};
    final center = addMap['center'];
    final centerMap = center is Map ? Map<String, dynamic>.from(center) : null;
    final rider = data['rider_info'];
    final riderMap = rider is Map ? Map<String, dynamic>.from(rider) : null;

    final showCenter =
        statusInt != 0 &&
        visitType == 'SELF_VISIT' &&
        centerMap != null &&
        centerMap.isNotEmpty;
    final showRider = _labShowRiderRow(statusInt, visitType, riderMap);
    final showRequested = statusInt == 3 && addMap['requested'] is Map;
    final addressId = _labAddressId(controller.infoMap['address']);
    final availableReschedule = data['available_reschedule'] == true;
    final showReschedule =
        statusInt == 5 &&
        addressId.isNotEmpty &&
        availableReschedule &&
        _isLabSubOrderReschedulableNow(date: date, slotTime: slot);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CommonText(
                  '# $id',
                  fontSize: 12.rf,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (cat.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.rw,
                    vertical: 4.rh,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(20.rs),
                  ),
                  child: CommonText(
                    cat,
                    fontSize: 11.rf,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (visitType.isNotEmpty) ...[
            SizedBox(height: 6.rh),
            CommonText(
              'Visit: ${visitType.replaceAll('_', ' ')}',
              fontSize: 11.rf,
              color: AppColors.textTertiary,
            ),
          ],
          SizedBox(height: 8.rh),
          CommonText(
            'Status: $label',
            fontSize: 12.rf,
            color: AppColors.textSecondary,
          ),
          if (date != null && date.isNotEmpty) ...[
            SizedBox(height: 6.rh),
            CommonText(
              'Date: ${_formatDateHint(date)}${slot.isNotEmpty ? ' · $slot' : ''}',
              fontSize: 12.rf,
              color: AppColors.textPrimary,
            ),
          ],
          if (statusInt == 5 &&
              addressId.isNotEmpty &&
              data.containsKey('available_reschedule')) ...[
            SizedBox(height: 8.rh),
            CommonText(
              availableReschedule
                  ? (data['available_reschedule_limit'] != null
                        ? 'Note: You can reschedule only ${data['available_reschedule_limit']} time(s).'
                        : 'You can reschedule this booking.')
                  : 'Note: You have reached the maximum number of reschedules. Please contact support for cancellation.',
              fontSize: 11.rf,
              color: AppColors.textSecondary,
            ),
          ],
          if (showReschedule) ...[
            SizedBox(height: 8.rh),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () => _openLabRescheduleSheet(
                  controller: controller,
                  subOrder: data,
                ),
                child: const Text('Reschedule'),
              ),
            ),
          ],
          if (showRequested) ...[
            SizedBox(height: 10.rh),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 8.rh),
            CommonText(
              'Requested update',
              fontSize: 12.rf,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 4.rh),
            CommonText(
              _formatRequestedSlot(
                Map<String, dynamic>.from(addMap['requested'] as Map),
                addMap,
              ),
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ],
          if (showCenter) ...[
            SizedBox(height: 12.rh),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 8.rh),
            CommonText(
              'Center details',
              fontSize: 12.rf,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 6.rh),
            CommonText(
              centerMap['name']?.toString() ?? '—',
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            SizedBox(height: 4.rh),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CommonText(
                    _formatLabCenterAddressLine(centerMap),
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_labCenterHasDirectionsTarget(centerMap)) ...[
                  SizedBox(width: 6.rw),
                  _SmallDirectionsButton(
                    onPressed: () => _openLabCenterDirections(centerMap),
                  ),
                ],
              ],
            ),
            if ((centerMap['phone']?.toString() ?? '').trim().isNotEmpty) ...[
              SizedBox(height: 6.rh),
              CommonText(
                'Phone: ${centerMap['phone']}',
                fontSize: 12.rf,
                color: AppColors.textSecondary,
              ),
            ],
            if (addMap['collection_date'] != null ||
                addMap['collection_slot_time'] != null) ...[
              SizedBox(height: 6.rh),
              CommonText(
                'Booking time: ${addMap['collection_date'] ?? '—'}  ${addMap['collection_slot_time'] ?? ''}',
                fontSize: 11.rf,
                color: AppColors.textTertiary,
              ),
            ],
            if (statusInt == 3) ...[
              SizedBox(height: 10.rh),
              Obx(() {
                final busy = controller.isConfirmingCenter.value;
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: busy
                        ? null
                        : () => _confirmLabCenterDialog(controller, id),
                    child: busy
                        ? SizedBox(
                            height: 18.rh,
                            width: 18.rh,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Confirm details'),
                  ),
                );
              }),
            ],
          ],
          if (showRider && riderMap != null) ...[
            SizedBox(height: 12.rh),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 8.rh),
            CommonText(
              'Rider details',
              fontSize: 12.rf,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 4.rh),
            CommonText(
              riderMap['name']?.toString() ?? '—',
              fontSize: 12.rf,
              fontWeight: FontWeight.w600,
            ),
            if ((riderMap['contact']?.toString() ?? '').trim().isNotEmpty)
              TextButton.icon(
                onPressed: () => _dialPhone(riderMap['contact']?.toString()),
                icon: const Icon(Icons.phone_rounded, size: 18),
                label: Text(riderMap['contact']?.toString() ?? ''),
              ),
          ],
        ],
      ),
    );
  }
}

bool _labShowRiderRow(
  int status,
  String visitType,
  Map<String, dynamic>? rider,
) {
  if ([0, 1, 2, 3, 4].contains(status)) return false;
  if (visitType != 'HOME_PICKUP') return false;
  if (rider == null) return false;
  final name = rider['name']?.toString().trim() ?? '';
  return name.isNotEmpty;
}

String _formatRequestedSlot(
  Map<String, dynamic> requested,
  Map<String, dynamic> addMap,
) {
  final d =
      requested['collection_date']?.toString() ??
      addMap['collection_date']?.toString() ??
      '';
  final t =
      requested['collection_slot_time']?.toString() ??
      addMap['collection_slot_time']?.toString() ??
      '';
  if (d.isEmpty && t.isEmpty) return '—';
  return '${d.isEmpty ? '—' : _formatDateHint(d)}  ·  $t'.trim();
}

String _formatLabCenterAddressLine(Map<String, dynamic> center) {
  final disp = center['display_address']?.toString().trim();
  if (disp != null && disp.isNotEmpty) return disp;
  final addr = center['address'];
  if (addr is! Map) return '—';
  final m = Map<String, dynamic>.from(addr);
  final line1 = m['line_1']?.toString() ?? '';
  final city = m['city']?.toString() ?? '';
  final pin = m['pincode']?.toString() ?? '';
  final state = m['state']?.toString() ?? '';
  final parts = <String>[
    line1,
    [city, pin].where((e) => e.isNotEmpty).join(', '),
    state,
  ].where((e) => e.trim().isNotEmpty).join('\n');
  return parts.isEmpty ? '—' : parts;
}

bool _labCenterHasDirectionsTarget(Map<String, dynamic> center) {
  final addr = center['address'];
  if (addr is! Map) return false;
  final m = Map<String, dynamic>.from(addr);
  final link = m['isLink'];
  final coords = m['coordinates'];
  if (link == 1 && (coords?.toString().trim().isNotEmpty ?? false)) {
    return true;
  }
  if (coords is String && coords.contains(',')) {
    final p = coords.split(',');
    return p.length >= 2 &&
        double.tryParse(p[0].trim()) != null &&
        double.tryParse(p[1].trim()) != null;
  }
  return false;
}

Future<void> _openLabCenterDirections(Map<String, dynamic> center) async {
  final addr = center['address'];
  if (addr is! Map) return;
  final m = Map<String, dynamic>.from(addr);
  final link = m['isLink'];
  final coords = m['coordinates'];
  if (link == 1 && coords != null) {
    final u = Uri.tryParse(coords.toString());
    if (u != null && await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
      return;
    }
  }
  if (coords is String && coords.contains(',')) {
    final p = coords.split(',');
    if (p.length >= 2) {
      final lat = double.tryParse(p[0].trim());
      final lng = double.tryParse(p[1].trim());
      if (lat != null && lng != null) {
        await _openGoogleMapsLatLng(lat, lng);
      }
    }
  }
}

class _SmallDirectionsButton extends StatelessWidget {
  const _SmallDirectionsButton({required this.onPressed});

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
            size: 20.rs,
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmLabCenterDialog(
  LabOrderDetailController c,
  String subOrderId,
) async {
  await Get.dialog<void>(
    AlertDialog(
      title: CommonText(
        'Confirm details?',
        fontSize: 16.rf,
        fontWeight: FontWeight.w700,
      ),
      content: CommonText(
        'Confirm you have reviewed the center address and slot.',
        fontSize: 13.rf,
        color: AppColors.textSecondary,
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: CommonText(
            'No',
            fontSize: 14.rf,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await c.confirmLabSubOrderCenter(subOrderId);
          },
          child: CommonText(
            'Yes',
            fontSize: 14.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}

Future<void> _dialPhone(String? raw) async {
  final digits = raw?.replaceAll(RegExp(r'[^0-9+]'), '') ?? '';
  if (digits.isEmpty) return;
  final u = Uri(scheme: 'tel', path: digits);
  if (await canLaunchUrl(u)) {
    await launchUrl(u);
  }
}

String _labAddressId(dynamic address) {
  if (address is Map && address['id'] != null) {
    final id = address['id'].toString();
    if (id.trim().isNotEmpty) return id;
  }
  return '';
}

bool _isLabSubOrderReschedulableNow({
  required String? date,
  required String slotTime,
}) {
  if (date == null || date.isEmpty || slotTime.trim().isEmpty) return false;
  final parts = slotTime.split('-');
  if (parts.isEmpty) return false;
  final start = parts.first.trim();
  try {
    final parsedDate = DateFormat('yyyy-MM-dd').parseStrict(date);
    final dateLabel = DateFormat('yyyy-MM-dd').format(parsedDate);
    final dt = DateFormat(
      'yyyy-MM-dd hh:mm a',
    ).parseStrict('$dateLabel $start');
    final now = DateTime.now().subtract(const Duration(hours: 1));
    return dt.isAfter(now) || dt.isAtSameMomentAs(now);
  } catch (_) {
    return false;
  }
}

Future<void> _showLabCancelBottomSheet(LabOrderDetailController c) async {
  final reasonController = TextEditingController();
  await Get.bottomSheet<void>(
    SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.rs, 0, 12.rs, 12.rh),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.rs),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16.rs, 12.rh, 16.rs, 16.rh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonText(
                'Cancel booking',
                fontSize: 16.rf,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: 10.rh),
              TextField(
                controller: reasonController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell us why you want to cancel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.rs),
                  ),
                ),
              ),
              SizedBox(height: 12.rh),
              FilledButton(
                onPressed: () async {
                  await c.cancelLabOrder(reasonController.text);
                  if (!c.isCancellingOrder.value) {
                    Get.back();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
  reasonController.dispose();
}

Future<void> _openLabDetailPaymentSheet(LabOrderDetailController c) async {
  await c.loadPaymentQuote();
  await Get.bottomSheet<void>(
    SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.rs, 0, 12.rs, 12.rh),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.rs),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16.rs, 12.rh, 16.rs, 16.rh),
          child: Obx(() {
            final quote = c.paymentQuote.value ?? <String, dynamic>{};
            final pending =
                (quote['pending_amount'] as num?)?.toDouble() ??
                (quote['amount_to_pay'] as num?)?.toDouble() ??
                0;
            final total =
                (quote['price'] as num?)?.toDouble() ??
                (quote['netAmount'] as num?)?.toDouble() ??
                0;
            final opd = quote['opdWallet'] is Map
                ? Map<String, dynamic>.from(quote['opdWallet'] as Map)
                : <String, dynamic>{};
            final wallet = quote['wallet'] is Map
                ? Map<String, dynamic>.from(quote['wallet'] as Map)
                : <String, dynamic>{};
            final opdAvailable = _labSheetNum(opd['available']);
            final opdModule = _labSheetNum(opd['module_available']);
            final hasOpdCoverage = opdAvailable > 0 && opdModule > 0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonText(
                  'Booking confirmation',
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 12.rh),
                _labPayRow('Total amount', '₹ ${total.toStringAsFixed(0)}'),
                if (opd.isNotEmpty) ...[
                  SizedBox(height: 8.rh),
                  _labPayRow(
                    'Using from OPD wallet',
                    '- ₹ ${opd['used_amount'] ?? 0}',
                  ),
                  SizedBox(height: 2.rh),
                  CommonText(
                    'Available balance: ₹ ${_labSheetMoney(opd['available'])}',
                    fontSize: 11.rf,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 2.rh),
                  CommonText(
                    'Limit available for diagnostics: ₹ ${_labSheetMoney(opd['module_available'])}',
                    fontSize: 11.rf,
                    color: AppColors.textSecondary,
                  ),
                ],
                if (wallet.isNotEmpty) ...[
                  SizedBox(height: 8.rh),
                  _labPayRow(
                    'Using from app wallet',
                    '- ₹ ${wallet['used_amount'] ?? 0}',
                  ),
                  SizedBox(height: 2.rh),
                  CommonText(
                    'Available balance: ₹ ${_labSheetMoney(wallet['balance'])}',
                    fontSize: 11.rf,
                    color: AppColors.textSecondary,
                  ),
                ],
                SizedBox(height: 8.rh),
                _labPayRow(
                  'Total payable',
                  '₹ ${pending.toStringAsFixed(0)}',
                  emphasize: true,
                ),
                SizedBox(height: 10.rh),
                CommonText(
                  hasOpdCoverage
                      ? 'Note: Amount will be deducted from your Flip Health Wallet first. Any remaining amount will be charged from your pocket.'
                      : 'Note: Your available balance for diagnostics has exhausted. Please proceed to pay to use our services.',
                  fontSize: 11.rf,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 8.rh),
                SwitchListTile(
                  value: c.useWalletForPayment.value,
                  onChanged: (v) async {
                    c.useWalletForPayment.value = v;
                    await c.loadPaymentQuote();
                  },
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use app wallet'),
                ),
                SizedBox(height: 8.rh),
                FilledButton(
                  onPressed: c.isProcessingPayment.value
                      ? null
                      : () async {
                          final ok = await c.confirmPaymentFromDetail();
                          if (!ok) return;
                          final res =
                              c.paymentQuote.value ?? <String, dynamic>{};
                          if (res['paymentRequired'] == true &&
                              res['razorpay_payload'] is Map) {
                            final invoiceId = c.infoId;
                            Get.back();
                            Get.toNamed(
                              AppRoutes.razorPay,
                              arguments: [
                                'fromLabOrderDetail',
                                Map<String, dynamic>.from(
                                  res['razorpay_payload'] as Map,
                                ),
                                <String, dynamic>{'invoice_id': invoiceId},
                              ],
                            );
                            return;
                          }
                          Get.back();
                          Get.offAll(
                            () => const PaymentSuccessScreen(
                              title: 'Lab Test Booked Successfully',
                              subtitle:
                                  'We will notify you once the phlebotomist is assigned.',
                            ),
                          );
                        },
                  child: c.isProcessingPayment.value
                      ? SizedBox(
                          width: 18.rs,
                          height: 18.rs,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          pending <= 0
                              ? 'Proceed to Confirm'
                              : 'Proceed to pay ₹ ${pending.toStringAsFixed(0)}',
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget _labPayRow(String label, String value, {bool emphasize = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      CommonText(label, fontSize: 12.rf, color: AppColors.textSecondary),
      CommonText(
        value,
        fontSize: emphasize ? 13.rf : 12.rf,
        fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
      ),
    ],
  );
}

double _labSheetNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

String _labSheetMoney(dynamic v) {
  final n = _labSheetNum(v);
  if (n % 1 == 0) return n.toInt().toString();
  return n.toStringAsFixed(2);
}

Future<void> _openLabRescheduleSheet({
  required LabOrderDetailController controller,
  required Map<String, dynamic> subOrder,
}) async {
  final subOrderId = subOrder['id']?.toString() ?? '';
  if (subOrderId.isEmpty) return;
  final addressId = _labAddressId(controller.infoMap['address']);
  if (addressId.isEmpty) return;
  final vendorCode = controller.infoMap['source']?.toString() ?? '';
  if (vendorCode.isEmpty) return;
  final category = subOrder['category']?.toString().toLowerCase() == 'radiology'
      ? 'radiology'
      : 'pathology';
  final reasonController = TextEditingController();

  var selectedDate = DateTime.now().add(const Duration(days: 1));
  LabSlotsResponse? slots = await controller.getRescheduleSlots(
    addressId: addressId,
    vendorCode: vendorCode,
    category: category,
    date: selectedDate,
  );
  String selectedSlotDisplay = '';
  LabSlot? selectedSlot;

  await Get.bottomSheet<void>(
    StatefulBuilder(
      builder: (ctx, setSheetState) {
        final allSlots = <LabSlot>[
          ...?slots?.morning,
          ...?slots?.afternoon,
          ...?slots?.evening,
        ];
        return SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(16.rs, 12.rh, 16.rs, 16.rh),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.rs)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    'Reschedule appointment',
                    fontSize: 16.rf,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 10.rh),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Reason for reschedule',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.rs),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.rh),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 15),
                              ),
                              initialDate: selectedDate,
                            );
                            if (picked == null) return;
                            selectedDate = picked;
                            selectedSlotDisplay = '';
                            selectedSlot = null;
                            final fresh = await controller.getRescheduleSlots(
                              addressId: addressId,
                              vendorCode: vendorCode,
                              category: category,
                              date: selectedDate,
                            );
                            setSheetState(() => slots = fresh);
                          },
                          icon: const Icon(Icons.calendar_today_rounded),
                          label: Text(
                            DateFormat('dd MMM yyyy').format(selectedDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.rh),
                  if (allSlots.isEmpty)
                    CommonText(
                      'No slots available for selected date',
                      fontSize: 12.rf,
                      color: AppColors.textSecondary,
                    )
                  else
                    Wrap(
                      spacing: 8.rw,
                      runSpacing: 8.rh,
                      children: [
                        for (final s in allSlots)
                          ChoiceChip(
                            label: Text(s.displayTime),
                            selected: selectedSlotDisplay == s.displayTime,
                            onSelected: (_) {
                              setSheetState(() {
                                selectedSlotDisplay = s.displayTime;
                                selectedSlot = s;
                              });
                            },
                          ),
                      ],
                    ),
                  SizedBox(height: 12.rh),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (selectedSlot == null) return;
                        await controller.rescheduleLabSubOrder(
                          subOrderId: subOrderId,
                          reason: reasonController.text,
                          slot: selectedSlot!,
                          addressId: addressId,
                        );
                        if (!controller.isLoading.value) {
                          Get.back();
                        }
                      },
                      child: const Text('Confirm reschedule'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
  reasonController.dispose();
}

class _PatientTestsSection extends StatelessWidget {
  const _PatientTestsSection({required this.groups});

  final List<LabPatientLineGroup> groups;

  @override
  Widget build(BuildContext context) {
    final multi = groups.length > 1;
    return _SectionCard(
      title: multi ? 'Tests by patient' : 'Tests',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0) SizedBox(height: 12.rh),
            _PatientTestCard(group: groups[i]),
          ],
        ],
      ),
    );
  }
}

class _PatientTestCard extends StatelessWidget {
  const _PatientTestCard({required this.group});

  final LabPatientLineGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.rs),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            group.displayName,
            fontSize: 13.rf,
            fontWeight: FontWeight.w700,
          ),
          if (group.subtitle.isNotEmpty) ...[
            SizedBox(height: 2.rh),
            CommonText(
              group.subtitle,
              fontSize: 11.rf,
              color: AppColors.textSecondary,
            ),
          ],
          Divider(height: 14.rh, color: AppColors.divider),
          for (final line in group.lines) ...[
            _testLineRow(line),
            SizedBox(height: 6.rh),
          ],
        ],
      ),
    );
  }

  Widget _testLineRow(Map<String, dynamic> line) {
    final name = line['product_name']?.toString() ?? 'Test';
    final offer = line['offer_price'];
    final price = line['price'];
    final amt = offer ?? price;
    String rupee = '—';
    if (amt is num) {
      rupee = '₹${amt % 1 == 0 ? amt.toInt() : amt}';
    } else if (amt != null) {
      rupee = '₹$amt';
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CommonText(
            name,
            fontSize: 12.rf,
            color: AppColors.textPrimary,
          ),
        ),
        CommonText(rupee, fontSize: 12.rf, fontWeight: FontWeight.w600),
      ],
    );
  }
}

class _PrescriptionThumbSection extends StatelessWidget {
  const _PrescriptionThumbSection({required this.items});

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    final thumbs = <Widget>[];
    for (final a in items) {
      if (a is! Map) continue;
      final m = Map<String, dynamic>.from(a);
      final raw = m['path'] ?? m['url'];
      if (raw == null) continue;
      thumbs.add(_AttThumb(path: raw.toString()));
    }
    if (thumbs.isEmpty) return const SizedBox.shrink();
    return _SectionCard(
      title: 'Prescriptions',
      child: Wrap(spacing: 8.rw, runSpacing: 8.rh, children: thumbs),
    );
  }
}

class _FileThumbSection extends StatelessWidget {
  const _FileThumbSection({required this.title, required this.items});

  final String title;
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: Wrap(
        spacing: 8.rw,
        runSpacing: 8.rh,
        children: [
          for (final a in items)
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
          Get.to(() => CommonPdfViewer(url: url, title: path.split('/').last));
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
