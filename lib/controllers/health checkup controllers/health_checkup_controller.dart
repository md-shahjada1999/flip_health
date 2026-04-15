import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/health_checkup_repository.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/daignostics/health_checkup/explore_health_packages_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_checkup_overview_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_checkup_booking_success_screen.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_selection_slot_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/package_inclusions_screen.dart';
import 'package:flip_health/views/daignostics/health_checkup/select_plan_page.dart';

class HealthCheckupsController extends GetxController {
  final HealthCheckupRepository _repository;

  HealthCheckupsController({required HealthCheckupRepository repository})
    : _repository = repository;

  // -------------------------------------------------------------------------
  // Entry (dashboard AHC → `Get.arguments['sponsored'] == true`)
  // -------------------------------------------------------------------------

  final RxBool sponsoredHealthCheckup = false.obs;
  final RxBool filterAhcMembersOnly = false.obs;

  static bool _routeBoolFlag(Map<dynamic, dynamic>? map, String key) {
    if (map == null || !map.containsKey(key)) return false;
    final v = map[key];
    if (v == true) return true;
    if (v == false || v == null) return false;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }

  /// Call when opening [HealthCheckupsScreen] (sponsored / `ahc` from dashboard sets filters + sponsored APIs).
  void applyEntryArguments(dynamic args) {
    _resetBookingFlow();
    final map = args is Map ? Map<dynamic, dynamic>.from(args) : null;
    final flow =
        map != null &&
        (_routeBoolFlag(map, 'sponsored') || _routeBoolFlag(map, 'ahc'));
    sponsoredHealthCheckup.value = flow;
    filterAhcMembersOnly.value = flow;
  }

  /// Sponsored or AHC entry — hide add-member on the family picker.
  bool get hideAddFamilyMemberOnPicker =>
      sponsoredHealthCheckup.value || filterAhcMembersOnly.value;

  void _resetBookingFlow() {
    selectedMembers.clear();
    memberPackageMap.clear();
    _packagesCache.clear();
    activeMemberTab.value = 0;
    currentPackages.clear();
    vendorPricing.value = null;
    selectedPathologyVendor.value = null;
    selectedRadiologyVendor.value = null;
    pathologySlotsResponse.value = null;
    radiologySlotsResponse.value = null;
    selectedPathologySlot.value = null;
    selectedRadiologySlot.value = null;
    pathologyTimeSlot.value = '';
    radiologyTimeSlot.value = '';
    currentSlotCategory.value = 'pathology';
    pathologyDateIndex.value = 0;
    radiologyDateIndex.value = 0;
    bookingPreview.value = null;
    lastFinalizeResult.value = null;
    altPhoneController.clear();
    useAppWalletForBooking.value = false;
  }

  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

  /// API-driven booking summary after slots (`overview=yes` preview).
  final Rxn<BookingOverviewResponse> bookingPreview =
      Rxn<BookingOverviewResponse>();
  final Rxn<DiagnosticsBookingApiResult> lastFinalizeResult =
      Rxn<DiagnosticsBookingApiResult>();
  final RxBool isBookingPreviewLoading = false.obs;
  final RxBool isPlacingOrder = false.obs;
  final RxBool useAppWalletForBooking = false.obs;

  final TextEditingController altPhoneController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isVendorLoading = false.obs;
  final RxBool isSlotsLoading = false.obs;

  // Selected members from multi-select
  final RxList<FamilyMember> selectedMembers = <FamilyMember>[].obs;

  // Per-member package selection: memberId -> packageId
  final RxMap<String, int> memberPackageMap = <String, int>{}.obs;

  // Cached packages per member: memberId -> packages list
  final Map<String, List<DiagnosticsPackage>> _packagesCache = {};

  // Active member tab on package selection screen
  final RxInt activeMemberTab = 0.obs;

  // Current displayed packages (for active tab)
  final RxList<DiagnosticsPackage> currentPackages = <DiagnosticsPackage>[].obs;

  // Vendor/pricing
  final Rxn<AhcVendorPricingResponse> vendorPricing =
      Rxn<AhcVendorPricingResponse>();
  final Rxn<AhcVendor> selectedPathologyVendor = Rxn<AhcVendor>();
  final Rxn<AhcVendor> selectedRadiologyVendor = Rxn<AhcVendor>();

