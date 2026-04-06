import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/vaccine%20controllers/vaccine_controller.dart';
import 'package:flip_health/model/vvd%20models/vaccine_type_model.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/vaccine/vaccine_slot_selection_screen.dart';

class VaccineTypesScreen extends GetView<VaccineController> {
  const VaccineTypesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: AppString.kChooseVaccineType),
      body: Column(
        children: [
          const LocationHeaderBar(),
          Expanded(
            child: Obx(() {
              if (controller.vaccineTypes.isEmpty) {
                return Center(
                  child: CommonText(
                    'No vaccine types available',
                    fontSize: 14.rf,
                    color: AppColors.textSecondary,
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(18.rs),
                itemCount: controller.vaccineTypes.length,
                itemBuilder: (context, index) {
                  final vaccine = controller.vaccineTypes[index];
                  return _VaccineTypeCard(
                    vaccine: vaccine,
                    index: index,
                  );
                },
              );
            }),
          ),
          Obx(() {
            final count = controller.selectedVaccineIds.length;
            if (count == 0) return const SizedBox.shrink();
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.rw, vertical: 8.rh),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 18.rs),
                      SizedBox(width: 8.rw),
                      CommonText(
                        '${AppString.kSelectedVaccines}: $count',
                        fontSize: 13.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                SafeBottomPadding(
                  child: ActionButton(
                    text: AppString.kContinue,
                    onPressed: () {
                      controller.continueToSlots();
                      Get.to(() => const VaccineSlotSelectionScreen());
                    },
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _VaccineTypeCard extends StatefulWidget {
  final VaccineType vaccine;
  final int index;

  const _VaccineTypeCard({
    required this.vaccine,
    required this.index,
  });

  @override
  State<_VaccineTypeCard> createState() => _VaccineTypeCardState();
}

class _VaccineTypeCardState extends State<_VaccineTypeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final delay = widget.index * 0.08;
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Interval(delay.clamp(0.0, 0.6), 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval(delay.clamp(0.0, 0.6), 1.0, curve: Curves.easeOutCubic),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VaccineController>();

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Obx(() {
          final isSelected = controller.isVaccineSelected(widget.vaccine.id);
          return GestureDetector(
            onTap: () => controller.toggleVaccine(widget.vaccine.id),
            child: Container(
              margin: EdgeInsets.only(bottom: 12.rh),
              padding: EdgeInsets.all(16.rs),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.rs),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 42.rs,
                    height: 42.rs,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(12.rs),
                    ),
                    child: Icon(
                      Icons.vaccines,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: 22.rs,
                    ),
                  ),
                  SizedBox(width: 14.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          widget.vaccine.name,
                          fontSize: 15.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 2.rh),
                        CommonText(
                          widget.vaccine.serviceType,
                          fontSize: 12.rf,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 24.rs,
                    height: 24.rs,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(6.rs),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 18.rs)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
