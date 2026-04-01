import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';
import 'package:flip_health/controllers/vaccine%20controllers/vaccine_controller.dart';

class VaccineRepository {
  final ApiService apiService;
  VaccineRepository({required this.apiService});

  Future<List<FamilyMember>> getFamilyMembers() async {
    try {
      // TODO: Replace with actual API call
      return [
        FamilyMember(id: '1', name: 'Kalyan', isSponsored: true, sponsoredBy: 'Acme Corp'),
        FamilyMember(id: '2', name: 'Priya', isSponsored: false, hasPackages: true),
        FamilyMember(id: '3', name: 'Rahul', isSponsored: false, hasPackages: false),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<VaccineType>> getVaccineTypes() async {
    try {
      // TODO: Replace with actual API call
      return const [
        VaccineType(id: 'v1', name: 'Flu Vaccine', description: 'Seasonal influenza protection'),
        VaccineType(id: 'v2', name: 'COVID-19 Booster', description: 'Updated booster shot'),
        VaccineType(id: 'v3', name: 'Hepatitis B', description: '3-dose series for liver protection'),
        VaccineType(id: 'v4', name: 'Typhoid', description: 'Protection against typhoid fever'),
        VaccineType(id: 'v5', name: 'MMR', description: 'Measles, Mumps & Rubella'),
        VaccineType(id: 'v6', name: 'Tetanus', description: 'Tetanus toxoid booster'),
        VaccineType(id: 'v7', name: 'HPV', description: 'Human Papillomavirus vaccine'),
        VaccineType(id: 'v8', name: 'Pneumococcal', description: 'Pneumonia prevention'),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<VendorModel>> getVendors() async {
    try {
      // TODO: Replace with actual API call
      return [
        VendorModel(
          id: 'vc1',
          name: 'Apollo Vaccination Center',
          address: 'Jubilee Hills, Road No. 36',
          city: 'Hyderabad',
          distance: '2.3',
          phone: '9876543210',
        ),
        VendorModel(
          id: 'vc2',
          name: 'MaxCure Immunization Hub',
          address: 'Madhapur, Hitec City',
          city: 'Hyderabad',
          distance: '4.1',
          phone: '9876543211',
        ),
        VendorModel(
          id: 'vc3',
          name: 'Care Hospitals Vaccine Clinic',
          address: 'Banjara Hills, Road No. 1',
          city: 'Hyderabad',
          distance: '5.7',
          phone: '9876543212',
        ),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getAvailableSlots() async {
    try {
      // TODO: Replace with actual API call
      final now = DateTime.now().add(const Duration(days: 1));
      final monthYear =
          '${_monthName(now.month)} ${now.year}';
      final dates = List.generate(7, (i) {
        final date = now.add(Duration(days: i));
        return {
          'day': '${date.day}',
          'weekday': _weekdayName(date.weekday),
        };
      });
      return {
        'monthYearLabel': monthYear,
        'availableDates': dates,
        'morningSlots': [
          {'time': '9:00 AM', 'isDisabled': false},
          {'time': '9:30 AM', 'isDisabled': false},
          {'time': '10:00 AM', 'isDisabled': false},
          {'time': '10:30 AM', 'isDisabled': true},
          {'time': '11:00 AM', 'isDisabled': false},
          {'time': '11:30 AM', 'isDisabled': false},
        ],
        'afternoonSlots': [
          {'time': '2:00 PM', 'isDisabled': false},
          {'time': '2:30 PM', 'isDisabled': false},
          {'time': '3:00 PM', 'isDisabled': false},
          {'time': '3:30 PM', 'isDisabled': true},
          {'time': '4:00 PM', 'isDisabled': false},
        ],
      };
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
