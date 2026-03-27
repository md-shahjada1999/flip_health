import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';


class AppToast {
  AppToast._();

  /// Default toast duration
  static const Duration _defaultDuration = Duration(seconds: 3);

  /// Shows a success toast
  static void success({
    required String title,
    required String message,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppColors.successLight,
      colorText: AppColors.success,
      icon: const Icon(Icons.check_circle, color: AppColors.success),
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
      duration: duration ?? _defaultDuration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Shows an error toast
  static void error({
    required String title,
    required String message,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppColors.errorLight,
      colorText: AppColors.error,
      icon: const Icon(Icons.error, color: AppColors.error),
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
      duration: duration ?? _defaultDuration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Shows a warning toast
  static void warning({
    required String title,
    required String message,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppColors.warningLight,
      colorText: AppColors.warning,
      icon: const Icon(Icons.warning_amber, color: AppColors.warning),
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
      duration: duration ?? _defaultDuration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Shows an info toast
  static void info({
    required String title,
    required String message,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppColors.infoLight,
      colorText: AppColors.info,
      icon: const Icon(Icons.info, color: AppColors.info),
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
      duration: duration ?? _defaultDuration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Shows a primary themed toast (like your original example)
  static void primary({
    required String title,
    required String message,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppColors.primaryLight,
      colorText: AppColors.primary,
      icon: const Icon(Icons.notifications, color: AppColors.primary),
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
      duration: duration ?? _defaultDuration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Shows a custom toast with full control
  static void custom({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Color? iconColor,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
    EdgeInsets? margin,
    double? borderRadius,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor ?? AppColors.surface,
      colorText: textColor ?? AppColors.textPrimary,
      icon: icon != null
          ? Icon(icon, color: iconColor ?? AppColors.iconPrimary)
          : null,
      borderRadius: borderRadius ?? 8,
      margin: margin ?? const EdgeInsets.all(16),
      duration: duration ?? _defaultDuration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Shows a simple toast with minimal styling
  static void show({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      colorText: AppColors.primary,
      duration: _defaultDuration,
    );
  }
}