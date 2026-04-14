import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';

class HealthCheckupOverviewScreen extends StatelessWidget {
  const HealthCheckupOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HealthCheckupsController>();

    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: 'Booking Overview'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.rs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: _buildCard(
                      title: 'Members & Packages',
                      icon: Icons.people_outline,
                      child: _buildMemberPackages(controller),
                    ),
                  ),
                  SizedBox(height: 16.rh),
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: _buildCard(
                      title: 'Vendors',
                      icon: Icons.local_hospital_outlined,
                      child: _buildVendors(controller),
                    ),
                  ),
                  SizedBox(height: 16.rh),
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 200),
                    child: _buildCard(
                      title: 'Scheduled Slots',
                      icon: Icons.schedule_outlined,
                      child: _buildSlots(controller),
                    ),
                  ),
                  SizedBox(height: 16.rh),
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 300),
                    child: _buildCard(
                      title: 'Address',
                      icon: Icons.location_on_outlined,
                      child: _buildAddress(),
                    ),
                  ),
                  SizedBox(height: 24.rh),
                  FadeIn(
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.rs),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.rs),
                        border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.amber.shade700, size: 20.rs),
                          SizedBox(width: 10.rw),
                          Expanded(
                            child: CommonText(
                              'Booking API will be integrated soon. This screen shows your selection summary.',
                              fontSize: 12.rf,
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ActionButton(
            text: 'Book Appointment',
            onPressed: null,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.rs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.rs),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18.rs),
              ),
              SizedBox(width: 10.rw),
              CommonText(
                title,
                fontSize: 15.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: 14.rh),
          Divider(color: AppColors.borderLight, height: 1),
          SizedBox(height: 14.rh),
          child,
        ],
      ),
    );
  }

  Widget _buildMemberPackages(HealthCheckupsController c) {
    return Column(
      children: c.selectedMembers.map((m) {
        final pkgId = c.memberPackageMap[m.id];
        String pkgName = 'Not selected';
        if (pkgId != null) {
          final cached = c.currentPackages
              .firstWhereOrNull((p) => p.id == pkgId);
          pkgName = cached?.name ?? 'Package #$pkgId';
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 10.rh),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16.rs,
                backgroundColor: AppColors.backgroundSecondary,
                child: CommonText(
                  m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 10.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      m.name,
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    CommonText(
                      pkgName,
                      fontSize: 12.rf,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVendors(HealthCheckupsController c) {
    final items = <Widget>[];

    if (c.selectedPathologyVendor.value != null) {
      final v = c.selectedPathologyVendor.value!;
      items.add(_vendorRow('Pathology', v.name, '₹${v.price.toStringAsFixed(0)}'));
    }
    if (c.selectedRadiologyVendor.value != null) {
      final v = c.selectedRadiologyVendor.value!;
      items.add(_vendorRow('Radiology', v.name, '₹${v.price.toStringAsFixed(0)}'));
    }

    if (items.isEmpty) {
      return CommonText('No vendors selected',
          fontSize: 13.rf, color: AppColors.textSecondary);
    }

    return Column(children: items);
  }

  Widget _vendorRow(String category, String name, String price) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rh),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 3.rh),
            decoration: BoxDecoration(
              color: category == 'Pathology'
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.rs),
            ),
            child: CommonText(
              category,
              fontSize: 11.rf,
              fontWeight: FontWeight.w600,
              color: category == 'Pathology' ? Colors.blue : Colors.orange,
            ),
          ),
          SizedBox(width: 10.rw),
          Expanded(
            child: CommonText(name,
                fontSize: 13.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary),
          ),
          CommonText(price,
              fontSize: 14.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildSlots(HealthCheckupsController c) {
    final items = <Widget>[];

    if (c.selectedPathologySlot.value != null) {
      final s = c.selectedPathologySlot.value!;
      items.add(_slotRow('Pathology', s.slotDate, s.displayTime));
    }
    if (c.selectedRadiologySlot.value != null) {
      final s = c.selectedRadiologySlot.value!;
      items.add(_slotRow('Radiology', s.slotDate, s.displayTime));
    }

    if (items.isEmpty) {
      return CommonText('No slots selected',
          fontSize: 13.rf, color: AppColors.textSecondary);
    }

    return Column(children: items);
  }

  Widget _slotRow(String category, String date, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rh),
      child: Row(
        children: [
          Icon(Icons.event_outlined,
              size: 16.rs, color: AppColors.textSecondary),
          SizedBox(width: 8.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  category,
                  fontSize: 11.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                CommonText(
                  '$date  •  $time',
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddress() {
    final ac = Get.find<AddressController>();
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              ac.displayLabel,
              fontSize: 14.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 4.rh),
            CommonText(
              ac.displayAddress,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ],
        ));
  }
}
