import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/data/repositories/claims_repository.dart';
import 'package:flip_health/model/claims%20models/bank_account_model.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/claims/bank_detail_screen.dart';
import 'package:flip_health/views/claims/claim_detail_screen.dart';

class ClaimsController extends GetxController {
  final ClaimsRepository _repository;

  ClaimsController({required ClaimsRepository repository})
    : _repository = repository;
  final isLoading = false.obs;
  final allClaims = <ClaimModel>[].obs;
  final filteredClaims = <ClaimModel>[].obs;
  final selectedFilterIndex = 0.obs;

  final selectedClaim = Rxn<ClaimModel>();

  /// Loaded by [openClaimDetail] — `GET /patient/reimbursement/:id`.
  final claimDetailData = Rxn<Map<String, dynamic>>();
  final claimStatusSteps = <Map<String, dynamic>>[].obs;
  final isClaimDetailLoading = false.obs;
  int _claimDetailGen = 0;

  final claimsPage = 1.obs;
  final claimsHasMore = true.obs;
  final isClaimsLoadingMore = false.obs;

  /// Default service types from API (claim create).
  final billTypes = <Map<String, dynamic>>[].obs;
  final isSubmittingClaim = false.obs;
  final disputeReasonController = TextEditingController();

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

  /// API `bank_name` must be the bank **key** from `/patient/type`, not the display label.
  final selectedBankKey = ''.obs;
  final chequeFiles = <Map<String, dynamic>>[].obs;

  final bankDirectory = <Map<String, dynamic>>[].obs;
  final banksLoading = false.obs;
  final banksPage = 1.obs;
  final banksHasMore = true.obs;
  final bankSearchText = ''.obs;
  Timer? _bankSearchDebounce;
  int _bankLoadGeneration = 0;
  final isAddingBank = false.obs;

  /// Set when editing an existing bank (`PATCH`); null for create flow.
  final editingBankId = Rxn<String>();

  /// Loading [getBankDetailsById] when opening a row from the bank list.
  final isBankDetailLoading = false.obs;

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

  @override
  void onInit() {
    super.onInit();
    _loadClaims();
    _loadMembers();
    _loadBankAccounts();
  }

