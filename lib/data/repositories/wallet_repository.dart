import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

Map<String, dynamic> _unwrapPayload(Map<String, dynamic> root) {
  if (root['status'] == true && root['data'] != null) {
    final d = root['data'];
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return Map<String, dynamic>.from(d);
  }
  return root;
}

class WalletRepository {
  final ApiService apiService;

  WalletRepository({required this.apiService});

  /// GET `/patient/opd/wallet` — returns the inner `wallet` map (unparsed).
  Future<Map<String, dynamic>> getWalletData() async {
    try {
      final Response response = await apiService.get(ApiUrl.OPD_WALLET);
      final raw = response.data;
      if (raw is! Map) {
        throw AppException(
          message: 'Invalid wallet response',
          statusCode: response.statusCode,
        );
      }
      final root = _asJsonMap(raw);
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Failed to load wallet',
          statusCode: response.statusCode,
        );
      }
      final payload = _unwrapPayload(root);
      final wallet = payload['wallet'];
      if (wallet is Map) {
        return Map<String, dynamic>.from(wallet);
      }
      return {};
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('WalletRepository.getWalletData: $e\n$st');
      throw AppException(message: 'Failed to load wallet data.');
    }
  }

  /// GET `/patient/opd/wallet/transactions/{subscription_id}?page=` — raw `transactions` list items.
  /// [subscriptionId] must match `wallet['subscription_id']` from [getWalletData].
  Future<List<Map<String, dynamic>>> getOpdWalletTransactions({
    required String subscriptionId,
    int page = 1,
    Map<String, dynamic>? searchData,
  }) async {
    try {
      final id = subscriptionId.trim();
      if (id.isEmpty || id == '0' || id.toLowerCase() == 'null') {
        return [];
      }

      var path = '${ApiUrl.OPD_WALLET_TRANSACTIONS}/$id?page=$page';
      if (searchData != null && searchData.isNotEmpty) {
        final buf = StringBuffer('&search=');
        final entries = searchData.entries.toList();
        for (var i = 0; i < entries.length; i++) {
          if (i > 0) buf.write(',');
          final key = entries[i].key;
          final value = entries[i].value;
          if (value is List) {
            buf.write('$key:${value.join('|')}');
          } else {
            buf.write('$key:$value');
          }
        }
        path += buf.toString();
      }

      final Response response = await apiService.get(path);
      final raw = response.data;
      if (raw is! Map) {
        throw AppException(
          message: 'Invalid transactions response',
          statusCode: response.statusCode,
        );
      }
      final root = _asJsonMap(raw);
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Failed to load transactions',
          statusCode: response.statusCode,
        );
      }
      final payload = _unwrapPayload(root);
      final list = payload['transactions'];
      if (list is! List) {
        return [];
      }
      return list
          .map((e) {
            if (e is Map<String, dynamic>) return e;
            if (e is Map) return Map<String, dynamic>.from(e);
            return <String, dynamic>{};
          })
          .where((m) => m.isNotEmpty)
          .toList();
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('WalletRepository.getOpdWalletTransactions: $e\n$st');
      throw AppException(message: 'Failed to load transactions.');
    }
  }
}
