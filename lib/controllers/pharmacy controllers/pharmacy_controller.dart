import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/member_repository.dart';
import 'package:flip_health/data/repositories/pharmacy_repository.dart';
import 'package:flip_health/data/repositories/upload_repository.dart';
import 'package:flip_health/model/common%20models/upload_response_model.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/model/pharmacy%20models/flip_health_prescription_model.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_model.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';

class UploadedFile {
  final PickedFileInfo fileInfo;
  final Rx<UploadState> state;
  final Rxn<UploadResponse> uploadResponse;

  UploadedFile({required this.fileInfo})
      : state = UploadState.uploading.obs,
        uploadResponse = Rxn<UploadResponse>();
}

enum UploadState { uploading, success, failed }

class PharmacyController extends GetxController {
  final PharmacyRepository _repository;
  final MemberRepository _memberRepository;
  final UploadRepository _uploadRepository;

  PharmacyController({
    required PharmacyRepository repository,
    required MemberRepository memberRepository,
    required UploadRepository uploadRepository,
  })  : _repository = repository,
        _memberRepository = memberRepository,
        _uploadRepository = uploadRepository;

  // --- Members ---
  final members = <FamilyMember>[].obs;
  final membersLoading = true.obs;
  final selectedMemberId = ''.obs;

  // --- Prescription source ---
  final prescriptionSource = ''.obs;

  // --- Upload Prescription flow ---
  final uploadedFiles = <UploadedFile>[].obs;

  // --- Flip Health Prescription flow ---
  final prescriptions = <FlipHealthPrescription>[].obs;
  final prescriptionsLoading = false.obs;
  final selectedPrescriptionIds = <String>{}.obs;
  final prescriptionDetail = Rxn<FlipHealthPrescription>();
  final detailLoading = false.obs;

  // --- Order state ---
  final isOrdering = false.obs;

  // --- FAQs ---
  final faqItems = <FAQItem>[].obs;

  // --- Computed ---
  FamilyMember? get selectedMember {
    if (selectedMemberId.value.isEmpty) return null;
    try {
      return members.firstWhere((m) => m.id == selectedMemberId.value);
    } catch (_) {
      return null;
    }
  }

  int get patientIdInt => int.tryParse(selectedMember?.id ?? '') ?? 0;

  String get addressId {
    try {
      return Get.find<AddressController>().selectedAddress.value?.id ?? '';
    } catch (_) {
      return '';
    }
  }

  bool get canPlaceUploadOrder =>
      uploadedFiles.isNotEmpty &&
      uploadedFiles.every((f) => f.state.value == UploadState.success);

  bool get canPlaceFlipHealthOrder => selectedPrescriptionIds.isNotEmpty;

  // --- Selected files for backward compat with prescription screen ---
  List<Map<String, dynamic>> get selectedFiles =>
      uploadedFiles.map((f) => f.fileInfo.toMap()).toList();

  @override
  void onInit() {
    super.onInit();
    _loadMembers();
    _loadFAQs();
  }

  // ===================== Members =====================

  Future<void> _loadMembers() async {
    membersLoading.value = true;
    try {
      final list = await _memberRepository.getMembers();
      members.assignAll(list);
      if (list.isNotEmpty) {
        FamilyMember pick = list.first;
        for (final m in list) {
          if ((m.relationship ?? '').toLowerCase() == 'self') {
            pick = m;
            break;
          }
        }
        selectedMemberId.value = pick.id;
      }
    } catch (_) {
      members.clear();
    } finally {
      membersLoading.value = false;
    }
  }

  void selectMember(FamilyMember m) {
    selectedMemberId.value = m.id;
  }

  // ===================== FAQs =====================

  void _loadFAQs() {
    faqItems.value = _repository.getFAQs();
  }

  // ===================== Upload Prescription =====================

  void pickFile() {
    FilePickerHelper.showPickerBottomSheet(
      onFilePicked: (file) => _uploadFile(file),
    );
  }

  Future<void> pickFromGallery() async {
    final file = await FilePickerHelper.pickFromGallery();
    if (file != null) _uploadFile(file);
  }

  Future<void> pickFromCamera() async {
    final file = await FilePickerHelper.pickFromCamera();
    if (file != null) _uploadFile(file);
  }

  Future<void> _uploadFile(PickedFileInfo file) async {
    final entry = UploadedFile(fileInfo: file);
    uploadedFiles.add(entry);

    try {
      final response = await _uploadRepository.uploadFile(
        filePath: file.path,
        type: 'prescription',
      );
      entry.uploadResponse.value = response;
      entry.state.value = UploadState.success;
      PrintLog.printLog('Prescription uploaded: ${response.id}');
    } catch (e) {
      entry.state.value = UploadState.failed;
      PrintLog.printLog('Prescription upload failed: $e');
      AppToast.error(title: 'Upload Failed', message: e.toString());
    }
  }

