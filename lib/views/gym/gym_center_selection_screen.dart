import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/gym%20controllers/gym_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/gym/gym_overview_screen.dart';

class GymCenterSelectionScreen extends GetView<GymController> {
  const GymCenterSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: AppString.kSelectCityAndCenter),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.rs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    AppString.kSelectCity,
                    fontSize: 16.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 14.rh),
                  Obx(() => Wrap(
                        spacing: 10.rw,
                        runSpacing: 10.rh,
                        children: controller.cities
                            .map((city) => _CityChip(city: city))
                            .toList(),
                      )),
                  SizedBox(height: 28.rh),
                  Obx(() {
                    if (controller.selectedCity.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          AppString.kSelectGymCenter,
                          fontSize: 16.rf,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 14.rh),
                        if (controller.centersLoading.value)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.rs),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        else if (controller.centers.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.rs),
                              child: CommonText(
                                AppString.kNoCentersFound,
                                fontSize: 14.rf,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        else
                          ...List.generate(
                            controller.centers.length,
                            (index) => _CenterCard(
                              center: controller.centers[index],
                              index: index,
                            ),
                          ),
                      ],
                    );
                  }),
                  SizedBox(height: 80.rh),
                ],
              ),
            ),
          ),
          Obx(() => controller.selectedCenterId.value.isNotEmpty
              ? SafeBottomPadding(
                  child: ActionButton(
                    text: AppString.kContinue,
                    onPressed: () => Get.to(() => const GymOverviewScreen()),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String city;
  const _CityChip({required this.city});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GymController>();
    return Obx(() {
      final isSelected = controller.selectedCity.value == city;
      return GestureDetector(
        onTap: () => controller.selectCity(city),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(horizontal: 18.rw, vertical: 10.rh),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textPrimary : AppColors.surface,
            borderRadius: BorderRadius.circular(24.rs),
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : AppColors.border,
              width: 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_city,
                size: 16.rs,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              SizedBox(width: 6.rw),
              CommonText(
                city,
                fontSize: 13.rf,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _CenterCard extends StatefulWidget {
  final GymCenter center;
  final int index;
  const _CenterCard({required this.center, required this.index});

  @override
  State<_CenterCard> createState() => _CenterCardState();
}

class _CenterCardState extends State<_CenterCard>
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
    final delay = (widget.index * 0.1).clamp(0.0, 0.5);
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Interval(delay, 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
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
    final controller = Get.find<GymController>();
    final center = widget.center;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Obx(() {
          final isSelected = controller.selectedCenterId.value == center.id;
          return GestureDetector(
            onTap: () => controller.selectCenter(center.id),
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
                    width: 42.rs,
                    height: 42.rs,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(12.rs),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: 20.rs,
                    ),
                  ),
                  SizedBox(width: 14.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          center.name,
                          fontSize: 14.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 3.rh),
                        CommonText(
                          center.address,
                          fontSize: 12.rf,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 24.rs,
                        height: 24.rs,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(6.rs),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 16.rs)
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: 6.rh),
                      CommonText(
                        '${center.distance} km',
                        fontSize: 10.rf,
                        color: AppColors.textSecondary,
                      ),
                    ],
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
