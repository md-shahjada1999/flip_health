import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/medical%20records%20controllers/medical_records_controller.dart';
import 'package:flip_health/views/medical_records/widgets/consultation_record_card.dart';
import 'package:flip_health/views/medical_records/widgets/lab_test_record_card.dart';
import 'package:flip_health/views/medical_records/widgets/prescription_record_card.dart';
import 'package:flip_health/views/medical_records/widgets/vital_record_card.dart';
import 'package:flip_health/views/medical_records/widgets/symptom_record_card.dart';
import 'package:flip_health/views/medical_records/widgets/medicine_record_card.dart';
import 'package:flip_health/views/medical_records/widgets/mood_record_card.dart';
import 'package:flip_health/views/medical_records/widgets/measurement_record_card.dart';
import 'package:flip_health/views/medical_records/widgets/condition_record_card.dart';
import 'package:flip_health/views/medical_records/widgets/service_request_card.dart';
import 'package:flip_health/views/medical_records/medical_records_detail_screen.dart';
import 'package:flip_health/views/medical_records/lab_test_detail_screen.dart';
import 'package:flip_health/views/medical_records/prescription_detail_screen.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicalRecordsController>();

    return SafeScreenWrapper(
      appBar: CommonAppBar.build(
        title: AppString.kMedicalRecords,
        showBackButton: false,
      ),
      body: Column(
        children: [
          _CategoryChips(controller: controller),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: AppColors.primary,
              child: _RecordsList(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Category Chips
// ──────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final MedicalRecordsController controller;
  const _CategoryChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.rh,
      padding: EdgeInsets.symmetric(vertical: 8.rh),
      child: Obx(() {
        final selected = controller.selectedCategory.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.rw),
          itemCount: MedicalRecordsController.categories.length,
          itemBuilder: (_, i) {
            final cat = MedicalRecordsController.categories[i];
            final isSelected = cat == selected;
            return GestureDetector(
              onTap: () => controller.selectCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(right: 8.rw),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.rw,
                  vertical: 6.rh,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20.rs),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: CommonText(
                    cat,
                    fontSize: 12.rf,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Records List
// ──────────────────────────────────────────────────────────────

class _RecordsList extends StatelessWidget {
  final MedicalRecordsController controller;
  const _RecordsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final category = controller.selectedCategory.value;
      final isLoading = controller.isLoading.value;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      switch (category) {
        case 'Consultations':
          return _buildConsultationsList();
        case 'Lab Tests':
          return _buildLabTestsList();
        case 'Prescriptions':
          return _buildPrescriptionsList();
        case 'Vitals':
          return _buildVitalsList();
        case 'Symptoms':
          return _buildSymptomsList();
        case 'Medicines':
          return _buildMedicinesList();
        case 'Moods':
          return _buildMoodsList();
        case 'Measurements':
          return _buildMeasurementsList();
        case "Women's":
          return _buildWomensList();
        case 'Conditions':
          return _buildConditionsList();
        case 'Mental Wellness':
          return _buildMentalWellnessList();
        case 'Nutrition':
          return _buildNutritionList();
        default:
          return _buildEmptyState('No records found');
      }
    });
  }

  Widget _buildConsultationsList() {
    final records = controller.consultations;

    if (records.isEmpty) {
      return _buildEmptyState('No consultation records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) {
        final record = records[i];
        return ConsultationRecordCard(
          record: record,
          index: i,
          onTap: () => Get.to(
            () => MedicalRecordsDetailScreen(record: record),
          ),
        );
      },
    );
  }

  Widget _buildLabTestsList() {
    final records = controller.labTests;

    if (records.isEmpty) {
      return _buildEmptyState('No lab test records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) {
        final record = records[i];
        return LabTestRecordCard(
          record: record,
          index: i,
          onTap: () => Get.to(
            () => LabTestDetailScreen(record: record),
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsList() {
    final records = controller.prescriptions;

    if (records.isEmpty) {
      return _buildEmptyState('No prescription records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) {
        final record = records[i];
        return PrescriptionRecordCard(
          record: record,
          index: i,
          onTap: () => Get.to(
            () => PrescriptionDetailScreen(record: record),
          ),
        );
      },
    );
  }

  Widget _buildVitalsList() {
    final records = controller.vitals;

    if (records.isEmpty) {
      return _buildEmptyState('No vital records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) => VitalRecordCard(record: records[i], index: i),
    );
  }

  Widget _buildSymptomsList() {
    final records = controller.symptoms;

    if (records.isEmpty) {
      return _buildEmptyState('No symptom records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) => SymptomRecordCard(record: records[i], index: i),
    );
  }

  Widget _buildMedicinesList() {
    final records = controller.medicines;

    if (records.isEmpty) {
      return _buildEmptyState('No medicine records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) => MedicineRecordCard(record: records[i], index: i),
    );
  }

  Widget _buildMoodsList() {
    final records = controller.moods;

    if (records.isEmpty) {
      return _buildEmptyState('No mood records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) => MoodRecordCard(record: records[i], index: i),
    );
  }

  Widget _buildMeasurementsList() {
    final records = controller.measurements;

    if (records.isEmpty) {
      return _buildEmptyState('No measurement records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) =>
          MeasurementRecordCard(record: records[i], index: i),
    );
  }

  Widget _buildWomensList() {
    final records = controller.womens;

    if (records.isEmpty) {
      return _buildEmptyState("No women's health records found");
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) => SymptomRecordCard(record: records[i], index: i),
    );
  }

  Widget _buildConditionsList() {
    final records = controller.conditions;

    if (records.isEmpty) {
      return _buildEmptyState('No condition records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) =>
          ConditionRecordCard(record: records[i], index: i),
    );
  }

  Widget _buildMentalWellnessList() {
    final records = controller.mentalWellness;

    if (records.isEmpty) {
      return _buildEmptyState('No mental wellness records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) => ServiceRequestCard(
        record: records[i],
        index: i,
        gradientStart: const Color(0xff7C4DFF),
        gradientEnd: const Color(0xffB388FF),
        icon: Icons.psychology_rounded,
      ),
    );
  }

  Widget _buildNutritionList() {
    final records = controller.nutrition;

    if (records.isEmpty) {
      return _buildEmptyState('No nutrition records found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      itemCount: records.length,
      itemBuilder: (_, i) => ServiceRequestCard(
        record: records[i],
        index: i,
        gradientStart: const Color(0xffFF7043),
        gradientEnd: const Color(0xffFFAB91),
        icon: Icons.restaurant_rounded,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 80.rh),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.medical_information_outlined,
                size: 64.rs,
                color: AppColors.iconDisabled,
              ),
              SizedBox(height: 16.rh),
              CommonText(
                message,
                fontSize: 14.rf,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.rh),
              CommonText(
                'Pull down to refresh',
                fontSize: 12.rf,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
