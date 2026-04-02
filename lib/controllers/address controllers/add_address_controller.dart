import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/core/services/google%20places/google_places_service.dart';
import 'package:flip_health/core/services/google%20places/place_prediction.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/address_repository.dart';

class AddAddressController extends GetxController {
  final AddressRepository _repository;

  AddAddressController({required AddressRepository repository})
      : _repository = repository;

  // ---- Map state ----
  final Rx<LatLng> selectedLatLng = const LatLng(17.4401, 78.3489).obs;
  GoogleMapController? mapController;

  // ---- Reactive form values (UI reads these via Obx) ----
  final RxString addressLine1 = ''.obs;
  final RxString pincode = ''.obs;
  final RxString city = ''.obs;
  final RxString state = ''.obs;
  final RxString landmark = ''.obs;
  final RxString addressName = ''.obs;
  final RxString selectedTag = 'HOME'.obs;

  // Composite display address (for the preview card)
  final RxString currentAddress = ''.obs;

  // ---- Text editing controllers (for TextFormField binding) ----
  final TextEditingController addressLine1Ctrl = TextEditingController();
  final TextEditingController pincodeCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController landmarkCtrl = TextEditingController();
  final TextEditingController addressNameCtrl = TextEditingController();

  // ---- Search state ----
  final TextEditingController searchTextController = TextEditingController();
  final RxList<PlacePrediction> searchResults = <PlacePrediction>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  Timer? _debounce;

  // ---- Enable/disable flags ----
  final RxBool isCityEnabled = true.obs;
  final RxBool isStateEnabled = true.obs;

  // ---- Loading ----
  final RxBool isLoadingLocation = false.obs;
  final RxBool isReverseGeocoding = false.obs;
  final RxBool isSaving = false.obs;

  // ---- Tags ----
  static const List<String> addressTags = ['HOME', 'WORK', 'OTHER'];

