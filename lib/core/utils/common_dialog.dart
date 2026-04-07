import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

enum DialogType { confirm, warning, error, info, success }

class CommonDialog {
  CommonDialog._();

  static _DialogStyle _styleFor(DialogType type) {
    switch (type) {
      case DialogType.confirm:
        return const _DialogStyle(
          color: AppColors.primary,
          lightColor: AppColors.primaryLight,
          icon: Icons.help_outline_rounded,
        );
      case DialogType.warning:
        return const _DialogStyle(
          color: AppColors.warning,
          lightColor: AppColors.warningLight,
          icon: Icons.warning_amber_rounded,
        );
      case DialogType.error:
        return const _DialogStyle(
          color: AppColors.error,
          lightColor: AppColors.errorLight,
          icon: Icons.error_outline_rounded,
        );
      case DialogType.info:
        return const _DialogStyle(
          color: AppColors.info,
          lightColor: AppColors.infoLight,
          icon: Icons.info_outline_rounded,
        );
      case DialogType.success:
        return const _DialogStyle(
          color: AppColors.success,
          lightColor: AppColors.successLight,
          icon: Icons.check_circle_outline_rounded,
        );
    }
  }

  static String _illustrationFor(DialogType type) {
    switch (type) {
      case DialogType.confirm:
        return AppString.kDialogConfirmImage;
      case DialogType.warning:
        return AppString.kDialogWarningImage;
      case DialogType.error:
        return AppString.kDialogErrorImage;
      case DialogType.info:
        return AppString.kDialogInfoImage;
      case DialogType.success:
        return AppString.kDialogSuccessImage;
    }
  }

  static String _defaultConfirmText(DialogType type) {
    switch (type) {
      case DialogType.confirm:
        return 'Confirm';
      case DialogType.warning:
        return 'Proceed';
      case DialogType.error:
        return 'Delete';
      case DialogType.info:
        return 'Got it';
      case DialogType.success:
        return 'Done';
    }
  }

  /// Shows a styled dialog and returns a Future<bool?>.
  /// Returns `true` when the confirm button is tapped, `false` on cancel.
  static Future<bool?> show({
    required String title,
    required String message,
    DialogType type = DialogType.confirm,
    String? confirmText,
    String? cancelText,
    bool showCancel = true,
    bool barrierDismissible = true,
    IconData? icon,
    Widget? customContent,
  }) {
    final style = _styleFor(type);
    final String resolvedConfirm = confirmText ?? _defaultConfirmText(type);
    final String resolvedCancel = cancelText ?? 'Cancel';
    final IconData resolvedIcon = icon ?? style.icon;
    final String illustration = _illustrationFor(type);

    return Get.dialog<bool>(
      _DialogWidget(
        title: title,
        message: message,
        style: style,
        icon: resolvedIcon,
        illustration: illustration,
        confirmText: resolvedConfirm,
        cancelText: resolvedCancel,
        showCancel: showCancel,
        customContent: customContent,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Convenience for confirm dialogs.
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
  }) {
    return show(
      title: title,
      message: message,
      type: DialogType.confirm,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
    );
  }

  /// Convenience for warning dialogs.
  static Future<bool?> warning({
    required String title,
    required String message,
    String confirmText = 'Proceed',
    String cancelText = 'Cancel',
  }) {
    return show(
      title: title,
      message: message,
      type: DialogType.warning,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  /// Convenience for error/destructive dialogs.
  static Future<bool?> error({
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) {
    return show(
      title: title,
      message: message,
      type: DialogType.error,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  /// Convenience for info-only dialogs (no cancel button).
  static Future<bool?> info({
    required String title,
    required String message,
    String confirmText = 'Got it',
  }) {
    return show(
      title: title,
      message: message,
      type: DialogType.info,
      confirmText: confirmText,
      showCancel: false,
    );
  }

  /// Convenience for success dialogs (no cancel button).
  static Future<bool?> success({
    required String title,
    required String message,
    String confirmText = 'Done',
  }) {
    return show(
      title: title,
      message: message,
      type: DialogType.success,
      confirmText: confirmText,
      showCancel: false,
    );
  }
}

class _DialogStyle {
  final Color color;
  final Color lightColor;
  final IconData icon;

  const _DialogStyle({
    required this.color,
    required this.lightColor,
    required this.icon,
  });
}

class _DialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final _DialogStyle style;
  final IconData icon;
  final String illustration;
  final String confirmText;
  final String cancelText;
  final bool showCancel;
  final Widget? customContent;

  const _DialogWidget({
    required this.title,
    required this.message,
    required this.style,
    required this.icon,
    required this.illustration,
    required this.confirmText,
    required this.cancelText,
    required this.showCancel,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.rw),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.rs),
          boxShadow: [
            BoxShadow(
              color: style.color.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.fromLTRB(24.rw, 16.rh, 24.rw, 8.rh),
              child: Column(
                children: [
                  CommonText(
                    title,
                    fontSize: 17.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.rh),
                  if (customContent != null)
                    customContent!
                  else
                    CommonText(
                      message,
                      fontSize: 13.rf,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                      height: 1.5,
                    ),
                ],
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            style.lightColor,
            style.color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildIllustration(),
          Positioned(
            bottom: 6.rh,
            right: 20.rw,
            child: Container(
              width: 32.rs,
              height: 32.rs,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: Icon(icon, size: 16.rs, color: style.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 100.rh,
      width: double.infinity,
      
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
        child: Image.asset(
          illustration,
        
          fit: BoxFit.cover,
       
          errorBuilder: (_, __, ___) => _buildFallbackIcon(),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return SizedBox(
      height: 100.rh,
      child: Center(
        child: Container(
          width: 56.rs,
          height: 56.rs,
          decoration: BoxDecoration(
            color: style.color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28.rs, color: style.color),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.rw, 8.rh, 20.rw, 20.rh),
      child: showCancel
          ? Row(
              children: [
                Expanded(child: _buildCancelButton()),
                SizedBox(width: 12.rw),
                Expanded(child: _buildConfirmButton()),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: _buildConfirmButton(),
            ),
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () => Get.back(result: false),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.rh),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(12.rs),
        ),
        child: Center(
          child: CommonText(
            cancelText,
            fontSize: 14.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () => Get.back(result: true),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.rh),
        decoration: BoxDecoration(
          color: style.color,
          borderRadius: BorderRadius.circular(12.rs),
          boxShadow: [
            BoxShadow(
              color: style.color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: CommonText(
            confirmText,
            fontSize: 14.rf,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
