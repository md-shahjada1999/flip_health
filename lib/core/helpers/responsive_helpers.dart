// ====================
// 1. RESPONSIVE HELPER CLASS
// ====================
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flip_health/core/constants/app_colors.dart';

class ResponsiveHelper {
  static final ResponsiveHelper _singleton = ResponsiveHelper._internal();
  factory ResponsiveHelper() {
    return _singleton;
  }
  ResponsiveHelper._internal();
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late Orientation orientation;
  static late MobileScreenType mobileScreenType;

  // Design dimensions (Figma design base - common mobile design)
  static const double _designWidth = 375.0; // iPhone X width
  static const double _designHeight = 812.0; // iPhone X height

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    orientation = _mediaQueryData.orientation;

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    // Determine mobile screen type
    mobileScreenType = _getMobileScreenType();
  }

  static MobileScreenType _getMobileScreenType() {
    double deviceWidth = screenWidth;
    double deviceHeight = screenHeight;
    double diagonal = sqrt(pow(deviceWidth, 2) + pow(deviceHeight, 2));

    // Based on common mobile screen sizes
    if (diagonal < 1000) {
      return MobileScreenType.small; // iPhone SE, small Android
    } else if (diagonal < 1200) {
      return MobileScreenType.normal; // iPhone 12, most Android phones
    } else if (diagonal < 1400) {
      return MobileScreenType.large; // iPhone Pro Max, large Android
    } else {
      return MobileScreenType.extraLarge; // Small tablets
    }
  }

  // Responsive width based on design
  static double width(double designWidth) {
    return (designWidth / _designWidth) * screenWidth;
  }

  // Responsive height based on design
  static double height(double designHeight) {
    return (designHeight / _designHeight) * screenHeight;
  }

  // Responsive font size
  static double fontSize(double designFontSize) {
    double scaleFactor = screenWidth / _designWidth;
    // Clamp the scale factor to prevent too large/small fonts
    scaleFactor = scaleFactor.clamp(0.8, 1.3);
    return designFontSize * scaleFactor;
  }

  // Responsive padding/margin
  static double spacing(double designSpacing) {
    return (designSpacing / _designWidth) * screenWidth;
  }

  // Get responsive value based on screen type
  static T valueForScreen<T>({
    required T small,
    required T normal,
    required T large,
    T? extraLarge,
  }) {
    switch (mobileScreenType) {
      case MobileScreenType.small:
        return small;
      case MobileScreenType.normal:
        return normal;
      case MobileScreenType.large:
        return large;
      case MobileScreenType.extraLarge:
        return extraLarge ?? large;
    }
  }

  // Check if screen is small
  static bool get isSmallScreen => mobileScreenType == MobileScreenType.small;

  // Check if screen is normal
  static bool get isNormalScreen => mobileScreenType == MobileScreenType.normal;

  // Check if screen is large
  static bool get isLargeScreen => mobileScreenType == MobileScreenType.large;

  // Check if screen is extra large
  static bool get isExtraLargeScreen =>
      mobileScreenType == MobileScreenType.extraLarge;

  // Check orientation
  static bool get isPortrait => orientation == Orientation.portrait;
  static bool get isLandscape => orientation == Orientation.landscape;

  // Safe area values
  static double get statusBarHeight => _mediaQueryData.padding.top;
  static double get bottomBarHeight => _mediaQueryData.padding.bottom;
}

// ====================
// 2. MOBILE SCREEN TYPES
// ====================
enum MobileScreenType {
  small, // iPhone SE, small Android (< 1000 diagonal)
  normal, // iPhone 12, most Android (1000-1200 diagonal)
  large, // iPhone Pro Max, large Android (1200-1400 diagonal)
  extraLarge, // Small tablets (> 1400 diagonal)
}

// ====================
// 3. RESPONSIVE WIDGET
// ====================
class ResponsiveWidget extends StatelessWidget {
  final Widget Function(BuildContext context, MobileScreenType screenType)
      builder;

  const ResponsiveWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return builder(context, ResponsiveHelper.mobileScreenType);
  }
}

// ====================
// 4. RESPONSIVE EXTENSIONS
// ====================
extension ResponsiveExtensions on num {
  // Responsive width
  double get rw => ResponsiveHelper.width(this.toDouble());

  // Responsive height
  double get rh => ResponsiveHelper.height(this.toDouble());

  // Responsive font size
  double get rf => ResponsiveHelper.fontSize(this.toDouble());

  // Responsive spacing (padding/margin)
  double get rs => ResponsiveHelper.spacing(this.toDouble());

  // Percentage of screen width
  double get pw => ResponsiveHelper.screenWidth * (this / 100);

  // Percentage of screen height
  double get ph => ResponsiveHelper.screenHeight * (this / 100);

  // Safe area width percentage
  double get spw => ResponsiveHelper.safeBlockHorizontal * this;

  // Safe area height percentage
  double get sph => ResponsiveHelper.safeBlockVertical * this;
}

