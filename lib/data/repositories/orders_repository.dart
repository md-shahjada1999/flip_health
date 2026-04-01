import 'package:flip_health/controllers/orders%20controllers/orders_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';

class OrdersRepository {
  final ApiService apiService;

  OrdersRepository({required this.apiService});

  Future<List<Order>> getOrders() async {
    final now = DateTime.now();
    return [
      Order(
        id: 'ORD-10234',
        type: 'Consultation',
        patientName: 'Kalyan',
        date: now.subtract(const Duration(days: 2)),
        amount: 500,
        status: 'Completed',
        vendorName: 'Apollo Hospital',
        items: const [
          OrderItem(name: 'General Physician Consultation', price: 500),
        ],
      ),
      Order(
        id: 'ORD-10235',
        type: 'Lab Test',
        patientName: 'Priya',
        date: now.subtract(const Duration(days: 5)),
        amount: 1200,
        status: 'Completed',
        vendorName: 'Neuberg Diagnostics',
        items: const [
          OrderItem(name: 'Complete Blood Count', price: 400),
          OrderItem(name: 'Thyroid Profile', price: 800),
        ],
      ),
      Order(
        id: 'ORD-10236',
        type: 'Pharmacy',
        patientName: 'Kalyan',
        date: now.subtract(const Duration(days: 1)),
        amount: 340,
        status: 'Processing',
        vendorName: 'Flip Health Pharmacy',
        items: const [
          OrderItem(name: 'Paracetamol 500mg x 10', price: 45),
          OrderItem(name: 'Azithromycin 250mg x 6', price: 180),
          OrderItem(name: 'Vitamin D3 Capsules x 30', price: 115),
        ],
      ),
      Order(
        id: 'ORD-10237',
        type: 'Dental',
        patientName: 'Rahul',
        date: now.subtract(const Duration(days: 8)),
        amount: 0,
        status: 'Completed',
        vendorName: 'Smile Dental Clinic',
        items: const [
          OrderItem(name: 'Dental Comprehensive Checkup', price: 0),
        ],
      ),
      Order(
        id: 'ORD-10238',
        type: 'Vision',
        patientName: 'Kalyan',
        date: now.subtract(const Duration(days: 3)),
        amount: 0,
        status: 'Cancelled',
        vendorName: 'Lenskart Vision Center',
        items: const [OrderItem(name: 'Eye Checkup', price: 0)],
      ),
      Order(
        id: 'ORD-10239',
        type: 'Vaccine',
        patientName: 'Priya',
        date: now.subtract(const Duration(days: 10)),
        amount: 0,
        status: 'Completed',
        vendorName: 'Apollo Vaccination Center',
        items: const [
          OrderItem(name: 'Flu Vaccine', price: 0),
          OrderItem(name: 'Hepatitis B', price: 0),
        ],
      ),
      Order(
        id: 'ORD-10240',
        type: 'Gym',
        patientName: 'Kalyan',
        date: now.subtract(const Duration(days: 15)),
        amount: 11000,
        status: 'Completed',
        vendorName: 'Cult.fit Jubilee Hills',
        items: const [
          OrderItem(name: 'Cult ELITE Membership - 12 Months', price: 11000),
        ],
      ),
      Order(
        id: 'ORD-10241',
        type: 'Mental Wellness',
        patientName: 'Kalyan',
        date: now.subtract(const Duration(days: 4)),
        amount: 0,
        status: 'Pending',
        vendorName: 'Flip Health Wellness',
        items: const [
          OrderItem(name: 'Counselling Session', price: 0),
        ],
      ),
      Order(
        id: 'ORD-10242',
        type: 'Consultation',
        patientName: 'Rahul',
        date: now.subtract(const Duration(days: 12)),
        amount: 800,
        status: 'Completed',
        vendorName: 'MaxCure Hospital',
        items: const [
          OrderItem(name: 'Dermatologist Consultation', price: 800),
        ],
      ),
      Order(
        id: 'ORD-10243',
        type: 'Pharmacy',
        patientName: 'Priya',
        date: now,
        amount: 560,
        status: 'Pending',
        vendorName: 'Flip Health Pharmacy',
        items: const [
          OrderItem(name: 'Metformin 500mg x 30', price: 120),
          OrderItem(name: 'Atorvastatin 10mg x 30', price: 210),
          OrderItem(name: 'Crocin Advance x 15', price: 90),
          OrderItem(name: 'ORS Sachets x 10', price: 140),
        ],
      ),
      Order(
        id: 'ORD-10244',
        type: 'Nutrition',
        patientName: 'Kalyan',
        date: now.subtract(const Duration(days: 6)),
        amount: 0,
        status: 'Completed',
        vendorName: 'Flip Health Nutrition',
        items: const [OrderItem(name: 'Diet Consultation', price: 0)],
      ),
      Order(
        id: 'ORD-10245',
        type: 'Lab Test',
        patientName: 'Kalyan',
        date: now.subtract(const Duration(days: 20)),
        amount: 2500,
        status: 'Completed',
        vendorName: 'Orange Health Labs',
        items: const [
          OrderItem(name: 'Annual Health Checkup Package', price: 2500),
        ],
      ),
    ];
  }
}
