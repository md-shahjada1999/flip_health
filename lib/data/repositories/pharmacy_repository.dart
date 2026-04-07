import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/pharmacy%20models/flip_health_prescription_model.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_model.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_order_response.dart';

class PharmacyRepository {
  final ApiService apiService;

  PharmacyRepository({required this.apiService});

  Future<List<FlipHealthPrescription>> getFlipHealthPrescriptions() async {
    try {
      final response = await apiService.get(ApiUrl.PRESCRIPTIONS);
      PrintLog.printLog(
          'PharmacyRepository.getFlipHealthPrescriptions status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ??
                  'Failed to fetch prescriptions')
              : 'Failed to fetch prescriptions',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is Map<String, dynamic>) {
        final list = root['prescriptions'] as List<dynamic>? ?? [];
        return list
            .map((e) =>
                FlipHealthPrescription.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog(
          'PharmacyRepository.getFlipHealthPrescriptions error: $e');
      throw AppException(message: 'Failed to fetch prescriptions: $e');
    }
  }

  Future<FlipHealthPrescription> getPrescriptionById(String id) async {
    try {
      final response = await apiService.get('${ApiUrl.PRESCRIPTIONS}/$id');
      PrintLog.printLog(
          'PharmacyRepository.getPrescriptionById status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ??
                  'Failed to fetch prescription')
              : 'Failed to fetch prescription',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is Map<String, dynamic> &&
          root['prescription'] is Map<String, dynamic>) {
        return FlipHealthPrescription.fromJson(root['prescription']);
      }

      throw AppException(message: 'Unexpected prescription response format');
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('PharmacyRepository.getPrescriptionById error: $e');
      throw AppException(message: 'Failed to fetch prescription: $e');
    }
  }

  /// Place a medicine order. All 3 flows (upload, flip health, OTC) use this.
  Future<PharmacyOrderResponse> placeOrder({
    required String addressId,
    required int patientId,
    required List<Map<String, dynamic>> prescriptions,
  }) async {
    try {
      final body = {
        'address_id': addressId,
        'patient_id': patientId,
        'prescriptions': prescriptions,
      };

      final response = await apiService.post(ApiUrl.MEDICINE_ORDER, data: body);
      PrintLog.printLog(
          'PharmacyRepository.placeOrder status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ??
                  'Failed to place order')
              : 'Failed to place order',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is Map<String, dynamic>) {
        return PharmacyOrderResponse.fromJson(root);
      }

      throw AppException(message: 'Unexpected order response format');
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('PharmacyRepository.placeOrder error: $e');
      throw AppException(message: 'Failed to place order: $e');
    }
  }

  List<FAQItem> getFAQs() {
    return [
      FAQItem(
        question: 'Do I need to order all the medicine in the prescription?',
        answer:
            'No, you don\'t need to order all medicines. Our medicine partner will contact you to confirm the required medicines.',
      ),
      FAQItem(
        question: 'Can I change the quantity of medicines?',
        answer:
            'Yes, our medicine partner will contact you to confirm the medicines and quantities before delivery.',
      ),
      FAQItem(
        question: 'How do I know the price of medicines?',
        answer:
            'Once the order is confirmed, our medicine partner will share the price details with you before delivery.',
      ),
    ];
  }
}
