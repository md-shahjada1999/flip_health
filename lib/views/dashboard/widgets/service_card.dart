  import 'package:flutter/material.dart';
  import 'package:flutter_svg/flutter_svg.dart';
  import 'package:flip_health/core/constants/app_colors.dart';
  import 'package:flip_health/core/constants/string_define.dart';
  import 'package:flip_health/core/helpers/responsive_helpers.dart';
  import 'package:flip_health/core/utils/common_text.dart';

  class ServiceCard extends StatelessWidget {
    final String title;
    final String? subtitle;
    final String? badgeText;
    final String imagePath;
    final Color? backgroundColor;
    final VoidCallback? onPressed;
    final bool isLarge;
    final bool showServiceOptions; // New parameter to show/hide service options

    const ServiceCard({
      Key? key,
      required this.title,
      this.subtitle,
      this.badgeText,
      required this.imagePath,
      this.backgroundColor,
      this.onPressed,
      this.isLarge = false,
      this.showServiceOptions = false,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      ResponsiveHelper.init(context);

      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.rs),
        child: Stack(
          children: [
            Container(
              width: isLarge ? double.infinity : null,
              height: isLarge ? (showServiceOptions ? 140.rh : 120.rh) : 150.rh,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.rs),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 0.7.rs,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(12.rs),
              child: Stack(
                children: [
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      RText(
                        title,
                        fontSize: isLarge ? 18 : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),

                      RSizedBox.vertical(4),

                      // Subtitle
                      if (subtitle != null && !showServiceOptions)
                        RText(
                          subtitle!,
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          maxLines: 2,
                        ),

                      // Service Options (for Diagnostics card)
                      if (showServiceOptions && isLarge) ...[
                        RSizedBox.vertical(10),

                        // First Row: Same day slot booking
                        _ServiceOption(
                            icon: AppString.kClockIcon,
                            label: AppString.kSameDaySlotBooking,
                            color: AppColors.textTertiary),

                        RSizedBox.vertical(8),

                        // Second Row: Home collection and At center
                        Row(
                          children: [
                            _ServiceOption(
                              icon: AppString.kHomeIcon,
                              label: AppString.kHomeCollection,
                              color: AppColors.textPrimary,
                            ),
                            RSizedBox.horizontal(16),
                            _ServiceOption(
                              icon: AppString.kCenterIcon,
                              label: AppString.kAtCenter,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),

                        RSizedBox.vertical(10),

                        // Badge - UP TO 20% OFF with gradient
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.rs, vertical: 5.rs),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.discountBannerStart, // Vibrant orange
                                AppColors
                                    .discountBannerEnd // Lighter/faded orange
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12.rs),
                          ),
                          child: CommonText(
                            AppString.kUpTo20OffDiagnostics,
                            color: AppColors.primary,
                            fontSize: 10.rs,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],

                      // Badge for non-diagnostics cards
                      if (badgeText != null && !showServiceOptions)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.rs, vertical: 4.rs),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12.rs),
                          ),
                          child: CommonText(
                            badgeText!,
                            color: Colors.white,
                            fontSize: 10.rs,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),

                  // Image positioned at bottom right corner - no padding, extends to edge
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: isLarge ? 80.rw : 60.rw,
                  height: isLarge ? 80.rh : 60.rh,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.rs),
                      bottomRight: Radius.circular(16.rs),
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Image Error: $error for path: $imagePath');
                        return Container(
                          width: isLarge ? 80.rw : 60.rw,
                          height: isLarge ? 80.rh : 60.rh,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  class _ServiceOption extends StatelessWidget {
    final String icon;
    final String label;
    final Color? color;
    const _ServiceOption({
      Key? key,
      required this.icon,
      required this.label,
      required this.color,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      ResponsiveHelper.init(context);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            width: 10.rw,
            height: 10.rh,
          ),
          RSizedBox.horizontal(4),
          RText(
            label,
            fontSize: 9,
            color: color ?? AppColors.textTertiary,
            fontWeight: FontWeight.w400,
          ),
        ],
      );
    }
  }

  class CommonDashboardServiceCard extends StatelessWidget {
    final String title;
    final String? subtitle;
    final String? badgeText;
    final String imagePath;
    final Color borderColor;
    final Color? badgeBackgroundColor;
    final VoidCallback? onPressed;
    final List<ServiceFeatureRow>? featureRows;
    final bool isImageSvg;
    final bool hasGradientBorder;

    const CommonDashboardServiceCard({
      Key? key,
      required this.title,
      this.subtitle,
      this.badgeText,
      required this.imagePath,
      this.borderColor = Colors.grey,
      this.badgeBackgroundColor,
      this.onPressed,
      this.featureRows,
      this.isImageSvg = false,
      this.hasGradientBorder = false,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {

      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15.rs),
        child: Container(
          // height: 140.rh,
          // width: 170.rw,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.rs),
            border: Border.all(
              color: borderColor.withOpacity(0.3),
              width: 0.7.rs,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0.5,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Container(
            // margin: hasGradientBorder ? EdgeInsets.all(1.5) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(hasGradientBorder ? 14.5.rs : 16.rs),
              boxShadow: hasGradientBorder
                  ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.rs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      RText(
                        title,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),

                      RSizedBox.vertical(4),

                      // Subtitle
                      if (subtitle != null)
                        RText(
                          subtitle!,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary,
                          maxLines: 2,
                        ),

                      RSizedBox.vertical(8),

                      // Feature Rows
                      if (featureRows != null && featureRows!.isNotEmpty) ...[
                        ...featureRows!.map((featureRow) => Padding(
                              padding: EdgeInsets.only(bottom: 4.rh),
                              child: _buildFeatureRow(featureRow),
                            )),
                      ],

                      // Spacer(),
                      RSizedBox.vertical(4),

                      // Badge
                      if (badgeText != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.rs,
                            vertical: 3.rs,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.discountBannerStart, // Vibrant orange
                                AppColors
                                    .discountBannerEnd // Lighter/faded orange
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12.rs),
                          ),
                          child: SizedBox(
                            width: 90.rw,
                            child: Row(
                              children: [
                                CommonText(
                                  badgeText!,
                                  color: badgeBackgroundColor != null
                                      ? badgeBackgroundColor
                                      : AppColors.primary,
                                  fontSize: 8.rs,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Image positioned at bottom right
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 50.rw,
                    height: 50.rh,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.rs),
                        bottomRight: Radius.circular(14.rs),
                      ),
                      child: isImageSvg
                          ? SvgPicture.asset(
                              imagePath,
                              fit: BoxFit.fill,
                              placeholderBuilder: (context) =>
                                  _ImagePlaceholder(),
                            )
                          : Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _ImagePlaceholder();
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildFeatureRow(ServiceFeatureRow featureRow) {
      if (featureRow.features.length == 1) {
        // Single feature
        return _FeatureItem(feature: featureRow.features[0]);
      } else {
        // Multiple features in a row
        return Row(
          children: featureRow.features
              .map((feature) => Expanded(
                    child: _FeatureItem(feature: feature),
                  ))
              .toList(),
        );
      }
    }
  }

  class _FeatureItem extends StatelessWidget {
    final ServiceFeature feature;

    const _FeatureItem({
      Key? key,
      required this.feature,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      ResponsiveHelper.init(context);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (feature.iconPath != null)
            SvgPicture.asset(
              feature.iconPath!,
              width: 12.rw,
              height: 12.rh,
            )
          else if (feature.icon != null)
            Icon(
              feature.icon,
              size: 12.rs,
              color: feature.iconColor ?? Colors.green.shade600,
            ),
          if (feature.iconPath != null || feature.icon != null)
            RSizedBox.horizontal(4),
          Flexible(
            child: RText(
              feature.label,
              fontSize: 10,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
  }

  class _ImagePlaceholder extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.image,
            color: Colors.grey[400],
            size: 32,
          ),
        ),
      );
    }
  }

  class ServiceFeatureRow {
    final List<ServiceFeature> features;

    const ServiceFeatureRow({required this.features});
  }

  class ServiceFeature {
    final String label;
    final String? iconPath;
    final IconData? icon;
    final Color? iconColor;

    const ServiceFeature({
      required this.label,
      this.iconPath,
      this.icon,
      this.iconColor,
    });
  }
