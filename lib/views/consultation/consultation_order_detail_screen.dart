import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_family.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/consultation_invoice_summary.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/consultation_order_detail_controller.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/routes/app_routes.dart';

class ConsultationOrderDetailScreen extends StatelessWidget {
  const ConsultationOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ConsultationOrderDetailController>();

    return SafeScreenWrapper(
      appBar: CommonAppBar.build(title: AppString.kOrderDetails),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        if (!c.showBookFollowUp) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.rw),
          child: SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.rs),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.rs),
                onTap: () => Get.toNamed(
                  AppRoutes.consultation,
                  arguments: <dynamic>[
                    'follow_up',
                    c.followUpBookingArgs(),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.rh),
                  child: Center(
                    child: CommonText(
                      'Book follow up',
                      fontSize: 15.rf,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
      body: Obx(() {
        if (c.isLoading.value && !c.detailsFetched.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!c.detailsFetched.value) {
          return Center(
            child: CommonText(
              'Could not load consultation',
              fontSize: 14.rf,
              color: AppColors.textSecondary,
            ),
          );
        }

        final info = c.invoiceDetail['info'];
        final infoMap = info is Map
            ? Map<String, dynamic>.from(info)
            : <String, dynamic>{};
        final doctor = infoMap['doctor'] is Map
            ? Map<String, dynamic>.from(infoMap['doctor'] as Map)
            : <String, dynamic>{};
        final details = c.invoiceDetail['details'];
        final detailList = details is List ? details : const [];
        final payments = c.invoiceDetail['payments'];
        final payList = payments is List ? payments : const [];

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            12.rw,
            12.rh,
            12.rw,
            c.showBookFollowUp ? 88.rh : 12.rh,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConsultationStatusBanner(info: infoMap),
              SizedBox(height: 12.rh),
              _ConsultationSectionCard(
                title: 'Appointment',
                titleSuffix: c.isOffline
                    ? 'In-person'
                    : (c.isOnline ? 'Virtual' : null),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.rh),
                      child: CommonText(
                        infoMap['id'] != null ? '#${infoMap['id']}' : '—',
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _row(
                      AppString.kSchedule,
                      formatConsultationSchedule(
                        infoMap['date']?.toString(),
                        infoMap['time']?.toString(),
                      ),
                    ),
                    if (infoMap['purpose'] != null &&
                        '${infoMap['purpose']}'.trim().isNotEmpty)
                      _row('Purpose', '${infoMap['purpose']}'),
                  ],
                ),
              ),
              SizedBox(height: 16.rh),
              _PatientDetailsCard(
                invoiceDetail: c.invoiceDetail,
                infoMap: infoMap,
              ),
              SizedBox(height: 16.rh),
              if (c.isOffline)
                _OfflineNetworkVisitCard(infoMap: infoMap)
              else
                _DoctorDetailsCard(
                  doctor: doctor,
                  communication: infoMap['communication']?.toString(),
                ),
              SizedBox(height: 16.rh),
              _ConsultationSectionCard(
                title: 'Attachments',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!c.showAttachmentsBody)
                      CommonText(
                        'No attachments',
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                      )
                    else ...[
                      if (c.attachments.isNotEmpty)
                        Wrap(
                          spacing: 8.rw,
                          runSpacing: 8.rh,
                          children: [
                            for (final a in c.attachments)
                              if (a is Map && a['path'] != null)
                                _AttachmentThumb(path: a['path'].toString()),
                          ],
                        ),
                      if (c.attachments.isNotEmpty && c.canAddAttachment)
                        SizedBox(height: 8.rh),
                      if (c.canAddAttachment)
                        OutlinedButton.icon(
                          onPressed: () {
                            ToastCustom.showSnackBar(
                              subtitle:
                                  'Upload uses the same /upload + attachment APIs as patient_app — wire here if needed.',
                            );
                          },
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Add attachment'),
                        ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.rh),
              if (c.showInvoiceSection) ...[
                _InvoiceDetailsTable(
                  lines: detailList,
                  invoice: c.invoiceDetail,
                ),
                SizedBox(height: 16.rh),
              ],
              if (c.showPaymentsSection) ...[
                _PaymentDetailsCard(payments: payList),
                SizedBox(height: 16.rh),
              ],
              SizedBox(height: 24.rh),
              if (c.canJoinCall)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: c.onJoinCallPressed,
                    child: const Text('Join call'),
                  ),
                ),
              if (c.canCancel) ...[
                SizedBox(height: 12.rh),
                OutlinedButton(
                  onPressed: () => _cancelSheet(context, c),
                  child: const Text('Cancel appointment'),
                ),
              ],
              if (c.showPayConfirmBooking) ...[
                SizedBox(height: 12.rh),
                OutlinedButton(
                  onPressed: () async =>
                      _openConsultationBookingPaymentSheet(c),
                  child: const Text('Pay / confirm booking'),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  static void _cancelSheet(
    BuildContext context,
    ConsultationOrderDetailController c,
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
                c.cancelAppointment();
              },
              child: const Text('Submit cancellation'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

String _consultationStatusLabel(Map<String, dynamic> info) {
  final source = info['source']?.toString();
  final raw = info['status'];
  final st = raw is int ? raw : int.tryParse('$raw') ?? -1;

  if (source != null && source != 'FLIPHEALTH') {
    switch (st) {
      case 0:
        return 'Waiting for confirmation';
      case 1:
        return 'Completed';
      case 2:
        return 'Cancelled';
      case 3:
        return 'Confirm changes';
      case 4:
        return 'Payment pending';
      case 5:
        return 'Upcoming appointment';
      default:
        return 'Pending';
    }
  }

  final date = info['date']?.toString();
  final time = info['time']?.toString();
  DateTime? consultationTime;
  if (date != null && time != null) {
    try {
      consultationTime = DateTime.parse('${date}T$time');
    } catch (_) {
      try {
        consultationTime = DateTime.parse('$date $time');
      } catch (_) {}
    }
  }
  final isPastSlot =
      consultationTime != null &&
      DateTime.now().isAfter(consultationTime.add(const Duration(minutes: 10)));

  switch (st) {
    case 0:
      return 'Waiting for confirmation';
    case 1:
      return 'Completed';
    case 2:
      return 'Cancelled';
    case 3:
      return 'Confirm changes';
    case 4:
      return 'Payment pending';
    case 5:
      return isPastSlot ? 'Expired' : 'Upcoming';
    case 6:
      return 'In progress';
    case 7:
    case 8:
      return 'Pending';
    case 9:
      return 'Expired';
    default:
      return 'Upcoming appointment';
  }
}

/// Patient block aligned with [OrderDetailScreen] patient section (`_SectionCard` + label/value rows).
class _PatientDetailsCard extends StatelessWidget {
  final Map<String, dynamic> invoiceDetail;
  final Map<String, dynamic> infoMap;

  const _PatientDetailsCard({
    required this.invoiceDetail,
    required this.infoMap,
  });

  @override
  Widget build(BuildContext context) {
    final p = _PatientFields.from(invoiceDetail, infoMap);
    final entries = p.labelValueRows;

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
            AppString.kPatientDetails,
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          Divider(height: 20.rh, color: AppColors.divider),
          for (var i = 0; i < entries.length; i++)
            _PatientInfoRow(
              label: entries[i].key,
              value: entries[i].value,
              isLast: i == entries.length - 1,
            ),
        ],
      ),
    );
  }
}

class _PatientFields {
  _PatientFields._(this.labelValueRows);

  final List<MapEntry<String, String>> labelValueRows;

  static _PatientFields from(
    Map<String, dynamic> inv,
    Map<String, dynamic> info,
  ) {
    Map<String, dynamic> u = {};
    Map<String, dynamic> m = {};
    if (inv['user'] is Map) {
      u = Map<String, dynamic>.from(inv['user'] as Map);
    }
    if (inv['member'] is Map) {
      m = Map<String, dynamic>.from(inv['member'] as Map);
    }

    String? pick(List<dynamic> keys) {
      for (final k in keys) {
        final v = u[k] ?? m[k] ?? info[k];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return null;
    }

    final name = pick(['name', 'patient_name']) ?? '—';
    final phone = pick(['phone', 'mobile']);
    final email = pick(['email']);
    final age = pick(['age']);
    final gender = pick(['gender']);
    final ageParts = <String>[
      if (age != null && age.isNotEmpty) age,
      if (gender != null && gender.isNotEmpty) gender,
    ];
    final ageGender = ageParts.join(' · ');
    final vendor = pick([
      'hospital_name',
      'vendor_name',
      'clinic_name',
      'hospital',
      'clinic',
    ]);

    final rows = <MapEntry<String, String>>[
      MapEntry(AppString.kPatientName, name),
    ];
    if (phone != null) rows.add(MapEntry(AppString.kPhone, phone));
    if (email != null) rows.add(MapEntry(AppString.kEmail, email));
    if (ageGender.isNotEmpty) {
      rows.add(MapEntry('Age / ${AppString.kGender}', ageGender));
    }
    if (vendor != null) rows.add(MapEntry(AppString.kVendor, vendor));

    return _PatientFields._(rows);
  }
}

class _PatientInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _PatientInfoRow({
    required this.label,
    required this.value,
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
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorDetailsCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final String? communication;

  const _DoctorDetailsCard({required this.doctor, this.communication});

  @override
  Widget build(BuildContext context) {
    final d = _DoctorDisplay.from(doctor);
    final img =
        doctor['image']?.toString() ?? doctor['profile_image']?.toString();
    final url = ApiUrl.publicFileUrl(img);

    return _ConsultationSectionCard(
      title: 'Doctor details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28.rs,
                backgroundColor: AppColors.backgroundSecondary,
                backgroundImage: url != null
                    ? CachedNetworkImageProvider(url)
                    : null,
                child: url == null
                    ? Icon(
                        Icons.person,
                        size: 28.rs,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      d.name,
                      fontSize: 15.rf,
                      fontWeight: FontWeight.w600,
                    ),
                    if (d.specialty != null && d.specialty!.isNotEmpty)
                      CommonText(
                        d.specialty!,
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfflineVisitData {
  _OfflineVisitData({
    this.clinicName,
    this.doctorName,
    this.specialty,
    this.qualification,
    this.experienceYears,
    this.address,
    this.coordinates,
  });

  final String? clinicName;
  final String? doctorName;
  final String? specialty;
  final String? qualification;
  final int? experienceYears;
  final String? address;
  final String? coordinates;

  static _OfflineVisitData from(Map<String, dynamic> info) {
    final addl = info['additional_info'];
    final addMap = addl is Map
        ? Map<String, dynamic>.from(addl)
        : <String, dynamic>{};
    final booking = addMap['booking_details'];
    final bookMap = booking is Map
        ? Map<String, dynamic>.from(booking)
        : <String, dynamic>{};
    final clinic = addMap['clinic'];
    final clinMap = clinic is Map
        ? Map<String, dynamic>.from(clinic)
        : <String, dynamic>{};

    var specialty = '';
    final spec = addMap['speciality'];
    if (spec is Map && spec['specialty'] != null) {
      specialty = spec['specialty'].toString();
    }
    if (specialty.isEmpty) {
      specialty = clinMap['specialty']?.toString() ?? '';
    }
    if (specialty.isEmpty) {
      final specs = bookMap['specialties'];
      if (specs is List && specs.isNotEmpty) {
        specialty = specs.first.toString();
      }
    }

    final doctorName =
        bookMap['doctor_name']?.toString() ??
        bookMap['name']?.toString() ??
        clinMap['name']?.toString() ??
        '';

    final clinicName =
        bookMap['clinic_name']?.toString() ??
        clinMap['clinic_name']?.toString() ??
        '';

    final address =
        bookMap['clinic_address']?.toString() ??
        bookMap['address']?.toString() ??
        clinMap['address']?.toString() ??
        '';

    final coords = bookMap['coordinates']?.toString();

    int? expY;
    final ex = clinMap['experience'];
    if (ex is int) {
      expY = ex;
    } else if (ex != null) {
      expY = int.tryParse(ex.toString());
    }

    return _OfflineVisitData(
      clinicName: clinicName,
      doctorName: doctorName,
      specialty: specialty.isNotEmpty ? specialty : null,
      qualification: clinMap['qualification']?.toString(),
      experienceYears: expY,
      address: address.isNotEmpty ? address : null,
      coordinates: coords,
    );
  }

  bool get hasMapsTarget =>
      (coordinates != null && coordinates!.contains(',')) ||
      (address != null && address!.trim().isNotEmpty);
}

class _OfflineNetworkVisitCard extends StatelessWidget {
  final Map<String, dynamic> infoMap;

  const _OfflineNetworkVisitCard({required this.infoMap});

  @override
  Widget build(BuildContext context) {
    final d = _OfflineVisitData.from(infoMap);

    return _ConsultationSectionCard(
      title: 'Visit details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (d.clinicName != null && d.clinicName!.isNotEmpty)
            CommonText(
              d.clinicName!,
              fontSize: 15.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          if (d.doctorName != null && d.doctorName!.isNotEmpty) ...[
            SizedBox(height: 10.rh),
            CommonText(
              d.doctorName!,
              fontSize: 15.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ],
          if (d.specialty != null && d.specialty!.isNotEmpty) ...[
            SizedBox(height: 6.rh),
            CommonText(
              d.specialty!,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ],
          if (d.qualification != null && d.qualification!.isNotEmpty) ...[
            SizedBox(height: 4.rh),
            CommonText(
              d.qualification!,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ],
          if (d.experienceYears != null) ...[
            SizedBox(height: 4.rh),
            CommonText(
              '${d.experienceYears} years experience',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ],
          if (d.address != null && d.address!.trim().isNotEmpty) ...[
            SizedBox(height: 12.rh),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 12.rh),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CommonText(
                    d.address!,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                if (d.hasMapsTarget)
                  IconButton(
                    onPressed: () => _openGoogleMapsForVisit(
                      coordinates: d.coordinates,
                      address: d.address,
                    ),
                    icon: Icon(
                      Icons.directions,
                      color: AppColors.primary,
                      size: 26.rs,
                    ),
                    tooltip: 'Directions in Google Maps',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _openGoogleMapsForVisit({
  required String? coordinates,
  required String? address,
}) async {
  Uri? uri;
  final c = coordinates?.trim();
  if (c != null && c.contains(',')) {
    final parts = c
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      final lat = parts[0];
      final lng = parts[1];
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );
    }
  }
  if (uri == null) {
    final a = address?.trim();
    if (a != null && a.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(a.replaceAll('\n', ' '))}',
      );
    }
  }
  if (uri == null) return;
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (_) {}
}

class _DoctorDisplay {
  _DoctorDisplay({required this.name, this.specialty});

  final String name;
  final String? specialty;

  static _DoctorDisplay from(Map<String, dynamic> doctor) {
    final rawName = doctor['name'];
    if (rawName is Map) {
      final m = Map<String, dynamic>.from(rawName);
      final displayName =
          m['name']?.toString() ??
          m['doctor_name']?.toString() ??
          m['full_name']?.toString() ??
          'Doctor';
      final specRaw =
          m['speciality']['name'] ??
          m['specialty']['name'] ??
          m['specialization'];
      final spec = specRaw?.toString().trim();
      return _DoctorDisplay(
        name: displayName,
        specialty: (spec != null && spec.isNotEmpty) ? spec : null,
      );
    }
    final topName = rawName?.toString();
    final resolvedName = (topName != null && topName.isNotEmpty)
        ? topName
        : 'Doctor';
    final fallback =
        doctor['speciality']['name'] ?? doctor['specialty']['name'];
    final fb = fallback?.toString().trim();
    return _DoctorDisplay(
      name: resolvedName,
      specialty: (fb != null && fb.isNotEmpty) ? fb : null,
    );
  }
}

class _ConsultationStatusBanner extends StatelessWidget {
  final Map<String, dynamic> info;

  const _ConsultationStatusBanner({required this.info});

  @override
  Widget build(BuildContext context) {
    final label = _consultationStatusLabel(info);
    final style = _consultationStatusStyle(info);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  '${AppString.kStatusLabel}: $label',
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: style.fg,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationStatusStyle {
  const _ConsultationStatusStyle({
    required this.fg,
    required this.bg,
    required this.icon,
  });

  final Color fg;
  final Color bg;
  final IconData icon;
}

_ConsultationStatusStyle _consultationStatusStyle(Map<String, dynamic> info) {
  final raw = info['status'];
  final st = raw is int ? raw : int.tryParse('$raw') ?? -1;

  switch (st) {
    case 1:
    case 6:
      return _ConsultationStatusStyle(
        fg: AppColors.success,
        bg: AppColors.successLight,
        icon: Icons.check_circle_rounded,
      );
    case 2:
    case 9:
      return _ConsultationStatusStyle(
        fg: AppColors.error,
        bg: AppColors.errorLight,
        icon: Icons.cancel_rounded,
      );
    case 4:
      return _ConsultationStatusStyle(
        fg: AppColors.warning,
        bg: AppColors.warningLight,
        icon: Icons.payment_rounded,
      );
    case 5:
      return _ConsultationStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.event_rounded,
      );
    case 0:
    case 7:
    case 8:
      return _ConsultationStatusStyle(
        fg: AppColors.info,
        bg: AppColors.infoLight,
        icon: Icons.schedule_rounded,
      );
    default:
      return _ConsultationStatusStyle(
        fg: AppColors.textSecondary,
        bg: AppColors.backgroundSecondary,
        icon: Icons.info_outline_rounded,
      );
  }
}

class _ConsultationSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  /// Shown next to [title], e.g. "In-person" / "Virtual" for appointments.
  final String? titleSuffix;

  const _ConsultationSectionCard({
    required this.title,
    required this.child,
    this.titleSuffix,
  });

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
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6.rw,
            runSpacing: 4.rh,
            children: [
              CommonText(
                title,
                fontSize: 14.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              if (titleSuffix != null && titleSuffix!.trim().isNotEmpty) ...[
                CommonText(
                  '·',
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                CommonText(
                  titleSuffix!.trim(),
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
          Divider(height: 20.rh, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}

class _InvoiceDetailsTable extends StatelessWidget {
  final List<dynamic> lines;
  final Map<String, dynamic> invoice;

  const _InvoiceDetailsTable({required this.lines, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final rows = <TableRow>[
      TableRow(
        decoration: BoxDecoration(color: AppColors.backgroundSecondary),
        children: [
          _tableHeaderCell('Description'),
          _tableHeaderCell('MRP', alignEnd: true),
          _tableHeaderCell('Price', alignEnd: true),
          _tableHeaderCell('Qty', alignEnd: true),
          _tableHeaderCell('Amount', alignEnd: true),
        ],
      ),
    ];

    for (final line in lines) {
      if (line is! Map) continue;
      final m = Map<String, dynamic>.from(line);
      final cells = _invoiceLineCells(m);
      rows.add(
        TableRow(
          children: [
            _tableBodyCell(cells.description),
            _tableBodyCell(cells.mrp, alignEnd: true),
            _tableBodyCell(cells.price, alignEnd: true),
            _tableBodyCell(cells.qty, alignEnd: true),
            _tableBodyCell(cells.amount, alignEnd: true),
          ],
        ),
      );
    }

    if (lines.isEmpty) {
      return _ConsultationSectionCard(
        title: 'Invoice details',
        child: CommonText(
          'No line items',
          fontSize: 12.rf,
          color: AppColors.textSecondary,
        ),
      );
    }

    final summary = _InvoiceTotals.compute(lines: lines, invoice: invoice);

    return _ConsultationSectionCard(
      title: 'Invoice details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(2.6),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(0.75),
                      4: FlexColumnWidth(1.15),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(color: AppColors.divider),
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                    children: rows,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12.rh),
          Divider(height: 1, color: AppColors.divider),
          _invoiceSummaryRow('Total', _fmtRupee(summary.itemsTotal)),
          _invoiceSummaryRow(
            'Convenience charges',
            '+ ${_fmtRupee(summary.convenienceCharges)}',
          ),
          _invoiceSummaryRow('Saved', '- ${_fmtRupee(summary.saved)}'),
          SizedBox(height: 8.rh),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 12.rh),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12.rs),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  'Net amount',
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                CommonText(
                  _fmtRupee(summary.netAmount),
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _invoiceSummaryRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.only(top: 8.rh),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(label, fontSize: 12.rf, color: AppColors.textSecondary),
        CommonText(
          value,
          fontSize: 12.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ],
    ),
  );
}

class _InvoiceLineCells {
  _InvoiceLineCells({
    required this.description,
    required this.mrp,
    required this.price,
    required this.qty,
    required this.amount,
  });

  final String description;
  final String mrp;
  final String price;
  final String qty;
  final String amount;
}

_InvoiceLineCells _invoiceLineCells(Map<String, dynamic> line) {
  double? n(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  final productName = line['product_name']?.toString().trim();
  final description = (productName != null && productName.isNotEmpty)
      ? productName
      : _invoiceLineItemTitle(line);

  final mrpVal = n(line['price']);
  final offerVal = n(line['offer_price']);
  final qtyRaw = n(line['qty']);
  final qtyNeg = qtyRaw != null && qtyRaw < 0;

  final mrpStr = mrpVal != null ? _fmtRupee(mrpVal) : '—';
  final priceStr = offerVal != null ? _fmtRupee(offerVal) : '—';
  final qtyStr = qtyNeg ? '—' : (qtyRaw == null ? '—' : _fmtQty(qtyRaw));

  String amountStr;
  if (qtyNeg || offerVal == null || qtyRaw == null) {
    amountStr = '—';
  } else {
    amountStr = _fmtRupee(qtyRaw * offerVal);
  }

  return _InvoiceLineCells(
    description: description,
    mrp: mrpStr,
    price: priceStr,
    qty: qtyStr,
    amount: amountStr,
  );
}

String _fmtQty(double? q) {
  if (q == null) return '0';
  if (q % 1 == 0) return q.toInt().toString();
  return q.toString();
}

String _fmtRupee(double? x) {
  if (x == null) return '—';
  if (x % 1 == 0) return '₹${x.toInt()}';
  return '₹${x.toStringAsFixed(2)}';
}

class _InvoiceTotals {
  _InvoiceTotals({
    required this.itemsTotal,
    required this.convenienceCharges,
    required this.saved,
    required this.netAmount,
  });

  final double itemsTotal;
  final double convenienceCharges;
  final double saved;
  final double netAmount;

  static _InvoiceTotals compute({
    required List<dynamic> lines,
    required Map<String, dynamic> invoice,
  }) {
    double? n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    double itemsSum = 0;
    for (final line in lines) {
      if (line is! Map) continue;
      final m = Map<String, dynamic>.from(line);
      final offer = n(m['offer_price']);
      final qty = n(m['qty']);
      if (offer == null || qty == null || qty < 0) continue;
      itemsSum += qty * offer;
    }

    final add = invoice['additional_info'];
    final addMap = add is Map
        ? Map<String, dynamic>.from(add)
        : <String, dynamic>{};
    final tt = invoice['transaction_type']?.toString() ?? '';

    final delivery = tt == 'PHARMACY'
        ? (n(addMap['delivery_charges']) ?? 0)
        : 0.0;
    final collection = tt == 'LABTEST'
        ? (n(addMap['collection_fee']) ?? 0)
        : 0.0;
    final convenience = n(addMap['processing_fee']) ?? 0.0;
    final discount = n(invoice['discount']) ?? 0.0;

    final netComputed =
        itemsSum + convenience + delivery + collection - discount;

    final netApi = n(invoice['net_amount']);
    final netAmount = netApi ?? netComputed;

    return _InvoiceTotals(
      itemsTotal: itemsSum,
      convenienceCharges: convenience,
      saved: discount,
      netAmount: netAmount,
    );
  }
}

Widget _tableHeaderCell(String text, {bool alignEnd = false}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 6.rw),
    child: Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: CommonText(
        text,
        fontSize: 11.rf,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
  );
}

Widget _tableBodyCell(String text, {bool alignEnd = false}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 6.rw),
    child: Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: CommonText(text, fontSize: 11.rf, color: AppColors.textPrimary),
    ),
  );
}

String _invoiceLineItemTitle(Map<String, dynamic> line) {
  final n = line['name'];
  if (n is Map) {
    final m = Map<String, dynamic>.from(n);
    return m['title']?.toString() ??
        m['product_name']?.toString() ??
        m['name']?.toString() ??
        'Item';
  }
  return line['product_name']?.toString() ??
      n?.toString() ??
      line['title']?.toString() ??
      'Item';
}

class _PaymentDetailsCard extends StatelessWidget {
  final List<dynamic> payments;

  const _PaymentDetailsCard({required this.payments});

  @override
  Widget build(BuildContext context) {
    return _ConsultationSectionCard(
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
                    _PaymentEntryCard(entry: Map<String, dynamic>.from(p)),
              ],
            ),
    );
  }
}

class _PaymentEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _PaymentEntryCard({required this.entry});

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
                  _rowInline('Method', '${mode ?? '—'}'),
                  if (src != null && '$src'.isNotEmpty)
                    _rowInline('Source', '$src'),
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

Widget _rowInline(String label, String value) {
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

Widget _row(String k, String v) {
  return Padding(
    padding: EdgeInsets.only(bottom: 6.rh),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.rw,
          child: CommonText(k, fontSize: 12.rf, color: AppColors.textSecondary),
        ),
        Expanded(child: CommonText(v, fontSize: 13.rf)),
      ],
    ),
  );
}

Future<void> _openConsultationBookingPaymentSheet(
  ConsultationOrderDetailController c,
) async {
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );
  await c.refreshPaymentQuote();
  Get.back();
  if (c.paymentQuote.value == null) return;
  await Get.bottomSheet(
    _ConsultationBookingPaymentSheet(controller: c),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _ConsultationBookingPaymentSheet extends StatelessWidget {
  final ConsultationOrderDetailController controller;

  const _ConsultationBookingPaymentSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.rw,
            12.rh,
            16.rw,
            12.rh + bottomInset,
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
            final price = _sheetMoney(data['price']);
            final pendingStr = _sheetMoney(data['pending_amount']);
            final opd = data['opdWallet'];
            final showOpd = _hasOpdWalletData(data);
            final note = _bookingPaymentNote(data);

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
                  _sheetPayRow('Total amount', '₹ $price'),
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
                          // if (_sheetNum(opd['total']) > 0 ||
                          //     _sheetNum(opd['available']) > 0) ...[
                          //   SizedBox(height: 6.rh),
                          //   CommonText(
                          //     'Total limit: ₹ ${_sheetMoney(opd['total'])} · Available: ₹ ${_sheetMoney(opd['available'])}',
                          //     fontSize: 10.rf,
                          //     color: AppColors.textSecondary,
                          //   ),
                          // ],
                          // SizedBox(height: 4.rh),
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontFamily: FontFamily.fontName,
                                fontSize: 10.rf,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: 'Limit available : '),
                                TextSpan(
                                  text:
                                      '₹ ${_sheetMoney(opd['module_available'])}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // if (walletMap != null) ...[
                  //   SizedBox(height: 12.rh),
                  //   _bookingPaymentSheetSection(
                  //     title: 'App wallet',
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Obx(
                  //           () => Checkbox(
                  //             value: controller.useFlipCash.value,
                  //             onChanged: (v) async {
                  //               controller.useFlipCash.value = v ?? false;
                  //               await controller.refreshPaymentQuote();
                  //             },
                  //           ),
                  //         ),
                  //         Expanded(
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               CommonText(
                  //                 'Use Flip Health wallet for this booking',
                  //                 fontSize: 11.rf,
                  //                 color: AppColors.textSecondary,
                  //               ),
                  //               SizedBox(height: 8.rh),
                  //               _sheetPayRow(
                  //                 'Using from app wallet',
                  //                 walletMap.isEmpty
                  //                     ? '₹ 0'
                  //                     : '- ₹ ${_sheetMoney(walletMap['used_amount'] ?? 0)}',
                  //               ),
                  //               CommonText(
                  //                 walletMap.isEmpty
                  //                     ? 'Available balance: ₹ 0'
                  //                     : 'Available balance: ₹ ${_sheetMoney(walletMap['balance'])}',
                  //                 fontSize: 10.rf,
                  //                 color: AppColors.textSecondary,
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ],
                  // SizedBox(height: 12.rh),
                  // Divider(height: 1, color: AppColors.divider),
                  SizedBox(height: 10.rh),
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

/// OPD wallet section only when `opdWallet` exists and both balances are usable.
bool _hasOpdWalletData(Map<String, dynamic> data) {
  final opd = data['opdWallet'];
  if (opd is! Map) return false;
  final a = _sheetNum(opd['available']);
  final m = _sheetNum(opd['module_available']);
  return a > 0 && m > 0;
}

String _bookingPaymentNote(Map<String, dynamic> data) {
  final opd = data['opdWallet'];
  if (opd is Map) {
    final a = _sheetNum(opd['available']);
    final m = _sheetNum(opd['module_available']);
    if (a > 0 && m > 0) {
      return 'Note: Amount will be deducted from your Flip Health Wallet when booking for consultation.';
    }
  }
  return 'Note: Your available balance for consultation has exhausted. Please proceed to pay to use our services.';
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

class _AttachmentThumb extends StatelessWidget {
  final String path;

  const _AttachmentThumb({required this.path});

  @override
  Widget build(BuildContext context) {
    final url = ApiUrl.publicFileUrl(path);
    if (url == null) return const SizedBox.shrink();
    if (path.toLowerCase().endsWith('.pdf')) {
      return Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.picture_as_pdf),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      ),
    );
  }
}
