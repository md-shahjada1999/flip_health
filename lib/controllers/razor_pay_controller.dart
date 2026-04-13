import 'dart:convert';

import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/consultation_order_repository.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Razorpay flow aligned with patient_app `RazorPayController` (consultation verify).
class RazorPayController extends GetxController {
  late Razorpay _razorpay;
  String from = '';
  Map<String, dynamic> body = {};
  Map<String, dynamic> _consultationSuccessSummary = {};

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    if (a is List && a.length >= 2 && a[1] is Map) {
      from = a[0].toString();
      body = _normalizeRazorpayOptions(a[1]);
      if (a.length >= 3 && a[2] is Map) {
        _consultationSuccessSummary = Map<String, dynamic>.from(a[2] as Map);
      }
    }

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    if (body.isNotEmpty) {
      try {
        _razorpay.open(body);
      } catch (e) {
        ToastCustom.showSnackBar(subtitle: e.toString());
      }
    }
  }

  Future<void> _onSuccess(PaymentSuccessResponse response) async {
    if (from == 'fromConsultationOrder') {
      final map = <String, dynamic>{
        'order_id': response.orderId,
        'payment_id': response.paymentId,
        'signature': response.signature,
      };
      try {
        if (!Get.isRegistered<ConsultationOrderRepository>()) {
          if (!Get.isRegistered<ApiService>()) {
            Get.lazyPut<ApiService>(() => ApiService());
          }
          Get.lazyPut<ConsultationOrderRepository>(
            () => ConsultationOrderRepository(apiService: Get.find()),
          );
        }
        final repo = Get.find<ConsultationOrderRepository>();
        final res = await repo.verifyAppointmentPayment(map);
        if (res['status'] == true) {
          Get.offAllNamed(
            AppRoutes.consultationPaymentSuccess,
            arguments: _consultationSuccessSummary,
          );
        } else {
          ToastCustom.showSnackBar(
            subtitle: res['message']?.toString() ?? 'Verification failed',
          );
        }
      } catch (e) {
        ToastCustom.showSnackBar(subtitle: e.toString());
      }
    }
  }

  void _onError(PaymentFailureResponse response) {
    try {
      if (response.code != 0 && response.message != null) {
        final decoded = json.decode(response.message.toString());
        final err = decoded is Map ? decoded['error'] : null;
        final desc = err is Map ? err['description'] : null;
        ToastCustom.showSnackBar(
          subtitle: desc?.toString() ?? 'Payment failed',
        );
      } else {
        ToastCustom.showSnackBar(subtitle: response.message?.toString() ?? '');
      }
    } catch (_) {
      ToastCustom.showSnackBar(subtitle: 'Payment cancelled');
    }
    Get.back();
  }

  void _onExternalWallet(ExternalWalletResponse response) {}

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}

/// Ensures nested maps and numeric types match what the Razorpay SDK / platform channel expect.
Map<String, dynamic> _normalizeRazorpayOptions(dynamic raw) {
  if (raw is! Map) return {};
  final m = Map<String, dynamic>.from(raw);
  final prefill = m['prefill'];
  if (prefill is Map) {
    m['prefill'] = Map<String, dynamic>.from(prefill);
  }
  final amount = m['amount'];
  if (amount is num) {
    m['amount'] = amount.round();
  }
  return m;
}
