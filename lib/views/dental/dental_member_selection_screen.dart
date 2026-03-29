import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/dental%20controllers/dental_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/views/daignostics/widgets/add_family_member_button.dart';
import 'package:flip_health/views/daignostics/widgets/header_section.dart';
import 'package:flip_health/views/daignostics/widgets/user_card.dart';
import 'package:flip_health/views/dental/dental_vendors_screen.dart';

class DentalMemberSelectionScreen extends GetView<DentalController> {
  const DentalMemberSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: AppString.kDentalService),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.rs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: AppString.kForYou,
                        subtitle: AppString.kBookFreeDentalServices,
                      ),
                      SizedBox(height: 16.rh),
                      ...controller.sponsoredMembers.map((member) => UserCard(
                            name: member.name,
                            subtitle: AppString.kSponsoredByCompany(member.sponsoredBy ?? ''),
                            subtitleColor: AppColors.success,
                            isSelected: controller.isUserSelected(member.id),
                            onTap: () => controller.selectUser(member.id),
                          )),
                      SizedBox(height: 32.rh),
                      SectionHeader(
                        title: AppString.kForYourFamily,
                        subtitle: AppString.kBookDentalForFamily,
                      ),
                      SizedBox(height: 16.rh),
                      ...controller.nonSponsoredMembers.map((member) => UserCard(
                            name: member.name,
                            subtitle: member.hasPackages ? AppString.kPackagesAvailable : null,
                            subtitleColor: AppColors.textSecondary,
                            isSelected: controller.isUserSelected(member.id),
                            showAddButton: true,
                            onAddTap: () => controller.selectUser(member.id),
                          )),
                      AddFamilyMemberButton(onTap: controller.addNewFamilyMember),
                      SizedBox(height: 80.rh),
                    ],
                  ),
                ),
              ),
            ),
            ActionButton(
              text: AppString.kContinue,
              onPressed: () {
                controller.continueToVendors();
                Get.to(() => const DentalVendorsScreen());
              },
            ),
          ],
        );
      }),
    );
  }
}
