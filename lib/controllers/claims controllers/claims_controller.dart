import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class ClaimsController extends GetxController {
  final isLoading = false.obs;
  final allClaims = <ClaimModel>[].obs;
  final filteredClaims = <ClaimModel>[].obs;
  final selectedFilterIndex = 0.obs;

  // Claim detail
  final selectedClaim = Rxn<ClaimModel>();

  // Add claim wizard
  final currentStep = 0.obs;
  final pageController = PageController();

  // Step 1 - Patient Details
  final selectedMemberId = ''.obs;
  final selectedMemberName = ''.obs;
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final alternatePhoneController = TextEditingController();
  final selectedBankName = ''.obs;
  final termsAccepted = false.obs;
  final members = <Map<String, dynamic>>[].obs;

  // Step 2 - Bill Details
  final bills = <ClaimBill>[].obs;
  final billNumberController = TextEditingController();
  final billDateController = TextEditingController();
  final billAmountController = TextEditingController();
  final clinicNameController = TextEditingController();
  final clinicAddressController = TextEditingController();
  final doctorNameController = TextEditingController();
  final doctorRegController = TextEditingController();
  final paymentFiles = <Map<String, dynamic>>[].obs;
  final reportFiles = <Map<String, dynamic>>[].obs;
  final otherFiles = <Map<String, dynamic>>[].obs;

  static const List<Map<String, dynamic>> statusFilters = [
    {'status': -1, 'label': 'All', 'color': Color(0xFF607D8B)},
    {'status': 0, 'label': 'Submitted', 'color': Color(0xFF2196F3)},
    {'status': 4, 'label': 'In Review', 'color': Color(0xFFFF9800)},
    {'status': 3, 'label': 'Action Required', 'color': Color(0xFFE53935)},
    {'status': 5, 'label': 'Approved', 'color': Color(0xFF4CAF50)},
    {'status': 8, 'label': 'Pending Disbursement', 'color': Color(0xFF00BCD4)},
    {'status': 1, 'label': 'Settled', 'color': Color(0xFF43A047)},
    {'status': 2, 'label': 'Denied', 'color': Color(0xFFD32F2F)},
    {'status': 7, 'label': 'Disputed', 'color': Color(0xFFFF5722)},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadClaims();
    _loadMembers();
  }

  void _loadClaims() {
    isLoading.value = true;
    allClaims.value = [
      ClaimModel(id: 'CLM001', userName: 'Kalyan', userPhone: '9876543210', status: 0, claimAmount: 2500, createdAt: '2024-03-15', serviceType: 'Dental'),
      ClaimModel(id: 'CLM002', userName: 'Priya', userPhone: '9876543211', status: 5, claimAmount: 8500, approvedAmount: 7200, createdAt: '2024-03-10', serviceType: 'Consultation'),
      ClaimModel(id: 'CLM003', userName: 'Kalyan', userPhone: '9876543210', status: 1, claimAmount: 1200, approvedAmount: 1200, createdAt: '2024-02-28', serviceType: 'Pharmacy'),
      ClaimModel(id: 'CLM004', userName: 'Rahul', userPhone: '9876543212', status: 4, claimAmount: 5000, createdAt: '2024-03-20', serviceType: 'Vision'),
      ClaimModel(id: 'CLM005', userName: 'Kalyan', userPhone: '9876543210', status: 2, claimAmount: 3200, createdAt: '2024-01-15', serviceType: 'Dental'),
    ];
    filteredClaims.value = List.from(allClaims);
    isLoading.value = false;
  }

  void _loadMembers() {
    members.value = [
      {'id': '1', 'name': 'Kalyan', 'age': 32, 'gender': 'Male', 'relation': 'Self'},
      {'id': '2', 'name': 'Priya', 'age': 28, 'gender': 'Female', 'relation': 'Spouse'},
      {'id': '3', 'name': 'Rahul', 'age': 8, 'gender': 'Male', 'relation': 'Son'},
    ];
  }

  int getStatusCount(int status) {
    if (status == -1) return allClaims.length;
    return allClaims.where((c) => c.status == status).length;
  }

  void filterByStatus(int index) {
    selectedFilterIndex.value = index;
    final status = statusFilters[index]['status'] as int;
    if (status == -1) {
      filteredClaims.value = List.from(allClaims);
    } else {
      filteredClaims.value = allClaims.where((c) => c.status == status).toList();
    }
  }

  void selectClaimDetail(ClaimModel claim) {
    selectedClaim.value = claim;
  }

  // Wizard navigation
  void goToStep(int step) {
    currentStep.value = step;
    pageController.animateToPage(step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void selectMember(String id, String name) {
    selectedMemberId.value = id;
    selectedMemberName.value = name;
  }

  bool get isStep1Valid =>
      selectedMemberId.value.isNotEmpty &&
      phoneController.text.isNotEmpty &&
      termsAccepted.value;

  // Bill management
  void addBill() {
    if (billNumberController.text.isEmpty || billAmountController.text.isEmpty) return;
    bills.add(ClaimBill(
      billNumber: billNumberController.text,
      billDate: billDateController.text,
      billAmount: double.tryParse(billAmountController.text) ?? 0,
      clinicName: clinicNameController.text,
      clinicAddress: clinicAddressController.text,
      doctorName: doctorNameController.text,
      doctorRegistration: doctorRegController.text,
    ));
    _clearBillForm();
  }

  void removeBill(int index) => bills.removeAt(index);

  void _clearBillForm() {
    billNumberController.clear();
    billDateController.clear();
    billAmountController.clear();
    clinicNameController.clear();
    clinicAddressController.clear();
    doctorNameController.clear();
    doctorRegController.clear();
  }

  void pickFile(String type) {
    FilePickerHelper.showPickerBottomSheet(
      onFilePicked: (file) {
        final map = file.toMap();
        switch (type) {
          case 'PAYMENT': paymentFiles.add(map); break;
          case 'REPORT': reportFiles.add(map); break;
          case 'OTHER': otherFiles.add(map); break;
        }
      },
    );
  }

  void removeFile(String type, int index) {
    switch (type) {
      case 'PAYMENT': paymentFiles.removeAt(index); break;
      case 'REPORT': reportFiles.removeAt(index); break;
      case 'OTHER': otherFiles.removeAt(index); break;
    }
  }

  double get totalBillAmount => bills.fold(0, (sum, b) => sum + b.billAmount);

  void submitClaim() {
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void resetAddClaim() {
    currentStep.value = 0;
    selectedMemberId.value = '';
    selectedMemberName.value = '';
    phoneController.clear();
    emailController.clear();
    alternatePhoneController.clear();
    selectedBankName.value = '';
    termsAccepted.value = false;
    bills.clear();
    paymentFiles.clear();
    reportFiles.clear();
    otherFiles.clear();
    _clearBillForm();
  }

  @override
  void onClose() {
    pageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    alternatePhoneController.dispose();
    billNumberController.dispose();
    billDateController.dispose();
    billAmountController.dispose();
    clinicNameController.dispose();
    clinicAddressController.dispose();
    doctorNameController.dispose();
    doctorRegController.dispose();
    super.onClose();
  }
}
