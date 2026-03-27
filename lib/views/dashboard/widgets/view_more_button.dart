import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';

class ViewMoreButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ViewMoreButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    
    return ResponsiveScreen(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.rs),
        child: RContainer(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: RText(
              AppString.kViewMore,
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