// ====================
// 5. RESPONSIVE CONTAINER
// ====================
class RContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;

  const RContainer({
    Key? key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Container(
      width: width?.rw,
      height: height?.rh,
      padding: _getResponsiveEdgeInsets(padding),
      margin: _getResponsiveEdgeInsets(margin),
      color: color,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }

  EdgeInsetsGeometry? _getResponsiveEdgeInsets(EdgeInsetsGeometry? insets) {
    if (insets == null) return null;

    if (insets is EdgeInsets) {
      return EdgeInsets.fromLTRB(
        insets.left.rs,
        insets.top.rs,
        insets.right.rs,
        insets.bottom.rs,
      );
    }
    return insets;
  }
}

// ====================
// 6. RESPONSIVE TEXT
// ====================
class RText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? lineHeight;
  final TextStyle? style;

  const RText(
    this.text, {
    Key? key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.lineHeight,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: fontSize?.rf ?? style?.fontSize,
        fontWeight: fontWeight ?? style?.fontWeight,
        color: color ?? style?.color,
        height: lineHeight,
      ).merge(style),
    );
  }
}

// ====================
// 7. RESPONSIVE SIZED BOX
// ====================
class RSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const RSizedBox({
    Key? key,
    this.width,
    this.height,
    this.child,
  }) : super(key: key);

  // Named constructors for common spacings
  const RSizedBox.vertical(double height, {Key? key})
      : width = null,
        height = height,
        child = null,
        super(key: key);

  const RSizedBox.horizontal(double width, {Key? key})
      : width = width,
        height = null,
        child = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return SizedBox(
      width: width?.rw,
      height: height?.rh,
      child: child,
    );
  }
}

// ====================
// 8. RESPONSIVE BUTTON
// ====================
class RButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool isLoading;

  const RButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.height,
    this.width,
    this.padding,
    this.borderRadius,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return SizedBox(
      width: width?.rw ?? double.infinity,
      height: height?.rh ?? 56.rh,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          padding: _getResponsiveEdgeInsets(padding) ??
              EdgeInsets.symmetric(horizontal: 24.rs, vertical: 16.rs),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12.rs),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.rh,
                width: 20.rw,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: 8.rs),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize?.rf ?? 16.rf,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  EdgeInsetsGeometry? _getResponsiveEdgeInsets(EdgeInsetsGeometry? insets) {
    if (insets == null) return null;

    if (insets is EdgeInsets) {
      return EdgeInsets.fromLTRB(
        insets.left.rs,
        insets.top.rs,
        insets.right.rs,
        insets.bottom.rs,
      );
    }
    return insets;
  }
}

// ====================
// 9. RESPONSIVE CARD
// ====================
class RCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;

  const RCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Container(
      margin: _getResponsiveEdgeInsets(margin),
      child: Card(
        color: color ?? AppColors.cardBackground,
        elevation: elevation ??
            ResponsiveHelper.valueForScreen(
              small: 2.0,
              normal: 4.0,
              large: 6.0,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12.rs),
          side: border != null
              ? BorderSide(
                  color: border!.top.color,
                  width: border!.top.width,
                )
              : BorderSide.none,
        ),
        child: Padding(
          padding: _getResponsiveEdgeInsets(padding) ?? EdgeInsets.all(16.rs),
          child: child,
        ),
      ),
    );
  }

  EdgeInsetsGeometry? _getResponsiveEdgeInsets(EdgeInsetsGeometry? insets) {
    if (insets == null) return null;

    if (insets is EdgeInsets) {
      return EdgeInsets.fromLTRB(
        insets.left.rs,
        insets.top.rs,
        insets.right.rs,
        insets.bottom.rs,
      );
    }
    return insets;
  }
}

// ====================
// 10. RESPONSIVE SCREEN WRAPPER
// ====================
class ResponsiveScreen extends StatelessWidget {
  final Widget child;
  final bool addHorizontalPadding;
  final bool addVerticalPadding;
  final double? maxWidth;

  const ResponsiveScreen({
    Key? key,
    required this.child,
    this.addHorizontalPadding = true,
    this.addVerticalPadding = false,
    this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    double horizontalPadding = addHorizontalPadding
        ? ResponsiveHelper.valueForScreen(
            small: 16.0,
            normal: 20.0,
            large: 24.0,
            extraLarge: 32.0,
          )
        : 0.0;

    double verticalPadding = addVerticalPadding
        ? ResponsiveHelper.valueForScreen(
            small: 16.0,
            normal: 20.0,
            large: 24.0,
            extraLarge: 32.0,
          )
        : 0.0;

    Widget responsiveChild = Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.rs,
        vertical: verticalPadding.rs,
      ),
      child: child,
    );

    // Center content if maxWidth is specified
    if (maxWidth != null) {
      responsiveChild = Center(child: responsiveChild);
    }

    return responsiveChild;
  }
}

// ====================
// 11. USAGE EXAMPLES & HELPER FUNCTIONS
// ====================

// Replace your autosize function with this
double autosize(double value) => value.rw;
