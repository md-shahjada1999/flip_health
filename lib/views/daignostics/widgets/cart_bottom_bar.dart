import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class CartBottomBar extends StatelessWidget {
  final int itemCount;
  final String actionLabel;
  final VoidCallback onActionTap;
  final IconData? actionIcon;
  final Color? iconColor;

  const CartBottomBar({
    super.key,
    required this.itemCount,
    required this.actionLabel,
    required this.onActionTap,
    this.actionIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: onActionTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.rs, vertical: 12.rs),
          padding: EdgeInsets.symmetric(horizontal: 20.rs, vertical: 16.rs),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12.rs),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                '$itemCount test${itemCount > 1 ? 's' : ''}',
                fontSize: 14.rf,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    actionLabel,
                    fontSize: 14.rf,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  if (actionIcon != null) ...[
                    SizedBox(width: 8.rw),
                    Icon(
                      actionIcon,
                      size: 18.rs,
                      color: iconColor ?? AppColors.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
