import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/controllers/orders%20controllers/orders_controller.dart';
import 'package:flip_health/views/orders/widgets/order_card.dart';
import 'package:flip_health/views/orders/order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: AppString.kMyOrdersTitle),
      body: Column(
        children: [
          _FilterChipsRow(controller: controller),
          SizedBox(height: 8.rh),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredOrders.isEmpty) {
                return _EmptyState(
                  filter: controller.selectedFilter.value,
                );
              }
              return ListView.builder(
                key: ValueKey(controller.selectedFilter.value),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.rw,
                  vertical: 8.rh,
                ),
                itemCount: controller.filteredOrders.length,
                itemBuilder: (_, i) {
                  final order = controller.filteredOrders[i];
                  return OrderCard(
                    order: order,
                    iconPath: controller.iconForType(order.type),
                    index: i,
                    onTap: () {
                      controller.selectOrder(order);
                      Get.to(() => const OrderDetailScreen());
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final OrdersController controller;

  const _FilterChipsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.rh,
      child: Obx(
        () {
          final currentFilter = controller.selectedFilter.value;
          return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 4.rh),
          itemCount: OrdersController.filterCategories.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.rw),
          itemBuilder: (_, i) {
            final cat = OrdersController.filterCategories[i];
            final isSelected = currentFilter == cat;
            return GestureDetector(
              onTap: () => controller.filterOrders(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: 14.rw,
                  vertical: 6.rh,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20.rs),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: CommonText(
                  cat,
                  fontSize: 12.rf,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
              ),
            );
          },
        );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64.rs,
            color: AppColors.iconDisabled,
          ),
          SizedBox(height: 16.rh),
          CommonText(
            filter == AppString.kAll
                ? AppString.kNoOrdersFound
                : AppString.kNoOrdersForFilter,
            fontSize: 14.rf,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
