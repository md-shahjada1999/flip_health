import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_model.dart';

class PharmacyRepository {
  final ApiService apiService;

  PharmacyRepository({required this.apiService});

  Future<List<FAQItem>> getFAQs() async {
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

  Future<List<Map<String, dynamic>>> getFlipHealthPrescriptions() async {
    return [
      {
        'id': 'rx_1',
        'name': 'Prescription - Dr. Sharma',
        'date': '12 Mar 2024',
      },
      {
        'id': 'rx_2',
        'name': 'Prescription - Dr. Reddy',
        'date': '28 Feb 2024',
      },
    ];
  }

  Future<void> placeOrder({required List<Map<String, dynamic>> files}) async {
    // Mock: in real implementation, POST to API
  }
}
