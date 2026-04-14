import 'package:flutter/material.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/pharmacy_repository.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_order_invoice_model.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:get/get.dart';

/// Pharmacy / chronic medicine order detail — aligned with patient_app
/// [PharmacyOrderDetailsController].
class PharmacyOrderDetailController extends GetxController {
  PharmacyOrderDetailController({required PharmacyRepository repository})
      : _repository = repository;

  final PharmacyRepository _repository;

  final invoice = Rxn<PharmacyOrderInvoice>();
  final detailsFetched = false.obs;
  final isLoading = false.obs;

  final attachments = <dynamic>[].obs;

  final stepperIndex = 1.obs;
  final batchNo = 3.obs;

  final cancellationController = TextEditingController();
  final useFlipCash = true.obs;

  /// Latest payment quote from `PATCH ... payment?useWallet=` (confirm: false).
  final paymentQuote = Rxn<Map<String, dynamic>>();

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

  @override
  void onClose() {
    cancellationController.dispose();
    super.onClose();
  }

  Map<String, dynamic>? get _info => invoice.value?.info;

  int get infoStatus {
    final s = _info?['status'];
    if (s is int) return s;
    if (s is String) return int.tryParse(s) ?? -1;
    return -1;
  }

  String get transactionType => invoice.value?.transactionType ?? '';

  bool get isChronicMed => transactionType == 'CHRONIC_MED';

  /// Lines to render in the invoice table (handles chronic batch filtering like patient_app).
  List<dynamic> get invoiceLinesForTable {
    final inv = invoice.value;
    if (inv == null) return [];
    final details = inv.details;
    if (!isChronicMed) return List<dynamic>.from(details);

    final batches = inv.additionalInfo?['batches'];
    if (batches is List && batches.isNotEmpty) {
      final first = batches.first;
      if (first is Map && first['status']?.toString() == 'PENDING') {
        return details
            .where(
              (line) =>
                  line is Map &&
                  (line['batch'] == 0 || line['batch'] == null),
            )
            .toList();
      }
    }
    if (stepperIndex.value < batchNo.value) {
      final step = stepperIndex.value;
      return details
          .where((line) => line is Map && line['batch'] == step)
          .toList();
    }
    return [];
  }

  /// Show invoice block — patient_app hides chronic table when stepper >= batch (except pending-first-batch case).
  bool get showInvoiceSection {
    if (infoStatus == 0) return false;
    final inv = invoice.value;
    if (inv == null) return false;
    if (!isChronicMed) return inv.details.isNotEmpty;

    final batches = inv.additionalInfo?['batches'];
    if (batches is List && batches.isNotEmpty) {
      final first = batches.first;
      if (first is Map && first['status']?.toString() == 'PENDING') {
        return invoiceLinesForTable.isNotEmpty;
      }
    }
    if (stepperIndex.value >= batchNo.value) return false;
    return inv.details.isNotEmpty;
  }

  bool get showChronicStepper {
    if (!isChronicMed) return false;
    final b = invoice.value?.additionalInfo?['batches'];
    return b is List && b.isNotEmpty;
  }

  bool get showPaymentsSection => invoice.value!.payments.isNotEmpty;

  bool get showAttachmentsSection {
    if (attachments.isNotEmpty) return true;
    return ![0, 3, 4].contains(infoStatus);
  }

  /// Bottom "Complete payment" — status 4, payment_required, non-chronic, matches patient.
  bool get showCompletePaymentBar {
    if (infoStatus != 4) return false;
    if (isChronicMed) return false;
    final add = _info?['additional_info'];
    final payReq = add is Map && add['payment_required'] == true;
    return payReq;
  }

  bool get canCancelOrder => [0, 3, 4].contains(infoStatus);

  Future<void> fetchDetail() async {
    isLoading.value = true;
    detailsFetched.value = false;
    try {
      final inv = await _repository.getInvoiceDetail(invoiceId);
      invoice.value = inv;
      _syncStepper(inv);
      _syncAttachments(inv);
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

  void _syncStepper(PharmacyOrderInvoice inv) {
    final next = inv.additionalInfo?['next_batch'];
    if (next != null) {
      final n = next is int ? next : int.tryParse(next.toString()) ?? 3;
      if (n >= 3) {
        stepperIndex.value = 3;
        batchNo.value = 3;
      } else {
        stepperIndex.value = n;
        batchNo.value = n;
      }
    } else {
      stepperIndex.value = 3;
      batchNo.value = 3;
    }
  }

  void _syncAttachments(PharmacyOrderInvoice inv) {
    final info = inv.info;
    if (info == null) return;
    final raw = info['attachments'];
    if (raw is! List) {
      attachments.clear();
      return;
    }
    attachments.assignAll(
      raw.where((e) => e is Map && e['status'] == 1).toList(),
    );
  }

  String screenTitle() {
    if (transactionType == 'CHRONIC_MED') return 'Chronic medicine details';
    return 'Pharmacy details';
  }

  Future<void> cancelOrder() async {
    final id = _info?['id'];
    if (id == null) return;
    try {
      await _repository.cancelMedicineOrder(id.toString(), {
        'cancellation_reason': cancellationController.text.trim(),
      });
      ToastCustom.showSnackBar(subtitle: 'Order cancelled');
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  Future<void> confirmOrder() async {
    final id = _info?['id'];
    if (id == null) return;
    try {
      await _repository.confirmMedicineOrder(id.toString(), {'status': 4});
      ToastCustom.showSnackBar(subtitle: 'Order confirmed');
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  /// Fetches pharmacy payment breakdown (`confirm: false`) for the bottom sheet UI.
  Future<void> refreshPaymentQuote() async {
    final id = _info?['id'];
    if (id == null) return;
    try {
      final quote = await _repository.patchMedicineOrderPayment(
        invoiceId: id.toString(),
        confirm: false,
        useWallet: useFlipCash.value,
      );
      paymentQuote.value = quote;
    } on AppException catch (e) {
      paymentQuote.value = null;
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      paymentQuote.value = null;
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  /// After user confirms in bottom sheet (`confirm: true`).
  Future<void> confirmBookingPayment() async {
    final id = _info?['id'];
    if (id == null) return;
    try {
      final done = await _repository.patchMedicineOrderPayment(
        invoiceId: id.toString(),
        confirm: true,
        useWallet: useFlipCash.value,
      );
      final needPay =
          done['isPaymentRequired'] == true || done['paymentRequired'] == true;
      if (needPay && done['razorpay_payload'] is Map) {
        Get.toNamed(
          AppRoutes.razorPay,
          arguments: [
            'fromPharmacy',
            Map<String, dynamic>.from(done['razorpay_payload'] as Map),
          ],
        );
        return;
      }
      ToastCustom.showSnackBar(subtitle: 'Payment completed');
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  /// Backward compatible wrapper if invoked from elsewhere.
  Future<void> runCompletePaymentFlow() async => confirmBookingPayment();
}
