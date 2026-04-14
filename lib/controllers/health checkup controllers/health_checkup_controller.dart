import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/health_checkup_repository.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/views/daignostics/health_checkup/explore_health_packages_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_checkup_overview_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_selection_slot_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/select_plan_page.dart';

class HealthCheckupsController extends GetxController {
  final HealthCheckupRepository _repository;

  HealthCheckupsController({required HealthCheckupRepository repository})
      : _repository = repository;

  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

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
  final RxList<Map<String, String>> pathologyDates = <Map<String, String>>[].obs;
  final RxInt pathologyDateIndex = 0.obs;
  final RxString pathologyTimeSlot = ''.obs;
  final Rxn<AhcSlot> selectedPathologySlot = Rxn<AhcSlot>();
  final Rxn<AhcSlotsResponse> pathologySlotsResponse = Rxn<AhcSlotsResponse>();
  final RxString pathologyMonthYear = ''.obs;

  // Slot selection — radiology
  final RxList<Map<String, String>> radiologyDates = <Map<String, String>>[].obs;
  final RxInt radiologyDateIndex = 0.obs;
  final RxString radiologyTimeSlot = ''.obs;
  final Rxn<AhcSlot> selectedRadiologySlot = Rxn<AhcSlot>();
  final Rxn<AhcSlotsResponse> radiologySlotsResponse = Rxn<AhcSlotsResponse>();
  final RxString radiologyMonthYear = ''.obs;

  // Current slot category being selected
  final RxString currentSlotCategory = 'pathology'.obs;

  // Package detail (for expand)
  final Rxn<DiagnosticsPackageDetail> selectedPackageDetail =
      Rxn<DiagnosticsPackageDetail>();
  final RxInt expandedPackageId = (-1).obs;
  final RxBool isDetailLoading = false.obs;

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

  void continueToVendorSelection() {
    final allSelected = selectedMembers.every(
        (m) => memberPackageMap.containsKey(m.id));
    if (!allSelected) {
      AppToast.error(
        title: 'Incomplete',
        message: 'Please select a package for each member',
      );
      return;
    }
    Get.to(() => const ExploreHealthPackagesPage());
  }

  void continueToSlotSelection() {
    final vp = vendorPricing.value;
    if (vp != null && vp.hasSelectablePathology &&
        selectedPathologyVendor.value == null) {
      AppToast.error(
          title: 'Error', message: 'Please select a pathology vendor');
      return;
    }
    if (vp != null && vp.hasSelectableRadiology &&
        selectedRadiologyVendor.value == null) {
      AppToast.error(
          title: 'Error', message: 'Please select a radiology vendor');
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

  void confirmCurrentSlot() {
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

    Get.to(() => const HealthCheckupOverviewScreen());
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
      final result = await _repository.getPackages(userId: userId);
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
  // Package detail expand
  // -------------------------------------------------------------------------

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
      final users = memberPackageMap.entries.map((e) => {
            'user_id': int.tryParse(e.key) ?? 0,
            'packages': [e.value],
          }).toList();

      vendorPricing.value = await _repository.getVendorPricing(
        addressId: addressId,
        sponsored: false,
        users: users,
      );

      final vp = vendorPricing.value;
      if (vp != null &&
          !vp.hasSelectablePathology &&
          !vp.hasSelectableRadiology) {
        _skipToSlotsWithUnknownVendor();
      }
    } catch (e) {
      AppToast.error(title: 'Error', message: '$e');
    } finally {
      isVendorLoading.value = false;
    }
  }

  void _skipToSlotsWithUnknownVendor() {
    final firstCategory = containsPathology ? 'pathology' : 'radiology';
    currentSlotCategory.value = firstCategory;

    if (firstCategory == 'pathology') {
      _initDates(pathologyDates, pathologyMonthYear);
    } else {
      _initDates(radiologyDates, radiologyMonthYear);
    }
    _fetchSlotsForCategory(firstCategory);

    Get.off(() => const HealthCheckUpSlotSelectionPage());
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

  void _initDates(
      RxList<Map<String, String>> dates, RxString monthYear) {
    final now = DateTime.now();
    final dayFmt = DateFormat('dd');
    final weekFmt = DateFormat('EEE');
    final monthFmt = DateFormat('MMM yyyy');

    dates.assignAll(List.generate(7, (i) {
      final d = now.add(Duration(days: i + 1));
      return {'day': dayFmt.format(d), 'weekday': weekFmt.format(d)};
    }));

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
    final dateIdx =
        category == 'pathology' ? pathologyDateIndex.value : radiologyDateIndex.value;
    if (dates.isEmpty) return;

    final now = DateTime.now();
    final selectedDate =
        now.add(Duration(days: dateIdx + 1));
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

  void onTimeSlotSelected(String category, String time, AhcSlotsResponse slots) {
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
