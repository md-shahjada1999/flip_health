import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/data/repositories/claims_repository.dart';
import 'package:flip_health/data/repositories/member_repository.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/model/claims%20models/bank_account_model.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/claims/bank_detail_screen.dart';
import 'package:flip_health/views/claims/claim_detail_screen.dart';

class ClaimsController extends GetxController {
  final ClaimsRepository _repository;
  final MemberRepository _memberRepository;

  ClaimsController({
    required ClaimsRepository repository,
    required MemberRepository memberRepository,
  }) : _repository = repository,
       _memberRepository = memberRepository;
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
  final familyMembers = <FamilyMember>[].obs;
  final membersLoading = true.obs;

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
  final isBankFormValid = false.obs;

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

  /// `-1` = new bill; `>= 0` = editing `bills[index]` (patient_app `billIndex`).
  final billIndex = (-1).obs;
  final billServicePickerSelection = <Map<String, dynamic>>[].obs;
  final requiredPayments = <dynamic>[].obs;
  final requiredReports = <dynamic>[].obs;
  final step2DocumentsValid = true.obs;

  /// patient_app `selectedServices` during claim-doc service sheet (payment / report / other).
  final selectedDocServiceTypes = <Map<String, dynamic>>[].obs;
  final isClaimDocUploading = false.obs;

