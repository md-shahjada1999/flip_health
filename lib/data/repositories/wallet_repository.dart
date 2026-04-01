import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';

class WalletRepository {
  final ApiService apiService;

  WalletRepository({required this.apiService});

  Future<Map<String, dynamic>> getWalletData() async {
    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(milliseconds: 800));
      return {
        'available': 18500,
        'total': 25000,
        'expiresAt': 'Mar 31, 2027',
        'subscription_id': 'SUB-2024-001',
        'module': {
          'Consultation': {'available_limit': 4500, 'total_limit': 5000},
          'Lab': {'available_limit': 3200, 'total_limit': 5000},
          'Pharmacy': {'available_limit': 2800, 'total_limit': 3000},
          'Dental': {'available_limit': 1500, 'total_limit': 2000},
          'Vision': {'available_limit': 3000, 'total_limit': 5000},
          'Vaccine': {'available_limit': 3500, 'total_limit': 5000},
        },
      };
    } catch (e) {
      throw AppException(message: 'Failed to load wallet data.');
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions({int page = 1}) async {
    try {
      // TODO: Replace with real API call
      return [
        {
          'id': 'TXN-1042',
          'payment_date': '2026-03-25T14:30:00',
          'ref_type': 'Consultation',
          'amount': 500,
          'type': 'DEBIT',
          'status': 'success',
        },
        {
          'id': 'TXN-1041',
          'payment_date': '2026-03-22T10:15:00',
          'ref_type': 'Pharmacy',
          'amount': 1200,
          'type': 'DEBIT',
          'status': 'success',
        },
        {
          'id': 'TXN-1040',
          'payment_date': '2026-03-20T09:00:00',
          'ref_type': 'Labtest',
          'amount': 850,
          'type': 'DEBIT',
          'status': 'refunded',
          'note': 'Test cancelled by lab due to equipment maintenance',
        },
        {
          'id': 'TXN-1039',
          'payment_date': '2026-03-18T16:45:00',
          'ref_type': 'Dental',
          'amount': 2000,
          'type': 'DEBIT',
          'status': 'success',
        },
        {
          'id': 'TXN-1038',
          'payment_date': '2026-03-15T11:20:00',
          'ref_type': 'Vision',
          'amount': 1500,
          'type': 'DEBIT',
          'status': 'success',
        },
        {
          'id': 'TXN-1037',
          'payment_date': '2026-03-12T08:30:00',
          'ref_type': 'Consultation',
          'amount': 300,
          'type': 'DEBIT',
          'status': 'success',
        },
        {
          'id': 'TXN-1036',
          'payment_date': '2026-03-10T13:00:00',
          'ref_type': 'Pharmacy',
          'amount': 450,
          'type': 'DEBIT',
          'status': 'refunded',
          'note': 'Medicine out of stock',
        },
        {
          'id': 'TXN-1035',
          'payment_date': '2026-03-08T15:10:00',
          'ref_type': 'Vaccine',
          'amount': 750,
          'type': 'DEBIT',
          'status': 'success',
        },
        {
          'id': 'TXN-1034',
          'payment_date': '2026-03-05T10:00:00',
          'ref_type': 'Labtest',
          'amount': 1800,
          'type': 'DEBIT',
          'status': 'success',
        },
        {
          'id': 'TXN-1033',
          'payment_date': '2026-03-02T17:30:00',
          'ref_type': 'Consultation',
          'amount': 500,
          'type': 'DEBIT',
          'status': 'success',
        },
        {
          'id': 'TXN-1032',
          'payment_date': '2026-02-28T09:45:00',
          'ref_type': 'Dental',
          'amount': 3500,
          'type': 'DEBIT',
          'status': 'success',
        },
        {
          'id': 'TXN-1031',
          'payment_date': '2026-02-25T12:00:00',
          'ref_type': 'Vision',
          'amount': 2000,
          'type': 'DEBIT',
          'status': 'success',
        },
      ];
    } catch (e) {
      throw AppException(message: 'Failed to load transactions.');
    }
  }
}