  Future<void> _loadClaims() async {
    isLoading.value = true;
    claimsPage.value = 1;
    claimsHasMore.value = true;
    try {
      final r = await _repository.fetchClaimsPage(1);
      allClaims.assignAll(r.items);
      claimsHasMore.value = r.hasMore;
      claimsPage.value = 2;
      filterByStatus(selectedFilterIndex.value);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshClaims() async {
    await _loadClaims();
  }

  Future<void> loadMoreClaims() async {
    if (isClaimsLoadingMore.value || !claimsHasMore.value || isLoading.value) {
      return;
    }
    isClaimsLoadingMore.value = true;
    try {
      final page = claimsPage.value;
      final r = await _repository.fetchClaimsPage(page);
      if (r.items.isEmpty) {
        claimsHasMore.value = false;
        return;
      }
      allClaims.addAll(r.items);
      claimsHasMore.value = r.hasMore;
      claimsPage.value = page + 1;
      filterByStatus(selectedFilterIndex.value);
    } catch (_) {
    } finally {
      isClaimsLoadingMore.value = false;
    }
  }

  Future<void> ensureBillTypes() async {
    if (billTypes.isNotEmpty) return;
    try {
      final list = await _repository.getBillTypes();
      billTypes.assignAll(list);
    } catch (_) {}
  }

  Map<String, dynamic> get _defaultServiceType {
    if (billTypes.isNotEmpty) {
      final b = billTypes.first;
      final key = b['key']?.toString() ?? b['id']?.toString() ?? 'general_opd';
      return {'key': key, 'value': b['value']};
    }
    return {'key': 'general_opd', 'value': null};
  }

  Map<String, dynamic>? _selectedMemberMap() {
    final id = selectedMemberId.value;
    for (final m in members) {
      if (m['id']?.toString() == id) {
        return Map<String, dynamic>.from(m);
      }
    }
    return null;
  }

  Future<void> openClaimDetail(ClaimModel claim) async {
    selectedClaim.value = claim;
    final gen = ++_claimDetailGen;
    claimDetailData.value = null;
    claimStatusSteps.clear();
    isClaimDetailLoading.value = true;

    Get.to(() => const ClaimDetailScreen())?.then((_) {
      if (gen == _claimDetailGen) {
        clearClaimDetail();
      }
    });

    try {
      final bundle = await _repository.fetchClaimDetail(claim.id);
      if (gen != _claimDetailGen) return;
      claimDetailData.value = bundle.data;
      claimStatusSteps.assignAll(bundle.statusSteps);
    } on AppException catch (e) {
      if (gen == _claimDetailGen) {
        Get.snackbar(
          'Error',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
        Get.back();
      }
    } catch (_) {
      if (gen == _claimDetailGen) {
        Get.back();
      }
    } finally {
      if (gen == _claimDetailGen) {
        isClaimDetailLoading.value = false;
      }
    }
  }

  void clearClaimDetail() {
    claimDetailData.value = null;
    claimStatusSteps.clear();
    disputeReasonController.clear();
  }

  Future<void> reloadCurrentClaimDetail() async {
    final id =
        claimDetailData.value?['id']?.toString() ?? selectedClaim.value?.id;
    if (id == null || id.isEmpty) return;
    try {
      final bundle = await _repository.fetchClaimDetail(id);
      claimDetailData.value = bundle.data;
      claimStatusSteps.assignAll(bundle.statusSteps);
    } catch (_) {}
  }

  Future<void> openBankForClaimUpdate() async {
    final bd = claimDetailData.value?['bank_details'];
    if (bd is! Map) return;
    final bankId = bd['id']?.toString();
    if (bankId == null || bankId.isEmpty) return;
    isBankDetailLoading.value = true;
    try {
      final detail = await _repository.getBankDetailsById(bankId);
      await _prepareEditBank(detail);
      await Get.toNamed(AppRoutes.addBank);
      await _loadBankAccounts();
      await reloadCurrentClaimDetail();
    } on AppException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isBankDetailLoading.value = false;
    }
  }

  Future<void> submitDispute() async {
    final reason = disputeReasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a reason for dispute',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }
    final id =
        claimDetailData.value?['id']?.toString() ?? selectedClaim.value?.id;
    if (id == null || id.isEmpty) return;
    try {
      await _repository.disputeClaim(id, status: 7, reason: reason);
      disputeReasonController.clear();
      await reloadCurrentClaimDetail();
      await _loadClaims();
      Get.snackbar(
        'Success',
        'Claim status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } on AppException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _loadMembers() async {
    try {
      members.value = await _repository.getMembers();
    } catch (_) {}
  }

  Future<void> _loadBankAccounts() async {
    try {
      print("loadBankAccounts");
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
      filteredClaims.value = allClaims
          .where((c) => c.status == status)
          .toList();
    }
  }

  void goToStep(int step) {
    currentStep.value = step;
    pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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

  /// Loads bank directory for the picker (`/patient/type`). [reset] clears the list and loads page 1.
  Future<void> loadBanks({bool reset = false}) async {
    // Allow a new search/refresh while a previous request is in flight; ignore stale responses.
    if (banksLoading.value && !reset) return;
    if (!reset && !banksHasMore.value) return;

    final gen = ++_bankLoadGeneration;
    banksLoading.value = true;
    try {
      final pageToFetch = reset ? 1 : banksPage.value;
      if (reset) {
        banksPage.value = 1;
        bankDirectory.clear();
        banksHasMore.value = true;
      }

      final list = await _repository.getBanks(
        pageToFetch,
        search: bankSearchText.value,
      );

      PrintLog.printLog('ClaimsController.loadBanks: $list');

      if (gen != _bankLoadGeneration) return;

      if (reset) {
        bankDirectory.assignAll(list);
      } else {
        bankDirectory.addAll(list);
      }
      bankDirectory.refresh();

      if (list.length < 20) {
        banksHasMore.value = false;
      } else {
        banksPage.value = pageToFetch + 1;
      }
    } catch (e, st) {
      PrintLog.printLog('ClaimsController.loadBanks: $e $st');
    } finally {
      if (gen == _bankLoadGeneration) {
        banksLoading.value = false;
      }
    }
  }

  void scheduleBankSearch(String query) {
    bankSearchText.value = query;
    _bankSearchDebounce?.cancel();
    _bankSearchDebounce = Timer(const Duration(milliseconds: 400), () {
      loadBanks(reset: true);
    });
  }

  void prepareBankPicker() {
    PrintLog.printLog('ClaimsController.prepareBankPicker');
    bankSearchText.value = '';
    loadBanks(reset: true);
  }

  /// Bank list row tap — patient_app: `verify_status == 2` → full edit form; else read-only detail.
  Future<void> openBankFromList(BankAccount bank) async {
    isBankDetailLoading.value = true;
    try {
      final detail = await _repository.getBankDetailsById(bank.id);
      if (BankAccount.canEditBankDetails(detail.verifyStatus)) {
        await _prepareEditBank(detail);
        await Get.toNamed(AppRoutes.addBank);
      } else {
        await Get.to(() => BankDetailScreen(account: detail));
      }
    } on AppException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isBankDetailLoading.value = false;
    }
  }

  Future<void> _prepareEditBank(BankAccount d) async {
    editingBankId.value = d.id;
    selectedBankKey.value = d.bankName;
    selectedBankName.value = d.bankName;
    bankNameController.text = d.bankName;
    holderNameController.text = d.holderName;
    accountNumberController.text = d.accountNumber;
    confirmAccountController.text = d.accountNumber;
    ifscController.text = d.ifscCode;
    branchController.text = d.branch;
    chequeFiles.clear();
    final url = ApiUrl.publicFileUrl(d.chequeImagePath);
    if (url != null) {
      chequeFiles.add({
        'path': url,
        'name': 'Cheque',
        'isImage': !url.toLowerCase().endsWith('.pdf'),
        'isNetwork': true,
        if (d.chequeAttachmentId != null) 'attachmentId': d.chequeAttachmentId,
      });
    }
  }

  void clearEditBankMode() {
    editingBankId.value = null;
    _clearBankForm();
  }

  Future<void> updateBankAccount() async {
    final id = editingBankId.value;
    if (id == null) return;

    if (accountNumberController.text.isEmpty ||
        holderNameController.text.isEmpty ||
        ifscController.text.isEmpty ||
        selectedBankKey.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (branchController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Branch is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (chequeFiles.isEmpty) {
      Get.snackbar(
        'Error',
        'Cancelled cheque is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (accountNumberController.text != confirmAccountController.text) {
      Get.snackbar(
        'Error',
        'Account numbers do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    isAddingBank.value = true;
    try {
      final f = chequeFiles.first;
      String chequeId;
      if (f['isNetwork'] == true && f['attachmentId'] != null) {
        chequeId = f['attachmentId'].toString();
      } else {
        final path = f['path'] as String?;
        if (path == null || path.isEmpty) {
          Get.snackbar(
            'Error',
            'Invalid file',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
          );
          return;
        }
        chequeId = await _repository.uploadChequeAttachment(path);
      }

      await _repository.updateBankDetails(id, {
        'bank_name': selectedBankKey.value,
        'ifsc_code': ifscController.text.trim(),
        'branch': branchController.text.trim(),
        'account_number': accountNumberController.text.trim(),
        'account_holder_name': holderNameController.text.trim(),
        'cheque': chequeId,
      });

      await _loadBankAccounts();
      clearEditBankMode();
      Get.back();
      Get.snackbar(
        'Success',
        'Bank details updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } on AppException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isAddingBank.value = false;
    }
  }

  Future<void> addBankAccount() async {
    if (accountNumberController.text.isEmpty ||
        holderNameController.text.isEmpty ||
        ifscController.text.isEmpty ||
        selectedBankKey.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (branchController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Branch is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (chequeFiles.isEmpty) {
      Get.snackbar(
        'Error',
        'Cancelled cheque is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (accountNumberController.text != confirmAccountController.text) {
      Get.snackbar(
        'Error',
        'Account numbers do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    final path = chequeFiles.first['path'] as String?;
    if (path == null || path.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    isAddingBank.value = true;
    try {
      final attachmentId = await _repository.uploadChequeAttachment(path);
      await _repository.addBankDetails({
        'bank_name': selectedBankKey.value,
        'ifsc_code': ifscController.text.trim(),
        'branch': branchController.text.trim(),
        'account_number': accountNumberController.text.trim(),
        'account_holder_name': holderNameController.text.trim(),
        'cheque': attachmentId,
      });

      await _loadBankAccounts();

      final accNum = accountNumberController.text.trim();
      BankAccount? match;
      for (final b in bankAccounts) {
        if (b.accountNumber == accNum) {
          match = b;
          break;
        }
      }
      if (match != null) {
        selectBankAccount(match);
      }

      _clearBankForm();
      Get.back();
      Get.snackbar(
        'Success',
        'Bank account added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } on AppException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isAddingBank.value = false;
    }
  }

  void _clearBankForm() {
    bankNameController.clear();
    accountNumberController.clear();
    confirmAccountController.clear();
    ifscController.clear();
    branchController.clear();
    holderNameController.clear();
    selectedBankName.value = '';
    selectedBankKey.value = '';
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
    if (billNumberController.text.isEmpty || billAmountController.text.isEmpty) {
      return;
    }
    bills.add(
      ClaimBill(
        billNumber: billNumberController.text,
        billDate: billDateController.text,
        billAmount: double.tryParse(billAmountController.text) ?? 0,
        clinicName: clinicNameController.text,
        clinicAddress: clinicAddressController.text,
        doctorName: doctorNameController.text,
        doctorRegistration: doctorRegController.text,
        imageFiles: List.from(billImageFiles),
      ),
    );
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
          case 'PAYMENT':
            paymentFiles.add(map);
            break;
          case 'REPORT':
            reportFiles.add(map);
            break;
          case 'OTHER':
            otherFiles.add(map);
            break;
        }
      },
    );
  }

  void removeFile(String type, int index) {
    switch (type) {
      case 'PAYMENT':
        paymentFiles.removeAt(index);
        break;
      case 'REPORT':
        reportFiles.removeAt(index);
        break;
      case 'OTHER':
        otherFiles.removeAt(index);
        break;
    }
  }

  double get totalBillAmount => bills.fold(0, (sum, b) => sum + b.billAmount);

  /// Validates overview + uploads files, then `POST /patient/reimbursement/create`.
  Future<void> submitClaimToServer() async {
    if (!isStep1Valid) {
      Get.snackbar(
        'Error',
        'Please complete patient details, bank, and accept terms',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }
    if (alternatePhoneController.text.isNotEmpty &&
        alternatePhoneController.text.trim().length != 10) {
      Get.snackbar(
        'Error',
        'Alternate phone must be 10 digits',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }
    if (bills.isEmpty) {
      Get.snackbar(
        'Error',
        'Add at least one medical bill',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }
    if (totalBillAmount <= 0) {
      Get.snackbar(
        'Error',
        'Claim amount must be greater than zero',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }
    for (final bill in bills) {
      if (bill.imageFiles.isEmpty) {
        Get.snackbar(
          'Error',
          'Attach at least one bill document for each bill',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
        return;
      }
    }

    final memberRaw = _selectedMemberMap();
    if (memberRaw == null) {
      Get.snackbar(
        'Error',
        'Select a patient',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }
    final member = Map<String, dynamic>.from(memberRaw);
    final phone = phoneController.text.trim();
    if (phone.isNotEmpty) {
      member['phone'] = phone;
    }
    final email = emailController.text.trim();
    if (email.isNotEmpty) {
      member['email'] = email;
    }
    final bankId = selectedBank.value?.id;
    if (bankId == null || bankId.isEmpty) {
      Get.snackbar(
        'Error',
        'Select a bank account',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    await ensureBillTypes();
    final svc = _defaultServiceType;

    isSubmittingClaim.value = true;
    try {
      final reimbursementBills = <Map<String, dynamic>>[];
      for (final bill in bills) {
        final files = <Map<String, dynamic>>[];
        for (final f in bill.imageFiles) {
          final path = f['path'] as String?;
          if (path == null ||
              path.isEmpty ||
              path.startsWith('http://') ||
              path.startsWith('https://')) {
            continue;
          }
          final up = await _repository.uploadReimbursementFile(
            path,
            refType: 'BILL',
            documentType: '',
          );
          files.add({...up, 'service_types': [svc]});
        }
        if (files.isEmpty) {
          throw AppException(
            message: 'Bill upload failed. Try again.',
          );
        }
        reimbursementBills.add({
          'bill_number': bill.billNumber,
          'bill_date': bill.billDate,
          'bill_amount': bill.billAmount,
          'clinic_name': bill.clinicName,
          'clinic_address': bill.clinicAddress,
          'doctor_name': bill.doctorName,
          'doctor_registration_number': bill.doctorRegistration,
          'reimbursement_bill_files': files,
          'service_types': [svc],
        });
      }

      Future<List<Map<String, dynamic>>> uploadDocList(
        List<Map<String, dynamic>> src,
        String refType,
      ) async {
        final out = <Map<String, dynamic>>[];
        for (final f in src) {
          final path = f['path'] as String?;
          if (path == null ||
              path.isEmpty ||
              path.startsWith('http://') ||
              path.startsWith('https://')) {
            continue;
          }
          final up = await _repository.uploadReimbursementFile(
            path,
            refType: refType,
            documentType: '',
          );
          out.add({
            ...up,
            'service_types': [svc],
            'title': f['name']?.toString() ?? 'Document',
          });
        }
        return out;
      }

      final paymentUploaded =
          await uploadDocList(paymentFiles.toList(), 'PAYMENT');
      final reportUploaded =
          await uploadDocList(reportFiles.toList(), 'REPORT');
      final otherUploaded = await uploadDocList(otherFiles.toList(), 'OTHER');

      final body = <String, dynamic>{
        'user_id': selectedMemberId.value,
        'user_data': member,
        'bank_id': bankId,
        'reason_for_reimbursement': null,
        'alternative_number': alternatePhoneController.text.trim().isEmpty
            ? null
            : alternatePhoneController.text.trim(),
        'claim_amount': totalBillAmount,
        'reimbursement_bills': reimbursementBills,
        'reimbursement_bill_payment_files': paymentUploaded,
        'reimbursement_report_files': reportUploaded,
        'reimbursement_other_files': otherUploaded,
      };

      await _repository.createReimbursementClaim(body);
      Get.back();
      resetAddClaim();
      await _loadClaims();
      filterByStatus(0);
      Get.snackbar(
        'Success',
        'Claim submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } on AppException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isSubmittingClaim.value = false;
    }
  }

  void resetAddClaim() {
    currentStep.value = 0;
    selectedMemberId.value = '';
    selectedMemberName.value = '';
    phoneController.clear();
    emailController.clear();
    alternatePhoneController.clear();
    selectedBankName.value = '';
    selectedBankKey.value = '';
    editingBankId.value = null;
    selectedBank.value = null;
    termsAccepted.value = false;
    bills.clear();
    paymentFiles.clear();
    reportFiles.clear();
    otherFiles.clear();
    billImageFiles.clear();
    billTypes.clear();
    _clearBillForm();
    _clearBankForm();
    Future.microtask(() => ensureBillTypes());
  }

  @override
  void onClose() {
    disputeReasonController.dispose();
    _bankSearchDebounce?.cancel();
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
