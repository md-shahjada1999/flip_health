import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/gym_repository.dart';
import 'package:flip_health/routes/app_routes.dart';

class MembershipPlan {
  final String id;
  final String tier;
  final String type;
  final int months;
  final double originalPrice;
  final double discountedPrice;
  final Color tierColor;
  final String backgroundImage;
  final List<String> benefits;

  const MembershipPlan({
    required this.id,
    required this.tier,
    required this.type,
    required this.months,
    required this.originalPrice,
    required this.discountedPrice,
    required this.tierColor,
    required this.backgroundImage,
    required this.benefits,
  });
}

class GymCenter {
  final String id;
  final String name;
  final String address;
  final String city;
  final String distance;

  const GymCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.distance,
  });
}

class GymController extends GetxController {
  final GymRepository _repository;

  GymController({required GymRepository repository}) : _repository = repository;

  final isLoading = false.obs;

  // Membership plans
  final membershipPlans = <MembershipPlan>[].obs;
  final selectedPlanIndex = (-1).obs;
  final expandedPlanIndex = (-1).obs;

  // City & center
  final cities = <String>[].obs;
  final selectedCity = ''.obs;
  final centers = <GymCenter>[].obs;
  final selectedCenterId = ''.obs;
  final centersLoading = false.obs;

  // Overview
  final termsAccepted = false.obs;

  MembershipPlan? get selectedPlan {
    if (selectedPlanIndex.value < 0 || selectedPlanIndex.value >= membershipPlans.length) return null;
    return membershipPlans[selectedPlanIndex.value];
  }

  GymCenter? get selectedCenter {
    final idx = centers.indexWhere((c) => c.id == selectedCenterId.value);
    return idx != -1 ? centers[idx] : null;
  }

  MemberController get _mc => Get.find<MemberController>();

  double get totalPrice => _mc.selectedMembers.length * (selectedPlan?.discountedPrice ?? 0);

  double get gstAmount => totalPrice * 0.18;

  double get grandTotal => totalPrice + gstAmount;

  @override
  void onInit() {
    super.onInit();
    _loadPlans();
    _loadCities();
  }

  Future<void> _loadPlans() async {
    try {
      membershipPlans.value = await _repository.getMembershipPlans();
    } catch (_) {}
  }

  Future<void> _loadCities() async {
    try {
      cities.value = await _repository.getCities();
    } catch (_) {}
  }

  void selectPlan(int index) => selectedPlanIndex.value = index;

  void toggleExpanded(int index) {
    expandedPlanIndex.value = expandedPlanIndex.value == index ? -1 : index;
  }

  bool isExpanded(int index) => expandedPlanIndex.value == index;

  void selectCity(String city) {
    selectedCity.value = city;
    selectedCenterId.value = '';
    _loadCenters(city);
  }

  Future<void> _loadCenters(String city) async {
    centersLoading.value = true;
    try {
      centers.value = await _repository.getCenters(city: city);
    } catch (_) {
    } finally {
      centersLoading.value = false;
    }
  }

  void selectCenter(String id) => selectedCenterId.value = id;

  void toggleTerms() => termsAccepted.value = !termsAccepted.value;

  void confirmBooking() {
    Get.offAllNamed(AppRoutes.dashboard);
  }
}
