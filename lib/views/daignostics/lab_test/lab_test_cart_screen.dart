import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/views/daignostics/widgets/cart_bottom_bar.dart';

class LabTestCartScreen extends GetView<LabTestController> {
  const LabTestCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
        title: 'Cart Overview',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.cartTests.isEmpty) {
                return _buildEmptyState();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.rs, 16.rs, 20.rs, 12.rs),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 18.rs, color: AppColors.textSecondary),
                        SizedBox(width: 8.rw),
                        CommonText(
                          'Order info',
                          fontSize: 14.rf,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.rs),
                      itemCount: controller.cartTests.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(controller.cartTests[index]);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
          Obx(() => CartBottomBar(
                itemCount: controller.cartTests.length,
                actionLabel: 'Continue',
                actionIcon: Icons.arrow_forward_ios,
                onActionTap: controller.goToLabSelection,
              )),
        ],
      ),
    );
  }

  Widget _buildCartItem(LabTestModel test) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.rh),
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
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
                SizedBox(height: 4.rh),
                CommonText(
                  test.reportTime,
                  fontSize: 12.rf,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.rw),
          GestureDetector(
            onTap: () => controller.removeFromCart(test),
            child: Icon(
              Icons.delete_outline,
              size: 22.rs,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 16.rw),
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.edit_outlined,
              size: 22.rs,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64.rs,
            color: AppColors.textQuaternary,
          ),
          SizedBox(height: 16.rh),
          CommonText(
            'Your cart is empty',
            fontSize: 18.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 8.rh),
          CommonText(
            'Add tests to get started',
            fontSize: 14.rf,
            color: AppColors.textQuaternary,
          ),
        ],
      ),
    );
  }
}
