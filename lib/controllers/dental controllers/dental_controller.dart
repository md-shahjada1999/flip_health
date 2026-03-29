import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class DentalController extends GetxController {
  final isLoading = false.obs;
  final selectedUserId = ''.obs;
  final familyMembers = <FamilyMember>[].obs;

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

  // Overview state
  final alternatePhoneController = TextEditingController();
  final selectedDateTimeDisplay = ''.obs;

  List<FamilyMember> get sponsoredMembers =>
      familyMembers.where((m) => m.isSponsored).toList();

  List<FamilyMember> get nonSponsoredMembers =>
      familyMembers.where((m) => !m.isSponsored).toList();

  VendorModel? get selectedVendor {
    final idx = vendors.indexWhere((v) => v.id == selectedVendorId.value);
    return idx != -1 ? vendors[idx] : null;
  }

  FamilyMember? get selectedMember {
    final idx = familyMembers.indexWhere((m) => m.id == selectedUserId.value);
    return idx != -1 ? familyMembers[idx] : null;
  }

  @override
  void onInit() {
    super.onInit();
    _loadFamilyMembers();
  }

  void _loadFamilyMembers() {
    isLoading.value = true;
    familyMembers.value = [
      FamilyMember(id: '1', name: 'Kalyan', isSponsored: true, sponsoredBy: 'Acme Corp'),
      FamilyMember(id: '2', name: 'Priya', isSponsored: false, hasPackages: true),
      FamilyMember(id: '3', name: 'Rahul', isSponsored: false, hasPackages: false),
    ];
    isLoading.value = false;
  }

  bool isUserSelected(String id) => selectedUserId.value == id;

  void selectUser(String id) => selectedUserId.value = id;

  void addNewFamilyMember() => Get.toNamed(AppRoutes.addFamilyMember);

  void continueToVendors() {
    _loadVendors();
  }

  void _loadVendors() {
    vendorsLoading.value = true;
    vendors.value = [
      VendorModel(
        id: 'v1',
        name: 'Smile Dental Clinic',
        address: 'Plot 42, Road No. 5, Jubilee Hills',
        city: 'Hyderabad',
        distance: '2.5',
        phone: '9876543210',
      ),
      VendorModel(
        id: 'v2',
        name: 'Apollo Dental Care',
        address: 'Banjara Hills, Road No. 12',
        city: 'Hyderabad',
        distance: '4.8',
        phone: '9876543211',
      ),
      VendorModel(
        id: 'v3',
        name: 'Clove Dental',
        address: 'Madhapur, Hitec City Main Road',
        city: 'Hyderabad',
        distance: '6.1',
        phone: '9876543212',
      ),
    ];
    vendorsLoading.value = false;
  }

  void selectVendor(String id) => selectedVendorId.value = id;

  void continueToSlots() {
    _loadSlots();
  }

  void _loadSlots() {
    final now = DateTime.now().add(const Duration(days: 1));
    monthYearLabel.value =
        '${_monthName(now.month)} ${now.year}';
    availableDates.value = List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      return {
        'day': '${date.day}',
        'weekday': _weekdayName(date.weekday),
      };
    });
    morningSlots.value = [
      {'time': '9:00 AM', 'isDisabled': false},
      {'time': '9:30 AM', 'isDisabled': false},
      {'time': '10:00 AM', 'isDisabled': false},
      {'time': '10:30 AM', 'isDisabled': true},
      {'time': '11:00 AM', 'isDisabled': false},
      {'time': '11:30 AM', 'isDisabled': false},
    ];
    afternoonSlots.value = [
      {'time': '2:00 PM', 'isDisabled': false},
      {'time': '2:30 PM', 'isDisabled': false},
      {'time': '3:00 PM', 'isDisabled': false},
      {'time': '3:30 PM', 'isDisabled': true},
      {'time': '4:00 PM', 'isDisabled': false},
    ];
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

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  void onClose() {
    alternatePhoneController.dispose();
    super.onClose();
  }
}
