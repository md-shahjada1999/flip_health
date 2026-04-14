import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/controllers/orders%20controllers/orders_controller.dart';
import 'package:flip_health/views/orders/widgets/order_card.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/orders/order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();

    return SafeScreenWrapper(
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
              // Snapshot RxList inside Obx so GetX tracks list mutations (append/pagination).
              final rows = controller.orders.toList();
              final showFooter =
                  controller.hasMore.value || controller.isLoadingMore.value;
              if (rows.isEmpty) {
                return _EmptyState(
                  filter: controller.selectedFilter.value,
                  onRetry: controller.refreshOrders,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refreshOrders,
                child: ListView.builder(
                  key: ValueKey(controller.selectedFilter.value),
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.rw,
                    vertical: 8.rh,
                  ),
                  itemCount: rows.length + (showFooter ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i >= rows.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.rh),
                        child: Center(
                          child: controller.isLoadingMore.value
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    }
                    final order = rows[i];
                    return OrderCard(
                      order: order,
                      iconPath: controller.iconForType(order.type),
                      index: i,
                      onTap: () {
                        controller.selectOrder(order);
                        final tx = order.rawJson?['transaction_type']
                            ?.toString()
                            .toUpperCase();
                        final invId =
                            order.rawJson?['id']?.toString() ?? order.id;
                        if (tx == 'MENTALWELLNESS' ||
                            tx == 'NUTRITION' ||
                            tx == 'YOGA') {
                          Get.toNamed(
                            AppRoutes.wellnessOrderDetail,
                            arguments: {'invoiceId': invId},
                          );
                          return;
                        }
                        if (order.type == 'Consultation') {
                          Get.toNamed(
                            AppRoutes.consultationOrderDetail,
                            arguments: {'invoiceId': invId},
                          );
                        } else if (order.type == 'Pharmacy' ||
                            order.type == 'Chronic') {
                          Get.toNamed(
                            AppRoutes.pharmacyOrderDetail,
                            arguments: {'invoiceId': invId},
                          );
                        } else if (order.type == 'Gym') {
                          Get.toNamed(
                            AppRoutes.gymMembershipOrderDetail,
                            arguments: {'invoiceId': invId},
                          );
                        } else if (order.type == 'Dental' ||
                            order.type == 'Vision' ||
                            order.type == 'Vaccine') {
                          Get.toNamed(
                            AppRoutes.serviceRequestOrderDetail,
                            arguments: {
                              'invoiceId': invId,
                              'service': order.type.toLowerCase(),
                            },
                          );
                        } else {
                          Get.to(() => const OrderDetailScreen());
                        }
                      },
                    );
                  },
                ),
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
      child: Obx(() {
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
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  final Future<void> Function() onRetry;

  const _EmptyState({required this.filter, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.rh),
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