  void retryUpload(int index) {
    if (index < 0 || index >= uploadedFiles.length) return;
    final entry = uploadedFiles[index];
    if (entry.state.value != UploadState.failed) return;
    entry.state.value = UploadState.uploading;
    _retryUploadFile(entry);
  }

  Future<void> _retryUploadFile(UploadedFile entry) async {
    try {
      final response = await _uploadRepository.uploadFile(
        filePath: entry.fileInfo.path,
        type: 'prescription',
      );
      entry.uploadResponse.value = response;
      entry.state.value = UploadState.success;
    } catch (e) {
      entry.state.value = UploadState.failed;
      AppToast.error(title: 'Upload Failed', message: e.toString());
    }
  }

  void removeUploadedFile(int index) {
    if (index >= 0 && index < uploadedFiles.length) {
      uploadedFiles.removeAt(index);
    }
  }

  Future<void> placeUploadOrder() async {
    if (!canPlaceUploadOrder) return;
    if (addressId.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please select an address');
      return;
    }

    final prescriptionsList = uploadedFiles
        .where((f) => f.uploadResponse.value != null)
        .map((f) => {
              'type': 'OTHER',
              'prescription_id': f.uploadResponse.value!.id,
            })
        .toList();

    await _placeOrder(prescriptionsList);
  }

  // ===================== Flip Health Prescription =====================

  Future<void> fetchPrescriptions() async {
    prescriptionsLoading.value = true;
    try {
      final result = await _repository.getFlipHealthPrescriptions();
      prescriptions.assignAll(result);
    } catch (e) {
      PrintLog.printLog('fetchPrescriptions error: $e');
      AppToast.error(
          title: 'Error', message: 'Failed to load prescriptions');
    } finally {
      prescriptionsLoading.value = false;
    }
  }

  Future<void> fetchPrescriptionDetail(String id) async {
    detailLoading.value = true;
    prescriptionDetail.value = null;
    try {
      final result = await _repository.getPrescriptionById(id);
      prescriptionDetail.value = result;
    } catch (e) {
      PrintLog.printLog('fetchPrescriptionDetail error: $e');
      AppToast.error(
          title: 'Error', message: 'Failed to load prescription details');
    } finally {
      detailLoading.value = false;
    }
  }

  void togglePrescription(String appointmentId) {
    if (selectedPrescriptionIds.contains(appointmentId)) {
      selectedPrescriptionIds.assignAll({});
    } else {
      selectedPrescriptionIds.assignAll({appointmentId});
    }
  }

  bool isPrescriptionSelected(String appointmentId) {
    return selectedPrescriptionIds.contains(appointmentId);
  }

  Future<void> placeFlipHealthOrder() async {
    if (!canPlaceFlipHealthOrder) return;
    if (addressId.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please select an address');
      return;
    }

    final prescriptionsList = selectedPrescriptionIds
        .map((id) => {
              'type': 'FLIPHEALTH',
              'prescription_id': id,
            })
        .toList();

    await _placeOrder(prescriptionsList);
  }

  /// Place order from the detail screen using a specific appointment ID
  Future<void> placeOrderFromDetail(String appointmentId) async {
    if (addressId.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please select an address');
      return;
    }

    final prescriptionsList = [
      {'type': 'FLIPHEALTH', 'prescription_id': appointmentId},
    ];

    await _placeOrder(prescriptionsList);
  }

  // ===================== OTC =====================

  Future<void> placeOTCOrder() async {
    if (addressId.isEmpty) {
      AppToast.error(title: 'Error', message: 'Please select an address');
      return;
    }
    await _placeOrder([]);
  }

  // ===================== Common Order =====================

  Future<void> _placeOrder(List<Map<String, dynamic>> prescriptionsList) async {
    isOrdering.value = true;
    try {
      final response = await _repository.placeOrder(
        addressId: addressId,
        patientId: patientIdInt,
        prescriptions: prescriptionsList,
      );

      isOrdering.value = false;

      Get.off(
        () => PaymentSuccessScreen(
          title: 'Order Generated\nSuccessfully',
          subtitle: response.message,
          buttonText: 'Done',
        ),
      );
    } catch (e) {
      isOrdering.value = false;
      PrintLog.printLog('placeOrder error: $e');
      AppToast.error(title: 'Order Failed', message: e.toString());
    }
  }

  // ===================== Reset =====================

  void resetUploadState() {
    uploadedFiles.clear();
  }

  void resetFlipHealthState() {
    selectedPrescriptionIds.clear();
    prescriptionDetail.value = null;
  }
}
