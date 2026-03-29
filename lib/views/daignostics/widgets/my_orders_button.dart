import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class MyOrdersButton extends StatelessWidget {
  final VoidCallback? onTap;

  const MyOrdersButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.rw),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 6.rh),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderDark, width: 0.7),
            borderRadius: BorderRadius.circular(20.rs),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(AppString.kShoppingBagIcon, width: 12.rs),
              SizedBox(width: 4.rw),
              CommonText(
                AppString.kMyOrders,
                fontSize: 12.rf,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
