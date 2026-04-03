import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';

/// Same shape as other patient APIs: flat `{ members }` or `{ status, data: { members } }`.
Map<String, dynamic> _unwrapMembersPayload(Map<String, dynamic> root) {
  if (root['status'] == true && root['data'] != null) {
    final d = root['data'];
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return Map<String, dynamic>.from(d);
  }
  return root;
}

class MemberRepository {
  final ApiService apiService;

  MemberRepository({required this.apiService});

  Future<List<FamilyMember>> getMembers() async {
    try {
      final response = await apiService.get(ApiUrl.GET_MEMBERS);
      final code = response.statusCode ?? 0;
      final ok = code == 200 || code == 201;

      if (!ok || response.data is! Map) {
        final msg = response.data is Map
            ? (response.data as Map)['message']?.toString()
            : null;
        throw AppException(
          message: msg ?? 'Failed to fetch members',
          statusCode: response.statusCode,
        );
      }

      final root = Map<String, dynamic>.from(response.data as Map);
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Failed to fetch members',
          statusCode: response.statusCode,
        );
      }

      final payload = _unwrapMembersPayload(root);
      return FamilyMember.fromMembersResponse(payload);
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('MemberRepository.getMembers error: $e');
      throw AppException(message: 'Failed to load members: $e');
    }
  }
}
