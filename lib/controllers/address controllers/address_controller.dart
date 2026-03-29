import 'package:get/get.dart';
import 'package:flip_health/model/address%20models/address_model.dart';

class AddressController extends GetxController {
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxBool isLoading = false.obs;

  String get displayLabel => selectedAddress.value?.label ?? 'Home';
  String get displayAddress =>
      selectedAddress.value?.fullAddress ?? 'Select an address';

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  void loadAddresses() {
    isLoading.value = true;

    // TODO: Replace with actual API call
    addresses.value = [
      const AddressModel(
        id: '1',
        label: 'Home',
        fullAddress: 'Isprout, 7th floor, Plot No: 25, Divyasree Trinity, Gachibowli',
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

    selectedAddress.value =
        addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.firstOrNull;

    isLoading.value = false;
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  void addAddress(AddressModel address) {
    addresses.add(address);
  }

  void removeAddress(String id) {
    addresses.removeWhere((a) => a.id == id);
    if (selectedAddress.value?.id == id) {
      selectedAddress.value = addresses.firstOrNull;
    }
  }
}
