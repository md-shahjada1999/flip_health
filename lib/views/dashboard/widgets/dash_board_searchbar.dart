import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';

class DashboardSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onVoicePressed;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final VoidCallback? onClear;
  final bool isListening;

  const DashboardSearchBar({
    Key? key,
    this.controller,
    this.onVoicePressed,
    this.onChanged,
    this.focusNode,
    this.onClear,
    this.isListening = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return ResponsiveScreen(
      child: RContainer(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10.rs),
          border: Border.all(
            color: AppColors.border,
            width: 0.5.rs,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.rs),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: AppColors.textTertiary,
              size: 20.rf,
            ),
            RSizedBox.horizontal(12),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                style: TextStyleCustom.textFieldStyle(
                  fontSize: 14.rf,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppString.kSearchPlaceholder,
                  hintStyle: TextStyleCustom.textFieldStyle(
                    fontSize: 14.rf,
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (onClear != null)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller ?? TextEditingController(),
                builder: (_, value, __) {
                  if (value.text.isEmpty) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VerticalDivider(
                          color: AppColors.border,
                          thickness: 1.rs,
                          endIndent: 10,
                          indent: 10,
                        ),
                        InkWell(
                          onTap: onVoicePressed,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.all(isListening ? 4.rs : 0),
                            decoration: BoxDecoration(
                              color: isListening ? AppColors.primaryLight : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: isListening
                                ? Icon(
                                    Icons.mic_rounded,
                                    size: 20.rf,
                                    color: AppColors.primary,
                                  )
                                : SvgPicture.asset(
                                    AppString.kIconMicrophone,
                                    width: 20.rw,
                                    height: 20.rh,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }
                  return GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.rf,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            if (onClear == null) ...[
              VerticalDivider(
                color: AppColors.border,
                thickness: 1.rs,
                endIndent: 10,
                indent: 10,
              ),
              InkWell(
                onTap: onVoicePressed,
                child: SvgPicture.asset(
                  AppString.kIconMicrophone,
                  width: 20.rw,
                  height: 20.rh,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
