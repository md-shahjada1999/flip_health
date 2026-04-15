import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';

/// Full-screen list of package inclusions — aligned with patient_app [IncludedTestView].
/// Data comes from `GET /patient/diagnostics/packages/{pricingId}` → `data.parameters`, using **pricing.id**.
class PackageInclusionsScreen extends StatelessWidget {
  const PackageInclusionsScreen({
    super.key,
    required this.items,
  });

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      appBar: CommonAppBar.build(
        title: AppString.kWhatsIncludedTitle,
        onBackPressed: () => Get.back<void>(),
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.rw),
                child: CommonText(
                  AppString.kNoPackageInclusions,
                  fontSize: 15.rf,
                  height: 1.45,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.rw, 12.rh, 16.rw, 24.rh),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.rh),
                itemBuilder: (context, index) {
                  return _InclusionBlock(item: items[index]);
                },
              ),
            ),
    );
  }
}

class _InclusionBlock extends StatelessWidget {
  const _InclusionBlock({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    if (item is! Map) return const SizedBox.shrink();
    final map = Map<String, dynamic>.from(item);
    final name = map['name']?.toString() ?? '';
    final detailRaw = map['package_detail'];
    final details = detailRaw is List ? detailRaw : null;

    if (details == null || details.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 12.rh),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.rs),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: CommonText(
          name.isNotEmpty ? name : '—',
          fontSize: 14.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 4.rh),
          childrenPadding: EdgeInsets.only(bottom: 10.rh),
          title: CommonText(
            name,
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          children: details.map<Widget>((e) {
            final subName = e is Map ? e['name']?.toString() ?? '' : e.toString();
            return Padding(
              padding: EdgeInsets.only(left: 14.rw, right: 14.rw, bottom: 8.rh),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 20.rs,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 8.rw),
                  Expanded(
                    child: CommonText(
                      subName,
                      fontSize: 13.rf,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