  // ---- Indian states ----
  static const List<String> indianStates = [
    'Andaman and Nicobar Islands',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chandigarh',
    'Chhattisgarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu and Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Ladakh',
    'Lakshadweep',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Puducherry',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  final RxList<String> filteredStates = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredStates.assignAll(indianStates);

    // Sync TextEditingController → Rx observable on every keystroke
    addressLine1Ctrl.addListener(() => addressLine1.value = addressLine1Ctrl.text);
    pincodeCtrl.addListener(() => pincode.value = pincodeCtrl.text);
    cityCtrl.addListener(() => city.value = cityCtrl.text);
    landmarkCtrl.addListener(() => landmark.value = landmarkCtrl.text);
    addressNameCtrl.addListener(() => addressName.value = addressNameCtrl.text);

    _getCurrentLocation();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    addressLine1Ctrl.dispose();
    pincodeCtrl.dispose();
    cityCtrl.dispose();
    landmarkCtrl.dispose();
    addressNameCtrl.dispose();
    _debounce?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // ---------------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------------

  Future<void> _getCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        isLoadingLocation.value = false;
        _reverseGeocode(selectedLatLng.value);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          isLoadingLocation.value = false;
          _reverseGeocode(selectedLatLng.value);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      selectedLatLng.value = latLng;
      _animateToLatLng(latLng);
      _reverseGeocode(latLng);
    } catch (_) {
      _reverseGeocode(selectedLatLng.value);
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> useCurrentLocation() async => _getCurrentLocation();

  // ---------------------------------------------------------------------------
  // Map Interaction
  // ---------------------------------------------------------------------------

  void onCameraIdle(LatLng center) {
    if ((center.latitude - selectedLatLng.value.latitude).abs() > 0.00001 ||
        (center.longitude - selectedLatLng.value.longitude).abs() > 0.00001) {
      selectedLatLng.value = center;
      _reverseGeocode(center);
    }
  }

  void _animateToLatLng(LatLng latLng) {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
  }

  // ---------------------------------------------------------------------------
  // Reverse Geocoding — fills reactive Rx + TextEditingControllers
  // ---------------------------------------------------------------------------

  Future<void> _reverseGeocode(LatLng latLng) async {
    isReverseGeocoding.value = true;
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.name != null && p.name!.isNotEmpty) p.name!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null &&
              p.administrativeArea!.isNotEmpty)
            p.administrativeArea!,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode!,
        ];

        currentAddress.value = parts.join(', ');

        _setField(addressLine1Ctrl, addressLine1, p.name ?? '');
        _setField(pincodeCtrl, pincode, p.postalCode ?? '');
        _setField(cityCtrl, city, p.locality ?? '');
        state.value = p.administrativeArea ?? '';
      }
    } catch (_) {
      currentAddress.value = 'Unable to determine address';
    } finally {
      isReverseGeocoding.value = false;
    }
  }

  /// Sets both the TextEditingController text and the Rx observable in one call.
  void _setField(TextEditingController ctrl, RxString rx, String value) {
    ctrl.text = value;
    rx.value = value;
  }

  // ---------------------------------------------------------------------------
  // Places Search
  // ---------------------------------------------------------------------------

  void onSearchChanged(String query) {
    _debounce?.cancel();
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    isSearching.value = true;
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    final results = await GooglePlacesService.instance.searchPlaces(query);
    searchResults.value = results;
    isSearching.value = false;
  }

  Future<void> selectSearchResult(PlacePrediction prediction) async {
    searchTextController.text = prediction.mainText;
    searchResults.clear();
    FocusManager.instance.primaryFocus?.unfocus();

    final detail =
        await GooglePlacesService.instance.getPlaceDetails(prediction.placeId);
    if (detail != null) {
      final latLng = LatLng(detail.latitude, detail.longitude);
      selectedLatLng.value = latLng;
      currentAddress.value = detail.formattedAddress;
      city.value = detail.city ?? '';
      cityCtrl.text = detail.city ?? '';
      pincode.value = detail.pincode ?? '';
      pincodeCtrl.text = detail.pincode ?? '';
      _animateToLatLng(latLng);
    }
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  // ---------------------------------------------------------------------------
  // State selection
  // ---------------------------------------------------------------------------

  void filterStates(String query) {
    if (query.isEmpty) {
      filteredStates.assignAll(indianStates);
    } else {
      filteredStates.assignAll(
        indianStates
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  void selectState(String value) {
    state.value = value;
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  String? get validationMessage {
    if (addressLine1.value.trim().isEmpty) return 'Please enter the address';
    if (pincode.value.trim().length != 6) {
      return 'Please enter a valid 6-digit pincode';
    }
    if (city.value.trim().isEmpty) return 'Please enter city';
    if (selectedTag.value.isEmpty) return 'Please select address type';
    if (selectedTag.value == 'OTHER' && addressName.value.trim().isEmpty) {
      return 'Please enter name for address';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> saveAddress() async {
    final msg = validationMessage;
    if (msg != null) {
      Get.snackbar('Missing Info', msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50);
      return;
    }

    isSaving.value = true;
    try {
      final tag = selectedTag.value.toUpperCase();
      final name = tag == 'OTHER' ? addressName.value.trim() : tag;

      final locationStr =
          '${selectedLatLng.value.latitude},${selectedLatLng.value.longitude}';

      final body = {
        'line_1': addressLine1.value.trim(),
        'line_2': '',
        'landmark': landmark.value.trim(),
        'area': '',
        'city': city.value.trim(),
        'state': state.value.trim(),
        'pincode': pincode.value.trim(),
        'location': locationStr,
        'tag': tag,
        'name': name,
      };

      PrintLog.printLog('AddAddressController.saveAddress body: $body');

      final savedAddress = await _repository.addAddress(data: body);
      final addressController = Get.find<AddressController>();
      addressController.addAddress(savedAddress);

      Get.back(); // pop form
      Get.back(); // pop map picker
    } catch (e) {
      PrintLog.printLog('AddAddressController.saveAddress error: $e');
      Get.snackbar('Error', 'Failed to save address. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
}
