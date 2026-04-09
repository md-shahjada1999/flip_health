import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/daignostics/widgets/my_orders_button.dart';

class LabTestSearchScreen extends GetView<LabTestController> {
  const LabTestSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Search Tests',
        showBackButton: true,
        actions: [const MyOrdersButton()],
      ),
      body: Column(
        children: [
          const LocationHeaderBar(),
          _buildSearchField(),
          Expanded(
            child: Obx(() {
              if (controller.isSearchLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.searchQuery.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_rounded, size: 40.rs, color: AppColors.textQuaternary),
                      SizedBox(height: 12.rh),
                      CommonText('Search for tests, packages...', fontSize: 13.rf, color: AppColors.textSecondary),
                    ],
                  ),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, size: 40.rs, color: AppColors.textQuaternary),
                      SizedBox(height: 12.rh),
                      CommonText('No results found', fontSize: 13.rf, color: AppColors.textSecondary),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.only(bottom: 80.rh),
                itemCount: controller.searchResults.length,
                itemBuilder: (_, index) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 120),
                    child: _buildTestTile(controller.searchResults[index]),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.rs, 8.rh, 16.rs, 6.rh),
      child: Container(
        height: 42.rh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.rs),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: TextField(
          controller: controller.searchTextController,
          onChanged: controller.onSearchChanged,
          autofocus: true,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13.rf, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search lab tests...',
            hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13.rf, color: AppColors.textQuaternary),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textQuaternary, size: 20.rs),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.rs),
          ),
        ),
      ),
    );
  }

  Widget _buildTestTile(LabTest test) {
    return Obx(() {
      final inCart = controller.isInCart(test.id);
      return InkWell(
        onTap: () => controller.toggleCart(test.id),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.rs, vertical: 12.rs),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 36.rs,
                height: 36.rs,
                decoration: BoxDecoration(
                  color: inCart ? AppColors.primary.withValues(alpha: 0.08) : AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(8.rs),
                ),
                child: Icon(Icons.science_outlined, size: 18.rs,
                    color: inCart ? AppColors.primary : AppColors.textTertiary),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(test.name, fontSize: 13.rf, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary, maxLines: 2, overflow: TextOverflow.ellipsis, height: 1.3),
                    SizedBox(height: 3.rh),
                    Wrap(
                      spacing: 6.rw,
                      runSpacing: 2.rh,
                      children: [
                        CommonText(test.fastingLabel, fontSize: 10.5.rf, color: AppColors.textTertiary, height: 1.4),
                        if (test.tatLabel.isNotEmpty)
                          CommonText(test.tatLabel, fontSize: 10.5.rf, color: AppColors.textTertiary, height: 1.4),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.rw),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22.rs,
                height: 22.rs,
                decoration: BoxDecoration(
                  color: inCart ? Colors.black : Colors.transparent,
                  border: Border.all(color: inCart ? Colors.black : AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(4.rs),
                ),
                child: inCart ? Icon(Icons.check_rounded, size: 14.rs, color: Colors.white) : null,
              ),
            ],
          ),
        ),
      );
    });
  }
}
