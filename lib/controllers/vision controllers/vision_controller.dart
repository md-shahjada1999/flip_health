import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/data/repositories/upload_repository.dart';
import 'package:flip_health/data/repositories/vision_repository.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';
import 'package:flip_health/core/services/app_exception.dart';

class VisionController extends GetxController {
  final VisionRepository _repository;
  final UploadRepository _uploadRepository;

  VisionController({
    required VisionRepository repository,
    required UploadRepository uploadRepository,
  })  : _repository = repository,
        _uploadRepository = uploadRepository;

  final isLoading = false.obs;

  // 'eye_checkup' or 'glasses_lens'
  final visionType = 'eye_checkup'.obs;

  bool get isEyeCheckup => visionType.value == 'eye_checkup';

  String get appBarTitle => isEyeCheckup ? 'Eye Checkup' : 'Glasses/Lens';

  String get vendorListTitle =>
      isEyeCheckup ? 'Select Hospital' : 'Select Store';

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
  final eveningSlots = <Map<String, dynamic>>[].obs;
  final slotDateStrings = <String>[].obs;

  // All slot data from API, kept for per-date filtering
  final _allMorningSlots = <Map<String, dynamic>>[];
  final _allAfternoonSlots = <Map<String, dynamic>>[];
  final _allEveningSlots = <Map<String, dynamic>>[];

  // Selected slot's full data for booking payload
  Map<String, dynamic>? _selectedSlotData;

  // Prescription state (lens flow)
  final prescriptionFiles = <PickedFileInfo>[].obs;
  final prescriptionAttachmentIds = <String>[].obs;
  final prescriptionUploading = false.obs;

  // Overview / booking
  final alternatePhoneController = TextEditingController();
  final selectedDateTimeDisplay = ''.obs;
  final confirmBookingLoading = false.obs;

  VendorModel? get selectedVendor {
    final idx = vendors.indexWhere((v) => v.id == selectedVendorId.value);
    return idx != -1 ? vendors[idx] : null;
  }

  // --- Vendors ---

  void continueToVendors() {
    loadVendorsFromSelectedAddress();
  }

  Future<void> loadVendorsFromSelectedAddress() async {
    if (!Get.isRegistered<AddressController>()) {
      AppToast.error(title: 'Error', message: 'Address is not available');
      return;
    }
    final addr = Get.find<AddressController>().selectedAddress.value;
    final lat = addr?.latitude;
    final lng = addr?.longitude;
    if (addr == null || lat == null || lng == null) {
     
      vendors.clear();
      selectedVendorId.value = '';
      return;
    }
    final location = '$lat,$lng';

    vendorsLoading.value = true;
    try {
      vendors.value = await _repository.getVendors(
        location,
        isEyeCheckup: isEyeCheckup,
      );
      selectedVendorId.value = '';
    } on AppException catch (e) {
      AppToast.error(title: 'Vendors', message: e.message);
      vendors.clear();
    } catch (e) {
      AppToast.error(title: 'Error', message: e.toString());
      vendors.clear();
    } finally {
      vendorsLoading.value = false;
    }
  }

  void selectVendor(String id) => selectedVendorId.value = id;

  // --- Slots ---

  void continueToSlots() {
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    isLoading.value = true;
    try {
      final result = await _repository.getSlots();
      monthYearLabel.value = result['monthYearLabel'] as String;
      availableDates.value = List<Map<String, String>>.from(
        (result['availableDates'] as List)
            .map((e) => Map<String, String>.from(e)),
      );
      slotDateStrings.value =
          List<String>.from(result['daysList'] as List);

      _allMorningSlots
        ..clear()
        ..addAll(List<Map<String, dynamic>>.from(
            result['morningSlots'] as List));
      _allAfternoonSlots
        ..clear()
        ..addAll(List<Map<String, dynamic>>.from(
            result['afternoonSlots'] as List));
      _allEveningSlots
        ..clear()
        ..addAll(List<Map<String, dynamic>>.from(
            result['eveningSlots'] as List));

      selectedDateIndex.value = 0;
      selectedTimeSlot.value = '';
      selectedDateTimeDisplay.value = '';
      _selectedSlotData = null;
      _filterSlotsForSelectedDate();
    } on AppException catch (e) {
      AppToast.error(title: 'Slots', message: e.message);
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to load slots');
    } finally {
      isLoading.value = false;
    }
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
    selectedTimeSlot.value = '';
    selectedDateTimeDisplay.value = '';
    _selectedSlotData = null;
    _filterSlotsForSelectedDate();
  }