  // Derive categories from the actual selected packages
  Set<String> get _selectedCategories {
    final cats = <String>{};
    for (final m in selectedMembers) {
      final pkgId = memberPackageMap[m.id];
      if (pkgId == null) continue;
      final pkgList = _packagesCache[m.id] ?? [];
      final pkg = pkgList.firstWhereOrNull((p) => p.id == pkgId);
      if (pkg != null) {
        if (pkg.category == 'group') {
          cats.addAll(['pathology', 'radiology']);
        } else if (pkg.category.isNotEmpty) {
          cats.add(pkg.category);
        }
      }
    }
    return cats;
  }

  bool get containsPathology {
    if (vendorPricing.value != null) return vendorPricing.value!.hasPathology;
    return _selectedCategories.contains('pathology');
  }

  bool get containsRadiology {
    if (vendorPricing.value != null) return vendorPricing.value!.hasRadiology;
    return _selectedCategories.contains('radiology');
  }

  bool get hasOnlyPathology => containsPathology && !containsRadiology;
  bool get hasOnlyRadiology => !containsPathology && containsRadiology;

  // Slot selection — pathology
  final RxList<Map<String, String>> pathologyDates =
      <Map<String, String>>[].obs;
  final RxInt pathologyDateIndex = 0.obs;
  final RxString pathologyTimeSlot = ''.obs;
  final Rxn<AhcSlot> selectedPathologySlot = Rxn<AhcSlot>();
  final Rxn<AhcSlotsResponse> pathologySlotsResponse = Rxn<AhcSlotsResponse>();
  final RxString pathologyMonthYear = ''.obs;

  // Slot selection — radiology
  final RxList<Map<String, String>> radiologyDates =
      <Map<String, String>>[].obs;
  final RxInt radiologyDateIndex = 0.obs;
  final RxString radiologyTimeSlot = ''.obs;
  final Rxn<AhcSlot> selectedRadiologySlot = Rxn<AhcSlot>();
  final Rxn<AhcSlotsResponse> radiologySlotsResponse = Rxn<AhcSlotsResponse>();
  final RxString radiologyMonthYear = ''.obs;

  // Current slot category being selected
  final RxString currentSlotCategory = 'pathology'.obs;

  // -------------------------------------------------------------------------
  // Navigation
  // -------------------------------------------------------------------------

  void continueWithMemberSelection(List<FamilyMember> members) {
    if (members.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please select a family member');
      return;
    }
    selectedMembers.assignAll(members);
    memberPackageMap.clear();
    _packagesCache.clear();
    activeMemberTab.value = 0;
    Get.to(() => const SelectPlanPage());
  }

  /// Loads pricing first; if only unknown vendors, goes straight to slots (no vendor UI flash).
  Future<void> continueToVendorSelection() async {
    final allSelected = selectedMembers.every(
      (m) => memberPackageMap.containsKey(m.id),
    );
    if (!allSelected) {
      AppToast.error(
        title: 'Incomplete',
        message: 'Please select a package for each member',
      );
      return;
    }

    await fetchVendorPricing();

    final vp = vendorPricing.value;
    if (vp == null) return;

    if (!vp.hasSelectablePathology && !vp.hasSelectableRadiology) {
      _navigateToSlots();
      return;
    }

    Get.to(() => const ExploreHealthPackagesPage());
  }

  void continueToSlotSelection() {
    final vp = vendorPricing.value;
    if (vp != null &&
        vp.hasSelectablePathology &&
        selectedPathologyVendor.value == null) {
      AppToast.error(
        title: 'Error',
        message: 'Please select a pathology vendor',
      );
      return;
    }
    if (vp != null &&
        vp.hasSelectableRadiology &&
        selectedRadiologyVendor.value == null) {
      AppToast.error(
        title: 'Error',
        message: 'Please select a radiology vendor',
      );
      return;
    }

    _navigateToSlots();
  }

