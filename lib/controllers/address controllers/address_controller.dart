import 'package:get/get.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/address_repository.dart';
import 'package:flip_health/model/address%20models/address_model.dart';

class AddressController extends GetxController {
  final AddressRepository _repository;

  AddressController({required AddressRepository repository})
      : _repository = repository;

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxBool isLoading = false.obs;

  String get displayLabel => selectedAddress.value?.displayLabel ?? 'Home';
  String get displayAddress =>
      selectedAddress.value?.fullAddress ?? 'Select an address';

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses({bool forceRefresh = false}) async {
    if (!forceRefresh && addresses.isNotEmpty) return;

    isLoading.value = true;
    try {
      final result = await _repository.getAddresses();
      PrintLog.printLog('AddressController: loaded ${result.length} addresses');
      addresses.assignAll(result);
      if (addresses.isNotEmpty) {
        final primary = addresses.firstWhereOrNull((a) => a.isPrimary);
        selectedAddress.value = primary ?? addresses.first;
      }
    } catch (e) {
      PrintLog.printLog('AddressController.loadAddresses error: $e');
      AppToast.error(title: 'Error', message: 'Failed to load addresses');
    } finally {
      isLoading.value = false;
    }
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  void addAddress(AddressModel address) {
    addresses.add(address);
    selectedAddress.value = address;
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _repository.deleteAddress(id);
      addresses.removeWhere((a) => a.id == id);
      if (selectedAddress.value?.id == id) {
        selectedAddress.value = addresses.firstOrNull;
      }
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to delete address');
    }
  }
}
