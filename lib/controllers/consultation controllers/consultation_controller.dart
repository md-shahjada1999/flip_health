import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/data/repositories/consultation_repository.dart';
import 'package:flip_health/model/consultation%20models/consultation_model.dart';
import 'package:flip_health/model/consultation%20models/issue_model.dart';
import 'package:flip_health/model/consultation%20models/online_doctor_model.dart';
import 'package:flip_health/model/consultation%20models/slot_model.dart';
import 'package:flip_health/model/consultation%20models/offline_speciality_model.dart';
import 'package:flip_health/model/consultation%20models/network_doctor_model.dart';
import 'package:flip_health/model/consultation%20models/network_slots_response.dart';
import 'package:flip_health/views/consultation/select_speciality_screen.dart';
import 'package:flip_health/views/consultation/doctor_list_screen.dart';
import 'package:flip_health/views/consultation/consultation_slot_selection_screen.dart';
import 'package:flip_health/views/consultation/consultation_booking_screen.dart';

class ConsultationController extends GetxController {
  final ConsultationRepository _repository;
  ConsultationController({required ConsultationRepository repository})
      : _repository = repository;

  // ─── Flow type ───────────────────────────────────────────────
  final Rx<ConsultationType> consultationType = ConsultationType.hospital.obs;

  bool get isOnline => consultationType.value == ConsultationType.virtual_;

  String get appBarTitle => isOnline
      ? 'Virtual Consultation'
      : 'At Hospital Consultation';

  // ─── Search controllers ──────────────────────────────────────
  final TextEditingController specialitySearchController = TextEditingController();
  final RxString specialitySearchQuery = ''.obs;
  final TextEditingController doctorSearchController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();

  // ─── Online: Issues / Specialities ───────────────────────────
  final RxList<IssueModel> allIssues = <IssueModel>[].obs;
  final RxList<IssueModel> filteredIssues = <IssueModel>[].obs;
  final RxBool issuesLoading = false.obs;
  final Rx<IssueModel?> selectedIssue = Rx<IssueModel?>(null);

  // ─── Online: Doctors ─────────────────────────────────────────
  final RxList<OnlineDoctorModel> onlineDoctors = <OnlineDoctorModel>[].obs;
  final RxList<OnlineDoctorModel> filteredOnlineDoctors = <OnlineDoctorModel>[].obs;
  final RxBool onlineDoctorsLoading = false.obs;
  final Rx<OnlineDoctorModel?> selectedOnlineDoctor = Rx<OnlineDoctorModel?>(null);

  // ─── Online: Slots ───────────────────────────────────────────
  final RxList<SlotModel> availableSlots = <SlotModel>[].obs;
  final RxBool slotsLoading = false.obs;
  final Rx<SlotModel?> selectedSlot = Rx<SlotModel?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedLanguage = 'English'.obs;

  List<SlotModel> get morningSlots =>
      availableSlots.where((s) => s.isMorning && s.available).toList();
  List<SlotModel> get afternoonSlots =>
      availableSlots.where((s) => s.isAfternoon && s.available).toList();
  List<SlotModel> get eveningSlots =>
      availableSlots.where((s) => s.isEvening && s.available).toList();

  // ─── Offline: Specialities ───────────────────────────────────
  final RxList<OfflineSpecialityModel> offlineSpecialities = <OfflineSpecialityModel>[].obs;
  final RxList<OfflineSpecialityModel> filteredOfflineSpecialities = <OfflineSpecialityModel>[].obs;
  final RxBool offlineSpecialitiesLoading = false.obs;
  final Rx<OfflineSpecialityModel?> selectedOfflineSpeciality = Rx<OfflineSpecialityModel?>(null);

  // ─── Offline: Nearby Doctors ─────────────────────────────────
  final RxList<NetworkDoctorModel> nearbyDoctors = <NetworkDoctorModel>[].obs;
  final RxList<NetworkDoctorModel> filteredNearbyDoctors = <NetworkDoctorModel>[].obs;
  final RxBool nearbyDoctorsLoading = false.obs;
  final Rx<NetworkDoctorModel?> selectedNetworkDoctor = Rx<NetworkDoctorModel?>(null);

