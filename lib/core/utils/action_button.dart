import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  const ActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.padding,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final enabled = onPressed != null && !isLoading;
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20.rs),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.45,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.textPrimary,
            disabledBackgroundColor:
                (backgroundColor ?? AppColors.textPrimary).withValues(alpha: 0.6),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 18.rh),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.rs),
            ),
          ),
        child: isLoading
            ? SizedBox(
                height: 20.rh,
                width: 20.rw,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                    text,
                    fontSize: 15.rf,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(width: 8.rw),

                  Icon(icon, color: Colors.white, size: 20.rs),
              ],
            ),
        ),
      ),
    );
  }
}