  /// Add-bill sheet: uploading bill attachment to `/upload` (patient_app `uploadFile` for BILL).
  final isBillImageUploading = false.obs;

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
    _initBankFormListeners();
  }

  void _initBankFormListeners() {
    void validate() {
      isBankFormValid.value =
          selectedBankName.value.isNotEmpty &&
          holderNameController.text.trim().isNotEmpty &&
          accountNumberController.text.trim().isNotEmpty &&
          confirmAccountController.text.trim().isNotEmpty &&
          ifscController.text.trim().isNotEmpty &&
          branchController.text.trim().isNotEmpty &&
          chequeFiles.isNotEmpty;
    }

    holderNameController.addListener(validate);
    accountNumberController.addListener(validate);
    confirmAccountController.addListener(validate);
    ifscController.addListener(validate);
    branchController.addListener(validate);
    ever(selectedBankName, (_) => validate());
    ever(chequeFiles, (_) => validate());
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

  static String _digits10(String? raw) {
    final d = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (d.length >= 10) return d.substring(d.length - 10);
    return d;
  }

  Map<String, dynamic>? _selectedMemberMap() {
    final id = selectedMemberId.value;
    for (final m in familyMembers) {
      if (m.id == id) {
        return {
          'id': m.id,
          'name': m.name,
          'first_name': m.firstName,
          'last_name': m.lastName,
          'relationship': m.relationship,
          'relation': m.relationship ?? '',
          'gender': m.gender,
          'age': m.age,
          'phone': m.phone,
          'email': m.email,
          'dob': m.dob,
          'bloodGroup': m.bloodGroup,
          'empId': m.empId,
          'image': m.image,
          'corporate_id': m.corporateId,
          'isSubscribed': m.isSubscribed,
        };
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
    membersLoading.value = true;
    try {
      final list = await _memberRepository.getMembers();
      familyMembers.assignAll(list);
      if (list.isNotEmpty) {
        FamilyMember pick = list.first;
        for (final m in list) {
          if ((m.relationship ?? '').toLowerCase() == 'self') {
            pick = m;
            break;
          }
        }
        selectMember(pick);
      }
    } catch (_) {
      familyMembers.clear();
    } finally {
      membersLoading.value = false;
    }
  }

  FamilyMember? get _primaryMember {
    for (final m in familyMembers) {
      final rel = (m.relationship ?? '').toLowerCase().trim();
      if (rel.isEmpty || rel == 'self' || rel == 'employee') return m;
    }
    return familyMembers.isNotEmpty ? familyMembers.first : null;
  }

  void selectMember(FamilyMember m) {
    selectedMemberId.value = m.id;
    selectedMemberName.value = m.name;

    final phone = _digits10(m.phone);
    if (phone.isNotEmpty) {
      phoneController.text = phone;
    } else {
      phoneController.text = _digits10(_primaryMember?.phone);
    }

    final email = (m.email ?? '').trim();
    if (email.isNotEmpty) {
      emailController.text = email;
    } else {
      emailController.text = (_primaryMember?.email ?? '').trim();
    }
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
      _clearBankForm();

      if (match != null) {
        selectBankAccount(match);
      }

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

  // Bill management — service types + required docs (patient_app `add_claims_new`)
  void prepareNewBillSheet() {
    billIndex.value = -1;
    _clearBillForm();
  }

  void loadBillForEdit(int index) {
    if (index < 0 || index >= bills.length) return;
    billIndex.value = index;
    final b = bills[index];
    billNumberController.text = b.billNumber;
    billDateController.text = b.billDate;
    billAmountController.text = b.billAmount.toString();
    clinicNameController.text = b.clinicName;
    clinicAddressController.text = b.clinicAddress;
    doctorNameController.text = b.doctorName;
    doctorRegController.text = b.doctorRegistration;
    billImageFiles.assignAll(
      b.imageFiles.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  bool _billFormFieldsValid() {
    if (billNumberController.text.trim().isEmpty ||
        billDateController.text.trim().isEmpty ||
        billAmountController.text.trim().isEmpty ||
        clinicNameController.text.trim().isEmpty ||
        clinicAddressController.text.trim().isEmpty ||
        billImageFiles.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill mandatory bill fields and attach at least one bill image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }
    final amt = double.tryParse(billAmountController.text.trim());
    if (amt == null || amt < 1) {
      Get.snackbar(
        'Error',
        'Bill amount must be at least 1',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }
    return true;
  }

  Future<void> onSaveMedicalBillPressed() async {
    if (!_billFormFieldsValid()) return;
    await ensureBillTypes();
    if (billTypes.isEmpty) {
      Get.snackbar(
        'Error',
        'Could not load service types. Try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }
    if (billIndex.value < 0) {
      showBillReviewTermsBottomSheet();
    } else {
      showBillServiceTypesBottomSheet();
    }
  }

  void showBillReviewTermsBottomSheet() {
    Get.bottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      SizedBox(
        height: Get.height * 0.52,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.rw, 12.rh, 20.rw, 16.rh),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(6.rs),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0E0E0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, size: 20.rs, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.rh),
                  CommonText(
                    AppString.kReviewYourSubmission,
                    fontSize: 17.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 12.rh),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(12.rw, 10.rh, 16.rw, 10.rh),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(12.rs),
                        ),
                        child: SingleChildScrollView(
                          child: CommonText(
                            AppString.kBillReviewDisclaimer,
                            fontSize: 13.rf,
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.rh),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      showBillServiceTypesBottomSheet();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.rh),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.rs)),
                      elevation: 0,
                    ),
                    child: CommonText(
                      AppString.kIAgree,
                      fontSize: 15.rf,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetBillServicePickerSelection() {
    billServicePickerSelection.clear();
    final i = billIndex.value;
    if (i >= 0 && i < bills.length) {
      for (final m in bills[i].serviceTypes) {
        billServicePickerSelection.add(
          Map<String, dynamic>.from(json.decode(json.encode(m))),
        );
      }
    }
  }

  void toggleBillServiceTypeSelection(Map<String, dynamic> value) {
    final key = value['key']?.toString() ?? '';
    if (key.isEmpty) return;
    final idx = billServicePickerSelection.indexWhere(
      (e) => e['key']?.toString() == key,
    );
    if (idx >= 0) {
      billServicePickerSelection.removeAt(idx);
    } else {
      billServicePickerSelection.add({
        'type': key,
        ...Map<String, dynamic>.from(value),
      });
    }
  }

  void showBillServiceTypesBottomSheet() {
    _resetBillServicePickerSelection();
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: Get.height * 0.55,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
        ),
        padding: EdgeInsets.fromLTRB(20.rs, 12.rh, 20.rs, 20.rh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CommonText(
                    AppString.kSelectServiceTypes,
                    fontSize: 18.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 24.rs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Divider(height: 20.rh, thickness: 1, color: AppColors.borderLight),
            Expanded(
              child: Obx(() {
                if (billTypes.isEmpty) {
                  return Center(
                    child: CommonText(
                      AppString.kNoServiceTypesAvailable,
                      fontSize: 14.rf,
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 10.rw,
                    runSpacing: 10.rh,
                    children: billTypes.map((value) {
                      final key = value['key']?.toString() ?? '';
                      final selected = billServicePickerSelection.any(
                        (e) => e['key']?.toString() == key,
                      );
                      return GestureDetector(
                        onTap: () => toggleBillServiceTypeSelection(value),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.rw,
                            vertical: 8.rh,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.rs),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                            ),
                            color: selected
                                ? AppColors.primary
                                : AppColors.surface,
                          ),
                          child: CommonText(
                            value['value']?.toString() ?? key,
                            fontSize: 12.rf,
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
            Obx(() {
              if (billServicePickerSelection.isEmpty) {
                return SizedBox(height: 8.rh);
              }
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => billServicePickerSelection.clear(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.rh),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.rs),
                        ),
                        side: BorderSide(color: AppColors.borderLight),
                      ),
                      child: CommonText(
                        AppString.kClearAll,
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.rw),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await commitBillAfterServiceSelection();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.rh),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.rs),
                        ),
                        elevation: 0,
                      ),
                      child: CommonText(
                        AppString.kApply,
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> commitBillAfterServiceSelection() async {
    if (billServicePickerSelection.isEmpty) {
      Get.snackbar(
        'Error',
        AppString.kSelectAtLeastOneServiceType,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }
    final normalized = billServicePickerSelection
        .map((e) => Map<String, dynamic>.from(json.decode(json.encode(e))))
        .toList();

    final newBill = ClaimBill(
      billNumber: billNumberController.text.trim(),
      billDate: billDateController.text.trim(),
      billAmount: double.tryParse(billAmountController.text.trim()) ?? 0,
      clinicName: clinicNameController.text.trim(),
      clinicAddress: clinicAddressController.text.trim(),
      doctorName: doctorNameController.text.trim(),
      doctorRegistration: doctorRegController.text.trim(),
      imageFiles: billImageFiles
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      serviceTypes: normalized,
    );

    if (billIndex.value < 0) {
      bills.add(newBill);
    } else {
      bills[billIndex.value] = newBill;
    }

    billIndex.value = -1;
    _clearBillForm();
    billServicePickerSelection.clear();

    await syncRequiredDocumentsFromApi();
    refreshStep2DocumentValidation();

    Get.back();
    Get.back();
  }

  List<Map<String, dynamic>> getUniqueSelectedServiceTypesFromBills() {
    final out = <Map<String, dynamic>>[];
    for (final bill in bills) {
      for (final st in bill.serviceTypes) {
        final key = st['key']?.toString();
        if (key == null || key.isEmpty) continue;
        if (out.any((e) => e['key'] == key)) continue;
        out.add(Map<String, dynamic>.from(st));
      }
    }
    return out;
  }

  List<dynamic> _normalizeRequiredDocList(List<dynamic> raw) {
    return raw.map((e) {
      if (e is Map) {
        final m = Map<String, dynamic>.from(e);
        m['missingReports'] = <dynamic>[];
        return m;
      }
      return e;
    }).toList();
  }

  Future<void> syncRequiredDocumentsFromApi() async {
    final keys = getUniqueSelectedServiceTypesFromBills()
        .map((e) => e['key']?.toString())
        .where((k) => (k ?? '').isNotEmpty)
        .join(',');
    if (keys.isEmpty) {
      requiredPayments.clear();
      requiredReports.clear();
      refreshStep2DocumentValidation();
      return;
    }
    try {
      final r = await _repository.getRequiredDocumentsMultiList(keys);
      requiredPayments.assignAll(_normalizeRequiredDocList(r.payments));
      requiredReports.assignAll(_normalizeRequiredDocList(r.reports));
    } catch (_) {
      requiredPayments.clear();
      requiredReports.clear();
    }
    refreshStep2DocumentValidation();
  }

  Map<String, dynamic> _claimDraftForValidation() {
    return {
      'reimbursement_report_files': reportFiles
          .map((f) => Map<String, dynamic>.from(f))
          .toList(),
      'reimbursement_bill_payment_files': paymentFiles
          .map((f) => Map<String, dynamic>.from(f))
          .toList(),
    };
  }

  bool _rowParticularsRequired(Map<String, dynamic> row) {
    final p = row['particulars'];
    if (p is Map) {
      return p['required'] == true;
    }
    return false;
  }

  bool _step2ValidationSync() {
    final claimData = _claimDraftForValidation();
    bool paymentOk = true;
    bool reportOk = true;

    for (var index = 0; index < requiredReports.length; index++) {
      final report = requiredReports[index];
      if (report is! Map) continue;
      final row = Map<String, dynamic>.from(report);
      requiredReports[index] = row;
      row['missingReports'] = <dynamic>[];

      if (!_rowParticularsRequired(row)) continue;

      final category = row['category']?.toString() ?? '';
      final merged = <Map<String, dynamic>>[];
      for (final file in claimData['reimbursement_report_files'] as List) {
        if (file is! Map) continue;
        final fm = Map<String, dynamic>.from(file);
        if ((fm['document_type']?.toString() ?? '') != category) continue;
        final st = fm['service_types'];
        if (st is List) {
          for (final s in st) {
            if (s is Map) {
              final sm = Map<String, dynamic>.from(s);
              final k = sm['key']?.toString();
              if (k != null && !merged.any((e) => e['key'] == k)) {
                merged.add(sm);
              }
            }
          }
        }
      }

      final claimTypes = row['claim_type'];
      if (claimTypes is List) {
        for (final ct in claimTypes) {
          if (ct is! Map) continue;
          final ctm = Map<String, dynamic>.from(ct);
          final ck = ctm['key']?.toString();
          if (ck == null) continue;
          if (!merged.map((e) => e['key']).contains(ck)) {
            (row['missingReports'] as List).add(json.decode(json.encode(ctm)));
            reportOk = false;
          }
        }
      }
    }

    for (var index = 0; index < requiredPayments.length; index++) {
      final payment = requiredPayments[index];
      if (payment is! Map) continue;
      final row = Map<String, dynamic>.from(payment);
      requiredPayments[index] = row;
      row['missingReports'] = <dynamic>[];

      if (!_rowParticularsRequired(row)) continue;

      final category = row['category']?.toString() ?? '';
      final merged = <Map<String, dynamic>>[];
      for (final file
          in claimData['reimbursement_bill_payment_files'] as List) {
        if (file is! Map) continue;
        final fm = Map<String, dynamic>.from(file);
        if ((fm['document_type']?.toString() ?? '') != category) continue;
        final st = fm['service_types'];
        if (st is List) {
          for (final s in st) {
            if (s is Map) {
              final sm = Map<String, dynamic>.from(s);
              final k = sm['key']?.toString();
              if (k != null && !merged.any((e) => e['key'] == k)) {
                merged.add(sm);
              }
            }
          }
        }
      }

      final claimTypes = row['claim_type'];
      if (claimTypes is List) {
        for (final ct in claimTypes) {
          if (ct is! Map) continue;
          final ctm = Map<String, dynamic>.from(ct);
          final ck = ctm['key']?.toString();
          if (ck == null) continue;
          if (!merged.map((e) => e['key']).contains(ck)) {
            (row['missingReports'] as List).add(json.decode(json.encode(ctm)));
            paymentOk = false;
          }
        }
      }
    }

    requiredPayments.refresh();
    requiredReports.refresh();

    return paymentOk && reportOk;
  }

  void refreshStep2DocumentValidation() {
    if (bills.isEmpty) {
      step2DocumentsValid.value = true;
      return;
    }
    if (requiredPayments.isEmpty && requiredReports.isEmpty) {
      step2DocumentsValid.value = true;
      return;
    }
    step2DocumentsValid.value = _step2ValidationSync();
  }

  void removeBill(int index) {
    bills.removeAt(index);
    Future(() async {
      await syncRequiredDocumentsFromApi();
    });
  }

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
    FocusManager.instance.primaryFocus?.unfocus();
    final ctx = Get.context;
    if (ctx != null) {
      FocusScope.of(ctx).unfocus();
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      FilePickerHelper.showPickerBottomSheet(
        onFilePicked: (picked) async {
          await _uploadBillImageAfterPick(picked);
        },
      );
    });
  }

  /// patient_app `uploadFile` → `result['data']` merged into `billFills` (same shape as API).
  Future<void> _uploadBillImageAfterPick(PickedFileInfo picked) async {
    final localPath = picked.path;
    if (localPath.isEmpty) return;
    isBillImageUploading.value = true;
    try {
      final up = await _repository.uploadReimbursementFile(
        localPath,
        refType: 'BILL',
        documentType: '',
      );
      final logo = up['logo']?.toString() ?? '';
      final displayName = logo.contains('/')
          ? logo.split('/').last
          : picked.name.isNotEmpty
              ? picked.name
              : (up['title']?.toString() ?? 'file');
      billImageFiles.add({
        ...up,
        'name': displayName,
        'title': displayName,
        'isImage': picked.isImage,
      });
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
      isBillImageUploading.value = false;
    }
  }

  void removeBillImage(int index) => billImageFiles.removeAt(index);

  RxList<Map<String, dynamic>> _filesForClaimDocType(String refType) {
    switch (refType) {
      case 'PAYMENT':
        return paymentFiles;
      case 'REPORT':
        return reportFiles;
      case 'OTHER':
        return otherFiles;
      default:
        return otherFiles;
    }
  }

  void _putClaimDocEntry(
    String refType,
    Map<String, dynamic> entry, {
    int replaceIndex = -1,
  }) {
    final list = _filesForClaimDocType(refType);
    if (replaceIndex >= 0 && replaceIndex < list.length) {
      list[replaceIndex] = entry;
    } else {
      list.add(entry);
    }
  }

  void toggleDocServiceType(Map<String, dynamic> value) {
    final key = value['key']?.toString() ?? '';
    if (key.isEmpty) return;
    final idx = selectedDocServiceTypes.indexWhere(
      (e) => e['key']?.toString() == key,
    );
    if (idx >= 0) {
      selectedDocServiceTypes.removeAt(idx);
    } else {
      selectedDocServiceTypes.add({
        'type': key,
        ...Map<String, dynamic>.from(value),
      });
    }
  }

  /// patient_app `uploadFile` → `getUniqueSelectedServiceList` → `serviceTypesBottomsheet` (non-BILL).
  Future<void> _pickUploadThenServiceSheet(
    String refType,
    PickedFileInfo picked,
    String documentType,
  ) async {
    final localPath = picked.path;
    if (localPath.isEmpty) return;
    final options = getUniqueSelectedServiceTypesFromBills();
    if (options.isEmpty) {
      Get.snackbar(
        'Error',
        'Add bills and select service types before uploading documents.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    isClaimDocUploading.value = true;
    try {
      final up = await _repository.uploadReimbursementFile(
        localPath,
        refType: refType,
        documentType: documentType,
      );
      final docLogo = up['logo']?.toString() ?? '';
      final docDisplayName = docLogo.contains('/')
          ? docLogo.split('/').last
          : picked.name.isNotEmpty
              ? picked.name
              : (up['title']?.toString() ?? 'file');
      final base = <String, dynamic>{
        ...up,
        'name': docDisplayName,
        'document_type': documentType,
        'isImage': picked.isImage,
      };
      showClaimDocumentServiceTypesSheet(
        claimDocType: refType,
        uploadedBase: base,
        editIndex: -1,
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
      isClaimDocUploading.value = false;
    }
  }

  void showClaimDocumentServiceTypesSheet({
    required String claimDocType,
    required Map<String, dynamic> uploadedBase,
    int editIndex = -1,
  }) {
    if (editIndex < 0) {
      selectedDocServiceTypes.clear();
    }
    final options = getUniqueSelectedServiceTypesFromBills();
    if (options.isEmpty) {
      Get.snackbar(
        'Error',
        'No bill service types to attach. Add a bill with service types first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    final path = uploadedBase['path']?.toString() ?? '';
    final isHttp = path.startsWith('http://') || path.startsWith('https://');
    final isPdf =
        path.toLowerCase().endsWith('.pdf') ||
        (uploadedBase['name']?.toString() ?? '').toLowerCase().endsWith('.pdf');

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: Get.height * 0.58,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
        ),
        padding: EdgeInsets.fromLTRB(20.rs, 12.rh, 20.rs, 20.rh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CommonText(
                    AppString.kSelectServiceTypes,
                    fontSize: 18.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (editIndex >= 0) {
                      removeFile(claimDocType, editIndex);
                    }
                    selectedDocServiceTypes.clear();
                    Get.back();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 24.rs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Divider(height: 16.rh, thickness: 1, color: AppColors.borderLight),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.rs),
                  child: SizedBox(
                    width: 64.rs,
                    height: 64.rs,
                    child: isPdf
                        ? ColoredBox(
                            color: AppColors.backgroundTertiary,
                            child: Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 36.rs,
                              color: AppColors.error,
                            ),
                          )
                        : (isHttp
                              ? Image.network(
                                  path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.broken_image_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : (path.isNotEmpty && File(path).existsSync()
                                    ? Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.broken_image_outlined,
                                          color: AppColors.textSecondary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.insert_drive_file_outlined,
                                        color: AppColors.textSecondary,
                                      ))),
                  ),
                ),
                SizedBox(width: 10.rw),
                Expanded(
                  child: CommonText(
                    uploadedBase['name']?.toString() ?? 'Document',
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.rh),
            Expanded(
              child: Obx(() {
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 10.rw,
                    runSpacing: 10.rh,
                    children: options.map((value) {
                      final key = value['key']?.toString() ?? '';
                      final selected = selectedDocServiceTypes.any(
                        (e) => e['key']?.toString() == key,
                      );
                      return GestureDetector(
                        onTap: () => toggleDocServiceType(value),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.rw,
                            vertical: 8.rh,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.rs),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                            ),
                            color: selected
                                ? AppColors.primary
                                : AppColors.surface,
                          ),
                          child: CommonText(
                            value['value']?.toString() ?? key,
                            fontSize: 12.rf,
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
            Obx(() {
              if (selectedDocServiceTypes.isEmpty) {
                return SizedBox(height: 8.rh);
              }
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => selectedDocServiceTypes.clear(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.rh),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.rs),
                        ),
                        side: BorderSide(color: AppColors.borderLight),
                      ),
                      child: CommonText(
                        AppString.kClearAll,
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.rw),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedDocServiceTypes.isEmpty) {
                          Get.snackbar(
                            'Error',
                            AppString.kSelectAtLeastOneServiceType,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade800,
                          );
                          return;
                        }
                        final entry = Map<String, dynamic>.from(uploadedBase);
                        entry['service_types'] = selectedDocServiceTypes
                            .map(
                              (e) => Map<String, dynamic>.from(
                                json.decode(json.encode(e)),
                              ),
                            )
                            .toList();
                        _putClaimDocEntry(
                          claimDocType,
                          entry,
                          replaceIndex: editIndex,
                        );
                        selectedDocServiceTypes.clear();
                        refreshStep2DocumentValidation();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.rh),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.rs),
                        ),
                        elevation: 0,
                      ),
                      child: CommonText(
                        AppString.kApply,
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// patient_app `imagesWidget` edit callback → `serviceTypesBottomsheet` with existing row.
  void editClaimDocumentServiceTypes(String refType, int index) {
    final list = _filesForClaimDocType(refType);
    if (index < 0 || index >= list.length) return;
    final raw = Map<String, dynamic>.from(list[index]);
    selectedDocServiceTypes.clear();
    final st = raw['service_types'];
    if (st is List) {
      for (final e in st) {
        if (e is Map) {
          selectedDocServiceTypes.add(Map<String, dynamic>.from(e));
        }
      }
    }
    showClaimDocumentServiceTypesSheet(
      claimDocType: refType,
      uploadedBase: raw,
      editIndex: index,
    );
  }

  bool _claimFileIsPdf(Map<String, dynamic> file, String path) {
    final ft = file['file_type']?.toString().toUpperCase();
    if (ft == 'PDF') return true;
    final n = '${file['name'] ?? ''}${file['title'] ?? ''}'.toLowerCase();
    if (n.endsWith('.pdf')) return true;
    return path.toLowerCase().endsWith('.pdf');
  }

  bool _claimFileIsImageExtension(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
  }

  Future<void> openClaimAttachmentPreview(Map<String, dynamic> file) async {
    final path = file['path']?.toString() ?? '';
    if (path.isEmpty) return;
    final label =
        file['name']?.toString() ?? file['title']?.toString() ?? 'Preview';
    final isPdf = _claimFileIsPdf(file, path);

    if (path.startsWith('http://') || path.startsWith('https://')) {
      if (isPdf) {
        await Get.dialog(
          Dialog(
            insetPadding: EdgeInsets.zero,
            child: SizedBox(
              width: Get.width,
              height: Get.height * 0.92,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ),
                body: SfPdfViewer.network(path),
              ),
            ),
          ),
        );
        return;
      }
      await Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.rs),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.rs),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                path,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.broken_image_outlined, size: 48.rs),
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }

    final f = File(path);
    if (!f.existsSync()) return;

    if (isPdf) {
      await Get.dialog(
        Dialog(
          insetPadding: EdgeInsets.zero,
          child: SizedBox(
            width: Get.width,
            height: Get.height * 0.92,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ),
              body: SfPdfViewer.file(f),
            ),
          ),
        ),
      );
      return;
    }

    if (_claimFileIsImageExtension(path) || file['isImage'] == true) {
      await Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.rs),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.rs),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(f, fit: BoxFit.contain),
            ),
          ),
        ),
      );
    }
  }

  void pickFile(String type) {
    final docType = type == 'PAYMENT' ? 'PAYMENT' : '';
    FilePickerHelper.showPickerBottomSheet(
      onFilePicked: (file) {
        _pickUploadThenServiceSheet(type, file, docType);
      },
    );
  }

  /// Upload for a specific required category (prescription, payment proof, report type, etc.).
  void pickFileForCategory(String refType, String category) {
    FilePickerHelper.showPickerBottomSheet(
      onFilePicked: (file) {
        _pickUploadThenServiceSheet(refType, file, category);
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
    refreshStep2DocumentValidation();
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

    refreshStep2DocumentValidation();
    if ((requiredPayments.isNotEmpty || requiredReports.isNotEmpty) &&
        !step2DocumentsValid.value) {
      Get.snackbar(
        'Error',
        'Please upload all mandatory documents for your selected service types',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
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

    isSubmittingClaim.value = true;
    try {
      List<Map<String, dynamic>> serviceTypesForBill(ClaimBill bill) {
        if (bill.serviceTypes.isNotEmpty) {
          return bill.serviceTypes
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        return [Map<String, dynamic>.from(_defaultServiceType)];
      }

      final reimbursementBills = <Map<String, dynamic>>[];
      for (final bill in bills) {
        final billSvc = serviceTypesForBill(bill);
        final files = <Map<String, dynamic>>[];
        for (final f in bill.imageFiles) {
          final path = f['path']?.toString();
          if (path == null || path.isEmpty) continue;
          if (path.startsWith('http://') || path.startsWith('https://')) {
            files.add({
              if (f['id'] != null) 'id': f['id'],
              'path': path,
              'file_type': f['file_type']?.toString() ?? 'IMG',
              'document_type': f['document_type']?.toString() ?? '',
              'ref_type': 'BILL',
              'service_types': billSvc,
            });
            continue;
          }
          final up = await _repository.uploadReimbursementFile(
            path,
            refType: 'BILL',
            documentType: '',
          );
          files.add({...up, 'service_types': billSvc});
        }
        if (files.isEmpty) {
          throw AppException(message: 'Bill upload failed. Try again.');
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
          'service_types': billSvc,
        });
      }

      Future<List<Map<String, dynamic>>> uploadDocList(
        List<Map<String, dynamic>> src,
        String refType,
      ) async {
        final out = <Map<String, dynamic>>[];
        for (final f in src) {
          final path = f['path']?.toString();
          if (path == null || path.isEmpty) continue;

          final docType = f['document_type']?.toString() ?? '';
          final stRaw = f['service_types'];
          final List<Map<String, dynamic>> svcList;
          if (stRaw is List && stRaw.isNotEmpty) {
            svcList = stRaw
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          } else {
            svcList = [Map<String, dynamic>.from(_defaultServiceType)];
          }
          final title = f['name']?.toString() ?? 'Document';

          if (path.startsWith('http://') || path.startsWith('https://')) {
            out.add({
              if (f['id'] != null) 'id': f['id'],
              'path': path,
              'file_type': f['file_type']?.toString() ?? 'file',
              'service_types': svcList,
              if (docType.isNotEmpty) 'document_type': docType,
              'title': title,
            });
            continue;
          }

          final up = await _repository.uploadReimbursementFile(
            path,
            refType: refType,
            documentType: docType,
          );
          out.add({
            ...up,
            'service_types': svcList,
            if (docType.isNotEmpty) 'document_type': docType,
            'title': title,
          });
        }
        return out;
      }

      final paymentUploaded = await uploadDocList(
        paymentFiles.toList(),
        'PAYMENT',
      );
      final reportUploaded = await uploadDocList(
        reportFiles.toList(),
        'REPORT',
      );
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
    if (familyMembers.isNotEmpty) {
      FamilyMember pick = familyMembers.first;
      for (final m in familyMembers) {
        if ((m.relationship ?? '').toLowerCase() == 'self') {
          pick = m;
          break;
        }
      }
      selectMember(pick);
    }
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
    billIndex.value = -1;
    billServicePickerSelection.clear();
    selectedDocServiceTypes.clear();
    requiredPayments.clear();
    requiredReports.clear();
    step2DocumentsValid.value = true;
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
