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
    final code = response.statusCode ?? 0;

    PrintLog.printLog('CODE: $code');
    PrintLog.printLog('DATA TYPE: ${response.data.runtimeType}');

    if ((code != 200 && code != 201) || response.data is! Map) {
      PrintLog.printLog('FAILED GUARD: code=$code isMap=${response.data is Map}');
      throw AppException(
        message: 'Failed to fetch members',
        statusCode: response.statusCode,
      );
    }

    final root = Map<String, dynamic>.from(response.data as Map);
    PrintLog.printLog('MEMBERS COUNT: ${(root['members'] as List?)?.length}');
    return FamilyMember.fromMembersResponse(root);
  } on AppException {
    rethrow;
  } catch (e, st) {
    PrintLog.printLog('ERROR: $e');
    PrintLog.printLog('STACKTRACE: $st');
    throw AppException(message: 'Failed to load members: $e');
  }
}
}