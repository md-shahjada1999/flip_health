import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_family.dart';

class TextStyleCustom {
  TextStyleCustom._();

  static TextStyle normalStyle({
    double? fontSize,
    Color? color,
    String? fontFamily,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      color: color ?? AppColors.textPrimary,
      fontFamily: fontFamily ?? FontFamily.fontName,
      fontWeight: FontWeight.w400,
      decoration: decoration ?? TextDecoration.none,
    );
  }

  static TextStyle headingStyle({
    double? fontSize,
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 25.0,
      color: color ?? AppColors.textPrimary,
      fontFamily: fontFamily ?? FontFamily.fontName,
      height: 1.3,
      fontWeight: fontWeight ?? FontWeight.w700,
    );
  }

  static TextStyle textFieldStyle({
    double? fontSize,
    Color? color,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      color: color ?? AppColors.textPrimary,
      fontFamily: fontFamily ?? FontFamily.fontName,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle underLineStyle() {
    return const TextStyle(
      fontSize: 22.0,
      fontFamily: FontFamily.fontName,
      shadows: [
        Shadow(
          color: Colors.red,
          offset: Offset(0, -5),
        )
      ],
      color: Colors.transparent,
      fontWeight: FontWeight.w900,
      decoration: TextDecoration.underline,
      decorationColor: Colors.red,
      decorationThickness: 1,
    );
  }
}