  void _filterSlotsForSelectedDate() {
    if (slotDateStrings.isEmpty) return;
    final dateStr = slotDateStrings[selectedDateIndex.value];

    List<Map<String, dynamic>> filterByDate(List<Map<String, dynamic>> all) {
      return all
          .where((s) => s['slot_date'] == dateStr)
          .toList();
    }

    morningSlots.value = filterByDate(_allMorningSlots);
    afternoonSlots.value = filterByDate(_allAfternoonSlots);
    eveningSlots.value = filterByDate(_allEveningSlots);
  }

  void selectTimeSlot(String time) {
    selectedTimeSlot.value = time;
    final dateMap = availableDates[selectedDateIndex.value];
    selectedDateTimeDisplay.value =
        '${dateMap['day']} ${dateMap['weekday']}, ${monthYearLabel.value} | $time';

    // Find the full slot data for booking
    final allSlots = [
      ...morningSlots,
      ...afternoonSlots,
      ...eveningSlots,
    ];
    _selectedSlotData = allSlots.firstWhereOrNull(
      (s) => s['time'] == time,
    );
  }

  // --- Prescription (lens flow) ---

  void pickPrescription() {
    FilePickerHelper.showPickerBottomSheet(
      onFilePicked: (file) => _uploadPrescription(file),
    );
  }

  Future<void> _uploadPrescription(PickedFileInfo file) async {
    prescriptionUploading.value = true;
    try {
      final result = await _uploadRepository.uploadFile(
        filePath: file.path,
        type: 'prescription',
      );
      prescriptionFiles.add(file);
      prescriptionAttachmentIds.add(result.id);
    } on AppException catch (e) {
      AppToast.error(title: 'Upload', message: e.message);
    } catch (e) {
      AppToast.error(title: 'Upload', message: 'Upload failed');
    } finally {
      prescriptionUploading.value = false;
    }
  }

  void removePrescription(int index) {
    if (index < prescriptionFiles.length) {
      prescriptionFiles.removeAt(index);
    }
    if (index < prescriptionAttachmentIds.length) {
      prescriptionAttachmentIds.removeAt(index);
    }
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
    if (_selectedSlotData == null) {
      AppToast.error(title: 'Booking', message: 'Select a time slot');
      return;
    }
    if (!isEyeCheckup && prescriptionAttachmentIds.isEmpty) {
      AppToast.error(
        title: 'Booking',
        message: 'Please upload a prescription',
      );
      return;
    }

    final slotPayload = {
      'slot_id': _selectedSlotData!['slot_id'] ?? '',
      'slot_date': _selectedSlotData!['slot_date'] ?? '',
      'start_time': _selectedSlotData!['start_time'] ?? '',
      'end_time': _selectedSlotData!['end_time'] ?? '',
    };

    final prescriptionPayload = prescriptionAttachmentIds
        .map((id) => {'id': id})
        .toList();

    confirmBookingLoading.value = true;
    try {
      await _repository.bookVisionService(
        bookingType: isEyeCheckup ? 'clinic' : 'store',
        userId: int.tryParse(member.id) ?? 0,
        addressId: addr.id,
        slot: slotPayload,
        networkId: selectedVendorId.value,
        prescription: prescriptionPayload,
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
