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
  final RxBool isActionLoading = false.obs;

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
    isActionLoading.value = true;
    try {
      await _repository.deleteAddress(id);
      addresses.removeWhere((a) => a.id == id);
      if (selectedAddress.value?.id == id) {
        selectedAddress.value = addresses.firstOrNull;
      }
      AppToast.success(title: 'Deleted', message: 'Address removed');
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to delete address');
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateAddress({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    isActionLoading.value = true;
    try {
      final updated = await _repository.updateAddress(id: id, data: data);
      final idx = addresses.indexWhere((a) => a.id == id);
      if (idx != -1) {
        addresses[idx] = updated;
      } else {
        addresses.add(updated);
      }
      if (selectedAddress.value?.id == id) {
        selectedAddress.value = updated;
      }
      AppToast.success(title: 'Updated', message: 'Address updated');
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to update address');
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> setPrimaryAddress(String id) async {
    isActionLoading.value = true;
    try {
      await _repository.setPrimaryAddress(id);
      final updatedList = addresses.map((a) {
        if (a.id == id) {
          return AddressModel(
            id: a.id, name: a.name, tag: a.tag, line1: a.line1,
            line2: a.line2, landmark: a.landmark, area: a.area,
            city: a.city, state: a.state, pincode: a.pincode,
            location: a.location, isPrimary: true,
            userId: a.userId, userType: a.userType,
            createdAt: a.createdAt, updatedAt: a.updatedAt,
          );
        }
        return AddressModel(
          id: a.id, name: a.name, tag: a.tag, line1: a.line1,
          line2: a.line2, landmark: a.landmark, area: a.area,
          city: a.city, state: a.state, pincode: a.pincode,
          location: a.location, isPrimary: false,
          userId: a.userId, userType: a.userType,
          createdAt: a.createdAt, updatedAt: a.updatedAt,
        );
      }).toList();
      addresses.assignAll(updatedList);
      selectedAddress.value = updatedList.firstWhereOrNull((a) => a.id == id);
      AppToast.success(title: 'Primary', message: 'Primary address updated');
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to set primary address');
    } finally {
      isActionLoading.value = false;
    }
  }
}
