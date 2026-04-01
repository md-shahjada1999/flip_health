import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  }) : iconColor = null;

  const ProfileInfoTile.custom({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.rh),
      child: Row(
        children: [
          Container(
            width: 40.rs,
            height: 40.rs,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.rs),
            ),
            child: Icon(
              icon,
              size: 20.rs,
              color: iconColor ?? AppColors.primary,
            ),
          ),
          SizedBox(width: 14.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  label,
                  fontSize: 12.rf,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  value,
                  fontSize: 15.rf,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
