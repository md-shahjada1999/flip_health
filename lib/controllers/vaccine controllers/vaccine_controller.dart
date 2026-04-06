import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/data/repositories/upload_repository.dart';
import 'package:flip_health/data/repositories/vaccine_repository.dart';
import 'package:flip_health/model/vvd%20models/vaccine_type_model.dart';
import 'package:flip_health/core/services/app_exception.dart';

class VaccineController extends GetxController {
  final VaccineRepository _repository;
  final UploadRepository _uploadRepository;

  VaccineController({
    required VaccineRepository repository,
    required UploadRepository uploadRepository,
  })  : _repository = repository,
        _uploadRepository = uploadRepository;

  final isLoading = false.obs;

  // Vaccine types (multi-select)
  final vaccineTypes = <VaccineType>[].obs;
  final selectedVaccineIds = <int>{}.obs;

  // Slot state
  final selectedDateIndex = 0.obs;
  final selectedTimeSlot = ''.obs;
  final monthYearLabel = ''.obs;
  final availableDates = <Map<String, String>>[].obs;
  final morningSlots = <Map<String, dynamic>>[].obs;
  final afternoonSlots = <Map<String, dynamic>>[].obs;
  final eveningSlots = <Map<String, dynamic>>[].obs;
  final slotDateStrings = <String>[].obs;

  final _wholeDates = <DateTime>[];

  // Overview / booking
  final alternatePhoneController = TextEditingController();
  final selectedDateTimeDisplay = ''.obs;
  final confirmBookingLoading = false.obs;

  // Prescription (required when selected member age <= 5)
  final prescriptionFile = Rxn<PickedFileInfo>();
  final prescriptionAttachmentId = ''.obs;
  final prescriptionUploading = false.obs;

  List<VaccineType> get selectedVaccines =>
      vaccineTypes.where((v) => selectedVaccineIds.contains(v.id)).toList();

  List<int> get selectedVaccineTypeIds => selectedVaccineIds.toList();

  bool get needsPrescription {
    if (!Get.isRegistered<MemberController>()) return false;
    final member = Get.find<MemberController>().selectedMember;
    if (member == null) return false;
    return member.age >= 0 && member.age <= 5;
  }

  @override
  void onInit() {
    super.onInit();
    _loadVaccineTypes();
  }

