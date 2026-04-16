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
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/lab_order_detail_controller.dart';
import 'package:flip_health/views/orders/widgets/order_invoice_table.dart';
import 'package:flip_health/views/orders/widgets/order_payment_details_section.dart';
import 'package:flip_health/views/orders/widgets/order_patient_details_card.dart';

class LabOrderDetailScreen extends StatelessWidget {
  const LabOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LabOrderDetailController>();

    return Obx(() {
      return SafeScreenWrapper(
        appBar: CommonAppBar.build(
          title: c.detailsFetched.value
              ? AppString.kLabOrderDetails
              : AppString.kOrderDetails,
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
                  collectionSlot: addMap['collection_slot_time']?.toString() ??
                      addMap['collection_slot']?.toString(),
                  labBookingId:
                      c.invoice.value?.additionalInfo?['lab_booking_id']
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
                if (info['source'] != null &&
                    info['source'].toString().isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _SectionCard(
                    title: 'Lab partner',
                    child: CommonText(
                      info['source'].toString(),
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                ..._buildOrderSubCards(invMap),
                if (c.patientLineGroups.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  _PatientTestsSection(groups: c.patientLineGroups),
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

  static List<Widget> _buildOrderSubCards(Map<String, dynamic> invMap) {
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
          child: _LabSubOrderCard(data: Map<String, dynamic>.from(o)),
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
              _row('Invoice ID', _hashOrDash(invoice['invoice_id'] ?? invoice['id'])),
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
  const _LabSubOrderCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final id = data['id']?.toString() ?? '—';
    final cat = data['category']?.toString() ?? '';
    final st = data['status'];
    final statusInt = st is int ? st : int.tryParse(st?.toString() ?? '') ?? -1;
    final date = data['date']?.toString();
    final slot = data['slot_time']?.toString() ?? '';
    final label = _labStatusLabel(statusInt);

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
                  padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 4.rh),
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
        ],
      ),
    );
  }
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
        CommonText(
          rupee,
          fontSize: 12.rf,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}

class _FileThumbSection extends StatelessWidget {
  const _FileThumbSection({
    required this.title,
    required this.items,
  });

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
