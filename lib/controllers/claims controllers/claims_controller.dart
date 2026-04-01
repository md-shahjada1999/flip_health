import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/data/repositories/claims_repository.dart';
import 'package:flip_health/model/claims%20models/bank_account_model.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class ClaimsController extends GetxController {
  final ClaimsRepository _repository;

  ClaimsController({required ClaimsRepository repository})
      : _repository = repository;
  final isLoading = false.obs;
  final allClaims = <ClaimModel>[].obs;
  final filteredClaims = <ClaimModel>[].obs;
  final selectedFilterIndex = 0.obs;

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
  final termsAccepted = false.obs;
  final members = <Map<String, dynamic>>[].obs;

  // Bank Details
  final bankAccounts = <BankAccount>[].obs;
  final selectedBank = Rxn<BankAccount>();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountController = TextEditingController();
  final ifscController = TextEditingController();
  final branchController = TextEditingController();
  final holderNameController = TextEditingController();
  final selectedBankName = ''.obs;
  final chequeFiles = <Map<String, dynamic>>[].obs;

  // Step 2 - Bill Details
  final bills = <ClaimBill>[].obs;
  final billNumberController = TextEditingController();
  final billDateController = TextEditingController();
  final billAmountController = TextEditingController();
  final clinicNameController = TextEditingController();
  final clinicAddressController = TextEditingController();
  final doctorNameController = TextEditingController();
  final doctorRegController = TextEditingController();
  final billImageFiles = <Map<String, dynamic>>[].obs;
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

  static const List<String> bankNames = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Kotak Mahindra Bank',
    'IndusInd Bank',
    'Yes Bank',
    'Union Bank of India',
    'Canara Bank',
    'Bank of India',
    'IDBI Bank',
    'Federal Bank',
    'Indian Overseas Bank',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadClaims();
    _loadMembers();
    _loadBankAccounts();
  }

  Future<void> _loadClaims() async {
    isLoading.value = true;
    try {
      allClaims.value = await _repository.getClaims();
      filteredClaims.value = List.from(allClaims);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMembers() async {
    try {
      members.value = await _repository.getMembers();
    } catch (_) {}
  }

  Future<void> _loadBankAccounts() async {
    try {
      bankAccounts.value = await _repository.getBankAccounts();
    } catch (_) {}
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

  void goToStep(int step) {
    currentStep.value = step;
    pageController.animateToPage(step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void selectMember(String id, String name) {
    selectedMemberId.value = id;
    selectedMemberName.value = name;
  }

  // Bank methods
  void selectBankAccount(BankAccount bank) {
    selectedBank.value = bank;
    selectedBankName.value = '${bank.bankName} - ${bank.maskedAccountNumber}';
  }

  void addBankAccount() {
    if (accountNumberController.text.isEmpty ||
        holderNameController.text.isEmpty ||
        ifscController.text.isEmpty ||
        bankNameController.text.isEmpty) return;

    if (accountNumberController.text != confirmAccountController.text) {
      Get.snackbar('Error', 'Account numbers do not match',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800);
      return;
    }

    final newBank = BankAccount(
      id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
      bankName: bankNameController.text,
      accountNumber: accountNumberController.text,
      ifscCode: ifscController.text,
      branch: branchController.text,
      holderName: holderNameController.text,
      verifyStatus: 0,
      chequeImagePath: chequeFiles.isNotEmpty ? chequeFiles.first['path'] : null,
    );
    bankAccounts.add(newBank);
    selectBankAccount(newBank);
    _clearBankForm();
    Get.back();
    Get.snackbar('Success', 'Bank account added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800);
  }

  void _clearBankForm() {
    bankNameController.clear();
    accountNumberController.clear();
    confirmAccountController.clear();
    ifscController.clear();
    branchController.clear();
    holderNameController.clear();
    chequeFiles.clear();
  }

  void pickChequeImage() {
    FilePickerHelper.showPickerBottomSheet(
      onFilePicked: (file) {
        chequeFiles.clear();
        chequeFiles.add(file.toMap());
      },
    );
  }

  void removeChequeImage(int index) => chequeFiles.removeAt(index);

  bool get isStep1Valid =>
      selectedMemberId.value.isNotEmpty &&
      phoneController.text.isNotEmpty &&
      selectedBank.value != null &&
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
      imageFiles: List.from(billImageFiles),
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
    billImageFiles.clear();
  }

  void pickBillImage() {
    FilePickerHelper.showPickerBottomSheet(
      onFilePicked: (file) => billImageFiles.add(file.toMap()),
    );
  }

  void removeBillImage(int index) => billImageFiles.removeAt(index);

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
    selectedBank.value = null;
    termsAccepted.value = false;
    bills.clear();
    paymentFiles.clear();
    reportFiles.clear();
    otherFiles.clear();
    billImageFiles.clear();
    _clearBillForm();
    _clearBankForm();
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
    bankNameController.dispose();
    accountNumberController.dispose();
    confirmAccountController.dispose();
    ifscController.dispose();
    branchController.dispose();
    holderNameController.dispose();
    super.onClose();
  }
}
