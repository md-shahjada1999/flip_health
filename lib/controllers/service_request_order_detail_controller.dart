import 'package:flutter/material.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/service_request_repository.dart';
import 'package:flip_health/model/service_request_invoice_model.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:get/get.dart';

class ServiceRequestOrderDetailController extends GetxController {
  ServiceRequestOrderDetailController({
    required ServiceRequestRepository repository,
  }) : _repository = repository;

  final ServiceRequestRepository _repository;

  final invoice = Rxn<ServiceRequestInvoice>();
  final detailsFetched = false.obs;
  final isLoading = false.obs;

  final attachments = <dynamic>[].obs;
  final reports = <dynamic>[].obs;

  final cancellationController = TextEditingController();
  final useFlipCash = true.obs;
  final paymentQuote = Rxn<Map<String, dynamic>>();

  late final String invoiceId;
  late final String serviceType;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['invoiceId'] != null) {
      invoiceId = args['invoiceId'].toString();
      serviceType = (args['service']?.toString() ?? '').toLowerCase();
    } else {
      invoiceId = '';
      serviceType = '';
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

  Map<String, dynamic>? get info => invoice.value?.info;

  int get infoStatus {
    final raw = info?['status'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? -1;
  }

  String get source => info?['source']?.toString() ?? '';

  bool get isDental => _resolvedServiceType == 'dental';
  bool get isVision => _resolvedServiceType == 'vision';
  bool get isVaccine => _resolvedServiceType == 'vaccine';

  String get _resolvedServiceType {
    if (serviceType.isNotEmpty) return serviceType;
    final tx = invoice.value?.transactionType?.toLowerCase() ?? '';
    if (tx == 'dental' || tx == 'vision' || tx == 'vaccine') return tx;
    return '';
  }

  String get screenTitle {
    if (isDental) return 'Dental request';
    if (isVision) return 'Vision request';
    if (isVaccine) return 'Vaccine request';
    return 'Service request';
  }

  bool get showInvoiceSection =>
      infoStatus != 0 && (invoice.value?.details.isNotEmpty ?? false);

  bool get showPaymentsSection => invoice.value?.payments.isNotEmpty ?? false;

  bool get canConfirmCenter => infoStatus == 3;

  bool get canCancelRequest {
    // Keep behavior aligned with patient_app practical flow where pending states
    // allow cancellation.
    return [0, 3, 4].contains(infoStatus);
  }

  bool get showCompletePaymentBar {
    if (infoStatus != 4) return false;
    final add = info?['additional_info'];
    if (add is Map) {
      return add['payment_required'] == true;
    }
    return false;
  }

  bool get showSelfVisitCenterCard {
    if (infoStatus == 0) return false;
    final details = info?['details'];
    if (details is! Map) return false;
    if (details['center'] == null) return false;
    final visitType = info?['visit_type']?.toString() ?? '';
    return visitType == 'SELF_VISIT';
  }

  bool get showRiderCard {
    if ([0, 1, 2, 3, 4].contains(infoStatus)) return false;
    final visitType = info?['visit_type']?.toString() ?? '';
    if (visitType != 'HOME_SERVICE') return false;
    final details = info?['details'];
    if (details is! Map) return false;
    final rider = details['visitor_info'];
    if (rider is! Map) return false;
    final name = rider['name']?.toString() ?? '';
    final contact = rider['contact']?.toString() ?? '';
    return name.isNotEmpty && contact.isNotEmpty;
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    detailsFetched.value = false;
    try {
      final inv = await _repository.getInvoiceDetail(invoiceId);
      invoice.value = inv;
      _syncAttachmentsAndReports();
      detailsFetched.value = true;
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _syncAttachmentsAndReports() {
    final infoMap = info;
    if (infoMap == null) return;
    final att = infoMap['attachments'];
    if (att is List) {
      attachments.assignAll(att.where((e) => e is Map && e['status'] == 1));
    } else {
      attachments.clear();
    }
    final rep = infoMap['reports'];
    if (rep is List) {
      reports.assignAll(rep.where((e) => e is Map && e['status'] == 1));
    } else {
      reports.clear();
    }
  }

  Future<void> confirmCenterDetails() async {
    final id = info?['id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      await _repository.confirmServiceRequest(id);
      ToastCustom.showSnackBar(subtitle: 'Details confirmed');
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  Future<void> cancelRequest() async {
    final id = info?['id']?.toString();
    if (id == null || id.isEmpty) return;
    final reason = cancellationController.text.trim();
    if (reason.isEmpty) {
      ToastCustom.showSnackBar(subtitle: 'Please enter a cancellation reason');
      return;
    }
    try {
      await _repository.cancelServiceRequest(id, <String, dynamic>{
        'cancellation_reason': reason,
      });
      ToastCustom.showSnackBar(subtitle: 'Request cancelled');
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  Future<void> refreshPaymentQuote() async {
    final id = info?['id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      paymentQuote.value = await _repository.patchServiceRequestPayment(
        requestId: id,
        confirm: false,
        useWallet: useFlipCash.value,
      );
    } on AppException catch (e) {
      paymentQuote.value = null;
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      paymentQuote.value = null;
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  Future<void> confirmServiceRequestPayment() async {
    final id = info?['id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      final res = await _repository.patchServiceRequestPayment(
        requestId: id,
        confirm: true,
        useWallet: useFlipCash.value,
      );
      if (res['paymentRequired'] == true && res['razorpay_payload'] is Map) {
        Get.toNamed(
          AppRoutes.razorPay,
          arguments: <dynamic>[
            'fromServiceRequest',
            Map<String, dynamic>.from(res['razorpay_payload'] as Map),
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
}
