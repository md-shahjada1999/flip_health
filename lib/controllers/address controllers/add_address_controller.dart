import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/core/services/google%20places/google_places_service.dart';
import 'package:flip_health/core/services/google%20places/place_prediction.dart';
import 'package:flip_health/data/repositories/address_repository.dart';
import 'package:flip_health/model/address%20models/address_model.dart';

class AddAddressController extends GetxController {
  final AddressRepository _repository;

  AddAddressController({required AddressRepository repository})
      : _repository = repository;
  // Map state
  final Rx<LatLng> selectedLatLng = const LatLng(17.4401, 78.3489).obs;
  GoogleMapController? mapController;

  // Reverse-geocoded address info
  final RxString currentAddress = ''.obs;
  final RxString currentCity = ''.obs;
  final RxString currentPincode = ''.obs;

  // Search state
  final TextEditingController searchTextController = TextEditingController();
  final RxList<PlacePrediction> searchResults = <PlacePrediction>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  Timer? _debounce;

  // Form state
  final TextEditingController houseController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final Rx<AddressType> selectedType = AddressType.home.obs;

  // Loading states
  final RxBool isLoadingLocation = false.obs;
  final RxBool isReverseGeocoding = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    houseController.dispose();
    landmarkController.dispose();
    _debounce?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // --- Location ---

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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
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

  Future<void> useCurrentLocation() async {
    await _getCurrentLocation();
  }

  // --- Map Interaction ---

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

  // --- Reverse Geocoding ---

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
        currentCity.value = p.locality ?? '';
        currentPincode.value = p.postalCode ?? '';
      }
    } catch (_) {
      currentAddress.value = 'Unable to determine address';
    } finally {
      isReverseGeocoding.value = false;
    }
  }

  // --- Places Search ---

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
      currentCity.value = detail.city ?? '';
      currentPincode.value = detail.pincode ?? '';
      _animateToLatLng(latLng);
    }
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  // --- Save ---

  String get _labelText {
    switch (selectedType.value) {
      case AddressType.home:
        return 'Home';
      case AddressType.office:
        return 'Office';
      case AddressType.other:
        return 'Other';
    }
  }

  Future<void> saveAddress() async {
    isSaving.value = true;
    try {
      final houseNum = houseController.text.trim();
      final landmark = landmarkController.text.trim();

      String fullAddr = currentAddress.value;
      if (houseNum.isNotEmpty) {
        fullAddr = '$houseNum, $fullAddr';
      }

      final newAddress = AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: _labelText,
        fullAddress: fullAddr,
        houseNumber: houseNum.isEmpty ? null : houseNum,
        landmark: landmark.isEmpty ? null : landmark,
        pincode: currentPincode.value.isEmpty ? null : currentPincode.value,
        city: currentCity.value.isEmpty ? null : currentCity.value,
        latitude: selectedLatLng.value.latitude,
        longitude: selectedLatLng.value.longitude,
        type: selectedType.value,
      );

      await _repository.saveAddress(address: newAddress);

      final addressController = Get.find<AddressController>();
      addressController.addAddress(newAddress);
      addressController.selectAddress(newAddress);

      Get.back(); // pop form
      Get.back(); // pop map picker
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save address. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
