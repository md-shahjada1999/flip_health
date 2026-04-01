import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/data/repositories/lab_test_repository.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/views/daignostics/lab_test/lab_selection_screen.dart';
import 'package:flip_health/views/daignostics/lab_test/lab_test_cart_screen.dart';
import 'package:flip_health/views/daignostics/lab_test/lab_test_overview_screen.dart';
import 'package:flip_health/views/daignostics/lab_test/lab_test_screen.dart';
import 'package:flip_health/views/daignostics/lab_test/lab_test_slot_selection_page.dart';

class LabTestController extends GetxController {
  final LabTestRepository _repository;

  LabTestController({required LabTestRepository repository})
      : _repository = repository;

  // --- Search state ---
  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<LabTestModel> allTests = <LabTestModel>[].obs;
  final RxList<LabTestModel> searchResults = <LabTestModel>[].obs;

  // --- Cart state ---
  final RxList<LabTestModel> cartTests = <LabTestModel>[].obs;

  // --- Popular packages ---
  final RxList<LabPackageModel> popularPackages = <LabPackageModel>[].obs;

  // --- Lab selection state ---
  final RxList<LabModel> availableLabs = <LabModel>[].obs;
  final RxInt selectedLabIndex = (-1).obs;
  final RxInt selectedCollectionTab = 0.obs;

  // --- Slot selection state ---
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
    {'time': '12 PM-1 PM', 'isDisabled': false},
    {'time': '1 PM-2 PM', 'isDisabled': false},
    {'time': '2 PM-3 PM', 'isDisabled': false},
    {'time': '3 PM-4 PM', 'isDisabled': false},
    {'time': '4 PM-5 PM', 'isDisabled': false},
  ];

  // --- Loading ---
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  // --- Member selection (delegated to MemberController) ---

  void continueWithMemberSelection() {
    final mc = Get.find<MemberController>();
    if (mc.selectedUserId.value.isEmpty) {
      AppToast.error(title: 'Failed', message: 'Please select a family member');
      return;
    }
    Get.to(() => const LabTestScreen());
  }

  // --- Data loading ---

  Future<void> _loadMockData() async {
    try {
      allTests.value = await _repository.getAllTests();
      searchResults.value = List.from(allTests);
      popularPackages.value = await _repository.getPopularPackages();
    } catch (_) {}
  }

  Future<void> loadAvailableLabs() async {
    try {
      availableLabs.value = await _repository.getAvailableLabs(cartTests: cartTests);
    } catch (_) {}
  }

  // --- Search ---

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      searchResults.value = List.from(allTests);
      return;
    }
    searchResults.value = allTests
        .where((t) => t.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    searchResults.value = List.from(allTests);
  }

  // --- Cart ---

  bool isInCart(String testId) =>
      cartTests.any((t) => t.id == testId);

  void toggleTestInCart(LabTestModel test) {
    if (isInCart(test.id)) {
      cartTests.removeWhere((t) => t.id == test.id);
    } else {
      cartTests.add(test);
    }
  }

  void removeFromCart(LabTestModel test) {
    cartTests.removeWhere((t) => t.id == test.id);
  }

  // --- Lab selection ---

  void selectLab(int index) {
    selectedLabIndex.value = index;
  }

  LabModel? get selectedLab {
    if (selectedLabIndex.value < 0 ||
        selectedLabIndex.value >= availableLabs.length) return null;
    return availableLabs[selectedLabIndex.value];
  }

  // --- Slot selection ---

  void selectDate(int index) {
    selectedDateIndex.value = index;
    update();
  }

  void selectTimeSlot(String time) {
    selectedTimeSlot.value = time;
  }

  String getFormattedSelectedDate() {
    if (availableDates.isEmpty) return '';
    final date = availableDates[selectedDateIndex.value];
    return '${date['day']} ${date['weekday']}';
  }

  // --- Navigation ---

  void goToSearchScreen() {
    Get.toNamed('/lab-test-search');
  }

  void goToLabTests() {
    Get.toNamed('/lab-tests');
  }

  void goToCart() {
    Get.to(() => const LabTestCartScreen());
  }

  void goToLabSelection() {
    if (cartTests.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please add tests to cart');
      return;
    }
    loadAvailableLabs();
    Get.to(() => const LabSelectionScreen());
  }

  void confirmLabSelection() {
    if (selectedLabIndex.value == -1) {
      AppToast.error(title: 'Error', message: 'Please select a lab');
      return;
    }
    Get.to(() => const LabTestSlotSelectionPage());
  }

  void confirmSlotSelection() {
    if (selectedTimeSlot.value.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please select a time slot');
      return;
    }

    final date = availableDates[selectedDateIndex.value];
    AppToast.success(
      title: 'Slot Confirmed',
      message:
          'Appointment scheduled for ${date['day']} ${date['weekday']}, ${selectedTimeSlot.value}',
    );

    Get.to(() => const LabTestOverviewScreen());
  }

  void confirmBooking() {
    Get.to(() => PaymentSuccessScreen());
  }
}
