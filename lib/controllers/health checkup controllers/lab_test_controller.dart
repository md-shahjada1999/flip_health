import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/routes/app_routes.dart';
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

  // -----------------------------------------------------------------------
  // Lab tests (paginated)
  // -----------------------------------------------------------------------

  final labTests = <LabTest>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final ScrollController scrollController = ScrollController();

  // -----------------------------------------------------------------------
  // Search
  // -----------------------------------------------------------------------

  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final searchResults = <LabTest>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isSearchLoading = false.obs;
  Timer? _debounce;

  // -----------------------------------------------------------------------
  // Cart
  // -----------------------------------------------------------------------

  final Rxn<LabCartResponse> cart = Rxn<LabCartResponse>();
  final RxBool isCartLoading = false.obs;
  final RxSet<int> _cartProductIds = <int>{}.obs;

  int get cartItemCount => cart.value?.itemCount ?? 0;

  // -----------------------------------------------------------------------
  // Vendors
  // -----------------------------------------------------------------------

  final vendors = <LabVendor>[].obs;
  final RxInt selectedVendorIndex = (-1).obs;
  final RxBool isVendorsLoading = false.obs;

  LabVendor? get selectedVendor {
    if (selectedVendorIndex.value < 0 ||
        selectedVendorIndex.value >= vendors.length) {
      return null;
    }
    return vendors[selectedVendorIndex.value];
  }

  // -----------------------------------------------------------------------
  // Booking overview
  // -----------------------------------------------------------------------

  final Rxn<BookingOverviewResponse> bookingOverview =
      Rxn<BookingOverviewResponse>();
  final RxBool isOverviewLoading = false.obs;
  final RxBool isPlacingOrder = false.obs;
  final RxBool useAppWalletForBooking = false.obs;
  final TextEditingController altPhoneController = TextEditingController();

  // -----------------------------------------------------------------------
  // Slots
  // -----------------------------------------------------------------------

  final Rxn<LabSlotsResponse> slotsResponse = Rxn<LabSlotsResponse>();
  final RxBool isSlotsLoading = false.obs;
  final RxString selectedSlotId = ''.obs;
  final RxString selectedSlotDisplay = ''.obs;
  final RxInt selectedDateIndex = 0.obs;
  final availableDates = <Map<String, String>>[].obs;
  final RxString selectedMonthYear = ''.obs;

  // -----------------------------------------------------------------------
  // Lifecycle
  // -----------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _generateDates();
    fetchCart();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchTextController.dispose();
    altPhoneController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  // -----------------------------------------------------------------------
  // Address helper
  // -----------------------------------------------------------------------

  String get _addressId =>
      Get.find<AddressController>().selectedAddress.value?.id ?? '';

  // -----------------------------------------------------------------------
  // Lab tests loading
  // -----------------------------------------------------------------------

  Future<void> fetchLabTests({bool reset = false}) async {
    if (_addressId.isEmpty) return;

    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;
      labTests.clear();
    }

    if (!hasMore.value) return;
    isLoading.value = true;

    try {
      final results = await _repository.getLabTests(
        addressId: _addressId,
        page: currentPage.value,
      );
      labTests.addAll(results);
      if (results.length < 20) hasMore.value = false;
      currentPage.value++;
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isLoading.value = false;
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading.value &&
        hasMore.value) {
      fetchLabTests();
    }
  }

  // -----------------------------------------------------------------------
  // Search
  // -----------------------------------------------------------------------

  void openSearch() => isSearching.value = true;
  void closeSearch() {
    isSearching.value = false;
    searchTextController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (_addressId.isEmpty) return;
    isSearchLoading.value = true;
    try {
      searchResults.value = await _repository.getLabTests(
        addressId: _addressId,
        name: query,
      );
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isSearchLoading.value = false;
    }
  }

  // -----------------------------------------------------------------------
  // Cart
  // -----------------------------------------------------------------------

  Future<void> fetchCart() async {
    try {
      cart.value = await _repository.getCart();
      _syncCartIds();
    } catch (_) {}
  }

  void _syncCartIds() {
    _cartProductIds.clear();
    final ids = cart.value?.items
            .map((i) => int.tryParse(i.productId) ?? 0)
            .where((id) => id != 0) ??
        [];
    _cartProductIds.addAll(ids);
  }

  bool isInCart(int testId) => _cartProductIds.contains(testId);

  Future<void> addToCart(int productId) async {
    _cartProductIds.add(productId);
    try {
      await _repository.addToCart(productId);
      await fetchCart();
    } catch (e) {
      _cartProductIds.remove(productId);
      AppToast.error(title: 'Error', message: '$e');
    }
  }

  Future<void> removeFromCart(int cartItemId, int productId) async {
    _cartProductIds.remove(productId);
    try {
      await _repository.removeFromCart(cartItemId);
      await fetchCart();
    } catch (e) {
      _cartProductIds.add(productId);
      AppToast.error(title: 'Error', message: '$e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      cart.value = null;
      _cartProductIds.clear();
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    }
  }

  int? cartItemIdForProduct(int productId) {
    final pid = productId.toString();
    return cart.value?.items
        .firstWhereOrNull((i) => i.productId == pid)
        ?.id;
  }

  Future<void> toggleCart(int productId) async {
    if (isInCart(productId)) {
      final itemId = cartItemIdForProduct(productId);
      if (itemId != null) await removeFromCart(itemId, productId);
    } else {
      await addToCart(productId);
    }
  }

  // -----------------------------------------------------------------------
  // Vendors
  // -----------------------------------------------------------------------

  Future<void> fetchVendors() async {
    if (_addressId.isEmpty) return;
    isVendorsLoading.value = true;
    selectedVendorIndex.value = -1;

    try {
      vendors.value = await _repository.getVendors(addressId: _addressId);
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isVendorsLoading.value = false;
    }
  }

  void selectVendor(int index) => selectedVendorIndex.value = index;

  // -----------------------------------------------------------------------
  // Slots
  // -----------------------------------------------------------------------

  void _generateDates() {
    final now = DateTime.now();
    final dates = <Map<String, String>>[];
    for (int i = 0; i < 7; i++) {
      final d = now.add(Duration(days: i));
      dates.add({
        'day': DateFormat('dd').format(d),
        'weekday': DateFormat('EEE').format(d),
        'full': DateFormat('yyyy-MM-dd').format(d),
      });
    }
    availableDates.value = dates;
    selectedMonthYear.value = '${DateFormat('MMM yyyy').format(now)} ( IST )';
  }

  String get _selectedDateFull {
    if (availableDates.isEmpty) return '';
    return availableDates[selectedDateIndex.value]['full'] ?? '';
  }

  Future<void> fetchSlots() async {
    if (_addressId.isEmpty || selectedVendor == null) return;
    isSlotsLoading.value = true;
    selectedSlotId.value = '';
    selectedSlotDisplay.value = '';

    try {
      slotsResponse.value = await _repository.getSlots(
        addressId: _addressId,
        date: _selectedDateFull,
        vendorCode: selectedVendor!.code,
      );
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isSlotsLoading.value = false;
    }
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
    fetchSlots();
  }

  void selectTimeSlot(String slotDisplay) {
    selectedSlotDisplay.value = slotDisplay;
    final allSlots = [
      ...slotsResponse.value?.morning ?? [],
      ...slotsResponse.value?.afternoon ?? [],
      ...slotsResponse.value?.evening ?? [],
    ];
    final match = allSlots.firstWhereOrNull((s) => s.displayTime == slotDisplay);
    selectedSlotId.value = match?.slotId ?? '';
  }

  List<Map<String, dynamic>> get morningSlotMaps =>
      _toSlotMaps(slotsResponse.value?.morning ?? []);

  List<Map<String, dynamic>> get afternoonSlotMaps =>
      _toSlotMaps(slotsResponse.value?.afternoon ?? []);

  List<Map<String, dynamic>> get eveningSlotMaps =>
      _toSlotMaps(slotsResponse.value?.evening ?? []);

  List<Map<String, dynamic>> _toSlotMaps(List<LabSlot> slots) =>
      slots.map((s) => {'time': s.displayTime, 'isDisabled': false}).toList();

  // -----------------------------------------------------------------------
  // Navigation
  // -----------------------------------------------------------------------

  void continueWithMemberSelection() {
    final mc = Get.find<MemberController>();
    if (mc.selectedUserId.value.isEmpty) {
      AppToast.error(title: 'Failed', message: 'Please select a family member');
      return;
    }
    Get.to(() => const LabTestScreen());
  }

  void goToCart() => Get.to(() => const LabTestCartScreen());

  void goToVendorSelection() {
    if (cartItemCount == 0) {
      AppToast.error(title: 'Error', message: 'Please add tests to cart');
      return;
    }
    fetchVendors();
    Get.to(() => const LabSelectionScreen());
  }

  void goToSlotSelection() {
    if (vendors.isNotEmpty && selectedVendorIndex.value == -1) {
      AppToast.error(title: 'Error', message: 'Please select a lab');
      return;
    }
    fetchSlots();
    Get.to(() => const LabTestSlotSelectionPage());
  }

  void confirmSlotSelection() {
    if (selectedSlotId.value.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please select a time slot');
      return;
    }
    _navigateToOverview();
  }

  // -----------------------------------------------------------------------
  // Booking body builder
  // -----------------------------------------------------------------------

  LabSlot? get _selectedSlot {
    final allSlots = [
      ...slotsResponse.value?.morning ?? [],
      ...slotsResponse.value?.afternoon ?? [],
      ...slotsResponse.value?.evening ?? [],
    ];
    return allSlots.firstWhereOrNull((s) => s.slotId == selectedSlotId.value);
  }

  Map<String, dynamic> _buildBookingBody() {
    final mc = Get.find<MemberController>();
    final slot = _selectedSlot;
    return {
      'address_id': _addressId,
      'sponsored': false,
      'alternative_phone': altPhoneController.text.trim(),
      'slot': {
        'slot_id': slot?.slotId ?? selectedSlotId.value,
        'vendor_code': selectedVendor?.code ?? slot?.vendorCode ?? '',
        'slot_date': slot?.slotDate ?? _selectedDateFull,
        'start_time': slot?.startTime ?? '',
        'end_time': slot?.endTime ?? '',
      },
      'users': [
        {'user_id': int.tryParse(mc.selectedUserId.value) ?? 0},
      ],
    };
  }

  // -----------------------------------------------------------------------
  // Fetch booking overview (overview=yes)
  // -----------------------------------------------------------------------

  Future<void> fetchBookingOverview() async {
    isOverviewLoading.value = true;
    bookingOverview.value = null;
    useAppWalletForBooking.value = false;

    try {
      bookingOverview.value = await _repository.getBookingOverview(
        body: _buildBookingBody(),
      );
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isOverviewLoading.value = false;
    }
  }

  // -----------------------------------------------------------------------
  // Place order (overview=no)
  // -----------------------------------------------------------------------

  /// Matches patient_app [bookingOrderOverviewForTests] when `forOverView == "no"`:
  /// `verify` + `razorpay_payload` → Razorpay; `verify` + no payload → confirm API;
  /// `!verify` → success without confirm.
  Future<void> placeOrder() async {
    isPlacingOrder.value = true;
    try {
      final wallet = useAppWalletForBooking.value ? 'yes' : 'no';
      final res = await _repository.placeOrder(
        body: _buildBookingBody(),
        useAppWallet: wallet,
      );

      if (res.verify) {
        final rp = res.razorpayPayload;
        if (rp != null && rp.isNotEmpty) {
          final inv = res.overview.invoiceId ?? '';
          Get.toNamed(
            AppRoutes.razorPay,
            arguments: [
              'fromLabTest',
              Map<String, dynamic>.from(rp),
              <String, dynamic>{
                'invoice_id': inv,
                'title': 'Booking Confirmed!',
                'subtitle': inv.isNotEmpty
                    ? 'Invoice: $inv'
                    : 'Your lab test has been booked successfully.',
              },
            ],
          );
          return;
        }
        await _repository.postDiagnosticsOrderConfirm({
          'invoice_id': res.overview.invoiceId ?? '',
          'payment_id': '',
        });
        Get.offAll(
          () => PaymentSuccessScreen(
            title: 'Booking Confirmed!',
            subtitle: res.overview.invoiceId != null
                ? 'Invoice: ${res.overview.invoiceId}'
                : 'Your lab test has been booked successfully.',
          ),
        );
        return;
      }

      Get.offAll(
        () => PaymentSuccessScreen(
          title: 'Booking Confirmed!',
          subtitle: res.overview.invoiceId != null
              ? 'Invoice: ${res.overview.invoiceId}'
              : 'Your lab test has been booked successfully.',
        ),
      );
    } catch (e) {
      AppToast.error(title: 'Booking Failed', message: '$e');
    } finally {
      isPlacingOrder.value = false;
    }
  }

  // -----------------------------------------------------------------------
  // Navigation
  // -----------------------------------------------------------------------

  void _navigateToOverview() {
    fetchBookingOverview();
    Get.to(() => const LabTestOverviewScreen());
  }
}