  void _navigateToSlots() {
    final firstCategory = containsPathology ? 'pathology' : 'radiology';
    currentSlotCategory.value = firstCategory;

    if (firstCategory == 'pathology') {
      _initDates(pathologyDates, pathologyMonthYear);
    } else {
      _initDates(radiologyDates, radiologyMonthYear);
    }
    _fetchSlotsForCategory(firstCategory);

    Get.to(() => const HealthCheckUpSlotSelectionPage());
  }

  Future<void> confirmCurrentSlot() async {
    final cat = currentSlotCategory.value;

    if (cat == 'pathology') {
      if (selectedPathologySlot.value == null) {
        AppToast.error(title: 'Error', message: 'Please select a time slot');
        return;
      }
      if (containsRadiology) {
        currentSlotCategory.value = 'radiology';
        _initDates(radiologyDates, radiologyMonthYear);
        _fetchSlotsForCategory('radiology');
        radiologyTimeSlot.value = '';
        selectedRadiologySlot.value = null;
        return;
      }
    } else {
      if (selectedRadiologySlot.value == null) {
        AppToast.error(title: 'Error', message: 'Please select a time slot');
        return;
      }
    }

    await _loadBookingPreviewAndOpenOverview();
  }

  Map<String, dynamic> buildHealthCheckupBookingBody() {
    final ac = Get.find<AddressController>();
    final addressId = ac.selectedAddress.value?.id ?? '';

    final users = memberPackageMap.entries
        .map(
          (e) => {
            'user_id': int.tryParse(e.key) ?? 0,
            'packages': [e.value],
          },
        )
        .toList();

    final body = <String, dynamic>{
      'booking_type': 'special',
      'sponsored': sponsoredHealthCheckup.value,
      'address_id': addressId,
      'alternative_phone': altPhoneController.text.trim(),
      'users': users,
    };

    if (containsPathology && selectedPathologySlot.value != null) {
      final s = selectedPathologySlot.value!;
      body['pathology_slot'] = {
        'slot_id': s.slotId,
        'vendor_code': s.vendorCode,
        'slot_date': s.slotDate,
        'start_time': s.startTime,
        'end_time': s.endTime,
      };
    }
    if (containsRadiology && selectedRadiologySlot.value != null) {
      final s = selectedRadiologySlot.value!;
      body['radiology_slot'] = {
        'slot_id': s.slotId,
        'vendor_code': s.vendorCode,
        'slot_date': s.slotDate,
        'start_time': s.startTime,
        'end_time': s.endTime,
      };
    }

    return body;
  }

  Future<void> _loadBookingPreviewAndOpenOverview() async {
    isBookingPreviewLoading.value = true;
    bookingPreview.value = null;
    try {
      final res = await _repository.postDiagnosticsOrder(
        body: buildHealthCheckupBookingBody(),
        preview: true,
        useAppWallet: 'no',
      );
      bookingPreview.value = res.overview;
      final alt = res.overview.alternativePhone;
      if (alt.isNotEmpty) {
        altPhoneController.text = alt;
      }
      Get.to(() => const HealthCheckupOverviewScreen());
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isBookingPreviewLoading.value = false;
    }
  }

  /// Reload preview after failed load or when returning to this screen.
  Future<void> refreshBookingPreview() async {
    isBookingPreviewLoading.value = true;
    try {
      final res = await _repository.postDiagnosticsOrder(
        body: buildHealthCheckupBookingBody(),
        preview: true,
        useAppWallet: 'no',
      );
      bookingPreview.value = res.overview;
      final alt = res.overview.alternativePhone;
      if (alt.isNotEmpty && altPhoneController.text.isEmpty) {
        altPhoneController.text = alt;
      }
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isBookingPreviewLoading.value = false;
    }
  }

