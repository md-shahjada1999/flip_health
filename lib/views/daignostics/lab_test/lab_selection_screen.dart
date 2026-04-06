import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/views/daignostics/widgets/collection_type_tabs.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/daignostics/widgets/my_orders_button.dart';

class LabSelectionScreen extends GetView<LabTestController> {
  const LabSelectionScreen({super.key});

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
          Obx(() => CollectionTypeTabs(
                tabs: const [
                  CollectionTypeTab(
                      label: 'Home Collection',
                      iconPath: 'assets/svg/daignosticsHome.svg'),
                  CollectionTypeTab(
                      label: 'At Center',
                      iconPath: 'assets/svg/daignosticsCenter.svg'),
                  CollectionTypeTab(
                      label: 'Radiology', icon: Icons.medical_services_outlined),
                ],
                selectedIndex: controller.selectedCollectionTab.value,
                onTabSelected: (i) => controller.selectedCollectionTab.value = i,
              )),
          SizedBox(height: 12.rh),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.rs),
                  itemCount: controller.availableLabs.length,
                  itemBuilder: (context, index) {
                    final lab = controller.availableLabs[index];
                    final isSelected =
                        controller.selectedLabIndex.value == index;
                    return _buildLabCard(lab, isSelected, index);
                  },
                )),
          ),
          Padding(
            padding: EdgeInsets.all(16.rs),
            child: SafeBottomPadding(
              child: ActionButton(
                text: 'Confirm',
                onPressed: controller.confirmLabSelection,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCard(LabModel lab, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => controller.selectLab(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.rh),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // Lab header
            Padding(
              padding: EdgeInsets.all(12.rs),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.rs),
                    child: Image.asset(
                      lab.logoPath,
                      width: 100.rw,
                      height: 40.rh,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100.rw,
                        height: 40.rh,
                        color: AppColors.backgroundTertiary,
                        child: Center(
                          child: CommonText(
                            lab.name.split(' ').first,
                            fontSize: 10.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.rw),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.rw,
                      vertical: 2.rh,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.warning),
                      borderRadius: BorderRadius.circular(15.rs),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star,
                            size: 12.rs, color: AppColors.warning),
                        SizedBox(width: 4.rw),
                        CommonText(
                          lab.rating,
                          fontSize: 10.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (lab.address != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (lab.distance != null)
                          Row(
                            children: [
                              Icon(Icons.navigation_outlined,
                                  size: 12.rs, color: AppColors.accent),
                              SizedBox(width: 4.rw),
                              CommonText(
                                lab.distance!,
                                fontSize: 10.rf,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ] else
                    Container(
                      width: 24.rs,
                      height: 24.rs,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Colors.black
                              : AppColors.borderLight,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4.rs),
                      ),
                      child: isSelected
                          ? Icon(Icons.check,
                              size: 16.rs, color: Colors.white)
                          : null,
                    ),
                ],
              ),
            ),

            if (lab.address != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.rs),
                child: CommonText(
                  lab.address!,
                  fontSize: 10.rf,
                  color: AppColors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            Divider(
              height: 1,
              color: isSelected ? AppColors.primary : AppColors.borderLight,
            ),

            // Test prices
            ...lab.testPrices.map((tp) => Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.rs, vertical: 8.rs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CommonText(
                          tp.testName,
                          fontSize: 12.rf,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CommonText(
                        '₹ ${tp.price.toInt()}',
                        fontSize: 12.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                )),

            Divider(
              height: 1,
              color: isSelected ? AppColors.primary : AppColors.borderLight,
            ),

            // Home collection charges
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.rs, vertical: 8.rs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    'Home Collection Charges',
                    fontSize: 12.rf,
                    color: AppColors.textPrimary,
                  ),
                  CommonText(
                    '₹ ${lab.homeCollectionCharge.toInt()}',
                    fontSize: 12.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            // To Pay
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.rs, vertical: 8.rs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    'To Pay',
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  CommonText(
                    '₹ ${lab.totalPayable.toInt()}',
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),

            // Footer - collection types
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(vertical: 6.rh, horizontal: 16.rw),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14.rs),
                  bottomRight: Radius.circular(14.rs),
                ),
              ),
              child: Row(
                children: [
                  if (lab.supportedTypes.contains(CollectionType.home)) ...[
                    SvgPicture.asset(
                      AppString.kHomeIcon,
                      width: 10.rw,
                      height: 10.rh,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 8.rw),
                    CommonText(
                      'Home Collection',
                      fontSize: 10.rf,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                  if (lab.supportedTypes.contains(CollectionType.center)) ...[
                    SizedBox(width: 16.rw),
                    SvgPicture.asset(
                      AppString.kCenterIcon,
                      width: 10.rw,
                      height: 10.rh,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 8.rw),
                    CommonText(
                      'At Center',
                      fontSize: 10.rf,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
