import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/service_request_invoice_model.dart';

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

bool _ok(dynamic status) {
  if (status == true || status == 1) return true;
  final s = status?.toString().toLowerCase();
  return s == 'true' || s == '1' || s == 'success';
}

class ServiceRequestRepository {
  final ApiService apiService;

  ServiceRequestRepository({required this.apiService});

  Future<ServiceRequestInvoice> getInvoiceDetail(String id) async {
    try {
      final Response r = await apiService.get(ApiUrl.invoiceById(id));
      final raw = r.data;
      if (raw is! Map) {
        throw AppException(message: 'Invalid invoice response');
      }
      final root = _asMap(raw);
      if (!_ok(root['status']) &&
          !(root['status'] == null && root['data'] is Map)) {
        throw AppException(
          message:
              root['message']?.toString() ?? 'Failed to load request details',
        );
      }
      final data = root['data'];
      if (data is! Map) {
        throw AppException(message: 'Invalid invoice data');
      }
      return ServiceRequestInvoice.fromJson(Map<String, dynamic>.from(data));
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('ServiceRequestRepository.getInvoiceDetail: $e\n$st');
      throw AppException(message: 'Could not load service request details.');
    }
  }

  Future<void> confirmServiceRequest(String serviceId) async {
    await apiService.patch(
      '${ApiUrl.SERVICE_REQUEST_CONFIRM}/$serviceId',
      data: <String, dynamic>{'status': 4},
    );
  }

  Future<void> cancelServiceRequest(
    String serviceId,
    Map<String, dynamic> body,
  ) async {
    await apiService.patch(
      '${ApiUrl.SERVICE_REQUEST_CANCEL}/$serviceId',
      data: body,
    );
  }

  Future<Map<String, dynamic>> patchServiceRequestPayment({
    required String requestId,
    required bool confirm,
    required bool useWallet,
  }) async {
    final q = confirm
        ? '?status=confirm&useWallet=$useWallet'
        : '?useWallet=$useWallet';
    final Response r = await apiService.patch(
      '${ApiUrl.SERVICE_REQUEST_PAYMENT}/$requestId$q',
      data: <String, dynamic>{},
    );
    return _normalizePayload(r.data);
  }

  Future<Map<String, dynamic>> verifyServiceRequestPayment(
    Map<String, dynamic> body,
  ) async {
    final Response r = await apiService.patch(
      ApiUrl.SERVICE_REQUEST_PAYMENT_VERIFY,
      data: body,
    );
    return _normalizePayload(r.data);
  }

  Map<String, dynamic> _normalizePayload(dynamic raw) {
    if (raw is! Map) return {};
    final m = Map<String, dynamic>.from(raw);
    final inner = m['data'];
    if (inner is Map) return Map<String, dynamic>.from(inner);
    return m;
  }
}
