import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

bool _ok(dynamic status) {
  if (status == true) return true;
  if (status == 1) return true;
  final s = status?.toString().toLowerCase();
  return s == 'true' || s == '1';
}

bool _invoiceDetailOk(Map<String, dynamic> root) {
  if (_ok(root['status'])) return true;
  if (root['status'] == null && root['data'] is Map) return true;
  return false;
}

class ConsultationOrderRepository {
  final ApiService apiService;

  ConsultationOrderRepository({required this.apiService});

  /// GET `/patient/invoice/{id}` — full invoice (consultation) detail.
  Future<Map<String, dynamic>> getInvoiceDetail(String id) async {
    try {
      final Response r = await apiService.get(ApiUrl.invoiceById(id));
      final raw = r.data;
      if (raw is! Map) {
        throw AppException(message: 'Invalid invoice response');
      }
      final root = _asMap(raw);
      if (!_invoiceDetailOk(root)) {
        throw AppException(
          message: root['message']?.toString() ?? 'Failed to load consultation',
        );
      }
      final data = root['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      throw AppException(message: 'Invalid invoice data');
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('getInvoiceDetail: $e\n$st');
      throw AppException(message: 'Could not load consultation details.');
    }
  }

  Future<void> joinCall(String roomId) async {
    await apiService.patch(ApiUrl.joinCall(roomId), data: <String, dynamic>{});
  }

  Future<void> endCall(String roomId) async {
    await apiService.patch(ApiUrl.endCall(roomId), data: <String, dynamic>{});
  }

  Future<void> cancelAppointment(String appointmentId, Map<String, dynamic> body) async {
    await apiService.patch(
      ApiUrl.appointmentCancel(appointmentId),
      data: body,
    );
  }

  /// Confirm / initiate payment for offline flow — same as patient `bookOfflineAppointment`.
  /// Unwraps `data` when the API wraps the payload (matches patient `resp.body` usage).
  Future<Map<String, dynamic>> offlineAppointmentPayment({
    required String invoiceId,
    required bool confirm,
    required bool useWallet,
  }) async {
    final q = confirm
        ? '?status=confirm&useWallet=$useWallet'
        : '?useWallet=$useWallet';
    final Response r = await apiService.patch(
      '${ApiUrl.OFFLINE_APPOINTMENT_PAYMENT}/$invoiceId$q',
      data: <String, dynamic>{},
    );
    return _normalizeOfflinePaymentPayload(r.data);
  }

  /// After Razorpay success — `PATCH /patient/appointment/paymentverify`
  Future<Map<String, dynamic>> verifyAppointmentPayment(
    Map<String, dynamic> body,
  ) async {
    final Response r =
        await apiService.patch(ApiUrl.APPOINTMENT_PAYMENT_VERIFY, data: body);
    final raw = r.data;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  /// Post-call feedback — same payload as patient_app `videocall_review_popup` / `feedbackApi`.
  Future<void> submitAppointmentCallFeedback({
    required String appointmentId,
    required int rating,
    required int techRating,
    String? description,
  }) async {
    await apiService.post(
      ApiUrl.FEEDBACK,
      data: <String, dynamic>{
        'src': 'appointment',
        'src_id': appointmentId,
        'rating': rating,
        'tech_rating': techRating,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );
  }
}

Map<String, dynamic> _normalizeOfflinePaymentPayload(dynamic raw) {
  if (raw is! Map) return {};
  final m = Map<String, dynamic>.from(raw);
  final inner = m['data'];
  if (inner is Map) return Map<String, dynamic>.from(inner);
  return m;
}
