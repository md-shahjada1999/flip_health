import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class CollectionTypeTab {
  final String label;
  final String? iconPath;
  final IconData? icon;

  const CollectionTypeTab({
    required this.label,
    this.iconPath,
    this.icon,
  });
}

class CollectionTypeTabs extends StatelessWidget {
  final List<CollectionTypeTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CollectionTypeTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.rh,
      padding: EdgeInsets.symmetric(horizontal: 16.rs),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.rw),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(25.rs),
                border: Border.all(
                  color: !isSelected ? Colors.black : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tab.iconPath != null)
                    SvgPicture.asset(
                      tab.iconPath!,
                      width: 12.rw,
                      height: 12.rh,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : AppColors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    )
                  else if (tab.icon != null)
                    Icon(
                      tab.icon,
                      size: 14.rs,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  SizedBox(width: 6.rw),
                  CommonText(
                    tab.label,
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    height: 1.3,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
