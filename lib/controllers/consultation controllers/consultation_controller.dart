import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/consultation_repository.dart';
import 'package:flip_health/model/consultation%20models/consultation_model.dart';
import 'package:flip_health/views/consultation/consultation_booking_screen.dart';
import 'package:flip_health/views/consultation/consultation_slot_selection_screen.dart';
import 'package:flip_health/views/consultation/doctor_list_screen.dart';
import 'package:flip_health/views/consultation/select_speciality_screen.dart';

class ConsultationController extends GetxController {
  final ConsultationRepository _repository;
  ConsultationController({required ConsultationRepository repository}) : _repository = repository;
  // --- Consultation type ---
  final Rx<ConsultationType> consultationType = ConsultationType.hospital.obs;

  final RxBool isLoading = false.obs;

  // --- Speciality state ---
  final TextEditingController specialitySearchController =
      TextEditingController();
  final RxString specialitySearchQuery = ''.obs;
  final RxList<SpecialityModel> allSpecialities = <SpecialityModel>[].obs;
  final RxList<SpecialityModel> searchSpecialityResults =
      <SpecialityModel>[].obs;
  final Rx<SpecialityModel?> selectedSpeciality = Rx<SpecialityModel?>(null);

  // --- Doctor state ---
  final TextEditingController doctorSearchController = TextEditingController();
  final RxList<DoctorModel> allDoctors = <DoctorModel>[].obs;
  final RxList<DoctorModel> filteredDoctors = <DoctorModel>[].obs;
  final Rx<DoctorModel?> selectedDoctor = Rx<DoctorModel?>(null);
  final RxString selectedSortOption = 'Relevance'.obs;

  // --- Hospital state ---
  final RxList<HospitalModel> featuredHospitals = <HospitalModel>[].obs;

  // --- Slot selection state ---
  final RxInt selectedDateIndex = 0.obs;
  final RxString selectedTimeSlot = ''.obs;
  final RxString selectedMonthYear = 'Sept 2025 ( IST )'.obs;

  final RxList<Map<String, String>> availableDates = <Map<String, String>>[
    {'day': '10', 'weekday': 'Mon'},
    {'day': '11', 'weekday': 'Tue'},
    {'day': '12', 'weekday': 'Wed'},
    {'day': '13', 'weekday': 'Thu'},
    {'day': '14', 'weekday': 'Fri'},
  ].obs;

  final List<Map<String, dynamic>> morningSlots = [
    {'time': '7 AM-8 AM', 'isDisabled': false},
    {'time': '8 AM-9 AM', 'isDisabled': false},
    {'time': '9 AM-10 AM', 'isDisabled': true},
    {'time': '10 AM-11 AM', 'isDisabled': false},
    {'time': '11 AM-12 PM', 'isDisabled': false},
  ];

  final List<Map<String, dynamic>> afternoonSlots = [
    {'time': '12 PM-1 PM', 'isDisabled': false},
    {'time': '1 PM-2 PM', 'isDisabled': false},
    {'time': '2 PM-3 PM', 'isDisabled': false},
    {'time': '3 PM-4 PM', 'isDisabled': false},
    {'time': '4 PM-5 PM', 'isDisabled': false},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSpecialities();
    _loadDoctors();
    _loadHospitals();
  }

  @override
  void onClose() {
    specialitySearchController.dispose();
    doctorSearchController.dispose();
    super.onClose();
  }

  String get appBarTitle => consultationType.value == ConsultationType.hospital
      ? 'At Hospital Consultation'
      : 'Virtual Consultation';

  // --- Member selection (delegated to MemberController) ---

  void continueWithMemberSelection() {
    final mc = Get.find<MemberController>();
    if (mc.selectedUserId.value.isEmpty) {
      AppToast.error(
          title: 'Failed', message: 'Please select a family member');
      return;
    }
    Get.to(() => const SelectSpecialityScreen());
  }

  // --- Specialities ---

  Future<void> _loadSpecialities() async {
    allSpecialities.value = await _repository.getSpecialities();
    searchSpecialityResults.value = List.from(allSpecialities);
  }

  void searchSpecialities(String query) {
    specialitySearchQuery.value = query;
    if (query.trim().isEmpty) {
      searchSpecialityResults.value = List.from(allSpecialities);
      return;
    }
    searchSpecialityResults.value = allSpecialities
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void selectSpeciality(SpecialityModel speciality) {
    selectedSpeciality.value = speciality;
    Get.to(() => const DoctorListScreen());
  }

  // --- Doctors ---

  Future<void> _loadDoctors() async {
    allDoctors.value = await _repository.getDoctors();
    filteredDoctors.value = List.from(allDoctors);
  }

  Future<void> _loadHospitals() async {
    featuredHospitals.value = await _repository.getFeaturedHospitals();
  }

  void searchDoctors(String query) {
    if (query.trim().isEmpty) {
      filteredDoctors.value = List.from(allDoctors);
      return;
    }
    filteredDoctors.value = allDoctors
        .where((d) =>
            d.name.toLowerCase().contains(query.toLowerCase()) ||
            d.hospitalName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void sortDoctors(String option) {
    selectedSortOption.value = option;
    final sorted = List<DoctorModel>.from(filteredDoctors);
    switch (option) {
      case 'Consultation Fees(Low to High)':
        sorted.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case 'Consultation Fees(High to Low)':
        sorted.sort((a, b) => b.consultationFee.compareTo(a.consultationFee));
        break;
      default:
        break;
    }
    filteredDoctors.value = sorted;
  }

  void selectDoctor(DoctorModel doctor) {
    selectedDoctor.value = doctor;
    Get.to(() => const ConsultationSlotSelectionScreen());
  }

  // --- Slot selection ---

  void selectDate(int index) {
    selectedDateIndex.value = index;
  }

  void selectTimeSlot(String time) {
    selectedTimeSlot.value = time;
  }

  String getFormattedSelectedDate() {
    if (availableDates.isEmpty) return '';
    final date = availableDates[selectedDateIndex.value];
    return '${date['day']} ${date['weekday']}';
  }

  void confirmSlotSelection() {
    if (selectedTimeSlot.value.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please select a time slot');
      return;
    }
    final date = availableDates[selectedDateIndex.value];
    AppToast.success(
      title: 'Slot Confirmed',
      message:
          'Appointment scheduled for ${date['day']} ${date['weekday']}, ${selectedTimeSlot.value}',
    );
    Get.to(() => const ConsultationBookingScreen());
  }

  // --- Booking ---

  void confirmBooking() {
    Get.to(() => PaymentSuccessScreen());
  }
}
