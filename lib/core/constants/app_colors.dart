import 'package:flutter/material.dart';

/// App color constants with meaningful names and organized categories
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ========== Primary Colors ==========
  static const Color primary = Color(0xffFF5224);
  static const Color primaryLight = Color(0xffFBE9E7);
  static const Color primaryDark = Color(0xff16222E);

  // ========== Secondary Colors ==========
  static const Color secondary = Color(0xff607d8b);
  static const Color secondaryLight = Color(0xffeceff1);
  static const Color secondaryDark = Color(0xff16222E);

  // ========== Accent Colors ==========
  static const Color accent = Color(0xff3077CA);
  static const Color accentLight = Color(0xff9FC9FA);
  static const Color accentSecondary = Color.fromARGB(255, 112, 179, 255);

  // ========== Text Colors ==========
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xff8E8E8E);
  static const Color textTertiary = Color(0xff626262);
  static const Color textQuaternary = Color(0xff959595);
  static const Color textDisabled = Color(0xff6D6D6D);
  static const Color textOnPrimary = Color(0xffFBFBFB);
  static const Color textOnSecondary = Color(0xff16222E);

  // ========== Status Colors ==========
  static const Color success = Color(0xff1AAD0D);
  static const Color successLight = Color(0xffE8F5E8);
  static const Color warning = Color(0xffFFC839);
  static const Color warningLight = Color(0xffFFF8E1);
  static const Color error = Color(0xffF44336);
  static const Color errorLight = Color(0xffFFEBEE);
  static const Color info = Color(0xff4BA4FF);
  static const Color infoLight = Color(0xffE3F2FD);

  // ========== Background Colors ==========
  static const Color background = Colors.white;
  static const Color backgroundSecondary = Color(0xffEEF2F3);
  static const Color backgroundTertiary = Color(0xffF4F4F4);
  static const Color backgroundDark = Color(0xff16222E);

  // ========== Surface Colors ==========
  static const Color surface = Colors.white;
  static const Color surfaceLight = Color(0xffFAFAFA);
  static const Color surfaceDark = Color(0xff424242);

  // ========== Border & Divider Colors ==========
  static const Color border = Color(0xffD9D9D9);
  static const Color borderLight = Color(0xffEEEEEE);
  static const Color borderDark = Color(0xff595959);
  static const Color divider = Color(0xffE0E0E0);

  // ========== Icon Colors ==========
  static const Color iconPrimary = primary;
  static const Color iconSecondary = Color(0xff18203A);
  static const Color iconTertiary = Color(0xff8E8E8E);
  static const Color iconDisabled = Color(0xffBDBDBD);
  static const Color iconOnPrimary = Colors.white;
  static const Color iconBackground= Color(0xffE4E4E4);

  // ========== Card Colors ==========
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000);
  static const Color cardBorder = Color(0xff6C6C6C);

  // ========== Pharmaceutical Specific Colors ==========
  static const Color categoryDot = Color(0xff98cab5);
  static const Color pharmaText = Color(0xff6b6c8a);
  static const Color exploreButton = Color(0xffb0d5c6);
  static const Color selectedCard = Color(0xffe8f0ec);
  static const Color pharmaAccent = Color(0xff7dbea2);

  // ========== Utility Colors ==========
  static const Color transparent = Colors.transparent;
  static const Color shadow = Color(0x29000000);
    static const Color overlay = Color(0x80000000);
    static const Color shimmer = Color(0xffF8F8F8);

  //discount banner colors
  static const Color discountBannerStart = Color(0xffFFC0AC);
  static const Color discountBannerEnd = Color(0xffF8F8F8);
  // ========== Tertiary System Colors ==========
  static const Color tertiary = Colors.blueGrey;

  // ========== Constants ==========
  static const double deliveryCharge = 5.50;

  // ========== Gradient Colors ==========
  static const List<Color> primaryGradient = [
    primary,
    Color(0xffE94A2F),
  ];

  static const List<Color> successGradient = [
    success,
    Color(0xff0D8A02),
  ];

  static const List<Color> infoGradient = [
    info,
    Color(0xff2196F3),
  ];

  // ========== Helper Methods ==========
  
  /// Returns appropriate text color based on background color
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textOnPrimary;
  }

  /// Returns a color with specified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Returns a lighter shade of the given color
  static Color getLighterShade(Color color, [double factor = 0.1]) {
    return Color.lerp(color, Colors.white, factor) ?? color;
  }

  /// Returns a darker shade of the given color
  static Color getDarkerShade(Color color, [double factor = 0.1]) {
    return Color.lerp(color, Colors.black, factor) ?? color;
  }
}