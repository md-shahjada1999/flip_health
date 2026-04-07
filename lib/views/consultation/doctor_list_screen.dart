import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/consultation%20models/network_doctor_model.dart';
import 'package:flip_health/model/consultation%20models/online_doctor_model.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class DoctorListScreen extends GetView<ConsultationController> {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      appBar: CommonAppBar.build(title: controller.appBarTitle),
      body: Column(
        children: [
          if (!controller.isOnline) const LocationHeaderBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(),
                  _buildSearchBar(),
                  SizedBox(height: 12.rh),
                  Obx(() => controller.isOnline
                      ? _buildOnlineDoctorList()
                      : _buildOfflineDoctorList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 12.rh),
          padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 8.rh),
          decoration: BoxDecoration(color: AppColors.textPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonText(
                '${AppString.kConsultTopDoctors} ',
                fontSize: 12.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.cardBackground,
              ),
              Obx(() => CommonText(
                    controller.isOnline ? 'Online' : 'In-Clinic',
                    fontSize: 12.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cardBackground,
                  )),
            ],
          ),
        ),
        Positioned(
          right: 30.rw,
          bottom: 5,
          child: Image.asset(
            'assets/png/doctors_consult.png',
            height: 60.rh,
            width: 60.rw,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw),
      child: TextField(
        controller: controller.doctorSearchController,
        onChanged: (q) => controller.isOnline
            ? controller.searchOnlineDoctors(q)
            : controller.searchNearbyDoctors(q),
        decoration: InputDecoration(
          hintText: 'Search Doctors',
          hintStyle: TextStyle(
            fontSize: 14.rf,
            fontFamily: 'Poppins',
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20.rs),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.rs),
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.rs),
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.rs),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineDoctorList() {
    return Obx(() {
      if (controller.onlineDoctorsLoading.value) {
        return Padding(
          padding: EdgeInsets.all(48.rs),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final doctors = controller.filteredOnlineDoctors;
      if (doctors.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(32.rs),
          child: Center(
            child: CommonText(
              AppString.kNoDoctorsFound,
              fontSize: 14.rf,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 32.rh),
        itemCount: doctors.length,
        itemBuilder: (_, index) {
          final doctor = doctors[index];
          return _OnlineDoctorCard(
            doctor: doctor,
            onBook: () => controller.selectOnlineDoctor(doctor),
          );
        },
      );
    });
  }

  Widget _buildOfflineDoctorList() {
    return Obx(() {
      if (controller.nearbyDoctorsLoading.value) {
        return Padding(
          padding: EdgeInsets.all(48.rs),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final doctors = controller.filteredNearbyDoctors;
      if (doctors.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(32.rs),
          child: Center(
            child: CommonText(
              AppString.kNoDoctorsFound,
              fontSize: 14.rf,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 32.rh),
        itemCount: doctors.length,
        itemBuilder: (_, index) {
          final doctor = doctors[index];
          return _OfflineDoctorCard(
            doctor: doctor,
            onBook: () => controller.selectNetworkDoctor(doctor),
          );
        },
      );
    });
  }
}

// ─── Illustrated Doctor Avatar ─────────────────────────────────

class _DoctorAvatar extends StatelessWidget {
  final String name;
  final String gender;
  final String? imageUrl;

  static const double size = 56;

  const _DoctorAvatar({
    required this.name,
    required this.gender,
    this.imageUrl,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'Dr';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    final first = parts.first.replaceAll(RegExp(r'^(Dr\.?|Mr\.?|Ms\.?|Mrs\.?)\s*', caseSensitive: false), '');
    if (first.isEmpty) {
      return parts.length > 1 ? parts[1][0].toUpperCase() : 'D';
    }
    final last = parts.last;
    return '${first[0]}${last[0]}'.toUpperCase();
  }

  bool get _isFemale => gender.toLowerCase() == 'female';

  List<Color> get _gradientColors => _isFemale
      ? [const Color(0xFFE991C3), const Color(0xFFD45FA0)]
      : [const Color(0xFF6CB4EE), const Color(0xFF3A8FD6)];

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: size.rs,
          height: size.rs,
          errorBuilder: (_, __, ___) => _buildIllustration(),
        ),
      );
    }
    return _buildIllustration();
  }

  Widget _buildIllustration() {
    return Container(
      width: size.rs,
      height: size.rs,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: _gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 8.rs,
            offset: Offset(0, 3.rs),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body silhouette
          Positioned(
            bottom: 0,
            child: Container(
              width: size.rs * 0.7,
              height: size.rs * 0.35,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.rs * 0.35),
                  topRight: Radius.circular(size.rs * 0.35),
                ),
              ),
            ),
          ),
          // Head circle
          Positioned(
            top: size.rs * 0.1,
            child: Container(
              width: size.rs * 0.36,
              height: size.rs * 0.36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
          // Initials
          CommonText(
            _initials,
            fontSize: (size * 0.32).rf,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          // Stethoscope badge
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: (size * 0.34).rs,
              height: (size * 0.34).rs,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _gradientColors.last, width: 1.5),
              ),
              child: Icon(
                Icons.medical_services_rounded,
                size: (size * 0.18).rs,
                color: _gradientColors.last,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compact Book Button ────────────────────────────────────────

class _CompactBookButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CompactBookButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.rw, 4.rh, 16.rw, 12.rh),
      child: SizedBox(
        width: double.infinity,
        height: 40.rh,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.rs),
            ),
          ),
          child: CommonText(
            AppString.kBookAppointment,
            fontSize: 13.rf,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Online Doctor Card ──────────────────────────────────────

class _OnlineDoctorCard extends StatelessWidget {
  final OnlineDoctorModel doctor;
  final VoidCallback onBook;

  const _OnlineDoctorCard({required this.doctor, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final imageUrl = doctor.image != null ? ApiUrl.publicFileUrl(doctor.image!) : null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 6.rh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.rw, 14.rh, 16.rw, 12.rh),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DoctorAvatar(
                  name: doctor.name,
                  gender: doctor.gender,
                  imageUrl: imageUrl,
                ),
                SizedBox(width: 14.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        doctor.name,
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(height: 2.rh),
                      CommonText(
                        doctor.qualification,
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                      ),
                      if (doctor.specialityName.isNotEmpty) ...[
                        SizedBox(height: 2.rh),
                        CommonText(
                          doctor.specialityName,
                          fontSize: 11.rf,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textPrimary, size: 22.rs),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderLight),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
            child: Row(
              children: [
                if (doctor.experience.isNotEmpty)
                  _buildTag(Icons.work_outline, doctor.experience, AppColors.primary),
                if (doctor.experience.isNotEmpty && doctor.languageList.isNotEmpty)
                  SizedBox(width: 10.rw),
                if (doctor.languageList.isNotEmpty)
                  _buildTag(Icons.language, doctor.languageList.join(', '), Colors.blue),
              ],
            ),
          ),
          if (doctor.nextAvailableTime != null) ...[
            Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    AppString.kNextAvailable,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                  ),
                  CommonText(
                    doctor.nextAvailableTime!,
                    fontSize: 12.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ],
          _CompactBookButton(onPressed: onBook),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 6.rh),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.rs),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.rs, color: color),
            SizedBox(width: 6.rw),
            Flexible(
              child: CommonText(
                label,
                fontSize: 11.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Offline Doctor Card ──────────────────────────────────────

class _OfflineDoctorCard extends StatelessWidget {
  final NetworkDoctorModel doctor;
  final VoidCallback onBook;

  const _OfflineDoctorCard({required this.doctor, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 6.rh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.rw, 14.rh, 16.rw, 12.rh),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DoctorAvatar(
                  name: doctor.name,
                  gender: doctor.gender,
                ),
                SizedBox(width: 14.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        doctor.name,
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(height: 2.rh),
                      CommonText(
                        doctor.qualification,
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                      ),
                      if (doctor.specialities.isNotEmpty) ...[
                        SizedBox(height: 2.rh),
                        CommonText(
                          doctor.specialities.join(', '),
                          fontSize: 11.rf,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textPrimary, size: 22.rs),
              ],
            ),
          ),
          if (doctor.network != null) ...[
            Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
              child: Row(
                children: [
                  Icon(Icons.local_hospital_outlined, size: 16.rs, color: AppColors.success),
                  SizedBox(width: 8.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          doctor.network!.name,
                          fontSize: 12.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (doctor.network!.displayAddress.isNotEmpty)
                          CommonText(
                            doctor.network!.displayAddress,
                            fontSize: 11.rf,
                            color: AppColors.textSecondary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (doctor.experience.isNotEmpty) ...[
            Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
              child: Row(
                children: [
                  Icon(Icons.work_outline, size: 14.rs, color: AppColors.textSecondary),
                  SizedBox(width: 6.rw),
                  CommonText(
                    '${doctor.experience} yrs experience',
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
          _CompactBookButton(onPressed: onBook),
        ],
      ),
    );
  }
}
