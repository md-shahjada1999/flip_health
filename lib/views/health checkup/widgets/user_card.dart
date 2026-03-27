import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final bool isSelected;
  final bool showAddButton;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;
  final Color? subtitleColor;

  const UserCard({
    Key? key,
    required this.name,
    this.subtitle,
    this.isSelected = false,
    this.showAddButton = false,
    this.onTap,
    this.onAddTap,
    this.subtitleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.rh),
        padding: EdgeInsets.all(10.rs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12.rs),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 45.rw,
              height: 45.rh,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 27.rs,
              ),
            ),

            SizedBox(width: 12.rw),

            // Name and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    name,
                    fontSize: 14.rf,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.rh),
                    CommonText(
                      subtitle!,
                      fontSize: 10.rf,
                      color: subtitleColor ?? AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),

            // Action button
            if (showAddButton)
              GestureDetector(
                onTap: onAddTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.rw,
                    vertical: 4.rh,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8.rs),
                  ),
                  child: CommonText(
                    AppString.kAdd,
                    fontSize: 14.rf,
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (isSelected)
              Checkbox(
                value: true,
                onChanged: (v) {},
                shape: CircleBorder(),
                fillColor: MaterialStateProperty.all(AppColors.primary),
                activeColor: AppColors.primary,splashRadius: 23,
              )
            // Container(
            //   width: 27.rw,
            //   height: 27.rh,
            //   decoration: BoxDecoration(
            //     color: AppColors.primary,
            //     shape: BoxShape.circle,
            //   ),
            //   child: Icon(
            //     Icons.check,
            //     color: Colors.white,
            //     size: 20.rs,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
