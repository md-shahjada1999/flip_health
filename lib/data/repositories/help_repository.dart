import 'package:flip_health/controllers/help%20controllers/help_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';

class HelpRepository {
  final ApiService apiService;

  HelpRepository({required this.apiService});

  Future<List<SupportTicket>> getTickets() async {
    final now = DateTime.now();
    return [
      SupportTicket(
        id: 'TKT-1001',
        message:
            'Unable to book a consultation appointment. The app shows "Something went wrong" error when selecting a time slot.',
        status: 'open',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      SupportTicket(
        id: 'TKT-1002',
        message:
            'Pharmacy order delivery delayed by 3 days. Order ID: ORD-10236.',
        status: 'open',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      SupportTicket(
        id: 'TKT-1003',
        message:
            'Wallet balance not updated after recharge. Paid ₹2000 but balance still shows ₹0.',
        status: 'open',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      SupportTicket(
        id: 'TKT-1004',
        message:
            'Lab report not available in medical records even after 5 days of the test.',
        status: 'closed',
        createdAt: now.subtract(const Duration(days: 8)),
        feedback: 'Issue resolved quickly. Great support!',
        rating: 5,
      ),
      SupportTicket(
        id: 'TKT-1005',
        message:
            'Need to change the registered email address on my account.',
        status: 'closed',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  Future<SupportTicket> createTicket({required String message}) async {
    return SupportTicket(
      id: 'TKT-${DateTime.now().millisecondsSinceEpoch}',
      message: message.trim(),
      status: 'open',
      createdAt: DateTime.now(),
    );
  }

  Future<void> submitFeedback({
    required String ticketId,
    required int rating,
    String? feedback,
  }) async {
    // Mock: in real implementation, POST to API
  }
}
