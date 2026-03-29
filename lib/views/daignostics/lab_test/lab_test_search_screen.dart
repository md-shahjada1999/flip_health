import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/views/daignostics/widgets/cart_bottom_bar.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/daignostics/widgets/my_orders_button.dart';

class LabTestSearchScreen extends GetView<LabTestController> {
  const LabTestSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
        title: 'Lab Tests',
        showBackButton: true,
        actions: [const MyOrdersButton()],
      ),
      body: Column(
        children: [
          const LocationHeaderBar(),
          SizedBox(height: 12.rh),
          _buildSearchField(),
          SizedBox(height: 12.rh),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.rs),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(() => CommonText(
                    controller.searchQuery.value.isEmpty
                        ? 'Top Searches'
                        : 'Search Results',
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  )),
            ),
          ),
          SizedBox(height: 8.rh),
          const Divider(height: 1, color: AppColors.borderLight),
          Expanded(
            child: Obx(() => ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: controller.searchResults.length,
                  separatorBuilder: (_, __) =>
                      FadeInUp(child: const Divider(height: 1, color: AppColors.borderLight)),
                  itemBuilder: (context, index) {
                    final test = controller.searchResults[index];
                    return _buildTestTile(test);
                  },
                )),
          ),
          Obx(() => CartBottomBar(
                itemCount: controller.cartTests.length,
                actionLabel: 'View cart',
                actionIcon: Icons.shopping_cart_outlined,
                onActionTap: controller.goToCart,
              )),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rs),
      child: Container(
        height: 48.rh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.rs),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: TextField(
          controller: controller.searchTextController,
          onChanged: controller.onSearchChanged,
          autofocus: true,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.rf,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search and book lab tests',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.rf,
              color: AppColors.textQuaternary,
            ),
            prefixIcon:
                Icon(Icons.search, color: AppColors.textTertiary, size: 22.rs),
            suffixIcon:
                Icon(Icons.mic, color: AppColors.primary, size: 22.rs),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.rs),
          ),
        ),
      ),
    );
  }

  Widget _buildTestTile(LabTestModel test) {
    return FadeInUp(
      child: Obx(() {
        final isSelected = controller.isInCart(test.id);
        return InkWell(
          onTap: () => controller.toggleTestInCart(test),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.rs, vertical: 14.rs),
            child: Row(
              children: [
                Container(
                  width: 40.rw,
                  height: 40.rh,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(8.rs),
                  ),
                  child: Icon(
                    Icons.science_outlined,
                    size: 20.rs,
                    color: AppColors.textTertiary,
                  ),
                ),
                SizedBox(width: 14.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        test.name,
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      SizedBox(height: 2.rh),
                      CommonText(
                        test.reportTime,
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.rw),
                Container(
                  width: 24.rs,
                  height: 24.rs,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.black : AppColors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4.rs),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 16.rs, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
