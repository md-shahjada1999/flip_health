import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_family.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? prefixIcon;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.fontName,
            fontSize: 13.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.rh),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: FontFamily.fontName,
              fontSize: 14.rf,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: FontFamily.fontName,
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled ? AppColors.textSecondary : AppColors.iconDisabled,
            size: 22.rs,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(12.rs),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.backgroundTertiary,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.rw,
              vertical: 16.rh,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.rs),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.rs),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.rs),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.rs),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.rs),
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.rs),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
          ),
          style: TextStyle(
            fontFamily: FontFamily.fontName,
            fontSize: 15.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          elevation: 2,
          menuMaxHeight: 300.rh,
        ),
      ],
    );
  }
}