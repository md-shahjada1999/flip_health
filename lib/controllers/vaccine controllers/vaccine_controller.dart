import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/data/repositories/vaccine_repository.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class VaccineType {
  final String id;
  final String name;
  final String description;

  const VaccineType({
    required this.id,
    required this.name,
    required this.description,
  });
}

class VaccineController extends GetxController {
  final VaccineRepository _repository;
  VaccineController({required VaccineRepository repository}) : _repository = repository;
  final isLoading = false.obs;

  // Vaccine types
  final vaccineTypes = <VaccineType>[].obs;
  final selectedVaccineIds = <String>{}.obs;

  // Vendor state
  final vendors = <VendorModel>[].obs;
  final selectedVendorId = ''.obs;
  final vendorsLoading = false.obs;

  // Slot state
  final selectedDateIndex = 0.obs;
  final selectedTimeSlot = ''.obs;
  final monthYearLabel = ''.obs;
  final availableDates = <Map<String, String>>[].obs;
  final morningSlots = <Map<String, dynamic>>[].obs;
  final afternoonSlots = <Map<String, dynamic>>[].obs;

  // Overview state
  final alternatePhoneController = TextEditingController();
  final selectedDateTimeDisplay = ''.obs;

  VendorModel? get selectedVendor {
    final idx = vendors.indexWhere((v) => v.id == selectedVendorId.value);
    return idx != -1 ? vendors[idx] : null;
  }

  List<VaccineType> get selectedVaccines =>
      vaccineTypes.where((v) => selectedVaccineIds.contains(v.id)).toList();

  @override
  void onInit() {
    super.onInit();
    _loadVaccineTypes();
  }

  Future<void> _loadVaccineTypes() async {
    vaccineTypes.value = await _repository.getVaccineTypes();
  }

  void toggleVaccine(String id) {
    if (selectedVaccineIds.contains(id)) {
      selectedVaccineIds.remove(id);
    } else {
      selectedVaccineIds.add(id);
    }
  }

  bool isVaccineSelected(String id) => selectedVaccineIds.contains(id);

  void continueToVaccineTypes() {
    selectedVaccineIds.clear();
  }

  void continueToVendors() {
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    vendorsLoading.value = true;
    vendors.value = await _repository.getVendors();
    vendorsLoading.value = false;
  }

  void selectVendor(String id) => selectedVendorId.value = id;

  void continueToSlots() {
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final result = await _repository.getAvailableSlots();
    monthYearLabel.value = result['monthYearLabel'] as String;
    availableDates.value = List<Map<String, String>>.from(
      (result['availableDates'] as List).map((e) => Map<String, String>.from(e)),
    );
    morningSlots.value = List<Map<String, dynamic>>.from(result['morningSlots']);
    afternoonSlots.value = List<Map<String, dynamic>>.from(result['afternoonSlots']);
    selectedDateIndex.value = 0;
    selectedTimeSlot.value = '';
  }

  void selectDate(int index) => selectedDateIndex.value = index;

  void selectTimeSlot(String time) {
    selectedTimeSlot.value = time;
    final dateMap = availableDates[selectedDateIndex.value];
    selectedDateTimeDisplay.value =
        '${dateMap['day']} ${dateMap['weekday']}, ${monthYearLabel.value} | $time';
  }

  void confirmBooking() {
    Get.offAllNamed(AppRoutes.dashboard);
  }

  @override
  void onClose() {
    alternatePhoneController.dispose();
    super.onClose();
  }
}
