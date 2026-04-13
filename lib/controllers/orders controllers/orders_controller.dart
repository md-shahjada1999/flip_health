import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/orders_repository.dart';
import 'package:flip_health/model/order_models.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final OrdersRepository _repository;

  OrdersController({required OrdersRepository repository})
      : _repository = repository;

  /// Single list for the current filter (server-side filtered). UI binds to this only.
  final orders = <Order>[].obs;
  final selectedFilter = 'All'.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final selectedOrder = Rxn<Order>();

  int _page = 1;

  final ScrollController scrollController = ScrollController();

  static const filterCategories = [
    'All',
    'Consultation',
    'Lab Test',
    'Subscriptions',
    'Pharmacy',
    'Dental',
    'Vision',
    'Vaccine',
    'Gym',
    'Mental Wellness',
    'Nutrition',
  ];

  static const _categoryToApiType = {
    'Consultation': 'CONSULTATION',
    'Lab Test': 'LABTEST',
    'Subscriptions': 'PLAN',
    'Pharmacy': 'PHARMACY',
    'Dental': 'DENTAL',
    'Vision': 'VISION',
    'Vaccine': 'VACCINE',
    'Gym': 'GYM',
    'Mental Wellness': 'MENTALWELLNESS',
    'Nutrition': 'NUTRITION',
  };

  static const _iconMap = <String, String>{
    'Consultation': AppString.kIconConsultation,
    'Lab Test': AppString.kIconDiagnostics,
    'Subscriptions': AppString.kIconSubscriptions,
    'Pharmacy': AppString.kIconPrescribedPharmacy,
    'Dental': AppString.kIconDental,
    'Vision': AppString.kIconVision,
    'Vaccine': AppString.kIconVaccination,
    'Gym': AppString.kIconGymFitness,
    'Mental Wellness': AppString.kIconMentalWellness,
    'Nutrition': AppString.kIconNutrition,
    'Chronic': AppString.kIconChronicManagement,
  };

  String iconForType(String type) =>
      _iconMap[type] ?? AppString.kIconOrdersServices;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _loadOrders(reset: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    const threshold = 120.0;
    final atEnd = pos.maxScrollExtent <= 0
        ? true
        : pos.pixels >= pos.maxScrollExtent - threshold;
    if (atEnd) {
      loadMoreIfNeeded();
    }
  }

  void _scheduleLoadMoreIfShortViewport() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final pos = scrollController.position;
      if (pos.maxScrollExtent <= 0) {
        loadMoreIfNeeded();
      }
    });
  }

  String _apiTypeForSelectedFilter() {
    final cat = selectedFilter.value;
    if (cat == 'All') return '';
    return _categoryToApiType[cat] ?? '';
  }

  Future<void> refreshOrders() => _loadOrders(reset: true);

  Future<void> loadMoreIfNeeded() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) return;
    await _loadOrders(reset: false);
  }

  Future<void> _loadOrders({required bool reset}) async {
    if (reset) {
      _page = 1;
      hasMore.value = true;
    } else if (!hasMore.value) {
      return;
    }

    if (reset) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final type = _apiTypeForSelectedFilter();
      final result = await _repository.getOrders(
        page: _page,
        typeQuery: type,
      );

      if (reset) {
        orders.assignAll(result.orders);
      } else {
        orders.addAll(result.orders);
      }

      hasMore.value = result.hasMore;
      if (result.hasMore) {
        _page++;
      }

      orders.refresh();
    } on AppException catch (e) {
      if (reset) {
        orders.clear();
      }
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      if (reset) {
        orders.clear();
      }
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      if (hasMore.value && orders.isNotEmpty) {
        _scheduleLoadMoreIfShortViewport();
      }
    }
  }

  Future<void> filterOrders(String category) async {
    selectedFilter.value = category;
    await _loadOrders(reset: true);
  }

  void selectOrder(Order order) {
    selectedOrder.value = order;
  }
}
