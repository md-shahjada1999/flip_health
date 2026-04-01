import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/model/claims%20models/bank_account_model.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';

class ClaimsRepository {
  final ApiService apiService;

  ClaimsRepository({required this.apiService});

  Future<List<ClaimModel>> getClaims() async {
    try {
      // TODO: Replace with real API call
      return [
        ClaimModel(
          id: 'CLM001',
          userName: 'Kalyan',
          userPhone: '9876543210',
          status: 0,
          claimAmount: 2500,
          createdAt: '2024-03-15',
          serviceType: 'Dental',
        ),
        ClaimModel(
          id: 'CLM002',
          userName: 'Priya',
          userPhone: '9876543211',
          status: 5,
          claimAmount: 8500,
          approvedAmount: 7200,
          createdAt: '2024-03-10',
          serviceType: 'Consultation',
        ),
        ClaimModel(
          id: 'CLM003',
          userName: 'Kalyan',
          userPhone: '9876543210',
          status: 1,
          claimAmount: 1200,
          approvedAmount: 1200,
          createdAt: '2024-02-28',
          serviceType: 'Pharmacy',
        ),
        ClaimModel(
          id: 'CLM004',
          userName: 'Rahul',
          userPhone: '9876543212',
          status: 4,
          claimAmount: 5000,
          createdAt: '2024-03-20',
          serviceType: 'Vision',
        ),
        ClaimModel(
          id: 'CLM005',
          userName: 'Kalyan',
          userPhone: '9876543210',
          status: 2,
          claimAmount: 3200,
          createdAt: '2024-01-15',
          serviceType: 'Dental',
        ),
      ];
    } catch (e) {
      throw AppException(message: 'Failed to load claims.');
    }
  }

  Future<List<Map<String, dynamic>>> getMembers() async {
    try {
      // TODO: Replace with real API call
      return [
        {
          'id': '1',
          'name': 'Kalyan',
          'age': 32,
          'gender': 'Male',
          'relation': 'Self',
        },
        {
          'id': '2',
          'name': 'Priya',
          'age': 28,
          'gender': 'Female',
          'relation': 'Spouse',
        },
        {
          'id': '3',
          'name': 'Rahul',
          'age': 8,
          'gender': 'Male',
          'relation': 'Son',
        },
      ];
    } catch (e) {
      throw AppException(message: 'Failed to load members.');
    }
  }

  Future<List<BankAccount>> getBankAccounts() async {
    try {
      // TODO: Replace with real API call
      return [
        BankAccount(
          id: 'bank_1',
          bankName: 'State Bank of India',
          accountNumber: '30219876543',
          ifscCode: 'SBIN0001234',
          branch: 'Hyderabad Main Branch',
          holderName: 'Kalyan',
          verifyStatus: 1,
        ),
        BankAccount(
          id: 'bank_2',
          bankName: 'HDFC Bank',
          accountNumber: '50100987654321',
          ifscCode: 'HDFC0005678',
          branch: 'Banjara Hills',
          holderName: 'Kalyan',
          verifyStatus: 1,
        ),
      ];
    } catch (e) {
      throw AppException(message: 'Failed to load bank accounts.');
    }
  }

  Future<void> submitClaim({required Map<String, dynamic> claimData}) async {
    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw AppException(message: 'Failed to submit claim.');
    }
  }
}
