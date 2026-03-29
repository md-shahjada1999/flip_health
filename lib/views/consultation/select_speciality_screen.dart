import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/consultation%20models/consultation_model.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class SelectSpecialityScreen extends GetView<ConsultationController> {
  const SelectSpecialityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: controller.appBarTitle),
      body: Column(
        children: [
          const LocationHeaderBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(),
                  _buildSearchBar(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.rw,
                      vertical: 12.rh,
                    ),
                    child: CommonText(
                      'Common Specialities',
                      fontSize: 16.rf,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  _buildSpecialityList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 12.rh),

          padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 8.rh),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            // borderRadius: BorderRadius.circular(16.rs),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonText(
                'Consult Top Doctors ',
                fontSize: 12.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.cardBackground,
              ),
              SizedBox(height: 4.rh),
              Obx(
                () => CommonText(
                  controller.consultationType.value == ConsultationType.hospital
                      ? 'In-Clinic'
                      : 'Online',
                  fontSize: 12.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cardBackground,
                ),
              ),
              SizedBox(width: 4.rw),
              //Image.asset("assets/png/doctors_consult.png",height: 20.rh,width: 20.rw,)
            ],
          ),
        ),
        Positioned(
          right: 30.rw,
          bottom: 5,

          child: Image.asset(
            "assets/png/doctors_consult.png",
            height: 60.rh,
            width: 60.rw,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw),
      child: TextField(
        controller: controller.specialitySearchController,
        onChanged: controller.searchSpecialities,
        decoration: InputDecoration(
          hintText: 'Search Specialities',
          hintStyle: TextStyle(
            fontSize: 14.rf,
            fontFamily: 'Poppins',
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20.rs,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.rw,
            vertical: 12.rh,
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
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialityList() {
    return Obx(() {
      final specialities = controller.searchSpecialityResults;
      if (specialities.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(32.rs),
          child: Center(
            child: CommonText(
              'No specialities found',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.rw),
        itemCount: specialities.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppColors.borderLight),
        itemBuilder: (context, index) {
          final speciality = specialities[index];
          return ListTile(
            onTap: () => controller.selectSpeciality(speciality),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8.rw,
              vertical: 4.rh,
            ),
            leading: Container(
              padding: EdgeInsets.all(8.rs),
              width: 30.rs,
              height: 30.rs,
              decoration: BoxDecoration(
                color: AppColors.cardBorder.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.rs),
              ),
              child: speciality.iconPath != null
                  ? SvgPicture.asset(
                      speciality.iconPath!,
                      fit: BoxFit.contain,
                      height: 20.rh,
                      width: 20.rw,
                    )
                  : Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.primary,
                      size: 16.rs,
                    ),
            ),
            title: CommonText(
              speciality.name,
              fontSize: 12.rf,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20.rs,
            ),
          );
        },
      );
    });
  }
}
