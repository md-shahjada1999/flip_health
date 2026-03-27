// ====================
// BOTTOM SHEET WIDGET
// ====================
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class CommonBottomSheet {
  static void show({
    required BuildContext context,
    required String title,
    required List<ServiceCardData> items,
    double? maxHeight,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetContent(
        title: title,
        items: items,
        maxHeight: maxHeight,
      ),
    );
  }
}

class BottomSheetContent extends StatelessWidget {
  final String title;
  final List<ServiceCardData> items;
  final double? maxHeight;

  const BottomSheetContent({
    Key? key,
    required this.title,
    required this.items,
    this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? ResponsiveHelper.screenHeight * 0.75,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.rs),
          topRight: Radius.circular(24.rs),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(15.rs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  title,
                  fontSize: 18.rf,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 35.rw,
                    height: 35.rh,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20.rs,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(15.rs),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.rs,
                mainAxisSpacing: 12.rs,
                childAspectRatio: 1.11,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ServiceCard(data: items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ====================
// SERVICE CARD DATA MODEL
// ====================
class ServiceCardData {
  final String iconPath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconBackgroundColor;
  final Color? subtitleColor;
  final String? subtitleIconPath;

  ServiceCardData({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.backgroundColor,
    this.iconBackgroundColor,
    this.subtitleColor,
    this.subtitleIconPath,
  });
}

// ====================
// SERVICE CARD WIDGET
// ====================
class ServiceCard extends StatelessWidget {
  final ServiceCardData data;

  const ServiceCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: data.backgroundColor ?? AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(16.rs),
        ),
        padding: EdgeInsets.all(12.rs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Arrow Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon Container
                Container(
                  width: 45.rw,
                  height: 45.rh,
                  decoration: BoxDecoration(
                    color: data.iconBackgroundColor ?? AppColors.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(12.rs),
                  child: SvgPicture.asset(
                    data.iconPath,
                    fit: BoxFit.contain,
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_outward,
                  size: 24.rs,
                  color: AppColors.textPrimary,
                ),
              ],
            ),

            SizedBox(height: 16.rh),

            // Title
            CommonText(
              data.title,
              fontSize: 12.rf,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.3,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8.rh),

            // Subtitle with Icon
            Row(
              children: [
                Container(
                  width: 12.rw,
                  height: 12.rh,
                  // decoration: BoxDecoration(
                  //   color: data.subtitleColor ?? AppColors.success,
                  //   shape: BoxShape.circle,
                  // ),
                  child: SvgPicture.asset(
                    data.subtitleIconPath ?? data.subtitleIconPath ?? 'assets/assets/svg/all services icons/free_health_checkup.svg',
                    width: 7.rw,
                    height: 7.rh,
                  ),
                ),
                SizedBox(width: 6.rw),
                Expanded(
                  child: CommonText(
                    data.subtitle,
                    fontSize: 8.rf,
                    color: data.subtitleColor ?? AppColors.success,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
