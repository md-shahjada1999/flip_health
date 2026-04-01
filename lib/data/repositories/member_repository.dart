import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';

class MemberRepository {
  final ApiService apiService;

  MemberRepository({required this.apiService});

  Future<List<FamilyMember>> getMembers() async {
    try {
      final response = await apiService.get(ApiUrl.GET_MEMBERS);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return FamilyMember.fromMembersResponse(data);
      }

      throw AppException(
        message: response.data?['message'] ?? 'Failed to fetch members',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('MemberRepository.getMembers error: $e');
      throw AppException(message: 'Failed to load members: $e');
    }
  }
}
