import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/pharmacy%20controllers/pharmacy_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/pharmacy%20models/flip_health_prescription_model.dart';
import 'package:flip_health/views/pharmacy/pharmacy_prescription_detail_screen.dart';

class PharmacyPrescriptionScreen extends StatefulWidget {
  const PharmacyPrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<PharmacyPrescriptionScreen> createState() =>
      _PharmacyPrescriptionScreenState();
}

class _PharmacyPrescriptionScreenState
    extends State<PharmacyPrescriptionScreen> {
  final controller = Get.find<PharmacyController>();
  CardSwiperController? _swiperController;
  final _currentIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    if (controller.prescriptionSource.value == 'FLIPHEALTH') {
      _swiperController = CardSwiperController();
    }
  }

  @override
  void dispose() {
    _swiperController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFlipHealth =
          controller.prescriptionSource.value == 'FLIPHEALTH';

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: CommonAppBar.build(
          title: isFlipHealth
              ? AppString.kSelectPrescription
              : AppString.kUploadPrescriptionTitle,
        ),
        body: Column(
          children: [
            _buildMemberBanner(),
            Expanded(
              child: isFlipHealth
                  ? _buildFlipHealthSection()
                  : _buildUploadSection(),
            ),
            _buildBottomAction(isFlipHealth),
          ],
        ),
      );
    });
  }

  Widget _buildMemberBanner() {
    return Obx(() {
      final m = controller.selectedMember;
      if (m == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.fromLTRB(20.rs, 12.rs, 20.rs, 0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.rs, vertical: 10.rh),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 22.rs, color: AppColors.primary),
              SizedBox(width: 10.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      AppString.kOrderingFor,
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                    ),
                    CommonText(
                      m.name,
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ===================== Upload Prescription Section =====================

  Widget _buildUploadSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.rs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUploadArea(),
          SizedBox(height: 24.rh),
          _buildAddButton(),
          SizedBox(height: 24.rh),
          CommonText(
            AppString.kSelectedFiles,
            fontSize: 16.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 16.rh),
          _buildUploadedFilesList(),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: controller.pickFile,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.rs)),
              child: Image.asset(
                AppString.kUploadPrescriptionImage,
                height: 140.rh,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.rw, 12.rh, 20.rw, 20.rh),
              child: Column(
                children: [
                  CommonText(
                    'Tap to upload prescription',
                    fontSize: 15.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 4.rh),
                  CommonText(
                    AppString.kPrescriptionIsSafe,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: controller.pickFile,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.rh),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(12.rs),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                size: 20.rs, color: AppColors.primary),
            SizedBox(width: 8.rw),
            CommonText(
              AppString.kAddPrescription,
              fontSize: 14.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFilesList() {
    return Obx(() {
      if (controller.uploadedFiles.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 40.rh),
          child: Column(
            children: [
              Icon(Icons.image_not_supported_outlined,
                  size: 48.rs, color: AppColors.borderLight),
              SizedBox(height: 12.rh),
              CommonText(
                AppString.kNoFilesSelected,
                fontSize: 14.rf,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.rw,
          mainAxisSpacing: 12.rh,
        ),
        itemCount: controller.uploadedFiles.length,
        itemBuilder: (context, index) {
          final entry = controller.uploadedFiles[index];
          return _buildFileCard(entry, index);
        },
      );
    });
  }

  Widget _buildFileCard(UploadedFile entry, int index) {
    return Obx(() {
      final state = entry.state.value;
      final file = entry.fileInfo;

      return Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(12.rs),
              border: Border.all(
                color: state == UploadState.success
                    ? AppColors.success
                    : state == UploadState.failed
                        ? AppColors.error
                        : AppColors.borderLight,
                width: state == UploadState.uploading ? 0.5 : 1.5,
              ),
            ),
            child: file.isImage && file.path.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.rs),
                    child: Image.file(
                      File(file.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          _buildFileFallback(file.name),
                    ),
                  )
                : _buildFileFallback(file.name),
          ),
          if (state == UploadState.uploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12.rs),
                ),
                child: Center(
                  child: SizedBox(
                    width: 24.rs,
                    height: 24.rs,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          if (state == UploadState.success)
            Positioned(
              bottom: 4.rh,
              right: 4.rw,
              child: Container(
                padding: EdgeInsets.all(2.rs),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 12.rs),
              ),
            ),
          if (state == UploadState.failed)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => controller.retryUpload(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.rs),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 24.rs),
                      SizedBox(height: 4.rh),
                      CommonText(
                        'Retry',
                        fontSize: 10.rf,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 4.rh,
            right: 4.rw,
            child: GestureDetector(
              onTap: () => controller.removeUploadedFile(index),
              child: Container(
                width: 22.rs,
                height: 22.rs,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 14.rs),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFileFallback(String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 32.rs, color: AppColors.textSecondary),
          SizedBox(height: 6.rh),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.rw),
            child: CommonText(
              name,
              fontSize: 9.rf,
              color: AppColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Flip Health Prescription Section =====================

  Widget _buildFlipHealthSection() {
    return Obx(() {
      if (controller.prescriptionsLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.rh),
              CommonText(
                AppString.kLoadingPrescriptions,
                fontSize: 14.rf,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      }

      if (controller.prescriptions.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.rw),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppString.kFlipHealthPrescriptionImage,
                  height: 160.rh,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20.rh),
                CommonText(
                  AppString.kNoPrescriptionsAvailable,
                  fontSize: 15.rf,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return _FlipHealthSwiperContent(
        key: ValueKey(controller.prescriptions.length),
        prescriptions: controller.prescriptions.toList(),
        pharmacyController: controller,
        swiperController: _swiperController!,
        currentIndex: _currentIndex,
      );
    });
  }

  // ===================== Bottom Action =====================

  Widget _buildBottomAction(bool isFlipHealth) {
    if (isFlipHealth) return const SizedBox.shrink();

    return Obx(() {
      final canPlace = controller.canPlaceUploadOrder;
      final isOrdering = controller.isOrdering.value;

      if (!canPlace && !isOrdering) return const SizedBox.shrink();

      return SafeBottomPadding(
        child: ActionButton(
          text: AppString.kPlaceOrder,
          isLoading: isOrdering,
          onPressed: isOrdering ? () {} : controller.placeUploadOrder,
        ),
      );
    });
  }
}

class _FlipHealthSwiperContent extends StatefulWidget {
  final List<FlipHealthPrescription> prescriptions;
  final PharmacyController pharmacyController;
  final CardSwiperController swiperController;
  final RxInt currentIndex;

  const _FlipHealthSwiperContent({
    Key? key,
    required this.prescriptions,
    required this.pharmacyController,
    required this.swiperController,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<_FlipHealthSwiperContent> createState() =>
      _FlipHealthSwiperContentState();
}

class _FlipHealthSwiperContentState extends State<_FlipHealthSwiperContent> {
  List<FlipHealthPrescription> get prescriptions => widget.prescriptions;
  PharmacyController get controller => widget.pharmacyController;

  void _openDetail(FlipHealthPrescription prescription) {
    controller.fetchPrescriptionDetail(prescription.id);
    Get.to(() => const PharmacyPrescriptionDetailScreen());
  }

  @override
  Widget build(BuildContext context) {
    return ShakeX(
        duration: const Duration(milliseconds: 800),

      child: Column(
        children: [
          SizedBox(height: 8.rh),
          _buildSwiperIndicator(),
          SizedBox(height: 4.rh),
          Expanded(
            child: CardSwiper(
              controller: widget.swiperController,
              cardsCount: prescriptions.length,
              numberOfCardsDisplayed:
                  prescriptions.length < 3 ? prescriptions.length : 3,
              scale: 0.92,
              padding:
                  EdgeInsets.symmetric(horizontal: 24.rw, vertical: 16.rh),
              isLoop: true,
              allowedSwipeDirection: AllowedSwipeDirection.symmetric(
                horizontal: true,
                vertical: false,
              ),
              onSwipe: (prev, curr, direction) {
                widget.currentIndex.value = curr ?? 0;
                return true;
              },
              cardBuilder:
                  (context, index, percentThresholdX, percentThresholdY) {
                return _buildSwiperCard(prescriptions[index]);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.rh),
            child: CommonText(
              'Tap a card to view details & place order',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiperIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.swipe, size: 16.rs, color: AppColors.textSecondary),
        SizedBox(width: 6.rw),
        CommonText(
          'Swipe to browse  ',
          fontSize: 12.rf,
          color: AppColors.textSecondary,
        ),
        Obx(() => CommonText(
              '${widget.currentIndex.value + 1} / ${prescriptions.length}',
              fontSize: 12.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )),
      ],
    );
  }

  Widget _buildSwiperCard(FlipHealthPrescription prescription) {
    final doctor = prescription.appointment?.doctor;
    final medicines = [
      ...prescription.details.chronic,
      ...prescription.details.others,
    ];

    return GestureDetector(
      onTap: () => _openDetail(prescription),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.rs),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.rs),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20.rs)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.rs,
                    height: 48.rs,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.rs),
                    ),
                    child: Icon(Icons.person_outlined,
                        size: 26.rs, color: AppColors.primary),
                  ),
                  SizedBox(width: 12.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          doctor != null
                              ? 'Dr. ${doctor.name}'
                              : 'Prescription',
                          fontSize: 16.rf,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        if (doctor?.speciality != null) ...[
                          SizedBox(height: 2.rh),
                          CommonText(
                            doctor!.speciality!.name,
                            fontSize: 13.rf,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16.rs, color: AppColors.textSecondary),
                ],
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
              child: Row(
                children: [
                  _buildInfoChip(Icons.calendar_today_outlined,
                      prescription.createdAtDate),
                  SizedBox(width: 10.rw),
                  _buildInfoChip(Icons.medication_outlined,
                      '${prescription.medicineCount} ${AppString.kMedicineCount}'),
                  if (prescription.isChronic) ...[
                    SizedBox(width: 10.rw),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.rw, vertical: 4.rh),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.rs),
                      ),
                      child: CommonText(
                        AppString.kChronic,
                        fontSize: 10.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(
                color: AppColors.borderLight,
                height: 1,
                indent: 16.rw,
                endIndent: 16.rw),
            Expanded(
              child: medicines.isEmpty
                  ? Center(
                      child: CommonText(
                        'No medicines listed',
                        fontSize: 13.rf,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.rw, vertical: 10.rh),
                      itemCount:
                          medicines.length > 4 ? 4 : medicines.length,
                      itemBuilder: (context, i) {
                        if (i == 3 && medicines.length > 4) {
                          return Padding(
                            padding: EdgeInsets.only(top: 4.rh),
                            child: CommonText(
                              '+${medicines.length - 3} more medicines',
                              fontSize: 12.rf,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          );
                        }
                        return _buildMedicinePreviewRow(medicines[i]);
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.all(14.rs),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20.rs)),
              ),
              child: GestureDetector(
                onTap: () => _openDetail(prescription),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.rh),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.rs),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 16.rs, color: Colors.white),
                      SizedBox(width: 8.rw),
                      CommonText(
                        'View Details & Order',
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6.rw),
                      Icon(Icons.arrow_forward_rounded,
                          size: 16.rs, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 4.rh),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(8.rs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.rs, color: AppColors.textSecondary),
          SizedBox(width: 4.rw),
          CommonText(text, fontSize: 11.rf, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildMedicinePreviewRow(MedicineItem medicine) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rh),
      child: Row(
        children: [
          Container(
            width: 32.rs,
            height: 32.rs,
            decoration: BoxDecoration(
              color: medicine.isChronic
                  ? AppColors.warning.withValues(alpha: 0.12)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.rs),
            ),
            child: Icon(
              medicine.type.toLowerCase().contains('injection')
                  ? Icons.vaccines
                  : Icons.medication,
              size: 16.rs,
              color:
                  medicine.isChronic ? AppColors.warning : AppColors.primary,
            ),
          ),
          SizedBox(width: 10.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  medicine.name,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    CommonText(
                      medicine.type,
                      fontSize: 10.rf,
                      color: AppColors.textSecondary,
                    ),
                    if (medicine.days.isNotEmpty &&
                        medicine.days != '0') ...[
                      CommonText(
                        '  ·  ${medicine.days} days',
                        fontSize: 10.rf,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (medicine.hasMorning) _buildDoseDot(AppColors.warning),
              if (medicine.hasAfternoon) _buildDoseDot(AppColors.info),
              if (medicine.hasNight)
                _buildDoseDot(AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoseDot(Color color) {
    return Container(
      width: 8.rs,
      height: 8.rs,
      margin: EdgeInsets.only(left: 3.rw),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
