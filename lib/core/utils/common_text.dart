import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/font_family.dart';

class CommonText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final double? height;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final TextStyle? style;

  const CommonText(
    this.text, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.fontStyle,
    this.letterSpacing,
    this.style,
  });

  factory CommonText.heading(
    String text, {
    Key? key,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CommonText(
      text,
      key: key,
      fontSize: fontSize ?? 24,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w700,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: 1.3,
    );
  }

  factory CommonText.body(
    String text, {
    Key? key,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CommonText(
      text,
      key: key,
      fontSize: fontSize ?? 14,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w400,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontFamily: FontFamily.fontName,
      fontSize: fontSize ?? 14,
      color: color,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style != null
          ? defaultStyle.merge(style)
          : defaultStyle,
    );
  }
}
