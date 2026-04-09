import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/daignostics/widgets/my_orders_button.dart';

class LabSelectionScreen extends StatefulWidget {
  const LabSelectionScreen({super.key});

  @override
  State<LabSelectionScreen> createState() => _LabSelectionScreenState();
}

class _LabSelectionScreenState extends State<LabSelectionScreen> {
  late final LabTestController controller;
  bool _skipTriggered = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LabTestController>();
    _listenForEmptyVendors();
  }

  void _listenForEmptyVendors() {
    ever(controller.isVendorsLoading, (bool loading) {
      if (!loading && controller.vendors.isEmpty && !_skipTriggered && mounted) {
        _skipTriggered = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.back();
          controller.goToSlotSelection();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Select Lab',
        showBackButton: true,
        actions: [const MyOrdersButton()],
      ),
      body: Column(
        children: [
          const LocationHeaderBar(),
          SizedBox(height: 4.rh),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.rs),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CommonText(
                'Choose a lab for your tests',
                fontSize: 12.rf,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 12.rh),
          Expanded(
            child: Obx(() {
              if (controller.isVendorsLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.vendors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_hospital_outlined, size: 48.rs, color: AppColors.textQuaternary),
                      SizedBox(height: 12.rh),
                      CommonText('No labs available', fontSize: 14.rf, color: AppColors.textSecondary),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.rs),
                itemCount: controller.vendors.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 200),
                    delay: Duration(milliseconds: 60 * index),
                    child: Obx(() => _VendorCard(
                          vendor: controller.vendors[index],
                          isSelected: controller.selectedVendorIndex.value == index,
                          onTap: () => controller.selectVendor(index),
                        )),
                  );
                },
              );
            }),
          ),
          Obx(() {
            final selected = controller.selectedVendorIndex.value >= 0;
            return SafeBottomPadding(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: selected ? 1.0 : 0.4,
                child: ActionButton(
                  text: selected
                      ? 'Continue with ${controller.selectedVendor?.name ?? 'Lab'}'
                      : 'Select a lab to continue',
                  onPressed: controller.goToSlotSelection,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final LabVendor vendor;
  final bool isSelected;
  final VoidCallback onTap;

  const _VendorCard({
    required this.vendor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.rh),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(14.rs),
              child: Row(
                children: [
                  _buildLogo(),
                  SizedBox(width: 12.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          vendor.name,
                          fontSize: 14.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                        SizedBox(height: 2.rh),
                        Row(
                          children: [
                            Icon(Icons.home_outlined, size: 12.rs, color: AppColors.textTertiary),
                            SizedBox(width: 4.rw),
                            CommonText(
                              'Home Collection',
                              fontSize: 11.rf,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24.rs,
                    height: 24.rs,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check_rounded, size: 14.rs, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
            if (vendor.packages.isNotEmpty) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(16.rs),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.rs, vertical: 8.rs),
                child: Column(
                  children: [
                    ...vendor.packages.map((pkg) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.rh),
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonText(
                                  pkg.name,
                                  fontSize: 12.rf,
                                  color: AppColors.textPrimary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (pkg.pricing != null) ...[
                                SizedBox(width: 8.rw),
                                CommonText(
                                  '\u20B9${pkg.pricing!.b2cPrice.toStringAsFixed(0)}',
                                  fontSize: 12.rf,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ],
                            ],
                          ),
                        )),
                    if (vendor.totalPrice > 0) ...[
                      Padding(
                        padding: EdgeInsets.only(top: 6.rh),
                        child: const Divider(height: 1, color: AppColors.borderLight),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6.rh),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText(
                              'Total',
                              fontSize: 13.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            CommonText(
                              '\u20B9${vendor.totalPrice.toStringAsFixed(0)}',
                              fontSize: 14.rf,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (vendor.logo == null) {
      return Container(
        width: 44.rs,
        height: 44.rs,
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(10.rs),
        ),
        child: Center(
          child: CommonText(
            vendor.name.isNotEmpty ? vendor.name[0].toUpperCase() : 'L',
            fontSize: 18.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    final url = vendor.logo!.startsWith('http') ? vendor.logo! : '${ApiUrl.kImageUrl}${vendor.logo}';
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.rs),
      child: Image.network(
        url,
        width: 44.rs,
        height: 44.rs,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          width: 44.rs,
          height: 44.rs,
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(10.rs),
          ),
          child: Center(
            child: CommonText(
              vendor.name.isNotEmpty ? vendor.name[0].toUpperCase() : 'L',
              fontSize: 18.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
