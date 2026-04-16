import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      appBar: CommonAppBar.build(
        title: AppString.kMyOrdersTitle,
        actions: [
          IconButton(
            tooltip: 'Filter orders',
            onPressed: () => _showOrdersFilterSheet(context, controller),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 26.rs,
                  color: AppColors.textPrimary,
                ),
                Obx(() {
                  if (controller.selectedFilter.value == 'All') {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8.rs,
                      height: 8.rs,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(width: 4.rw),
        ],
      ),
      body: Column(
        children: [
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
                  padding: EdgeInsets.fromLTRB(16.rw, 8.rh, 16.rw, 8.rh),
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
                        if (tx == 'LABTEST' || order.type == 'Lab Test') {
                          Get.toNamed(
                            AppRoutes.labOrderDetail,
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

void _showOrdersFilterSheet(BuildContext context, OrdersController c) {
  Get.bottomSheet<void>(
    _OrdersFilterSheet(controller: c),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _OrdersFilterSheet extends StatelessWidget {
  const _OrdersFilterSheet({required this.controller});

  final OrdersController controller;

  String _iconAsset(String cat) {
    if (cat == 'All') return AppString.kIconOrdersServices;
    return controller.iconForType(cat);
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.rs)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                SizedBox(height: 10.rh),
                Center(
                  child: Container(
                    width: 40.rw,
                    height: 4.rh,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.rw, 18.rh, 20.rw, 8.rh),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.rs),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14.rs),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: AppColors.primary,
                          size: 22.rs,
                        ),
                      ),
                      SizedBox(width: 12.rw),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              'Filter orders',
                              fontSize: 18.rf,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(height: 4.rh),
                            CommonText(
                              'Choose a category to narrow your list',
                              fontSize: 12.rf,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.divider),
                Obx(() {
                  final selected = controller.selectedFilter.value;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16.rw, 16.rh, 16.rw, 20.rh),
                    child: Wrap(
                      spacing: 10.rw,
                      runSpacing: 10.rh,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final cat in OrdersController.filterCategories)
                          _OrderFilterCategoryChip(
                            label: cat,
                            iconAsset: _iconAsset(cat),
                            selected: selected == cat,
                            onTap: () async {
                              Get.back<void>();
                              await controller.filterOrders(cat);
                            },
                          ),
                      ],
                    ),
                  );
                }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single selectable chip for order type filters (used in [_OrdersFilterSheet]).
class _OrderFilterCategoryChip extends StatelessWidget {
  const _OrderFilterCategoryChip({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.sizeOf(context).width - 32.rw;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.rs),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(maxWidth: maxW),
          padding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 10.rh),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryLight
                : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(24.rs),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.borderLight,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18.rs,
                height: 18.rs,
                child: SvgPicture.asset(
                  iconAsset,
                  colorFilter: ColorFilter.mode(
                    selected ? AppColors.primary : AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 8.rw),
              Flexible(
                child: CommonText(
                  label,
                  fontSize: 13.rf,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected) ...[
                SizedBox(width: 6.rw),
                Icon(
                  Icons.check_rounded,
                  size: 18.rs,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
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
