import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/data/repositories/health_checkup_repository.dart';
import 'package:flip_health/views/daignostics/health_checkup/explore_health_packages_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_checkup_overview_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_selection_slot_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/select_plan_page.dart';

class HealthCheckupsController extends GetxController {
  final HealthCheckupRepository _repository;

  HealthCheckupsController({required HealthCheckupRepository repository})
      : _repository = repository;
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

  // --- Member selection (delegated to MemberController) ---

  void continueWithSelection() {
    final mc = Get.find<MemberController>();
    if (mc.selectedUserId.value.isEmpty) {
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