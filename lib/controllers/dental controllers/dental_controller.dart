import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/data/repositories/dental_repository.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';
import 'package:flip_health/core/services/app_exception.dart';

class DentalController extends GetxController {
  final DentalRepository _repository;
  DentalController({required DentalRepository repository}) : _repository = repository;
  final isLoading = false.obs;

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
  final eveningSlots = <Map<String, dynamic>>[].obs;
  final slotDateStrings = <String>[].obs;

  // Full DateTime objects for each date in the rolling window
  final _wholeDates = <DateTime>[];

  // Overview / booking
  final alternatePhoneController = TextEditingController();
  final selectedDateTimeDisplay = ''.obs;
  final confirmBookingLoading = false.obs;

  VendorModel? get selectedVendor {
    final idx = vendors.indexWhere((v) => v.id == selectedVendorId.value);
    return idx != -1 ? vendors[idx] : null;
  }

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
      AppToast.error(
        title: 'Address',
        message: 'Select an address with map location to find nearby clinics',
      );
      vendors.clear();
      selectedVendorId.value = '';
      return;
    }
    final location = '$lat,$lng';

    vendorsLoading.value = true;
    try {
      vendors.value = await _repository.getVendors(location);
      selectedVendorId.value = '';
    } on AppException catch (e) {
      AppToast.error(title: 'Clinics', message: e.message);
      vendors.clear();
    } catch (e) {
      AppToast.error(title: 'Error', message: e.toString());
      vendors.clear();
    } finally {
      vendorsLoading.value = false;
    }
  }

  void selectVendor(String id) => selectedVendorId.value = id;

  void continueToSlots() {
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final result = _repository.getDays();
    monthYearLabel.value = result['monthYearLabel'] as String;
    availableDates.value = List<Map<String, String>>.from(
      (result['availableDates'] as List).map((e) => Map<String, String>.from(e)),
    );
    slotDateStrings.value = List<String>.from(result['calendarDateStrings'] as List);
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

  Map<String, dynamic> _centerPayload(VendorModel v) {
    return {
      'name': v.name,
      'phone': v.phone ?? '',
      'address': {
        'line_1': v.address,
        'city': v.city,
        'pincode': v.pin,
      },
    };
  }

  Future<void> confirmBooking() async {
    final vendor = selectedVendor;
    if (vendor == null) {
      AppToast.error(title: 'Booking', message: 'Select a clinic');
      return;
    }
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

    final clinicId = vendor.clinicId.isNotEmpty ? vendor.clinicId : vendor.id;
    final providerId =
        vendor.providerId.isNotEmpty ? vendor.providerId : clinicId;

    confirmBookingLoading.value = true;
    try {
      await _repository.bookDentalService(
        addressId: addr.id,
        preferredDateTime: preferred,
        userId: member.id,
        providerId: providerId,
        clinicId: clinicId,
        alternatePhone: alternatePhoneController.text.trim(),
        center: _centerPayload(vendor),
      );
      Get.to(() => const PaymentSuccessScreen());
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
