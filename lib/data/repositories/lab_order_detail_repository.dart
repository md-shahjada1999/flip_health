import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_order_invoice_model.dart';

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

bool _invoiceOk(Map<String, dynamic> root) {
  if (_ok(root['status'])) return true;
  if (root['status'] == null && root['data'] is Map) return true;
  return false;
}

/// Repository dedicated to lab diagnostics order-detail flow.
class LabOrderDetailRepository {
  final ApiService apiService;

  LabOrderDetailRepository({required this.apiService});

  Future<PharmacyOrderInvoice> getInvoiceDetail(String id) async {
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
        return PharmacyOrderInvoice.fromJson(Map<String, dynamic>.from(data));
      }
      throw AppException(message: 'Invalid invoice data');
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('LabOrderDetailRepository.getInvoiceDetail: $e\n$st');
      throw AppException(message: 'Could not load lab order details.');
    }
  }

  Future<Map<String, dynamic>> confirmLabSubOrder(String subOrderId) async {
    if (subOrderId.isEmpty) {
      throw AppException(message: 'Invalid order id');
    }
    try {
      final Response r = await apiService.patch(
        '${ApiUrl.LAB_SUB_ORDER_CONFIRM}/$subOrderId',
        data: <String, dynamic>{},
      );
      if (r.statusCode != 200 || r.data is! Map) {
        throw AppException(
          message: 'Could not confirm center details',
          statusCode: r.statusCode,
        );
      }
      final root = r.data as Map<String, dynamic>;
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Confirmation failed',
        );
      }
      return root;
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('confirmLabSubOrder error: $e');
      throw AppException(message: 'Confirmation failed: $e');
    }
  }

  Future<Map<String, dynamic>> patchLabOrderPayment({
    required String invoiceInfoId,
    required bool confirm,
    required bool useWallet,
  }) async {
    if (invoiceInfoId.isEmpty) {
      throw AppException(message: 'Invalid order id');
    }
    final q = confirm
        ? '?status=confirm&useWallet=$useWallet'
        : '?useWallet=$useWallet';
    final Response r = await apiService.patch(
      '${ApiUrl.LAB_ORDER_PAYMENT}/$invoiceInfoId$q',
      data: <String, dynamic>{},
    );
    if (r.statusCode != 200 || r.data is! Map) {
      throw AppException(
        message: 'Could not process lab payment',
        statusCode: r.statusCode,
      );
    }
    final root = r.data as Map<String, dynamic>;
    if (root['status'] == false) {
      throw AppException(
        message: root['message']?.toString() ?? 'Payment failed',
      );
    }
    return root;
  }

  Future<void> cancelLabOrder(
    String invoiceInfoId,
    Map<String, dynamic> body,
  ) async {
    if (invoiceInfoId.isEmpty) {
      throw AppException(message: 'Invalid order id');
    }
    final Response r = await apiService.patch(
      '${ApiUrl.LAB_ORDER_CANCEL}/$invoiceInfoId',
      data: body,
    );
    if (r.statusCode != 200 || r.data is! Map) {
      throw AppException(
        message: 'Could not cancel lab order',
        statusCode: r.statusCode,
      );
    }
    final root = r.data as Map<String, dynamic>;
    if (root['status'] == false) {
      throw AppException(
        message: root['message']?.toString() ?? 'Cancellation failed',
      );
    }
  }

  Future<void> rescheduleLabSubOrder({
    required String subOrderId,
    required Map<String, dynamic> body,
  }) async {
    if (subOrderId.isEmpty) {
      throw AppException(message: 'Invalid sub-order id');
    }
    final Response r = await apiService.patch(
      '${ApiUrl.LAB_ORDER_RESCHEDULE}/$subOrderId',
      data: body,
    );
    if (r.statusCode != 200 || r.data is! Map) {
      throw AppException(
        message: 'Could not reschedule booking',
        statusCode: r.statusCode,
      );
    }
    final root = r.data as Map<String, dynamic>;
    if (root['status'] == false) {
      throw AppException(
        message: root['message']?.toString() ?? 'Reschedule failed',
      );
    }
  }

  Future<LabSlotsResponse> getLabSlotsForReschedule({
    required String addressId,
    required String date,
    required String vendorCode,
    required String category,
  }) async {
    final response = await apiService.post(
      ApiUrl.DIAGNOSTICS_SLOTS,
      data: {
        'address_id': addressId,
        'date': date,
        'vendor_code': vendorCode,
        'package': 'special',
        'category': category,
      },
    );
    if (response.statusCode != 200 || response.data is! Map) {
      throw AppException(
        message: 'Failed to fetch slots',
        statusCode: response.statusCode,
      );
    }
    final root = response.data as Map<String, dynamic>;
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    return LabSlotsResponse.fromJson(data);
  }

  /// Razorpay verify for lab detail flow.
  Future<Map<String, dynamic>> postDiagnosticsOrderConfirm(
    Map<String, dynamic> body,
  ) async {
    final response = await apiService.post(
      ApiUrl.DIAGNOSTICS_ORDER_CONFIRM,
      data: body,
    );
    if (response.statusCode != 200 || response.data is! Map) {
      throw AppException(
        message: 'Could not confirm booking',
        statusCode: response.statusCode,
      );
    }
    final root = response.data as Map<String, dynamic>;
    if (root['status'] == false) {
      throw AppException(
        message: root['message']?.toString() ?? 'Confirmation failed',
      );
    }
    return root;
  }
}
