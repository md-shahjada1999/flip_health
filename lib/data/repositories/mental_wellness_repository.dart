import 'package:flip_health/core/services/api%20services/api_controller.dart';

class MentalWellnessRepository {
  final ApiService apiService;

  MentalWellnessRepository({required this.apiService});

  Future<Map<String, String>> getProfileData() async {
    return {
      'name': 'Kalyan',
      'phone': '9876543210',
      'email': 'kalyan@fliphealth.com',
      'language': 'English',
      'service': 'Mental Wellness',
    };
  }

  Future<List<String>> getCategories() async {
    return [
      'Anxiety & Stress',
      'Depression',
      'Relationship Issues',
      'Work-Life Balance',
      'Sleep Disorders',
      'Grief & Loss',
      'Self-Esteem',
      'Corporate Wellness Solutions',
      'Child & Adolescent Counseling',
      'Adult Counseling',
    ];
  }

  Future<void> submitRequest({required Map<String, dynamic> data}) async {
    // Mock: in real implementation, POST to API
  }
}
