import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/lab_order_detail_repository.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_order_invoice_model.dart';
import 'package:get/get.dart';

/// Lab / diagnostics invoice detail — `GET /patient/invoice/{id}` with
/// `transaction_type: LABTEST`. Uses the same payload shape as pharmacy
/// ([PharmacyOrderInvoice]) with per-line `user` for multi-patient bookings.
class LabOrderDetailController extends GetxController {
  LabOrderDetailController({required LabOrderDetailRepository repository})
      : _repository = repository;

  final LabOrderDetailRepository _repository;

  final invoice = Rxn<PharmacyOrderInvoice>();
  final detailsFetched = false.obs;
  final isLoading = false.obs;

  final attachments = <dynamic>[].obs;
  final reports = <dynamic>[].obs;
  /// From `info.additional_info.prescriptions` (uploaded prescription images).
  final prescriptions = <dynamic>[].obs;

  final RxBool isConfirmingCenter = false.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxBool isCancellingOrder = false.obs;
  final RxBool useWalletForPayment = true.obs;
  final Rxn<Map<String, dynamic>> paymentQuote = Rxn<Map<String, dynamic>>();

  late final String invoiceId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['invoiceId'] != null) {
      invoiceId = args['invoiceId'].toString();
    } else {
      invoiceId = '';
    }
    if (invoiceId.isNotEmpty) {
      fetchDetail();
    }
  }

  Map<String, dynamic>? get _info => invoice.value?.info;

  int get infoStatus {
    final s = _info?['status'];
    if (s is int) return s;
    if (s is String) return int.tryParse(s) ?? -1;
    return -1;
  }

  Map<String, dynamic> get infoMap => _info ?? <String, dynamic>{};

  String get infoId => infoMap['id']?.toString() ?? '';

  List<Map<String, dynamic>> get subOrders {
    final raw = invoice.value?.raw['orders'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  bool get canCancelRequest {
    final orders = subOrders;
    if (orders.isEmpty) return false;
    return orders.every((o) {
      final s = o['status'];
      final status = s is int ? s : int.tryParse(s?.toString() ?? '') ?? -1;
      return [0, 3, 4].contains(status);
    });
  }

  bool get showCompletePaymentBar {
    final orders = subOrders;
    if (orders.isEmpty) return false;
    final allPending = orders.every((o) {
      final s = o['status'];
      final status = s is int ? s : int.tryParse(s?.toString() ?? '') ?? -1;
      return status == 4;
    });
    if (!allPending) return false;
    final add = infoMap['additional_info'];
    final paymentRequired = add is Map && add['payment_required'] == true;
    final net = invoice.value?.netAmount ?? 0;
    return paymentRequired && net > 0;
  }

  /// Invoice `details` lines grouped by `user.id` (multi-patient lab orders).
  List<LabPatientLineGroup> get patientLineGroups {
    final inv = invoice.value;
    if (inv == null) return [];
    final details = inv.details;
    final byUser = <int, List<Map<String, dynamic>>>{};
    for (final line in details) {
      if (line is! Map) continue;
      final m = Map<String, dynamic>.from(line);
      final u = m['user'];
      var uid = 0;
      if (u is Map) {
        final id = u['id'];
        if (id is int) {
          uid = id;
        } else {
          uid = int.tryParse(id?.toString() ?? '') ?? 0;
        }
      }
      byUser.putIfAbsent(uid, () => []).add(m);
    }
    final keys = byUser.keys.toList()..sort();
    return [
      for (final k in keys)
        LabPatientLineGroup(userId: k, lines: byUser[k] ?? []),
    ];
  }

  /// Align with patient_app lab detail: hide pricing table while status is "waiting" (0).
  bool get showInvoiceSection {
    final inv = invoice.value;
    if (inv == null) return false;
    if (infoStatus == 0) return false;
    return inv.details.isNotEmpty;
  }

  bool get showPaymentsSection => invoice.value?.payments.isNotEmpty ?? false;

  Future<void> fetchDetail() async {
    isLoading.value = true;
    detailsFetched.value = false;
    try {
      final inv = await _repository.getInvoiceDetail(invoiceId);
      invoice.value = inv;
      _syncAttachmentsAndReports(inv);
      detailsFetched.value = true;
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
      detailsFetched.value = false;
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
      detailsFetched.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _syncAttachmentsAndReports(PharmacyOrderInvoice inv) {
    final info = inv.info;
    if (info == null) return;

    final att = info['attachments'];
    if (att is List) {
      attachments.assignAll(
        att.where((e) => e is Map && e['status'] == 1).toList(),
      );
    } else {
      attachments.clear();
    }

    final rep = info['reports'];
    if (rep is List) {
      reports.assignAll(
        rep.where((e) => e is Map && e['status'] == 1).toList(),
      );
    } else {
      reports.clear();
    }

    final add = info['additional_info'];
    if (add is Map) {
      final pres = add['prescriptions'];
      if (pres is List) {
        prescriptions.assignAll(
          pres.where((e) {
            if (e is! Map) return false;
            final m = Map<String, dynamic>.from(e);
            return m['path'] != null || m['url'] != null;
          }).toList(),
        );
      } else {
        prescriptions.clear();
      }
    } else {
      prescriptions.clear();
    }
  }

  /// Patient_app `acceptOfflineLabSelfOrder` — confirm rescheduled center/slot (sub-order id).
  Future<void> confirmLabSubOrderCenter(String subOrderId) async {
    if (subOrderId.isEmpty) return;
    isConfirmingCenter.value = true;
    try {
      await _repository.confirmLabSubOrder(subOrderId);
      ToastCustom.showSnackBar(subtitle: 'Center details confirmed');
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      isConfirmingCenter.value = false;
    }
  }

  Future<void> loadPaymentQuote() async {
    if (infoId.isEmpty) return;
    isProcessingPayment.value = true;
    try {
      final res = await _repository.patchLabOrderPayment(
        invoiceInfoId: infoId,
        confirm: false,
        useWallet: useWalletForPayment.value,
      );
      paymentQuote.value = res;
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<bool> confirmPaymentFromDetail() async {
    if (infoId.isEmpty) return false;
    isProcessingPayment.value = true;
    try {
      final res = await _repository.patchLabOrderPayment(
        invoiceInfoId: infoId,
        confirm: true,
        useWallet: useWalletForPayment.value,
      );
      paymentQuote.value = res;
      return true;
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
      return false;
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> cancelLabOrder(String reason) async {
    if (infoId.isEmpty) return;
    if (reason.trim().isEmpty) {
      ToastCustom.showSnackBar(subtitle: 'Please enter cancellation reason');
      return;
    }
    isCancellingOrder.value = true;
    try {
      await _repository.cancelLabOrder(infoId, {
        'cancellation_reason': reason.trim(),
      });
      ToastCustom.showSnackBar(subtitle: 'Order cancelled successfully');
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      isCancellingOrder.value = false;
    }
  }

  Future<LabSlotsResponse?> getRescheduleSlots({
    required String addressId,
    required String vendorCode,
    required String category,
    required DateTime date,
  }) async {
    try {
      return await _repository.getLabSlotsForReschedule(
        addressId: addressId,
        date:
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        vendorCode: vendorCode,
        category: category,
      );
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
      return null;
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
      return null;
    }
  }

  Future<void> rescheduleLabSubOrder({
    required String subOrderId,
    required String reason,
    required LabSlot slot,
    required String addressId,
  }) async {
    if (reason.trim().isEmpty) {
      ToastCustom.showSnackBar(subtitle: 'Please add reschedule reason');
      return;
    }
    isLoading.value = true;
    try {
      await _repository.rescheduleLabSubOrder(
        subOrderId: subOrderId,
        body: {
          'reschedule_reason': reason.trim(),
          'collection_date': slot.slotDate,
          'start_time': slot.startTime,
          'end_time': slot.endTime,
          'slot_id': slot.slotId,
          'address_id': addressId,
        },
      );
      ToastCustom.showSnackBar(subtitle: 'Reschedule request submitted');
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

class LabPatientLineGroup {
  const LabPatientLineGroup({
    required this.userId,
    required this.lines,
  });

  final int userId;
  final List<Map<String, dynamic>> lines;

  Map<String, dynamic>? get userMap {
    for (final line in lines) {
      final u = line['user'];
      if (u is Map) return Map<String, dynamic>.from(u);
    }
    return null;
  }

  String get displayName => userMap?['name']?.toString().trim() ?? 'Patient';

  String get subtitle {
    final u = userMap;
    if (u == null) return '';
    final parts = <String>[
      if (u['age'] != null) '${u['age']}',
      if (u['gender'] != null)
        u['gender'].toString().trim(),
    ];
    return parts.where((e) => e.isNotEmpty).join(' · ');
  }
}
