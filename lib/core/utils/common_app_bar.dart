import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class CommonAppBar {
  static AppBar build({
    required String title,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 18,
    List<Widget>? actions,
  }) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: true,
      title: CommonText(
        title,
        fontSize: fontSize.rf,
        color: textColor ?? AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      actions: actions,
    );
  }
}
