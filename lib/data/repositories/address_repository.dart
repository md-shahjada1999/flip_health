import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/model/address%20models/address_model.dart';

class AddressRepository {
  final ApiService apiService;

  AddressRepository({required this.apiService});

  Future<List<AddressModel>> getAddresses() async {
    try {
      // TODO: Replace with real API call
      return [
        const AddressModel(
          id: '1',
          label: 'Home',
          fullAddress:
              'Isprout, 7th floor, Plot No: 25, Divyasree Trinity, Gachibowli',
          city: 'Hyderabad',
          pincode: '500032',
          isDefault: true,
          type: AddressType.home,
        ),
        const AddressModel(
          id: '2',
          label: 'Office',
          fullAddress: 'WeWork, Raheja Mindspace IT Park, HITEC City',
          city: 'Hyderabad',
          pincode: '500081',
          type: AddressType.office,
        ),
        const AddressModel(
          id: '3',
          label: 'Other',
          fullAddress: '12-1-45, Tarnaka, Secunderabad',
          city: 'Secunderabad',
          pincode: '500017',
          type: AddressType.other,
        ),
      ];
    } catch (e) {
      throw AppException(message: 'Failed to load addresses.');
    }
  }

  Future<AddressModel> saveAddress({required AddressModel address}) async {
    try {
      // TODO: Replace with real API call
      return address;
    } catch (e) {
      throw AppException(message: 'Failed to save address.');
    }
  }
}
