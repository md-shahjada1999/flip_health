import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/data/repositories/health_checkup_repository.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';
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

  // --- Packages from API ---
  final packages = <DiagnosticsPackage>[].obs;
  final Rxn<DiagnosticsPackageDetail> selectedPackageDetail =
      Rxn<DiagnosticsPackageDetail>();
  final RxInt expandedPackageId = (-1).obs;
  final RxBool isDetailLoading = false.obs;

  // --- Slot selection ---
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
    {'time': '7 AM-8 AM', 'isDisabled': false},
    {'time': '8 AM-9 AM', 'isDisabled': false},
    {'time': '9 AM-10 AM', 'isDisabled': false},
    {'time': '10 AM-11 AM', 'isDisabled': false},
    {'time': '11 AM-12 PM', 'isDisabled': false},
  ];

  // --- Packages API ---

  Future<void> fetchPackages() async {
    final userId =
        AppSecureStorage.getIntValueFromSharedPref(variableName: AppSecureStorage.kUserId) ?? 0;
    if (userId == 0) return;

    isLoading.value = true;
    try {
      packages.value = await _repository.getPackages(userId: userId);
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPackageDetail(int id) async {
    if (expandedPackageId.value == id) {
      expandedPackageId.value = -1;
      selectedPackageDetail.value = null;
      return;
    }

    isDetailLoading.value = true;
    expandedPackageId.value = id;
    selectedPackageDetail.value = null;

    try {
      selectedPackageDetail.value = await _repository.getPackageDetail(id);
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
      expandedPackageId.value = -1;
    } finally {
      isDetailLoading.value = false;
    }
  }

  // --- Member selection ---

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

  void continueWithPlanSelection() {
    Get.to(() => ExploreHealthPackagesPage());
  }

  void continueWithPackageSelection() {
    Get.to(() => HealthCheckUpSlotSelectionPage());
  }

  // --- Slot selection ---

  void selectDate(int index) {
    selectedDateIndex.value = index;
    update();
  }

  void selectTimeSlot(String time) {
    selectedTimeSlot.value = time;
  }

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
      message:
          'Appointment scheduled for ${selectedDate['day']} ${selectedDate['weekday']}, ${selectedTimeSlot.value}',
    );

    Get.to(() => HealthCheckupOverviewScreen());
  }

  void initializeSlotSelection() {
    selectedDateIndex.value = 0;
    selectedTimeSlot.value = '';
    loadAvailableDates();
  }

  void loadAvailableDates() {}

  bool isTimeSlotAvailable(String time) {
    final allSlots = [...morningSlots, ...afternoonSlots];
    final slot = allSlots.firstWhere(
      (s) => s['time'] == time,
      orElse: () => {'time': '', 'isDisabled': true},
    );
    return !(slot['isDisabled'] ?? true);
  }

  String getFormattedSelectedDate() {
    if (availableDates.isEmpty) return '';
    final selectedDate = availableDates[selectedDateIndex.value];
    return '${selectedDate['day']} ${selectedDate['weekday']}';
  }

  void resetSlotSelection() {
    selectedDateIndex.value = 0;
    selectedTimeSlot.value = '';
  }

  void confirmBooking() {
    Get.to(() => PaymentSuccessScreen());
  }
}