  // ─── Offline: Network Schedules & Generated Slots ───────────
  final Rx<NetworkSlotsResponse?> networkSlotsResponse = Rx<NetworkSlotsResponse?>(null);
  final RxBool networkSchedulesLoading = false.obs;
  List<NetworkSchedule> _rawSchedules = [];
  final Rx<DateTime> offlineSelectedDate = DateTime.now().obs;
  final RxList<String> offlineAvailableSlots = <String>[].obs;
  final RxString selectedOfflineSlot = ''.obs;

  // ─── Common ──────────────────────────────────────────────────
  final RxBool isBooking = false.obs;
  final RxBool preselectedFlow = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args == 'virtual') {
      consultationType.value = ConsultationType.virtual_;
      preselectedFlow.value = true;
    } else if (args == 'hospital') {
      consultationType.value = ConsultationType.hospital;
      preselectedFlow.value = true;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ─── Navigation: Start flow ──────────────────────────────────

  void continuePreselectedFlow() {
    final mc = Get.find<MemberController>();
    if (mc.selectedUserId.value.isEmpty) {
      AppToast.error(title: 'Select Member', message: 'Please select a family member first');
      return;
    }
    if (isOnline) {
      startOnlineFlow();
    } else {
      startOfflineFlow();
    }
  }

  void startOnlineFlow() {
    consultationType.value = ConsultationType.virtual_;
    _resetOnlineState();
    Get.to(() => const SelectSpecialityScreen());
    fetchIssues();
  }

  void startOfflineFlow() {
    consultationType.value = ConsultationType.hospital;
    _resetOfflineState();
    Get.to(() => const SelectSpecialityScreen());
    fetchOfflineSpecialities();
  }

  // ─── Online: Issues (Specialities) ──────────────────────────

  Future<void> fetchIssues() async {
    issuesLoading.value = true;
    try {
      final result = await _repository.getIssues();
      allIssues.assignAll(result);
      filteredIssues.assignAll(result);
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to load issues');
    } finally {
      issuesLoading.value = false;
    }
  }

  void searchIssues(String query) {
    specialitySearchQuery.value = query;
    if (query.trim().isEmpty) {
      filteredIssues.assignAll(allIssues);
      return;
    }
    filteredIssues.assignAll(
      allIssues.where((i) => i.title.toLowerCase().contains(query.toLowerCase())).toList(),
    );
  }

  void selectIssue(IssueModel issue) {
    selectedIssue.value = issue;
    selectedOnlineDoctor.value = null;
    onlineDoctors.clear();
    filteredOnlineDoctors.clear();
    fetchDoctorsBySpeciality(issue.parent);
  }

  // ─── Online: Doctors by Speciality ───────────────────────────

  Future<void> fetchDoctorsBySpeciality(int specialityId) async {
    onlineDoctorsLoading.value = true;
    try {
      final result = await _repository.getDoctorsBySpeciality(specialityId);
      onlineDoctors.assignAll(result);
      filteredOnlineDoctors.assignAll(result);
      if (result.isNotEmpty) {
        selectedOnlineDoctor.value = result.first;
      }
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to load doctors');
    } finally {
      onlineDoctorsLoading.value = false;
    }
  }

  void searchOnlineDoctors(String query) {
    if (query.trim().isEmpty) {
      filteredOnlineDoctors.assignAll(onlineDoctors);
      return;
    }
    filteredOnlineDoctors.assignAll(
      onlineDoctors.where((d) => d.name.toLowerCase().contains(query.toLowerCase())).toList(),
    );
  }

  void selectOnlineDoctor(OnlineDoctorModel doctor) {
    selectedOnlineDoctor.value = doctor;
  }

  void continueOnlineFlow() {
    if (selectedOnlineDoctor.value == null && onlineDoctors.isNotEmpty) {
      selectedOnlineDoctor.value = onlineDoctors.first;
    }
    if (selectedOnlineDoctor.value == null) {
      AppToast.error(title: 'Error', message: 'No doctor available');
      return;
    }
    Get.to(() => const ConsultationSlotSelectionScreen());
    fetchAvailableSlots();
  }

  // ─── Online: Slots ───────────────────────────────────────────

  Future<void> fetchAvailableSlots({DateTime? date}) async {
    slotsLoading.value = true;
    selectedSlot.value = null;

    final d = date ?? selectedDate.value;
    selectedDate.value = d;

    final dateStr = DateFormat('yyyy-MM-dd').format(d);
    final spid = selectedIssue.value?.parent ?? 0;

    try {
      final result = await _repository.getAvailableSlots(
        date: dateStr,
        spid: spid,
        language: selectedLanguage.value,
      );
      availableSlots.assignAll(result);
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to load slots');
    } finally {
      slotsLoading.value = false;
    }
  }

  void selectSlot(SlotModel slot) {
    selectedSlot.value = slot;
  }

  void confirmOnlineSlotSelection() {
    if (selectedSlot.value == null) {
      AppToast.error(title: 'Error', message: 'Please select a time slot');
      return;
    }
    Get.to(() => const ConsultationBookingScreen());
  }

  // ─── Online: Booking ─────────────────────────────────────────

  Future<void> bookOnlineAppointment() async {
    final slot = selectedSlot.value;
    final issue = selectedIssue.value;
    final mc = Get.find<MemberController>();

    if (slot == null || issue == null) return;

    isBooking.value = true;
    try {
      final response = await _repository.bookOnlineAppointment(
        date: slot.date.isNotEmpty ? slot.date : DateFormat('yyyy-MM-dd').format(selectedDate.value),
        time: slot.time,
        language: selectedLanguage.value,
        patientId: mc.selectedUserId.value,
        issueId: issue.id,
        purpose: purposeController.text.trim(),
      );
      isBooking.value = false;
      Get.off(() => PaymentSuccessScreen(
        title: 'Appointment Booked!',
        subtitle: response.message,
      ));
    } catch (e) {
      isBooking.value = false;
      AppToast.error(title: 'Error', message: 'Booking failed. Please try again.');
    }
  }

  // ─── Offline: Specialities ───────────────────────────────────

  Future<void> fetchOfflineSpecialities() async {
    offlineSpecialitiesLoading.value = true;
    try {
      final result = await _repository.getOfflineSpecialities();
      offlineSpecialities.assignAll(result);
      filteredOfflineSpecialities.assignAll(result);
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to load specialities');
    } finally {
      offlineSpecialitiesLoading.value = false;
    }
  }

  void searchOfflineSpecialities(String query) {
    specialitySearchQuery.value = query;
    if (query.trim().isEmpty) {
      filteredOfflineSpecialities.assignAll(offlineSpecialities);
      return;
    }
    filteredOfflineSpecialities.assignAll(
      offlineSpecialities.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList(),
    );
  }

  void selectOfflineSpeciality(OfflineSpecialityModel speciality) {
    selectedOfflineSpeciality.value = speciality;
    Get.to(() => const DoctorListScreen());
    fetchNearbyDoctors();
  }

  // ─── Offline: Nearby Doctors ─────────────────────────────────

  Future<void> fetchNearbyDoctors() async {
    nearbyDoctorsLoading.value = true;
    try {
      final addressCtrl = Get.find<AddressController>();
      final addr = addressCtrl.selectedAddress.value;
      final location = addr?.location ?? '';
      final specId = selectedOfflineSpeciality.value?.id ?? 0;

      final result = await _repository.getNearbyDoctors(
        location: location,
        specialityId: specId,
      );
      nearbyDoctors.assignAll(result);
      filteredNearbyDoctors.assignAll(result);
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to load nearby doctors');
    } finally {
      nearbyDoctorsLoading.value = false;
    }
  }

  void searchNearbyDoctors(String query) {
    if (query.trim().isEmpty) {
      filteredNearbyDoctors.assignAll(nearbyDoctors);
      return;
    }
    filteredNearbyDoctors.assignAll(
      nearbyDoctors.where((d) =>
        d.name.toLowerCase().contains(query.toLowerCase()) ||
        (d.network?.name.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList(),
    );
  }

  void selectNetworkDoctor(NetworkDoctorModel doctor) {
    selectedNetworkDoctor.value = doctor;
    Get.to(() => const ConsultationSlotSelectionScreen());
    fetchNetworkSlots();
  }

  // ─── Offline: Network Slots / Schedules ──────────────────────

  Future<void> fetchNetworkSlots() async {
    networkSchedulesLoading.value = true;
    _rawSchedules = [];
    offlineAvailableSlots.clear();
    selectedOfflineSlot.value = '';

    try {
      final networkId = selectedNetworkDoctor.value?.networkId ?? '';
      final doctorId = selectedNetworkDoctor.value?.id ?? 0;

      final result = await _repository.getNetworkSlots(
        networkId: networkId,
        doctorId: doctorId,
      );
      networkSlotsResponse.value = result;

      if (result.doctors.isNotEmpty) {
        _rawSchedules = result.doctors.first.schedules;
      }

      final skipDays = DateTime.now().hour < 19 ? 1 : 2;
      final defaultDate = DateTime.now().add(Duration(days: skipDays));
      offlineSelectedDate.value = defaultDate;
      _generateSlotsForDate(defaultDate);
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to load schedule');
    } finally {
      networkSchedulesLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get offlineNextDays {
    final now = DateTime.now();
    final skipDays = now.hour < 19 ? 1 : 2;
    return List.generate(5, (i) {
      final d = now.add(Duration(days: i + skipDays));
      return {
        'date': d.day.toString(),
        'weekday': DateFormat('EEE').format(d),
        'dateTime': d,
        'full': DateFormat('yyyy-MM-dd').format(d),
      };
    });
  }

  void selectOfflineDate(DateTime date) {
    offlineSelectedDate.value = date;
    selectedOfflineSlot.value = '';
    _generateSlotsForDate(date);
  }

  void selectOfflineTimeSlot(String slot) {
    selectedOfflineSlot.value = slot;
  }

  void _generateSlotsForDate(DateTime date) {
    offlineAvailableSlots.clear();
    final weekdayName = DateFormat('EEEE').format(date);

    for (final schedule in _rawSchedules) {
      if (schedule.day != weekdayName) continue;
      if (schedule.timings.isEmpty) break;

      for (final timing in schedule.timings) {
        final start24 = _parseTimeTo24h(timing.opening);
        final end24 = _parseTimeTo24h(timing.closing);
        if (start24 == null || end24 == null) continue;

        final slots = _generateIntervalSlots(start24, end24, date);
        offlineAvailableSlots.addAll(slots);
      }
      break;
    }
  }

  /// Parses "10:00 AM" or "04:00 PM" to 24h "HH:mm" string.
  String? _parseTimeTo24h(String timeStr) {
    final cleaned = timeStr.trim();
    if (cleaned.isEmpty) return null;

    final parts = cleaned.split(' ');
    if (parts.length < 2) return null;

    final timeParts = parts[0].split(':');
    if (timeParts.length < 2) return null;

    var hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final amPm = parts[1].toUpperCase();

    if (amPm == 'PM' && hour >= 1 && hour <= 11) hour += 12;
    if (amPm == 'AM' && hour == 12) hour = 0;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Generates 15-minute interval slots between start and end times.
  /// Filters out slots less than 24 hours from now.
  List<String> _generateIntervalSlots(String start24, String end24, DateTime date) {
    final startParts = start24.split(':');
    final endParts = end24.split(':');

    var startHour = int.parse(startParts[0]);
    var startMin = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMin = int.parse(endParts[1]);

    final slots = <String>[];
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    while (startHour < endHour || (startHour == endHour && startMin < endMin)) {
      final slotStr = '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}';
      final slotDateTime = DateTime.parse('$dateStr $slotStr:00');

      if (slotDateTime.difference(now).inHours >= 24) {
        slots.add(slotStr);
      }

      startMin += 15;
      if (startMin >= 60) {
        startHour += 1;
        startMin -= 60;
      }
    }
    return slots;
  }

  List<String> get offlineMorningSlots =>
      offlineAvailableSlots.where((s) {
        final h = int.parse(s.split(':')[0]);
        return h < 12;
      }).toList();

  List<String> get offlineAfternoonSlots =>
      offlineAvailableSlots.where((s) {
        final h = int.parse(s.split(':')[0]);
        return h >= 12 && h < 17;
      }).toList();

  List<String> get offlineEveningSlots =>
      offlineAvailableSlots.where((s) {
        final h = int.parse(s.split(':')[0]);
        return h >= 17;
      }).toList();

  /// Converts 24h "HH:mm" to 12h display "h:mm AM/PM".
  String to12HourFormat(String slot24) {
    final parts = slot24.split(':');
    var h = int.parse(parts[0]);
    final m = parts[1];
    final amPm = h >= 12 ? 'PM' : 'AM';
    if (h == 0) h = 12;
    if (h > 12) h -= 12;
    return '$h:$m $amPm';
  }

  void confirmOfflineSlotSelection() {
    if (selectedOfflineSlot.value.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please select a time slot');
      return;
    }
    Get.to(() => const ConsultationBookingScreen());
  }

  // ─── Offline: Booking ────────────────────────────────────────

  Future<void> bookOfflineAppointment() async {
    final doctor = selectedNetworkDoctor.value;
    final spec = selectedOfflineSpeciality.value;

    if (doctor == null || spec == null || selectedOfflineSlot.value.isEmpty) return;

    isBooking.value = true;
    try {
      final addressCtrl = Get.find<AddressController>();
      final addrId = addressCtrl.selectedAddress.value?.id ?? '';

      final dateStr = DateFormat('yyyy-MM-dd').format(offlineSelectedDate.value);
      final timeSlot = '$dateStr ${selectedOfflineSlot.value}';

      final response = await _repository.bookOfflineAppointment(
        doctorId: doctor.id,
        networkId: doctor.networkId,
        timeSlot: timeSlot,
        specialityId: spec.id,
        addressId: addrId,
        patientId: Get.find<MemberController>().selectedUserId.value,
      );
      isBooking.value = false;
      Get.off(() => PaymentSuccessScreen(
        title: 'Appointment Booked!',
        subtitle: response.message,
      ));
    } catch (e) {
      isBooking.value = false;
      AppToast.error(title: 'Error', message: 'Booking failed. Please try again.');
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────

  String get formattedSelectedDate =>
      DateFormat('dd MMM, yyyy').format(selectedDate.value);

  String get selectedTimeDisplay =>
      selectedSlot.value?.displayTime ?? selectedSlot.value?.time ?? '';

  String get offlineTimeDisplay => selectedOfflineSlot.value.isNotEmpty
      ? to12HourFormat(selectedOfflineSlot.value)
      : '';

  String get offlineDayDisplay =>
      DateFormat('dd MMM, yyyy').format(offlineSelectedDate.value);

  void _resetOnlineState() {
    allIssues.clear();
    filteredIssues.clear();
    selectedIssue.value = null;
    onlineDoctors.clear();
    filteredOnlineDoctors.clear();
    selectedOnlineDoctor.value = null;
    availableSlots.clear();
    selectedSlot.value = null;
    selectedDate.value = DateTime.now();
    purposeController.clear();
  }

  void _resetOfflineState() {
    offlineSpecialities.clear();
    filteredOfflineSpecialities.clear();
    selectedOfflineSpeciality.value = null;
    nearbyDoctors.clear();
    filteredNearbyDoctors.clear();
    selectedNetworkDoctor.value = null;
    networkSlotsResponse.value = null;
    _rawSchedules = [];
    offlineAvailableSlots.clear();
    selectedOfflineSlot.value = '';
    purposeController.clear();
  }

  /// Generates date chips for the next 7 days (for online slot selection).
  List<Map<String, String>> get nextSevenDays {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.add(Duration(days: i));
      return {
        'day': DateFormat('dd').format(d),
        'weekday': DateFormat('EEE').format(d),
        'full': DateFormat('yyyy-MM-dd').format(d),
      };
    });
  }
}
