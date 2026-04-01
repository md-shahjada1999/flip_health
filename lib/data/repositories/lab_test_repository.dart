import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';

class LabTestRepository {
  final ApiService apiService;
  LabTestRepository({required this.apiService});

  Future<List<FamilyMember>> getFamilyMembers() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      return [
        FamilyMember(id: '1', name: 'Gundari Abhinay', isSponsored: true, sponsoredBy: 'your company'),
        FamilyMember(id: '2', name: 'Gundari Abhinaya', isSponsored: false, hasPackages: true),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<LabTestModel>> getAllTests() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      return const [
        LabTestModel(id: '1', name: 'Bilurubin (total, direct and indirect)', reportTime: 'Reports within 48 hours'),
        LabTestModel(id: '2', name: 'Complete Blood Count (CBC)', reportTime: 'Reports within 24 hours'),
        LabTestModel(id: '3', name: 'Thyroid Profile (T3, T4, TSH)', reportTime: 'Reports within 48 hours'),
        LabTestModel(id: '4', name: 'Liver Function Test (LFT)', reportTime: 'Reports within 48 hours'),
        LabTestModel(id: '5', name: 'Kidney Function Test (KFT)', reportTime: 'Reports within 48 hours'),
        LabTestModel(id: '6', name: 'Lipid Profile', reportTime: 'Reports within 24 hours'),
        LabTestModel(id: '7', name: 'HbA1c (Glycated Hemoglobin)', reportTime: 'Reports within 48 hours'),
        LabTestModel(id: '8', name: 'Vitamin D (25-Hydroxy)', reportTime: 'Reports within 48 hours'),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<LabPackageModel>> getPopularPackages() async {
    try {
      // TODO: Replace with actual API call
      return const [
        LabPackageModel(
          id: 'pkg1',
          name: 'Basic Diagnostic Package - Home Collection',
          price: 6000,
          includedTests: ['1', '2', '3', '4'],
        ),
        LabPackageModel(
          id: 'pkg2',
          name: 'Advanced Health Package - Home Collection',
          price: 12000,
          includedTests: ['1', '2', '3', '4', '5', '6', '7', '8'],
        ),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<LabModel>> getAvailableLabs({required List<LabTestModel> cartTests}) async {
    try {
      // TODO: Replace with actual API call
      return [
        LabModel(
          id: 'lab1',
          name: 'Neuberg Diagnostics',
          logoPath: 'assets/png/neuberg_logo.png',
          rating: '4.5',
          testPrices: cartTests
              .map((t) => LabTestPrice(testId: t.id, testName: t.name, price: t.id == '1' ? 300 : 210))
              .toList(),
          homeCollectionCharge: 80,
          supportedTypes: [CollectionType.home, CollectionType.center],
        ),
        LabModel(
          id: 'lab2',
          name: 'OrangeHealthLabs',
          logoPath: 'assets/png/orange_health_logo.png',
          rating: '4.5',
          address: '3rd & 4th floor, Bright Square, Dharam Karan Rd, ShivBagh, Ameerpet, Hyderabad, Telangana 500016',
          distance: '18 km',
          testPrices: cartTests
              .map((t) => LabTestPrice(testId: t.id, testName: t.name, price: t.id == '1' ? 210 : 210))
              .toList(),
          homeCollectionCharge: 80,
          supportedTypes: [CollectionType.home, CollectionType.center],
        ),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }
}
