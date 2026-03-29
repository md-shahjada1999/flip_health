import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/consultation%20models/consultation_model.dart';

class HospitalCard extends StatelessWidget {
  final HospitalModel hospital;
  final VoidCallback? onTap;

  const HospitalCard({
    Key? key,
    required this.hospital,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo area with grey background
            Container(
              width: double.infinity,
              height: 100.rh,
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.rs),
                ),
              ),
              child: Center(
                child: Image.asset(
                  hospital.logoPath,
                  height: 60.rh,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.local_hospital,
                    color: AppColors.primary,
                    size: 32.rs,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.rw, 0.rh, 12.rw, 0.rh),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CommonText(
                          hospital.name,
                          fontSize: 13.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18.rs,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.rh),
                  CommonText(
                    '${hospital.location ?? ''} - ${hospital.distance ?? ''}',
                    fontSize: 11.rf,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
