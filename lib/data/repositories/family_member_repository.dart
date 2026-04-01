import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';

class FamilyMemberRepository {
  final ApiService apiService;
  FamilyMemberRepository({required this.apiService});

  Future<Map<String, dynamic>> addFamilyMember({required Map<String, dynamic> data}) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));
      return data;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }
}
