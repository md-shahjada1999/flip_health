import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';

class LabTestCartScreen extends StatefulWidget {
  const LabTestCartScreen({super.key});

  @override
  State<LabTestCartScreen> createState() => _LabTestCartScreenState();
}

class _LabTestCartScreenState extends State<LabTestCartScreen> {
  late final LabTestController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LabTestController>();
    controller.fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Your Cart',
        showBackButton: true,
        actions: [
          Obx(() => controller.cartItemCount > 0
              ? GestureDetector(
                  onTap: () => _showClearConfirmation(context),
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.rw),
                    child: Center(
                      child: CommonText(
                        'Clear all',
                        fontSize: 12.rf,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        final cart = controller.cart.value;

        if (controller.isCartLoading.value && cart == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (cart == null || cart.items.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.rs, 8.rh, 16.rs, 16.rh),
                children: [
                  CommonText(
                    '${cart.itemCount} test${cart.itemCount != 1 ? 's' : ''} in cart',
                    fontSize: 12.rf,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 12.rh),
                  ...List.generate(cart.items.length, (i) {
                    return FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      delay: Duration(milliseconds: 40 * i),
                      child: _CartItemCard(
                        item: cart.items[i],
                        controller: controller,
                      ),
                    );
                  }),
                ],
              ),
            ),
            SafeBottomPadding(
              child: ActionButton(
                text: 'Continue',
                onPressed: controller.goToVendorSelection,
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.rs)),
        title: CommonText('Clear Cart?', fontSize: 16.rf, fontWeight: FontWeight.w600),
        content: CommonText(
          'Remove all items from your cart?',
          fontSize: 13.rf,
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CommonText('Cancel', fontSize: 13.rf, color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearCart();
            },
            child: CommonText('Clear', fontSize: 13.rf, color: AppColors.error, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 56.rs, color: AppColors.textQuaternary),
            SizedBox(height: 16.rh),
            CommonText(
              'Your cart is empty',
              fontSize: 16.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 6.rh),
            CommonText(
              'Browse and add lab tests to continue',
              fontSize: 13.rf,
              color: AppColors.textQuaternary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final LabCartItem item;
  final LabTestController controller;

  const _CartItemCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.rw),
        margin: EdgeInsets.only(bottom: 8.rh),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12.rs),
        ),
        child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22.rs),
      ),
      onDismissed: (_) {
        final productId = int.tryParse(item.productId) ?? 0;
        controller.removeFromCart(item.id, productId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.rh),
        padding: EdgeInsets.all(14.rs),
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
                    item.product?.name ?? 'Test #${item.productId}',
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    height: 1.3,
                  ),
                  SizedBox(height: 4.rh),
                  Row(
                    children: [
                      if (item.product != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.rw, vertical: 2.rh),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundTertiary,
                            borderRadius: BorderRadius.circular(4.rs),
                          ),
                          child: CommonText(
                            item.product!.category,
                            fontSize: 10.rf,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (item.free) ...[
                        SizedBox(width: 6.rw),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.rw, vertical: 2.rh),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(4.rs),
                          ),
                          child: CommonText(
                            'FREE',
                            fontSize: 10.rf,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.rw),
            GestureDetector(
              onTap: () {
                final productId = int.tryParse(item.productId) ?? 0;
                controller.removeFromCart(item.id, productId);
              },
              child: Container(
                padding: EdgeInsets.all(6.rs),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(8.rs),
                ),
                child: Icon(Icons.close_rounded, size: 16.rs, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
