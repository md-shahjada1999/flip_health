import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';

class VendorCard extends StatelessWidget {
  final VendorModel vendor;
  final bool isSelected;
  final VoidCallback onTap;

  const VendorCard({
    Key? key,
    required this.vendor,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.rh),
        padding: EdgeInsets.all(16.rs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15.rs),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonText(
                    vendor.name,
                    fontSize: 16.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.rw),
                Container(
                  width: 24.rs,
                  height: 24.rs,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(4.rs),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 18.rs)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            SizedBox(height: 16.rh),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonText(
                    '${vendor.address}, ${vendor.city}',
                    fontSize: 12.rf,
                    color: AppColors.textTertiary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.rw),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.info),
                        borderRadius: BorderRadius.circular(3.rs),
                      ),
                      padding: EdgeInsets.all(2.rs),
                      child: Icon(Icons.directions, color: AppColors.info, size: 14.rs),
                    ),
                    SizedBox(height: 4.rh),
                    CommonText(
                      '${vendor.distance} km',
                      fontSize: 9.rf,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
