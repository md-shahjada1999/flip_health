import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';

/// My subscriptions + activate member — patient_app `getSubscriptionDetails` / `activatePlanFamilyMember`.
class SubscriptionRepository {
  SubscriptionRepository({required this.apiService});

  final ApiService apiService;

  String _messageFromBody(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ??
          data['msg']?.toString() ??
          data['error']?.toString() ??
          '';
    }
    return '';
  }

  static bool _ok(int? code) {
    final c = code ?? 0;
    return c >= 200 && c < 300;
  }

  /// `GET /subscription/plans` → `{ isSubscribed, data: [...] }`
  Future<Map<String, dynamic>> fetchMySubscriptions() async {
    try {
      final response = await apiService.get(ApiUrl.SUBSCRIPTION_PLANS);
      if (!_ok(response.statusCode) || response.data == null) {
        throw AppException(
          message: _messageFromBody(response.data).isNotEmpty
              ? _messageFromBody(response.data)
              : 'Could not load subscriptions',
          statusCode: response.statusCode,
        );
      }
      final raw = response.data;
      if (raw is Map<String, dynamic>) return raw;
      if (raw is Map) return Map<String, dynamic>.from(raw);
      throw AppException(
        message: 'Invalid subscriptions response',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('SubscriptionRepository.fetchMySubscriptions: $e\n$st');
      throw AppException(message: 'Could not load subscriptions');
    }
  }

  /// `POST /subscription/activate` — same body as patient_app `activatePlanFamilyMember`.
  Future<void> activateMemberOnPlan({
    required int memberId,
    required String subscriptionId,
    required String dependentType,
  }) async {
    try {
      final response = await apiService.post(
        ApiUrl.SUBSCRIPTION_ACTIVATE,
        data: <String, dynamic>{
          'member_id': memberId,
          'subscription_id': subscriptionId,
          'dependent_type': dependentType,
        },
      );
      final code = response.statusCode ?? 0;
      if (!_ok(code)) {
        throw AppException(
          message: _messageFromBody(response.data).isNotEmpty
              ? _messageFromBody(response.data)
              : 'Could not activate member',
          statusCode: response.statusCode,
        );
      }
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('SubscriptionRepository.activateMemberOnPlan: $e\n$st');
      throw AppException(message: 'Could not activate member');
    }
  }
}
