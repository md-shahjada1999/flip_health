import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

/// Patient block aligned with consultation order detail (`_PatientDetailsCard` pattern):
/// bordered surface card with title and label/value rows from `user` / `member` / [infoMap].
class OrderPatientDetailsCard extends StatelessWidget {
  const OrderPatientDetailsCard({
    super.key,
    required this.invoiceDetail,
    required this.infoMap,
  });

  final Map<String, dynamic> invoiceDetail;
  final Map<String, dynamic> infoMap;

  @override
  Widget build(BuildContext context) {
    final p = OrderPatientFields.from(invoiceDetail, infoMap);
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
            OrderPatientInfoRow(
              label: entries[i].key,
              value: entries[i].value,
              isLast: i == entries.length - 1,
            ),
        ],
      ),
    );
  }
}

class OrderPatientFields {
  OrderPatientFields._(this.labelValueRows);

  final List<MapEntry<String, String>> labelValueRows;

  static OrderPatientFields from(
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
    final location = pick(['location']);

    final rows = <MapEntry<String, String>>[
      MapEntry(AppString.kPatientName, name),
    ];
    if (phone != null) rows.add(MapEntry(AppString.kPhone, phone));
    if (email != null) rows.add(MapEntry(AppString.kEmail, email));
    if (ageGender.isNotEmpty) {
      rows.add(MapEntry('Age / ${AppString.kGender}', ageGender));
    }
    if (vendor != null) rows.add(MapEntry(AppString.kVendor, vendor));
    if (location != null) rows.add(MapEntry('Location', location));

    return OrderPatientFields._(rows);
  }
}

class OrderPatientInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const OrderPatientInfoRow({
    super.key,
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
