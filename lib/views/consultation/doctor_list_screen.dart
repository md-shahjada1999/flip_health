import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/consultation%20models/consultation_model.dart';
import 'package:flip_health/views/consultation/widgets/doctor_card.dart';
import 'package:flip_health/views/consultation/widgets/hospital_card.dart';
import 'package:flip_health/views/consultation/widgets/sort_bottom_sheet.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class DoctorListScreen extends GetView<ConsultationController> {
  const DoctorListScreen({Key? key}) : super(key: key);

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
                  _buildSearchAndSortBar(context),
                  _buildFeaturedHospitals(),
                  _buildDoctorList(),
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

  Widget _buildSearchAndSortBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.doctorSearchController,
              onChanged: controller.searchDoctors,
              decoration: InputDecoration(
                hintText: 'Search Doctors, Hospitals',
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
          ),
          SizedBox(width: 12.rw),
          GestureDetector(
            onTap: () {
              SortBottomSheet.show(
                context: context,
                selectedOption: controller.selectedSortOption.value,
                onOptionSelected: controller.sortDoctors,
              );
            },
            child: Container(
              padding: EdgeInsets.all(12.rs),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.rs),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Icon(
                Icons.sort,
                color: AppColors.textPrimary,
                size: 22.rs,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedHospitals() {
    return Obx(() {
      if (controller.featuredHospitals.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.rw, 20.rh, 20.rw, 12.rh),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  'Featured Hospitals',
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                CommonText(
                  'See all >',
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
          _FeaturedHospitalPageView(
            hospitals: controller.featuredHospitals,
          ),
        ],
      );
    });
  }

  Widget _buildDoctorList() {
    return Obx(() {
      final doctors = controller.filteredDoctors;
      if (doctors.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(32.rs),
          child: Center(
            child: CommonText(
              'No doctors found',
              fontSize: 14.rf,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 12.rh, bottom: 32.rh),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return DoctorCard(
            doctor: doctor,
            
            onBookAppointment: () => controller.selectDoctor(doctor),
          );
        },
      );
    });
  }
}

class _FeaturedHospitalPageView extends StatefulWidget {
  final List<HospitalModel> hospitals;
  const _FeaturedHospitalPageView({required this.hospitals});

  @override
  State<_FeaturedHospitalPageView> createState() =>
      _FeaturedHospitalPageViewState();
}

class _FeaturedHospitalPageViewState extends State<_FeaturedHospitalPageView> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final itemsPerPage = 2;
    final pageCount = (widget.hospitals.length / itemsPerPage).ceil();

    return Column(
      children: [
        SizedBox(
          height: 140.rh,
          child: PageView.builder(
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: pageCount,
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * itemsPerPage;
              final end = (start + itemsPerPage > widget.hospitals.length)
                  ? widget.hospitals.length
                  : start + itemsPerPage;
              final pageHospitals = widget.hospitals.sublist(start, end);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.rw),
                child: Row(
                  children: pageHospitals
                      .map((h) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.rw),
                              child: HospitalCard(hospital: h),
                            ),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8.rh),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pageCount,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.rw),
              width: i == _currentPage ? 24.rw : 8.rw,
              height: 6.rh,
              decoration: BoxDecoration(
                color: i == _currentPage
                    ? AppColors.textPrimary
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(3.rs),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
