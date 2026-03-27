
import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';


class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showCheckIcon;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.showCheckIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          title,
          fontSize: 20.rf,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        SizedBox(height: 8.rh),
        Row(
          children: [
            if (showCheckIcon) ...[
              Icon(
                Icons.check,
                size: 16.rs,
                color: AppColors.success,
              ),
              SizedBox(width: 6.rw),
            ],
            Expanded(
              child: CommonText(
                subtitle,
                fontSize: 14.rf,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