  /// Called from overview payment sheet — `overview=no`, optional wallet.
  Future<void> finalizeHealthCheckupBooking() async {
    final wallet = useAppWalletForBooking.value ? 'yes' : 'no';
    isPlacingOrder.value = true;
    try {
      final res = await _repository.postDiagnosticsOrder(
        body: buildHealthCheckupBookingBody(),
        preview: false,
        useAppWallet: wallet,
      );
      lastFinalizeResult.value = res;

      final rp = res.razorpayPayload;
      if (rp != null && rp.isNotEmpty) {
        final inv = res.overview.invoiceId ?? '';
        Get.toNamed(
          AppRoutes.razorPay,
          arguments: [
            'fromHealthCheckup',
            Map<String, dynamic>.from(rp),
            <String, dynamic>{
              'invoice_id': inv,
              'title': 'Health checkup booking',
              'subtitle': _successSubtitle(res.overview),
            },
          ],
        );
        return;
      }

      _navigateToBookingSuccess(res.overview);
    } catch (e) {
      AppToast.error(title: 'Booking', message: '$e');
    } finally {
      isPlacingOrder.value = false;
    }
  }

  String _successSubtitle(BookingOverviewResponse o) {
    final parts = <String>[];
    if ((o.invoiceId ?? '').isNotEmpty) {
      parts.add('Invoice ${o.invoiceId}');
    }
    final n = o.items.length;
    if (n > 0) parts.add('$n package${n == 1 ? '' : 's'}');
    return parts.isEmpty ? 'Your health checkup is booked.' : parts.join(' · ');
  }

  void _navigateToBookingSuccess(BookingOverviewResponse o) {
    Get.offAll(
      () => HealthCheckupBookingSuccessScreen(
        invoiceId: o.invoiceId,
        summaryLine: _successSubtitle(o),
      ),
    );
  }

  @override
  void onClose() {
    altPhoneController.dispose();
    super.onClose();
  }

  // -------------------------------------------------------------------------
  // Package fetching
  // -------------------------------------------------------------------------

