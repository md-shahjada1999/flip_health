import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';

/// Add dependent / family member — aligned with patient_app `AllProviders.addFamilyMember`,
/// `getOTP` (member flow), and `relations` (dependent types).
class FamilyMemberRepository {
  final ApiService apiService;

  FamilyMemberRepository({required this.apiService});

  String _messageFromBody(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ??
          data['msg']?.toString() ??
          data['error']?.toString() ??
          '';
    }
    return '';
  }

  /// `GET /patient/dependent/types` → `{ "data": [ { "name": "Son" }, ... ] }`
  Future<List<String>> getDependentTypes() async {
    try {
      final response = await apiService.get(ApiUrl.DEPENDENT_TYPES);
      final code = response.statusCode ?? 0;
      if (code != 200 || response.data is! Map) {
        throw AppException(
          message: _messageFromBody(response.data).isNotEmpty
              ? _messageFromBody(response.data)
              : 'Could not load relationship types',
          statusCode: response.statusCode,
        );
      }
      final root = Map<String, dynamic>.from(response.data as Map);
      final data = root['data'];
      if (data is! List) return [];
      final names = <String>[];
      for (final e in data) {
        if (e is Map) {
          final n = e['name']?.toString().trim();
          if (n != null && n.isNotEmpty) names.add(n);
        }
      }
      return names;
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('FamilyMemberRepository.getDependentTypes: $e\n$st');
      throw AppException(message: 'Could not load relationship types');
    }
  }

  /// Same payload as patient_app [EditProfileController.getOtpApi] for adding a member.
  Future<void> sendMemberOtp(String phoneDigits) async {
    final trimmed = phoneDigits.trim();
    if (trimmed.length != 10) {
      throw AppException(message: 'Enter a valid 10-digit mobile number');
    }
    try {
      final response = await apiService.post(
        ApiUrl.MEMBER_OTP,
        data: <String, dynamic>{
          'key': trimmed,
          'action': 'MEMBER',
        },
      );
      final code = response.statusCode ?? 0;
      if (code != 200 && code != 201) {
        throw AppException(
          message: _messageFromBody(response.data).isNotEmpty
              ? _messageFromBody(response.data)
              : 'Could not send OTP',
          statusCode: response.statusCode,
        );
      }
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('FamilyMemberRepository.sendMemberOtp: $e\n$st');
      throw AppException(message: 'Could not send OTP');
    }
  }

  /// `POST /patient/member` — body keys match patient_app `edit_profile_view` submit map
  /// (name, phone, dob, gender, relationship, health fields, and `code` after OTP).
  Future<Map<String, dynamic>> addFamilyMember({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiService.post(ApiUrl.GET_MEMBERS, data: data);
      final code = response.statusCode ?? 0;
      if (code != 200 && code != 201) {
        throw AppException(
          message: _messageFromBody(response.data).isNotEmpty
              ? _messageFromBody(response.data)
              : 'Could not add family member',
          statusCode: response.statusCode,
        );
      }
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return <String, dynamic>{};
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('FamilyMemberRepository.addFamilyMember: $e\n$st');
      throw AppException(message: 'Could not add family member');
    }
  }
}
