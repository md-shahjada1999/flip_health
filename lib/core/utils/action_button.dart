import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const ActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20.rs),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.textPrimary,
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
            : CommonText(
                text,
                fontSize: 15.rf,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
      ),
    );
  }
}