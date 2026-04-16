import 'dart:convert';

import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/core/utils/payment_success_screen.dart';
import 'package:flip_health/data/repositories/consultation_order_repository.dart';
import 'package:flip_health/data/repositories/gym_repository.dart';
import 'package:flip_health/data/repositories/health_checkup_repository.dart';
import 'package:flip_health/data/repositories/lab_test_repository.dart';
import 'package:flip_health/data/repositories/pharmacy_repository.dart';
import 'package:flip_health/data/repositories/service_request_repository.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_checkup_booking_success_screen.dart';
import 'package:flip_health/model/gym%20models/gym_membership_invoice_model.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Razorpay flow aligned with patient_app `RazorPayController` (consultation verify).
class RazorPayController extends GetxController {
  late Razorpay _razorpay;
  String from = '';
  Map<String, dynamic> body = {};
  Map<String, dynamic> _consultationSuccessSummary = {};
  Map<String, dynamic> _pharmacySuccessSummary = {};
  Map<String, dynamic> _serviceRequestSuccessSummary = {};

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    if (a is List && a.length >= 2 && a[1] is Map) {
      from = a[0].toString();
      body = _normalizeRazorpayOptions(a[1]);
      if (a.length >= 3 && a[2] is Map) {
        final extra = Map<String, dynamic>.from(a[2] as Map);
        if (from == 'fromConsultationOrder') {
          _consultationSuccessSummary = extra;
        } else if (from == 'fromPharmacy') {
          _pharmacySuccessSummary = extra;
        } else if (from == 'fromServiceRequest') {
          _serviceRequestSuccessSummary = extra;
        }
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
          final summary = Map<String, dynamic>.from(_consultationSuccessSummary);
          summary['payment_id'] = response.paymentId;
          summary['razorpay_order_id'] = response.orderId;
          Get.offAllNamed(
            AppRoutes.consultationPaymentSuccess,
            arguments: summary,
          );
        } else {
          ToastCustom.showSnackBar(
            subtitle: res['message']?.toString() ?? 'Verification failed',
          );
        }
      } catch (e) {
        ToastCustom.showSnackBar(subtitle: e.toString());
      }
    } else if (from == 'fromPharmacy') {
      final map = <String, dynamic>{
        'src': 'razorpay',
        'order_id': response.orderId,
        'payment_id': response.paymentId,
        'signature': response.signature,
      };
      try {
        if (!Get.isRegistered<PharmacyRepository>()) {
          if (!Get.isRegistered<ApiService>()) {
            Get.lazyPut<ApiService>(() => ApiService());
          }
          Get.lazyPut<PharmacyRepository>(
            () => PharmacyRepository(apiService: Get.find()),
          );
        }
        final repo = Get.find<PharmacyRepository>();
        final res = await repo.verifyMedicineOrderPayment(map);
        final ok =
            res['status'] == true ||
            res['status'] == 1 ||
            res['success'] == true;
        if (ok) {
          final summary = Map<String, dynamic>.from(_pharmacySuccessSummary);
          summary['payment_id'] = response.paymentId;
          Get.offAllNamed(
            AppRoutes.pharmacyPaymentSuccess,
            arguments: summary,
          );
        } else {
          ToastCustom.showSnackBar(
            subtitle: res['message']?.toString() ?? 'Verification failed',
          );
        }
      } catch (e) {
        ToastCustom.showSnackBar(subtitle: e.toString());
      }
    } else if (from == 'fromServiceRequest') {
      final map = <String, dynamic>{
        'src': 'razorpay',
        'order_id': response.orderId,
        'payment_id': response.paymentId,
        'signature': response.signature,
      };
      try {
        if (!Get.isRegistered<ServiceRequestRepository>()) {
          if (!Get.isRegistered<ApiService>()) {
            Get.lazyPut<ApiService>(() => ApiService());
          }
          Get.lazyPut<ServiceRequestRepository>(
            () => ServiceRequestRepository(apiService: Get.find()),
          );
        }
        final repo = Get.find<ServiceRequestRepository>();
        final res = await repo.verifyServiceRequestPayment(map);
        final ok =
            res['status'] == true ||
            res['status'] == 1 ||
            res['success'] == true;
        if (ok) {
          final summary = Map<String, dynamic>.from(_serviceRequestSuccessSummary);
          summary['payment_id'] = response.paymentId;
          Get.offAllNamed(
            AppRoutes.serviceRequestPaymentSuccess,
            arguments: summary,
          );
        } else {
          ToastCustom.showSnackBar(
            subtitle: res['message']?.toString() ?? 'Verification failed',
          );
        }
      } catch (e) {
        ToastCustom.showSnackBar(subtitle: e.toString());
      }
    } else if (from == 'fromHealthCheckup') {
      final a = Get.arguments;
      final summary = a is List && a.length >= 3 && a[2] is Map
          ? Map<String, dynamic>.from(a[2] as Map)
          : <String, dynamic>{};
      final invoiceId = summary['invoice_id']?.toString() ?? '';
      final map = <String, dynamic>{
        'src': 'razorpay',
        'order_id': response.orderId,
        'payment_id': response.paymentId,
        'signature': response.signature,
        'invoice_id': invoiceId,
      };
      try {
        if (!Get.isRegistered<HealthCheckupRepository>()) {
          if (!Get.isRegistered<ApiService>()) {
            Get.lazyPut<ApiService>(() => ApiService());
          }
          Get.lazyPut<HealthCheckupRepository>(
            () => HealthCheckupRepository(apiService: Get.find()),
          );
        }
        final repo = Get.find<HealthCheckupRepository>();
        final res = await repo.postDiagnosticsOrderConfirm(map);
        final ok = res['status'] == true ||
            res['status'] == 1 ||
            res['success'] == true;
        if (ok) {
          Get.offAll(
            () => HealthCheckupBookingSuccessScreen(
              invoiceId: invoiceId.isNotEmpty ? invoiceId : null,
              summaryLine: summary['subtitle']?.toString() ??
                  'Payment successful. Your health checkup is booked.',
            ),
          );
        } else {
          ToastCustom.showSnackBar(
            subtitle: res['message']?.toString() ?? 'Verification failed',
          );
        }
      } catch (e) {
        ToastCustom.showSnackBar(subtitle: e.toString());
      }
    } else if (from == 'fromLabTest') {
      final a = Get.arguments;
      final summary = a is List && a.length >= 3 && a[2] is Map
          ? Map<String, dynamic>.from(a[2] as Map)
          : <String, dynamic>{};
      final invoiceId = summary['invoice_id']?.toString() ?? '';
      final map = <String, dynamic>{
        'src': 'razorpay',
        'order_id': response.orderId,
        'payment_id': response.paymentId,
        'signature': response.signature,
        'invoice_id': invoiceId,
      };
      try {
        if (!Get.isRegistered<LabTestRepository>()) {
          if (!Get.isRegistered<ApiService>()) {
            Get.lazyPut<ApiService>(() => ApiService());
          }
          Get.lazyPut<LabTestRepository>(
            () => LabTestRepository(apiService: Get.find()),
          );
        }
        final repo = Get.find<LabTestRepository>();
        final res = await repo.postDiagnosticsOrderConfirm(map);
        final ok = res['status'] == true ||
            res['status'] == 1 ||
            res['success'] == true;
        if (ok) {
          final titleRaw = summary['title']?.toString() ?? '';
          final subRaw = summary['subtitle']?.toString() ?? '';
          Get.offAll(
            () => PaymentSuccessScreen(
              title:
                  titleRaw.isNotEmpty ? titleRaw : 'Booking Confirmed!',
              subtitle: subRaw.isNotEmpty
                  ? subRaw
                  : 'Your lab test has been booked successfully.',
            ),
          );
        } else {
          ToastCustom.showSnackBar(
            subtitle: res['message']?.toString() ?? 'Verification failed',
          );
        }
      } catch (e) {
        ToastCustom.showSnackBar(subtitle: e.toString());
      }
    } else if (from == 'fromGymMembership') {
      final invoiceId = _gymInvoiceIdFromArgs();
      final map = <String, dynamic>{
        'payment_id': response.paymentId,
        'invoice_id': invoiceId,
      };
      try {
        if (!Get.isRegistered<GymRepository>()) {
          if (!Get.isRegistered<ApiService>()) {
            Get.lazyPut<ApiService>(() => ApiService());
          }
          Get.lazyPut<GymRepository>(
            () => GymRepository(apiService: Get.find()),
          );
        }
        final repo = Get.find<GymRepository>();
        final res = await repo.confirmGymMembershipPayment(map);
        final ok =
            res['status'] == true ||
            res['status'] == 1 ||
            res['success'] == true;
        if (ok) {
          Map<String, dynamic> summary = <String, dynamic>{
            'invoice_id': invoiceId,
          };
          if (invoiceId.isNotEmpty) {
            try {
              final inv = await repo.getInvoiceDetail(invoiceId);
              summary = _buildGymSuccessSummary(inv);
            } catch (_) {}
          }
          Get.offAllNamed(
            AppRoutes.gymMembershipPaymentSuccess,
            arguments: summary,
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

String _gymInvoiceIdFromArgs() {
  final a = Get.arguments;
  if (a is List && a.length >= 3 && a[2] != null) {
    return a[2].toString();
  }
  return '';
}

Map<String, dynamic> _buildGymSuccessSummary(GymMembershipInvoice inv) {
  final info = inv.info is Map
      ? Map<String, dynamic>.from(inv.info as Map)
      : <String, dynamic>{};
  final details = info['details'] is Map
      ? Map<String, dynamic>.from(info['details'] as Map)
      : <String, dynamic>{};
  final memberInfo = details['info'] is Map
      ? Map<String, dynamic>.from(details['info'] as Map)
      : <String, dynamic>{};
  return <String, dynamic>{
    'invoice_id': info['id']?.toString() ?? inv.id?.toString() ?? '',
    'name': memberInfo['name']?.toString() ?? '',
    'email': memberInfo['email']?.toString() ?? '',
    'phone': memberInfo['phone']?.toString() ?? '',
    'location':
        details['location']?.toString() ?? info['location']?.toString() ?? '',
    'start_date': details['start_date']?.toString() ?? '',
    'end_date': details['end_date']?.toString() ?? '',
  };
}
