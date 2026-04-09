import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/consultation%20models/online_doctor_model.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class SelectSpecialityScreen extends GetView<ConsultationController> {
  const SelectSpecialityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: controller.appBarTitle),
      body: Column(
        children: [
          const LocationHeaderBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(),
                  _buildSearchBar(),
                  SizedBox(height: 12.rh),
                  Obx(() => controller.isOnline
                      ? _buildOnlineSection()
                      : _buildOfflineSpecialityList()),
                ],
              ),
            ),
          ),
          Obx(() {
            if (!controller.isOnline) return const SizedBox.shrink();
            if (controller.selectedIssue.value == null) return const SizedBox.shrink();
            if (controller.onlineDoctorsLoading.value) return const SizedBox.shrink();
            if (controller.onlineDoctors.isEmpty) return const SizedBox.shrink();
            return SafeBottomPadding(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.rw, 8.rh, 16.rw, 0),
                child: ActionButton(
                  text: AppString.kContinue,
                  onPressed: controller.continueOnlineFlow,
                ),
              ),
            );
          }),
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
              SizedBox(width: 4.rw),
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
        controller: controller.specialitySearchController,
        onChanged: (q) => controller.isOnline
            ? controller.searchIssues(q)
            : controller.searchOfflineSpecialities(q),
        decoration: InputDecoration(
          hintText: controller.isOnline
              ? AppString.kSearchIssues
              : AppString.kSearchSpecialities,
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

  // ─── Online: Issues grid + inline doctor strip ──────────────

  Widget _buildOnlineSection() {
    return Obx(() {
      if (controller.issuesLoading.value) {
        return Padding(
          padding: EdgeInsets.all(48.rs),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final issues = controller.filteredIssues;
      if (issues.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(32.rs),
          child: Center(
            child: CommonText(
              AppString.kNoIssuesFound,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      const crossAxisCount = 3;
      final selectedId = controller.selectedIssue.value?.id;

      int? selectedRowIndex;
      if (selectedId != null) {
        final idx = issues.indexWhere((i) => i.id == selectedId);
        if (idx >= 0) selectedRowIndex = idx ~/ crossAxisCount;
      }

      final rowCount = (issues.length / crossAxisCount).ceil();
      final children = <Widget>[];

      for (int row = 0; row < rowCount; row++) {
        final start = row * crossAxisCount;
        final end = (start + crossAxisCount).clamp(0, issues.length);
        final rowIssues = issues.sublist(start, end);

        children.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.rw),
            child: Row(
              children: [
                for (int col = 0; col < crossAxisCount; col++) ...[
                  if (col > 0) SizedBox(width: 12.rw),
                  Expanded(
                    child: col < rowIssues.length
                        ? _buildIssueTile(rowIssues[col])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );

        if (row < rowCount - 1) children.add(SizedBox(height: 12.rh));

        if (row == selectedRowIndex) {
          children.add(_buildDoctorStrip());
          if (row < rowCount - 1) children.add(SizedBox(height: 12.rh));
        }
      }

      if (selectedRowIndex == null && selectedId != null) {
        children.add(_buildDoctorStrip());
      }

      children.add(SizedBox(height: 24.rh));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    });
  }

  Widget _buildIssueTile(dynamic issue) {
    return Obx(() {
      final isSelected = controller.selectedIssue.value?.id == issue.id;
      return GestureDetector(
        onTap: () => controller.selectIssue(issue),
        child: AspectRatio(
          aspectRatio: 0.85,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12.rs),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (issue.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.rs),
                    child: Image.network(
                      ApiUrl.publicFileUrl(issue.image) ?? '',
                      height: 48.rs,
                      width: 48.rs,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackIcon(),
                    ),
                  )
                else
                  _fallbackIcon(),
                SizedBox(height: 8.rh),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.rw),
                  child: CommonText(
                    issue.title,
                    fontSize: 11.rf,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDoctorStrip() {
    return Obx(() {
      if (controller.onlineDoctorsLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.rh),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final doctors = controller.onlineDoctors;
      if (doctors.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(20.rs),
          child: Center(
            child: CommonText(
              AppString.kNoDoctorsFound,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14.rs),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.rw, 14.rh, 14.rw, 0),
              child: Row(
                children: [
                  Icon(Icons.people_outline, size: 18.rs, color: AppColors.primary),
                  SizedBox(width: 6.rw),
                  CommonText(
                    'Available Doctors',
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  CommonText(
                    '${doctors.length} found',
                    fontSize: 11.rf,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.rh),
            SizedBox(
              height: 72.rh,
              child: _AutoScrollDoctorList(
                doctors: doctors,
                selectedId: controller.selectedOnlineDoctor.value?.id,
                onSelect: controller.selectOnlineDoctor,
              ),
            ),
            SizedBox(height: 8.rh),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.rw),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14.rs, color: AppColors.textSecondary),
                  SizedBox(width: 6.rw),
                  Expanded(
                    child: CommonText(
                      'We will assign a doctor from the list above',
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.rh),
          ],
        ),
      );
    });
  }

  Widget _fallbackIcon() {
    return Container(
      width: 48.rs,
      height: 48.rs,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.rs),
      ),
      child: Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 24.rs),
    );
  }

  // ─── Offline: Speciality list with prices ───────────────────

  Widget _buildOfflineSpecialityList() {
    return Obx(() {
      if (controller.offlineSpecialitiesLoading.value) {
        return Padding(
          padding: EdgeInsets.all(48.rs),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final specs = controller.filteredOfflineSpecialities;
      if (specs.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(32.rs),
          child: Center(
            child: CommonText(
              'No specialities found',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.rw),
        itemCount: specs.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderLight),
        itemBuilder: (_, index) {
          final spec = specs[index];
          final initial = spec.name.isNotEmpty ? spec.name[0].toUpperCase() : 'S';
          return ListTile(
            onTap: () => controller.selectOfflineSpeciality(spec),
            contentPadding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 4.rh),
            leading: Container(
              width: 40.rs,
              height: 40.rs,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.rs),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 18.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            title: CommonText(
              spec.name,
              fontSize: 13.rf,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.rs),
          );
        },
      );
    });
  }
}

// ─── Compact horizontal doctor chip ──────────────────────────────

class _DoctorChip extends StatelessWidget {
  final OnlineDoctorModel doctor;
 
  const _DoctorChip({
    required this.doctor,

  });

  String get _initials {
    final parts = doctor.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'Dr';
    final first = parts.first.replaceAll(
        RegExp(r'^(Dr\.?|Mr\.?|Ms\.?|Mrs\.?)\s*', caseSensitive: false), '');
    if (first.isEmpty) {
      return parts.length > 1 ? parts[1][0].toUpperCase() : 'D';
    }
    if (parts.length == 1) return first[0].toUpperCase();
    return '${first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get _isFemale => doctor.gender.toLowerCase() == 'female';

  @override
  Widget build(BuildContext context) {
    final gradientColors = _isFemale
        ? [const Color(0xFFE991C3), const Color(0xFFD45FA0)]
        : [const Color(0xFF6CB4EE), const Color(0xFF3A8FD6)];

    final imageUrl =
        doctor.image != null ? ApiUrl.publicFileUrl(doctor.image!) : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 10.rw),
      padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 8.rh),
      decoration: BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.circular(10.rs),
        border: Border.all(
          color:  AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(imageUrl, gradientColors),
          SizedBox(width: 8.rw),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                doctor.name,
                fontSize: 12.rf,
                fontWeight: FontWeight.w600,
                color:AppColors.textPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.rh),
              CommonText(
                doctor.qualification.isNotEmpty
                    ? doctor.qualification
                    : doctor.specialityName,
                fontSize: 10.rf,
                color: AppColors.textSecondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
         
        ],
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, List<Color> gradientColors) {
    const double size = 36;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: size.rs,
          height: size.rs,
          errorBuilder: (_, __, ___) => _buildFallback(size, gradientColors),
        ),
      );
    }
    return _buildFallback(size, gradientColors);
  }

  Widget _buildFallback(double size, List<Color> gradientColors) {
    return Container(
      width: size.rs,
      height: size.rs,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: CommonText(
          _initials,
          fontSize: (size * 0.34).rf,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Auto-scrolling horizontal doctor list ───────────────────────

class _AutoScrollDoctorList extends StatefulWidget {
  final List<OnlineDoctorModel> doctors;
  final int? selectedId;
  final ValueChanged<OnlineDoctorModel> onSelect;

  const _AutoScrollDoctorList({
    required this.doctors,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  State<_AutoScrollDoctorList> createState() => _AutoScrollDoctorListState();
}

class _AutoScrollDoctorListState extends State<_AutoScrollDoctorList> {
  final ScrollController _scrollController = ScrollController();
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;

    final target = _forward ? max : 0.0;
    final distance = (_scrollController.offset - target).abs();
    final duration = Duration(milliseconds: (distance * 20).toInt().clamp(500, 6000));

    _scrollController
        .animateTo(target, duration: duration, curve: Curves.linear)
        .then((_) {
      if (!mounted) return;
      _forward = !_forward;
      Future.delayed(const Duration(milliseconds: 800), () => _startAutoScroll());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          _scrollController.jumpTo(_scrollController.offset);
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14.rw),
        itemCount: widget.doctors.length,
        itemBuilder: (_, index) {
          final doctor = widget.doctors[index];
          final isSelected = widget.selectedId == doctor.id;
          return _DoctorChip(
            doctor: doctor,
            
       
          );
        },
      ),
    );
  }
}
