import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';

class DentalRepository {
  final ApiService apiService;
  DentalRepository({required this.apiService});

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

  Future<List<VendorModel>> getVendors() async {
    try {
      // TODO: Replace with actual API call
      return [
        VendorModel(
          id: 'v1',
          name: 'Smile Dental Clinic',
          address: 'Plot 42, Road No. 5, Jubilee Hills',
          city: 'Hyderabad',
          distance: '2.5',
          phone: '9876543210',
        ),
        VendorModel(
          id: 'v2',
          name: 'Apollo Dental Care',
          address: 'Banjara Hills, Road No. 12',
          city: 'Hyderabad',
          distance: '4.8',
          phone: '9876543211',
        ),
        VendorModel(
          id: 'v3',
          name: 'Clove Dental',
          address: 'Madhapur, Hitec City Main Road',
          city: 'Hyderabad',
          distance: '6.1',
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