  Future<void> _loadVaccineTypes() async {
    isLoading.value = true;
    try {
      vaccineTypes.value = await _repository.getVaccineTypes();
    } on AppException catch (e) {
      AppToast.error(title: 'Vaccines', message: e.message);
    } catch (_) {
      AppToast.error(title: 'Error', message: 'Failed to load vaccine types');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleVaccine(int id) {
    if (selectedVaccineIds.contains(id)) {
      selectedVaccineIds.remove(id);
    } else {
      selectedVaccineIds.add(id);
    }
  }

  bool isVaccineSelected(int id) => selectedVaccineIds.contains(id);

  void continueToVaccineTypes() {
    selectedVaccineIds.clear();
  }

  void continueToSlots() {
    _loadSlots();
  }

  void _loadSlots() {
    final result = _repository.getDays();
    monthYearLabel.value = result['monthYearLabel'] as String;
    availableDates.value = List<Map<String, String>>.from(
      (result['availableDates'] as List)
          .map((e) => Map<String, String>.from(e)),
    );
    slotDateStrings.value =
        List<String>.from(result['calendarDateStrings'] as List);
    _wholeDates
      ..clear()
      ..addAll(List<DateTime>.from(result['wholeDates'] as List));

    selectedDateIndex.value = 0;
    selectedTimeSlot.value = '';
    selectedDateTimeDisplay.value = '';
    _fetchSlotsForSelectedDate();
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
    selectedTimeSlot.value = '';
    selectedDateTimeDisplay.value = '';
    _fetchSlotsForSelectedDate();
  }

  void _fetchSlotsForSelectedDate() {
    if (_wholeDates.isEmpty) return;
    final date = _wholeDates[selectedDateIndex.value];
    final slots = _repository.getSlotsForDate(date);
    morningSlots.value = slots['morningSlots'] ?? [];
    afternoonSlots.value = slots['afternoonSlots'] ?? [];
    eveningSlots.value = slots['eveningSlots'] ?? [];
  }

  void selectTimeSlot(String time) {
    selectedTimeSlot.value = time;
    final dateMap = availableDates[selectedDateIndex.value];
    selectedDateTimeDisplay.value =
        '${dateMap['day']} ${dateMap['weekday']}, ${monthYearLabel.value} | $time';
  }

  String? _preferredDateTimeForApi() {
    if (selectedTimeSlot.value.isEmpty) return null;
    final i = selectedDateIndex.value;
    if (i < 0 || i >= slotDateStrings.length) return null;
    final t = _parse12hSlot(selectedTimeSlot.value);
    if (t == null) return null;
    final datePart = slotDateStrings[i];
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$datePart $hh:$mm:00';
  }

  static TimeOfDay? _parse12hSlot(String raw) {
    final s = raw.trim().toUpperCase().replaceAll('.', '');
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(s);
    if (match == null) return null;
    var hour = int.tryParse(match.group(1)!) ?? 0;
    final minute = int.tryParse(match.group(2)!) ?? 0;
    final ap = match.group(3)!;
    if (ap == 'PM' && hour != 12) hour += 12;
    if (ap == 'AM' && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // --- Prescription upload ---

  void pickPrescription() {
    FilePickerHelper.showPickerBottomSheet(
      onFilePicked: (file) => _uploadPrescription(file),
    );
  }

  Future<void> _uploadPrescription(PickedFileInfo file) async {
    prescriptionFile.value = file;
    prescriptionUploading.value = true;
    try {
      final result = await _uploadRepository.uploadFile(
        filePath: file.path,
        type: 'prescription',
      );
      prescriptionAttachmentId.value = result.id;
    } on AppException catch (e) {
      AppToast.error(title: 'Upload', message: e.message);
      prescriptionFile.value = null;
      prescriptionAttachmentId.value = '';
    } catch (e) {
      AppToast.error(title: 'Upload', message: 'Upload failed');
      prescriptionFile.value = null;
      prescriptionAttachmentId.value = '';
    } finally {
      prescriptionUploading.value = false;
    }
  }

  void removePrescription() {
    prescriptionFile.value = null;
    prescriptionAttachmentId.value = '';
  }

  // --- Booking ---

  Future<void> confirmBooking() async {
    if (!Get.isRegistered<MemberController>()) {
      AppToast.error(title: 'Booking', message: 'Member data not loaded');
      return;
    }
    final member = Get.find<MemberController>().selectedMember;
    if (member == null || member.id.isEmpty) {
      AppToast.error(title: 'Booking', message: 'Select a member');
      return;
    }
    if (!Get.isRegistered<AddressController>()) {
      AppToast.error(title: 'Booking', message: 'Address not available');
      return;
    }
    final addr = Get.find<AddressController>().selectedAddress.value;
    if (addr == null || addr.id.isEmpty) {
      AppToast.error(title: 'Booking', message: 'Select an address');
      return;
    }
    final preferred = _preferredDateTimeForApi();
    if (preferred == null) {
      AppToast.error(title: 'Booking', message: 'Select date and time');
      return;
    }
    if (selectedVaccineIds.isEmpty) {
      AppToast.error(
          title: 'Booking', message: 'Select at least one vaccine');
      return;
    }
    if (needsPrescription && prescriptionAttachmentId.value.isEmpty) {
      AppToast.error(
          title: 'Booking',
          message: 'Prescription is required for children age 5 or below');
      return;
    }

    confirmBookingLoading.value = true;
    try {
      final attachments = prescriptionAttachmentId.value.isNotEmpty
          ? [prescriptionAttachmentId.value]
          : <String>[];

      await _repository.bookVaccineService(
        addressId: addr.id,
        preferredDateTime: preferred,
        userId: member.id,
        vaccineTypeIds: selectedVaccineTypeIds,
        alternatePhone: alternatePhoneController.text.trim(),
        attachmentIds: attachments,
      );
      Get.to(() => PaymentSuccessScreen());
    } on AppException catch (e) {
      AppToast.error(title: 'Booking', message: e.message);
    } catch (e) {
      AppToast.error(title: 'Booking', message: e.toString());
    } finally {
      confirmBookingLoading.value = false;
    }
  }

  @override
  void onClose() {
    alternatePhoneController.dispose();
    super.onClose();
  }
}
