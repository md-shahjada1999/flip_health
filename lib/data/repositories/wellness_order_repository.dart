import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/wellness%20models/wellness_order_invoice_model.dart';

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

bool _invoiceOk(Map<String, dynamic> root) {
  final st = root['status'];
  if (st == true || st == 1) return true;
  if (st == null && root['data'] is Map) return true;
  return false;
}

class WellnessOrderRepository {
  final ApiService apiService;

  WellnessOrderRepository({required this.apiService});

  Future<WellnessOrderInvoice> getInvoiceDetail(String id) async {
    try {
      final Response r = await apiService.get(ApiUrl.invoiceById(id));
      final raw = r.data;
      if (raw is! Map) {
        throw AppException(message: 'Invalid invoice response');
      }
      final root = _asMap(raw);
      if (!_invoiceOk(root)) {
        throw AppException(
          message: root['message']?.toString() ?? 'Failed to load order',
        );
      }
      final data = root['data'];
      if (data is Map) {
        return WellnessOrderInvoice.fromJson(Map<String, dynamic>.from(data));
      }
      throw AppException(message: 'Invalid invoice data');
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('WellnessOrderRepository.getInvoiceDetail: $e\n$st');
      throw AppException(message: 'Could not load wellness order details.');
    }
  }

  /// `PATCH /patient/jumping-mind/expert/order/cancel`
  Future<void> cancelWellnessOrder(Map<String, dynamic> body) async {
    await apiService.patch(ApiUrl.JUMPING_MIND_ORDER_CANCEL, data: body);
  }

  /// `PATCH /patient/jumping-mind/expert/order/reschedule`
  Future<void> rescheduleWellnessOrder(Map<String, dynamic> body) async {
    await apiService.patch(ApiUrl.JUMPING_MIND_ORDER_RESCHEDULE, data: body);
  }
}
