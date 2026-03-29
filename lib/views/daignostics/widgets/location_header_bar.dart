import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/address_selection_sheet.dart';
import 'package:flip_health/core/utils/common_text.dart';

class LocationHeaderBar extends StatelessWidget {
  final VoidCallback? onTap;

  const LocationHeaderBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.find<AddressController>();

    return GestureDetector(
      onTap: onTap ?? () => AddressSelectionSheet.show(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 12.rh),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 20.rs),
            SizedBox(width: 8.rw),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => CommonText(
                        addressController.displayLabel,
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => CommonText(
                              addressController.displayAddress,
                              fontSize: 11.rf,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
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
      ),
    );
  }
}
