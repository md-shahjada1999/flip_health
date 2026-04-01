import 'package:get/get.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/data/repositories/orders_repository.dart';

class OrderItem {
  final String name;
  final double price;

  const OrderItem({required this.name, required this.price});
}

class Order {
  final String id;
  final String type;
  final String patientName;
  final DateTime date;
  final double amount;
  final String status;
  final String vendorName;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.type,
    required this.patientName,
    required this.date,
    required this.amount,
    required this.status,
    required this.vendorName,
    required this.items,
  });
}

class OrdersController extends GetxController {
  final OrdersRepository _repository;

  OrdersController({required OrdersRepository repository})
      : _repository = repository;

  final orders = <Order>[].obs;
  final filteredOrders = <Order>[].obs;
  final selectedFilter = 'All'.obs;
  final isLoading = false.obs;
  final selectedOrder = Rxn<Order>();

  static const filterCategories = [
    'All',
    'Consultation',
    'Lab Test',
    'Pharmacy',
    'Dental',
    'Vision',
    'Vaccine',
    'Gym',
    'Mental Wellness',
    'Nutrition',
  ];

  static const _iconMap = <String, String>{
    'Consultation': AppString.kIconConsultation,
    'Lab Test': AppString.kIconDiagnostics,
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
    _loadOrders();
  }

  void filterOrders(String category) {
    selectedFilter.value = category;
    if (category == 'All') {
      filteredOrders.assignAll(orders);
    } else {
      filteredOrders.assignAll(
        orders.where((o) => o.type == category).toList(),
      );
    }
  }

  void selectOrder(Order order) {
    selectedOrder.value = order;
  }

  Future<void> _loadOrders() async {
    isLoading.value = true;
    try {
      orders.value = await _repository.getOrders();
      filteredOrders.assignAll(orders);
    } finally {
      isLoading.value = false;
    }
  }
}
