import 'package:flutter/material.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/wellness_order_repository.dart';
import 'package:flip_health/model/wellness%20models/wellness_order_invoice_model.dart';
import 'package:get/get.dart';

class WellnessOrderDetailController extends GetxController {
  WellnessOrderDetailController({required WellnessOrderRepository repository})
      : _repository = repository;

  final WellnessOrderRepository _repository;

  final invoice = Rxn<WellnessOrderInvoice>();
  final detailsFetched = false.obs;
  final isLoading = false.obs;

  final cancellationController = TextEditingController();

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

  Map<String, dynamic>? get info => invoice.value?.info;

  Map<String, dynamic>? get serviceDetails => invoice.value?.detailsMap;

  String get transactionType =>
      invoice.value?.transactionType?.toUpperCase() ?? '';

  bool get isMentalWellness => transactionType == 'MENTALWELLNESS';

  String get serviceTitle {
    final s = serviceDetails?['service']?.toString();
    if (s != null && s.trim().isNotEmpty) return s.trim();
    if (transactionType == 'NUTRITION') return 'Diet & Nutrition';
    if (transactionType == 'YOGA') return 'Yoga';
    return 'Mental Wellness';
  }

  int get infoStatus {
    final s = info?['status'];
    if (s is int) return s;
    if (s is String) return int.tryParse(s) ?? -1;
    return -1;
  }

  List<dynamic> get lineItems => invoice.value?.details ?? const [];

  List<dynamic> get paymentItems => invoice.value?.payments ?? const [];

  bool get showInvoiceSection => infoStatus != 0 && lineItems.isNotEmpty;

  bool get showPaymentsSection => paymentItems.isNotEmpty;

  String get statusLabel {
    const map = <int, String>{
      0: 'Waiting for confirmation',
      1: 'Completed',
      2: 'Cancelled',
      3: 'Confirm changes',
      4: 'Payment pending',
      9: 'Expired',
    };
    if (infoStatus == 5) {
      return isMentalWellness ? 'Upcoming session' : 'Booking confirmed';
    }
    return map[infoStatus] ?? 'Waiting for confirmation';
  }

  bool get canCancel {
    if (infoStatus != 5) return false;
    final booking = _booking;
    if (booking == null) return false;
    final selectedDate = booking['selected_date']?.toString();
    final slotMap = booking['slot'];
    final startTime =
        slotMap is Map ? slotMap['start_time']?.toString() : null;
    if (selectedDate == null ||
        selectedDate.isEmpty ||
        startTime == null ||
        startTime.isEmpty) {
      return false;
    }
    DateTime? start;
    try {
      start = DateTime.parse('$selectedDate $startTime');
    } catch (_) {
      try {
        start = DateTime.parse('${selectedDate}T$startTime');
      } catch (_) {
        return false;
      }
    }
    return start.difference(DateTime.now()).inMinutes > 60;
  }

  Map<String, dynamic>? get _booking {
    final bookingDetails = serviceDetails?['booking_details'];
    if (bookingDetails is! Map) return null;
    final booking = bookingDetails['booking'];
    if (booking is! Map) return null;
    return Map<String, dynamic>.from(booking);
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    detailsFetched.value = false;
    try {
      final inv = await _repository.getInvoiceDetail(invoiceId);
      invoice.value = inv;
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

  Future<void> cancelOrder() async {
    final reason = cancellationController.text.trim();
    if (reason.isEmpty) {
      ToastCustom.showSnackBar(subtitle: 'Please enter cancellation reason');
      return;
    }
    final id = info?['id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      await _repository.cancelWellnessOrder(<String, dynamic>{
        'service_id': id,
        'cancellation_reason': reason,
      });
      ToastCustom.showSnackBar(
        subtitle: 'Session cancelled successfully',
        isSuccess: true,
      );
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }
}
