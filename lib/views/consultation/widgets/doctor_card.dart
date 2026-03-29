import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/consultation%20models/consultation_model.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onBookAppointment;

  const DoctorCard({
    Key? key,
    required this.doctor,
    required this.onBookAppointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 6.rh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildTopSection(),
          Divider(height: 1, color: AppColors.borderLight),
          _buildTagRow(),
          Divider(height: 1, color: AppColors.borderLight),
          _buildFeeRow(),
          _buildBookButton(),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.rw, 0.rh, 16.rw, 12.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildDoctorImage(),
          ),
          SizedBox(width: 14.rw),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    doctor.name,
                    fontSize: 15.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 2.rh),
                  CommonText(
                    doctor.qualification,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (doctor.isCashless)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6.rs),bottomRight: Radius.circular(6.rs)),
                  ),
                  child: CommonText(
                    'Cashless Available',
                    fontSize: 10.rf,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              SizedBox(height: 12.rh),
              Icon(
                Icons.chevron_right,
                color: AppColors.textPrimary,
                size: 22.rs,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorImage() {
    return Container(
      width: 64.rs,
      height: 64.rs,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundTertiary,
      ),
      child: doctor.imageUrl != null
          ? ClipOval(
              child: Image.asset(
                doctor.imageUrl!,
                fit: BoxFit.cover,
                width: 64.rs,
                height: 64.rs,
              ),
            )
          : Icon(Icons.person, color: AppColors.primary, size: 32.rs),
    );
  }

  Widget _buildTagRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
      child: Row(
        children: [
          _buildTag(
            'assets/svg/doctor specialities/experience.svg',
            doctor.experience,
            AppColors.primary.withOpacity(0.08),
            AppColors.primary,
          ),
          SizedBox(width: 10.rw),
          _buildTag(
            'assets/svg/doctor specialities/hospital.svg',
            doctor.hospitalName,
            Colors.blue.withOpacity(0.08),
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(
    String svgPath,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 6.rh),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.rs),
          border: Border.all(color: iconColor.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 14.rs,
              height: 14.rs,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            SizedBox(width: 6.rw),
            Flexible(
              child: CommonText(
                label,
                fontSize: 11.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            'Your Consultation Fee',
            fontSize: 12.rf,
            color: AppColors.textSecondary,
          ),
          CommonText(
            '₹ ${doctor.consultationFee.toStringAsFixed(0)}',
            fontSize: 15.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return ActionButton(
      text: 'Book Appointment',
      onPressed: onBookAppointment,
      backgroundColor: AppColors.primary,
      padding: EdgeInsets.fromLTRB(16.rw, 0, 16.rw, 4.rh),
    );
  }
}
