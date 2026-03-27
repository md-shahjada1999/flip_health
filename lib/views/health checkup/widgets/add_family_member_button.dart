// ====================
import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';

class AddFamilyMemberButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddFamilyMemberButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.rh),
        padding: EdgeInsets.all(18.rs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.rs),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24.rw,
              height: 24.rh,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4.rs),
              ),
              child: Icon(
                Icons.add,
                size: 18.rs,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.rw),
            CommonText(
              AppString.kAddNewFamilyMember,
              fontSize: 16.rf,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}