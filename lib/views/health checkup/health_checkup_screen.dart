import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/views/health%20checkup/widgets/add_family_member_button.dart';
import 'package:flip_health/views/health%20checkup/widgets/header_section.dart';
import 'package:flip_health/views/health%20checkup/widgets/user_card.dart';

class HealthCheckupsScreen extends GetView<HealthCheckupsController> {
  const HealthCheckupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
    title: AppString.kHealthCheckupsTitle,
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
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.rs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // For You Section
                      SectionHeader(
                        title: AppString.kForYou,
                        subtitle: AppString.kBookFreeHealthCheckups,
                      ),
                      
                      SizedBox(height: 16.rh),
                      
                      // Sponsored members
                      ...controller.sponsoredMembers.map((member) => UserCard(
                            name: member.name,
                            subtitle: AppString.kSponsoredByCompany(
                              member.sponsoredBy ?? '',
                            ),
                            subtitleColor: AppColors.success,
                            isSelected: controller.isUserSelected(member.id),
                            onTap: () => controller.selectUser(member.id),
                          )),
                      
                      SizedBox(height: 32.rh),
                      
                      // For Your Family Section
                      SectionHeader(
                        title: AppString.kForYourFamily,
                        subtitle: AppString.kBookPaidHealthCheckups,
                      ),
                      
                      SizedBox(height: 16.rh),
                      
                      // Non-sponsored family members
                      ...controller.nonSponsoredMembers.map((member) => UserCard(
                            name: member.name,
                            subtitle: member.hasPackages
                                ? AppString.kPackagesAvailable
                                : null,
                            subtitleColor: AppColors.textSecondary,
                            showAddButton: true,
                            onAddTap: () => controller.addMemberToSelection(member.id),
                          )),
                      
                      // Add new family member button
                      AddFamilyMemberButton(
                        onTap: controller.addNewFamilyMember,
                      ),
                      
                      SizedBox(height: 80.rh),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Continue Button
            Obx(() => ActionButton(
                  text: AppString.kContinue,
                  onPressed: controller.continueWithSelection,
                  isLoading: controller.isLoading.value,
                )),
          ],
        );
      }),
    );
  }
}