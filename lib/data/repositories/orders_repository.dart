import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/order_models.dart';

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

bool _responseSuccess(dynamic status) {
  if (status == true) return true;
  if (status == 1) return true;
  final s = status?.toString().toLowerCase();
  return s == 'true' || s == '1' || s == 'success';
}

/// True when the invoice list call succeeded. Some APIs omit [status] and only
/// return `{ "data": [ ... ], "message": "..." }` (see sample invoice response).
bool _isInvoiceListResponseOk(Map<String, dynamic> root) {
  final st = root['status'];
  if (st == false || st == 'false' || st == 0 || st == '0') {
    return false;
  }
  if (_responseSuccess(st)) return true;
  if (st == null || st == '') {
    final data = root['data'];
    if (data is List || data is Map) return true;
  }
  return false;
}

/// API may return `{ data: [ ... ] }` or `{ data: { rows|records|invoices|...: [ ] } }`.
List<dynamic> _extractInvoiceList(dynamic data) {
  if (data == null) return [];
  if (data is List) return data;

  if (data is String && data.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      return _extractInvoiceList(decoded);
    } catch (_) {
      return [];
    }
  }

  if (data is Map) {
    final m = Map<String, dynamic>.from(data);
    const listKeys = [
      'data',
      'rows',
      'records',
      'invoices',
      'orders',
      'list',
      'items',
      'docs',
      'results',
      'content',
    ];
    for (final key in listKeys) {
      final v = m[key];
      if (v is List) return v;
    }
    // Nested single-object wrappers e.g. { invoice: { ... } } — not a list
    for (final key in listKeys) {
      final v = m[key];
      if (v is Map) {
        final inner = _extractInvoiceList(v);
        if (inner.isNotEmpty) return inner;
      }
    }
  }

  return [];
}

class OrdersPageResult {
  final List<Order> orders;
  final bool hasMore;

  OrdersPageResult({required this.orders, required this.hasMore});
}

class OrdersRepository {
  final ApiService apiService;

  OrdersRepository({required this.apiService});

  static const int defaultPageSize = 20;

  /// GET `/patient/invoice` — paginated invoice list (Bearer token via [ApiService]).
  Future<OrdersPageResult> getOrders({
    int page = 1,
    int limit = defaultPageSize,
    String typeQuery = '',
  }) async {
    try {
      final Response response = await apiService.get(
        ApiUrl.INVOICE,
        queryParameters: <String, dynamic>{
          'limit': limit,
          'page': page,
          'type': typeQuery,
        },
      );
      final raw = response.data;
      if (raw is! Map) {
        throw AppException(
          message: 'Invalid orders response',
          statusCode: response.statusCode,
        );
      }
      final root = _asJsonMap(raw);
      if (!_isInvoiceListResponseOk(root)) {
        throw AppException(
          message: root['message']?.toString() ?? 'Failed to load orders',
          statusCode: response.statusCode,
        );
      }
      var list = _extractInvoiceList(root['data']);
      if (list.isEmpty) {
        list = _extractInvoiceList(root);
      }
      if (list.isEmpty) {
        final d = root['data'];
        PrintLog.printLog(
          'OrdersRepository.getOrders: success but no list in payload; '
          'data: ${d is Map ? d.keys.toList() : d?.runtimeType}; '
          'root keys: ${root.keys.toList()}',
        );
      }
      final orders = list
          .map((e) => Order.fromInvoiceJson(_asJsonMap(e)))
          .toList();
      final hasMore = list.length >= limit;
      return OrdersPageResult(orders: orders, hasMore: hasMore);
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('OrdersRepository.getOrders: $e\n$st');
      throw AppException(message: 'Could not load orders. Please try again.');
    }
  }
}
