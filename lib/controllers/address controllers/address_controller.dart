import 'package:get/get.dart';
import 'package:flip_health/data/repositories/address_repository.dart';
import 'package:flip_health/model/address%20models/address_model.dart';

class AddressController extends GetxController {
  final AddressRepository _repository;

  AddressController({required AddressRepository repository})
      : _repository = repository;
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

  Future<void> loadAddresses() async {
    isLoading.value = true;
    try {
      addresses.value = await _repository.getAddresses();
      selectedAddress.value =
          addresses.firstWhereOrNull((a) => a.isDefault) ??
              addresses.firstOrNull;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
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
