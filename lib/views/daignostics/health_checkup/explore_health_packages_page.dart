import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';

class ExploreHealthPackagesPage extends StatelessWidget {
  const ExploreHealthPackagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HealthCheckupsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
        title: AppString.kHealthCheckupsTitle,
        showBackButton: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.rw),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 6.rh),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderDark, width: 0.7),
                borderRadius: BorderRadius.circular(20.rs),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(AppString.kShoppingBagIcon, width: 12.rs),
                  SizedBox(width: 4.rw),
                  CommonText(
                    'My Orders',
                    fontSize: 12.rf,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        return Column(
          children: [
            // Location Header
            _buildLocationHeader(),

            // Collection Type Tabs
            _buildCollectionTypeTabs(controller),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 16.rh),

                    // Package Cards
                    _buildPackageCard(
                      controller,
                      labLogoPath: AppString.kNeubergLogo,
                      rating: '4.5',
                      packageName: 'Flip Health AHC 2025-2026',
                      patientName: 'for Kalyan',
                      price: '₹ 0',
                      isSelected: controller.selectedPackageIndex.value == 0,
                      index: 0,
                      showOnlyHomeCollection: true,
                    ),

                    SizedBox(height: 16.rh),

                    _buildPackageCard(
                      controller,
                      labLogoPath: AppString.kOrangeHealthLogo,
                      rating: '4.5',
                      packageName: 'Flip Health AHC 2025-2026',
                      patientName: 'for Kalyan',
                      price: '₹ 0',
                      isSelected: controller.selectedPackageIndex.value == 1,
                      index: 1,
                      showOnlyHomeCollection: false,
                    ),

                    SizedBox(height: 100.rh),
                  ],
                ),
              ),
            ),

            // Bottom Continue Button
            _buildBottomButton(controller),
          ],
        );
      }),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 12.rh),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20.rs,
          ),
          SizedBox(width: 8.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Home',
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        'Isprout, 7th floor, Plot No: 25, Divyasree trinity,',
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16.rs,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionTypeTabs(HealthCheckupsController controller) {
    return Container(
      padding: EdgeInsets.all(16.rs),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildTabButton(
                  iconPath: AppString.kHomeIcon,
                  label: 'Home Collection',
                  isSelected: controller.isHomeCollection.value,
                  onTap: () => controller.isHomeCollection.value = true,
                )),
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: Obx(() => _buildTabButton(
                  iconPath: AppString.kCenterIcon,
                  label: 'At Center',
                  isSelected: !controller.isHomeCollection.value,
                  onTap: () => controller.isHomeCollection.value = false,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String iconPath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.rh),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(25.rs),
          border: Border.all(
            color: !isSelected ? Colors.black : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 12.rw,
              height: 12.rh,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            SizedBox(width: 6.rw),
            CommonText(
              label,
              fontSize: 13.rf,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              height: 1.3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(
    HealthCheckupsController controller, {
    required String labLogoPath,
    required String rating,
    required String packageName,
    required String patientName,
    required String price,
    required bool isSelected,
    required int index,
    required bool showOnlyHomeCollection,
  }) {
    return GestureDetector(
      onTap: () => controller.selectedPackageIndex.value = index,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.rw),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
          
        ),
        child: Column(
          children: [
            // Lab Header
            Padding(
              padding: EdgeInsets.all(10.rs),
              child: Row(
                children: [
                  // Lab Logo
                  Image.asset(
                    labLogoPath,
                    width: 100.rw,
                    height: 50.rh,
                  ),
                  SizedBox(width: 12.rw),

                  // Rating
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.rw,
                      vertical: 1.rh,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.warning,
                        width: 1,
                      ),
                      // color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15.rs),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 12.rs,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 4.rw),
                        CommonText(
                          rating,
                          fontSize: 10.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // Checkbox
                  Container(
                    width: 20.rs,
                    height: 20.rs,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected ? Colors.black : AppColors.borderLight,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4.rs),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 16.rs,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),

            Divider(
                height: 1,
                color: isSelected ? AppColors.primary : AppColors.borderLight),

            // Package Details
            Padding(
              padding: EdgeInsets.all(12.rs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CommonText(
                          packageName,
                          fontSize: 12.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.rw,
                          vertical: 2.rh,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12.rs),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppString.kIconFreeHealthCheckups,
                              width: 10.rw,
                              height: 10.rh,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.rw),
                            CommonText(
                              'Free',
                              fontSize: 10.rf,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.rh),
                  CommonText(
                    patientName,
                    fontSize: 10.rf,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: isSelected ? AppColors.primary : AppColors.borderLight),
// To Pay
            Padding(
              padding: EdgeInsets.all(12.rs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    'To Pay',
                    fontSize: 11.rf,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  CommonText(
                    price,
                    fontSize: 12.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ],
              ),
            ),
            // Footer Buttons
            Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14.rs),
                  bottomRight: Radius.circular(14.rs),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 6.rh, horizontal: 16.rw),
              child: showOnlyHomeCollection
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppString.kHomeIcon,
                          width: 10.rw,
                          height: 10.rh,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.rw),
                        CommonText(
                          'Home Collection',
                          fontSize: 10.rf,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        SvgPicture.asset(
                          AppString.kHomeIcon,
                          width: 10.rw,
                          height: 10.rh,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.rw),
                        CommonText(
                          'Home Collection',
                          fontSize: 10.rf,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        SizedBox(width: 16.rw),
                        // Container(
                        //   width: 1,
                        //   height: 16.rh,
                        //   color: Colors.white.withOpacity(0.3),
                        // ),
                        // Spacer(),
                        SvgPicture.asset(
                          AppString.kCenterIcon,
                          width: 10.rw,
                          height: 10.rh,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.rw),
                        CommonText(
                          'At Center',
                          fontSize: 10.rf,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(HealthCheckupsController controller) {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.background,
        
      
      ),
      child: ActionButton(
        text: "Continue",
        onPressed: () {
          if (controller.selectedPackageIndex.value != -1) {
            controller.continueWithPackageSelection();
          }
        },
      ),
    );
  }


  
}
