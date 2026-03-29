import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/daignostics/health_checkup/explore_health_packages_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_checkup_overview_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_selection_slot_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/select_plan_page.dart';

class HealthCheckupsController extends GetxController {
  // Observable variables
  final RxString selectedUserId = ''.obs;
  final RxList<FamilyMember> familyMembers = <FamilyMember>[].obs;
  final RxBool isLoading = false.obs;
  var selectedPackageIndex = (-1).obs;
  var isHomeCollection = true.obs;
  // Observable variables for slot selection
final RxInt selectedDateIndex = 0.obs;
final RxString selectedTimeSlot = ''.obs;
final RxString selectedMonthYear = 'Sept 2025 ( IST )'.obs;


// Available dates
final RxList<Map<String, String>> availableDates = <Map<String, String>>[
  {'day': '10', 'weekday': 'Mon'},
  {'day': '11', 'weekday': 'Tue'},
  {'day': '12', 'weekday': 'Wed'},
  {'day': '13', 'weekday': 'Thu'},
  {'day': '14', 'weekday': 'Fri'},
].obs;

// Morning time slots
final List<Map<String, dynamic>> morningSlots = [
  {'time': '7 AM-8 AM', 'isDisabled': false},
  {'time': '8 AM-9 AM', 'isDisabled': false},
  {'time': '9 AM-10 AM', 'isDisabled': true},
  {'time': '10 AM-11 AM', 'isDisabled': false},
  {'time': '11 AM-12 PM', 'isDisabled': false},
];

// Afternoon time slots
final List<Map<String, dynamic>> afternoonSlots = [
  {'time': '7 AM-8 AM', 'isDisabled': false},
  {'time': '8 AM-9 AM', 'isDisabled': false},
  {'time': '9 AM-10 AM', 'isDisabled': false},
  {'time': '10 AM-11 AM', 'isDisabled': false},
  {'time': '11 AM-12 PM', 'isDisabled': false},
];

  @override
  void onInit() {
    super.onInit();
    loadFamilyMembers();
  }

  // Load family members (replace with actual API call)
  void loadFamilyMembers() {
    isLoading.value = true;

    // Simulate API call - replace with actual service call
    Future.delayed(Duration(seconds: 1), () {
      familyMembers.value = [
        FamilyMember(
          id: '1',
          name: 'Gundari Abhinay',
          isSponsored: true,
          sponsoredBy: 'your company',
        ),
        FamilyMember(
          id: '2',
          name: 'Gundari Abhinaya',
          isSponsored: false,
          hasPackages: true,
        ),
      ];

      // Auto-select first sponsored member
      final sponsoredMember = familyMembers.firstWhere(
        (m) => m.isSponsored,
        orElse: () => familyMembers.first,
      );
      selectedUserId.value = sponsoredMember.id;

      isLoading.value = false;
    });
  }

  // Select user
  void selectUser(String userId) {
    selectedUserId.value = userId;
  }

  // Add family member to selection
  void addMemberToSelection(String userId) {
    // Implement your logic here
    AppToast.success(
      title: 'Member Added',
      message: 'Family member added to selection',
    );
  }

  // Navigate to add new family member
  void addNewFamilyMember() {
    // Navigate to add family member screen
    Get.toNamed(AppRoutes.addFamilyMember);
  }

  // Continue with selected user
  void continueWithSelection() {
    if (selectedUserId.value.isEmpty) {
      AppToast.error(
        title: 'Failed',
        message: 'Please select a family member',
      );

      return;
    }

    Get.to(() => SelectPlanPage());
  }

//continue with plan selected
  void continueWithPlanSelection() {
    Get.to(()=>ExploreHealthPackagesPage());
    // AppToast.success(
    //   title: 'Checked',
    //   message: 'Flip Health Checkup Plan Selected',
    // );
  }

  void continueWithPackageSelection() {
    Get.to(()=>HealthCheckUpSlotSelectionPage());
  }

  // Get sponsored members
  List<FamilyMember> get sponsoredMembers =>
      familyMembers.where((m) => m.isSponsored).toList();

  // Get non-sponsored members
  List<FamilyMember> get nonSponsoredMembers =>
      familyMembers.where((m) => !m.isSponsored).toList();

  // Get selected member
  FamilyMember? get selectedMember {
    final idx = familyMembers.indexWhere((m) => m.id == selectedUserId.value);
    return idx != -1 ? familyMembers[idx] : null;
  }

  // Check if user is selected
  bool isUserSelected(String userId) => selectedUserId.value == userId;




  // Select date
void selectDate(int index) {
  selectedDateIndex.value = index;
  update();
}

// Select time slot
void selectTimeSlot(String time) {
  selectedTimeSlot.value = time;
}

// Confirm slot selection
void confirmSlotSelection() {
  if (selectedTimeSlot.value.isEmpty) {
    AppToast.error(
      title: 'Error',
      message: 'Please select a time slot',
    );
    return;
  }

  final selectedDate = availableDates[selectedDateIndex.value];
  
  AppToast.success(
    title: 'Slot Confirmed',
    message: 'Appointment scheduled for ${selectedDate['day']} ${selectedDate['weekday']}, ${selectedTimeSlot.value}',
  );

  // Navigate to next screen or process the booking
  Get.to(() => HealthCheckupOverviewScreen());
}

// Initialize slot selection data
void initializeSlotSelection() {
  // Reset selections
  selectedDateIndex.value = 0;
  selectedTimeSlot.value = '';
  
  // You can load available dates from API here
  // For now using static data
  loadAvailableDates();
}

// Load available dates (replace with API call if needed)
void loadAvailableDates() {
  // This can be replaced with actual API call to get available dates
  // For now using the static data already defined
  
  // Example: You could modify this to load from backend
  // final response = await _healthCheckupService.getAvailableDates();
  // availableDates.value = response.dates;
}

// Check if a specific time slot is available
bool isTimeSlotAvailable(String time) {
  final allSlots = [...morningSlots, ...afternoonSlots];
  final slot = allSlots.firstWhere(
    (s) => s['time'] == time,
    orElse: () => {'time': '', 'isDisabled': true},
  );
  return !(slot['isDisabled'] ?? true);
}

// Get formatted selected date
String getFormattedSelectedDate() {
  if (availableDates.isEmpty) return '';
  final selectedDate = availableDates[selectedDateIndex.value];
  return '${selectedDate['day']} ${selectedDate['weekday']}';
}

// Reset slot selection
void resetSlotSelection() {
  selectedDateIndex.value = 0;
  selectedTimeSlot.value = '';
}


//confirm booking
void confirmBooking() {
  

  // Navigate to booking confirmation screen or process the booking
  Get.to(() => PaymentSuccessScreen());
}
}