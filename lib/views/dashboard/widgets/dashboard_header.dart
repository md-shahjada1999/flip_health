import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';

class DashboardHeader extends StatelessWidget {
  final String address;
  final VoidCallback? onAddressPressed;
  final VoidCallback? onCalendarPressed;
  final VoidCallback? onProfilePressed;
  /// OPD wallet quick balance from `/patient/opd/wallet` (shown next to wallet icon).
  final String? walletBalanceText;

  const DashboardHeader({
    Key? key,
    required this.address,
    this.onAddressPressed,
    this.onCalendarPressed,
    this.onProfilePressed,
    this.walletBalanceText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    
    return ResponsiveScreen(
      addVerticalPadding: false,
      child: RContainer(
        padding: EdgeInsets.only(top: ResponsiveHelper.statusBarHeight + 16.rs),
        child: Row(
          children: [
            // Location Section
            Expanded(
              child: InkWell(
                onTap: onAddressPressed,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20.rf,
                    ),
                    RSizedBox.horizontal(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RText(
                            AppString.kHome,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          RText(
                            address,
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textTertiary,
                      size: 16.rf,
                    ),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            Row(
              children: [
                // if (walletBalanceText != null &&
                //     walletBalanceText!.trim().isNotEmpty) ...[
                //   RText(
                //     walletBalanceText!,
                //     fontSize: 11,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.primary,
                //     maxLines: 1,
                //     overflow: TextOverflow.ellipsis,
                //   ),
                //   RSizedBox.horizontal(6),
                // ],
                _HeaderIconButton(
                  icon: AppString.kIconCalendar,
                  onPressed: onCalendarPressed,
                  color: AppColors.primary,
                ),
                RSizedBox.horizontal(12),
                _HeaderIconButton(
                  icon: AppString.kIconProfile,
                  onPressed: onProfilePressed,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _HeaderIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onPressed;
  final Color? color;

  const _HeaderIconButton({
    required this.icon,
    this.onPressed,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.rs),
      child: RContainer(
        width: 40,
        height: 40,
        // decoration: BoxDecoration(
        //   color: AppColors.primary,
        //   borderRadius: BorderRadius.circular(8.rs),
        // ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            width: 20.rw,
            height: 20.rh,
            color: color
          ),
        ),
      ),
    );
  }
}