  Future<void> fetchPackagesForMember(int memberIndex) async {
    activeMemberTab.value = memberIndex;
    final member = selectedMembers[memberIndex];

    if (_packagesCache.containsKey(member.id)) {
      currentPackages.assignAll(_packagesCache[member.id]!);
      return;
    }

    isLoading.value = true;
    try {
      final userId = int.tryParse(member.id) ?? 0;
      final result = await _repository.getPackages(
        userId: userId,
        sponsored: sponsoredHealthCheckup.value,
      );
      _packagesCache[member.id] = result;
      currentPackages.assignAll(result);
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPackageForMember(String memberId, int packageId) {
    memberPackageMap[memberId] = packageId;
  }

  bool isPackageSelected(String memberId, int packageId) {
    return memberPackageMap[memberId] == packageId;
  }

  bool get allMembersHavePackage =>
      selectedMembers.every((m) => memberPackageMap.containsKey(m.id));

  // -------------------------------------------------------------------------
  // Package inclusions (full screen)
  // -------------------------------------------------------------------------

  /// Opens full-screen inclusions for the **pricing** id (not package id) — matches patient_app `getPackageInclusions(pricing.id)`.
  Future<void> openPackageInclusions(int pricingId) async {
    if (pricingId <= 0) return;
    try {
      final items = await _repository.getPackageInclusions(pricingId);
      await Get.to<void>(() => PackageInclusionsScreen(items: items));
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    }
  }

  // -------------------------------------------------------------------------
  // Vendor / pricing
  // -------------------------------------------------------------------------

  Future<void> fetchVendorPricing() async {
    final ac = Get.find<AddressController>();
    final addressId = ac.selectedAddress.value?.id;
    if (addressId == null) {
      AppToast.error(title: 'Error', message: 'Please select an address');
      return;
    }

    isVendorLoading.value = true;
    selectedPathologyVendor.value = null;
    selectedRadiologyVendor.value = null;

    try {
      final users = memberPackageMap.entries
          .map(
            (e) => {
              'user_id': int.tryParse(e.key) ?? 0,
              'packages': [e.value],
            },
          )
          .toList();

      vendorPricing.value = await _repository.getVendorPricing(
        addressId: addressId,
        sponsored: sponsoredHealthCheckup.value,
        users: users,
      );

      final vp = vendorPricing.value;
      if (vp != null && sponsoredHealthCheckup.value) {
        if (vp.pathologyVendors.length == 1) {
          selectedPathologyVendor.value = vp.pathologyVendors.first;
        }
        if (vp.radiologyVendors.length == 1) {
          selectedRadiologyVendor.value = vp.radiologyVendors.first;
        }
      }
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isVendorLoading.value = false;
    }
  }

  void selectPathologyVendor(AhcVendor vendor) {
    selectedPathologyVendor.value = vendor;
  }

  void selectRadiologyVendor(AhcVendor vendor) {
    selectedRadiologyVendor.value = vendor;
  }

  // -------------------------------------------------------------------------
  // Slots
  // -------------------------------------------------------------------------

  void _initDates(RxList<Map<String, String>> dates, RxString monthYear) {
    final now = DateTime.now();
    final dayFmt = DateFormat('dd');
    final weekFmt = DateFormat('EEE');
    final monthFmt = DateFormat('MMM yyyy');

    dates.assignAll(
      List.generate(7, (i) {
        final d = now.add(Duration(days: i + 1));
        return {'day': dayFmt.format(d), 'weekday': weekFmt.format(d)};
      }),
    );

    monthYear.value = '${monthFmt.format(now)} (IST)';
  }

  Future<void> _fetchSlotsForCategory(String category) async {
    final ac = Get.find<AddressController>();
    final addressId = ac.selectedAddress.value?.id;
    if (addressId == null) return;

    final vendorCode = category == 'pathology'
        ? (selectedPathologyVendor.value?.code ?? 'unknown')
        : (selectedRadiologyVendor.value?.code ?? 'unknown');

    final dates = category == 'pathology' ? pathologyDates : radiologyDates;
    final dateIdx = category == 'pathology'
        ? pathologyDateIndex.value
        : radiologyDateIndex.value;
    if (dates.isEmpty) return;

    final now = DateTime.now();
    final selectedDate = now.add(Duration(days: dateIdx + 1));
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    isSlotsLoading.value = true;
    try {
      final result = await _repository.getSlots(
        addressId: addressId,
        date: dateStr,
        vendorCode: vendorCode,
        category: category,
      );

      if (category == 'pathology') {
        pathologySlotsResponse.value = result;
      } else {
        radiologySlotsResponse.value = result;
      }
    } catch (e) {
      PrintLog.printLog('fetchSlots error: $e');
      AppToast.error(title: 'Error', message: 'Failed to load slots');
    } finally {
      isSlotsLoading.value = false;
    }
  }

  void onDateSelected(String category, int index) {
    if (category == 'pathology') {
      pathologyDateIndex.value = index;
      pathologyTimeSlot.value = '';
      selectedPathologySlot.value = null;
    } else {
      radiologyDateIndex.value = index;
      radiologyTimeSlot.value = '';
      selectedRadiologySlot.value = null;
    }
    _fetchSlotsForCategory(category);
  }

  void onTimeSlotSelected(
    String category,
    String time,
    AhcSlotsResponse slots,
  ) {
    final allSlots = [...slots.morning, ...slots.afternoon, ...slots.evening];
    final slot = allSlots.firstWhereOrNull((s) => s.displayTime == time);

    if (category == 'pathology') {
      pathologyTimeSlot.value = time;
      selectedPathologySlot.value = slot;
    } else {
      radiologyTimeSlot.value = time;
      selectedRadiologySlot.value = slot;
    }
  }

  // Helpers for CommonSlotSelector format
  List<Map<String, dynamic>> morningSlotMaps(AhcSlotsResponse? r) =>
      r?.toSlotMaps(r.morning) ?? [];
  List<Map<String, dynamic>> afternoonSlotMaps(AhcSlotsResponse? r) =>
      r?.toSlotMaps(r.afternoon) ?? [];
  List<Map<String, dynamic>> eveningSlotMaps(AhcSlotsResponse? r) =>
      r?.toSlotMaps(r.evening) ?? [];

  // -------------------------------------------------------------------------
  // Overview helpers
  // -------------------------------------------------------------------------

  String get summaryText {
    final parts = <String>[];
    for (final m in selectedMembers) {
      final pkgId = memberPackageMap[m.id];
      final pkgList = _packagesCache[m.id] ?? [];
      final pkg = pkgList.firstWhereOrNull((p) => p.id == pkgId);
      if (pkg != null) {
        parts.add('${m.name}: ${pkg.name}');
      }
    }
    return parts.join('\n');
  }
}
