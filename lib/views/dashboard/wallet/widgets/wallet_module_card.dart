import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class WalletModuleCard extends StatelessWidget {
  final String moduleName;
  final String svgIcon;
  final int available;
  final int total;
  final Color color;
  final Animation<double>? animation;

  const WalletModuleCard({
    Key? key,
    required this.moduleName,
    required this.svgIcon,
    required this.available,
    required this.total,
    required this.color,
    this.animation,
  }) : super(key: key);

  double get _percent =>
      total > 0 ? (available / total).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.symmetric(horizontal: 6.rs, vertical: 8.rs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 20.rs,
            lineWidth: 3.5.rs,
            percent: _percent,
            animation: true,
            animationDuration: 1200,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.15),
            center: SvgPicture.asset(
              svgIcon,
              width: 15.rs,
              height: 15.rs,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
          SizedBox(height: 4.rh),
          CommonText(
            moduleName,
            fontSize: 10.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.rh),
          CommonText(
            '₹$available',
            fontSize: 11.rf,
            fontWeight: FontWeight.w700,
            color: color,
            maxLines: 1,
          ),
          CommonText(
            'of ₹$total',
            fontSize: 8.rf,
            color: AppColors.textSecondary,
            maxLines: 1,
          ),
        ],
      ),
    );

    if (animation != null) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation!, curve: Curves.easeOutBack),
        child: FadeTransition(
          opacity:
              CurvedAnimation(parent: animation!, curve: Curves.easeOut),
          child: card,
        ),
      );
    }

    return card;
  }
}
