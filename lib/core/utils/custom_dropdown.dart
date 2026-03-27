import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class CustomDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomDropdown({
    Key? key,
    required this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: CommonText(
        hint,
        fontSize: 16.rf,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: CommonText(
            item,
            fontSize: 16.rf,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: enabled ? AppColors.primary : AppColors.iconDisabled,
        size: 24.rs,
      ),
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.backgroundTertiary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.rw,
          vertical: 12.rh,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rs),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rs),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rs),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rs),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rs),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rs),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      style: TextStyleCustom.textFieldStyle(
        fontSize: 16.rf,
        color: AppColors.textPrimary,
      ),
      iconSize: 24.rs,
      elevation: 8,
      menuMaxHeight: 300.rh,
    );
  }
}