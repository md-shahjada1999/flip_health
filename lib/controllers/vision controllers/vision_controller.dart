import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/data/repositories/vision_repository.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class VisionController extends GetxController {
  final VisionRepository _repository;
  VisionController({required VisionRepository repository}) : _repository = repository;
  final isLoading = false.obs;

  // 'eye_checkup' or 'glasses_lens'
  final visionType = 'eye_checkup'.obs;

  bool get isEyeCheckup => visionType.value == 'eye_checkup';

  String get appBarTitle => isEyeCheckup ? 'Eye Checkup' : 'Glasses/Lens';

  String get vendorListTitle => isEyeCheckup ? 'Select Hospital' : 'Select Store';

  // Vendor state
  final vendors = <VendorModel>[].obs;
  final selectedVendorId = ''.obs;
  final vendorsLoading = false.obs;

  // Slot state
  final selectedDateIndex = 0.obs;
  final selectedTimeSlot = ''.obs;
  final monthYearLabel = 'April 2024'.obs;
  final availableDates = <Map<String, String>>[].obs;
  final morningSlots = <Map<String, dynamic>>[].obs;
  final afternoonSlots = <Map<String, dynamic>>[].obs;

  // Prescription state
  final uploadedFiles = <Map<String, dynamic>>[].obs;

  // Overview state
  final alternatePhoneController = TextEditingController();
  final selectedDateTimeDisplay = ''.obs;

  VendorModel? get selectedVendor {
    final idx = vendors.indexWhere((v) => v.id == selectedVendorId.value);
    return idx != -1 ? vendors[idx] : null;
  }

  void continueToVendors() {
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    vendorsLoading.value = true;
    vendors.value = await _repository.getVendors(isEyeCheckup: isEyeCheckup);
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

  // Prescription
  Future<void> pickFromGallery() async {
    final file = await FilePickerHelper.pickFromGallery();
    if (file != null) uploadedFiles.add(file.toMap());
  }

  Future<void> pickFromCamera() async {
    final file = await FilePickerHelper.pickFromCamera();
    if (file != null) uploadedFiles.add(file.toMap());
  }

  void removePrescriptionFile(int index) {
    uploadedFiles.removeAt(index);
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
