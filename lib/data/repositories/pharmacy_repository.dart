import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/pharmacy%20models/flip_health_prescription_model.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_model.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_order_invoice_model.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_order_response.dart';

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

bool _ok(dynamic status) {
  if (status == true) return true;
  if (status == 1) return true;
  final s = status?.toString().toLowerCase();
  return s == 'true' || s == '1';
}

/// Same success rules as [ConsultationOrderRepository._invoiceDetailOk].
bool _invoiceOk(Map<String, dynamic> root) {
  if (_ok(root['status'])) return true;
  if (root['status'] == null && root['data'] is Map) return true;
  return false;
}

class PharmacyRepository {
  final ApiService apiService;

  PharmacyRepository({required this.apiService});

  Future<List<FlipHealthPrescription>> getFlipHealthPrescriptions() async {
    try {
      final response = await apiService.get(ApiUrl.PRESCRIPTIONS);
      PrintLog.printLog(
          'PharmacyRepository.getFlipHealthPrescriptions status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ??
                  'Failed to fetch prescriptions')
              : 'Failed to fetch prescriptions',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is Map<String, dynamic>) {
        final list = root['prescriptions'] as List<dynamic>? ?? [];
        return list
            .map((e) =>
                FlipHealthPrescription.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog(
          'PharmacyRepository.getFlipHealthPrescriptions error: $e');
      throw AppException(message: 'Failed to fetch prescriptions: $e');
    }
  }

  Future<FlipHealthPrescription> getPrescriptionById(String id) async {
    try {
      final response = await apiService.get('${ApiUrl.PRESCRIPTIONS}/$id');
      PrintLog.printLog(
          'PharmacyRepository.getPrescriptionById status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ??
                  'Failed to fetch prescription')
              : 'Failed to fetch prescription',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is Map<String, dynamic> &&
          root['prescription'] is Map<String, dynamic>) {
        return FlipHealthPrescription.fromJson(root['prescription']);
      }

      throw AppException(message: 'Unexpected prescription response format');
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('PharmacyRepository.getPrescriptionById error: $e');
      throw AppException(message: 'Failed to fetch prescription: $e');
    }
  }

  /// Place a medicine order. All 3 flows (upload, flip health, OTC) use this.
  Future<PharmacyOrderResponse> placeOrder({
    required String addressId,
    required int patientId,
    required List<Map<String, dynamic>> prescriptions,
  }) async {
    try {
      final body = {
        'address_id': addressId,
        'patient_id': patientId,
        'prescriptions': prescriptions,
      };

      final response = await apiService.post(ApiUrl.MEDICINE_ORDER, data: body);
      PrintLog.printLog(
          'PharmacyRepository.placeOrder status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ??
                  'Failed to place order')
              : 'Failed to place order',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is Map<String, dynamic>) {
        return PharmacyOrderResponse.fromJson(root);
      }

      throw AppException(message: 'Unexpected order response format');
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('PharmacyRepository.placeOrder error: $e');
      throw AppException(message: 'Failed to place order: $e');
    }
  }

  /// Same as [ConsultationOrderRepository.getInvoiceDetail] — full invoice for pharmacy orders.
  Future<PharmacyOrderInvoice> getInvoiceDetail(String id) async {
    try {
      final Response r = await apiService.get(ApiUrl.invoiceById(id));
      final raw = r.data;
      if (raw is! Map) {
        throw AppException(message: 'Invalid invoice response');
      }
      final root = _asMap(raw);
      if (!_invoiceOk(root)) {
        throw AppException(
          message: root['message']?.toString() ?? 'Failed to load order',
        );
      }
      final data = root['data'];
      if (data is Map) {
        return PharmacyOrderInvoice.fromJson(Map<String, dynamic>.from(data));
      }
      throw AppException(message: 'Invalid invoice data');
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('PharmacyRepository.getInvoiceDetail: $e\n$st');
      throw AppException(message: 'Could not load pharmacy order details.');
    }
  }

  /// `PATCH /patient/medicine/order/payment/{invoiceId}?...` — quote or confirm payment.
  Future<Map<String, dynamic>> patchMedicineOrderPayment({
    required String invoiceId,
    required bool confirm,
    required bool useWallet,
  }) async {
    final q = confirm
        ? '?status=confirm&useWallet=$useWallet'
        : '?useWallet=$useWallet';
    final Response r = await apiService.patch(
      '${ApiUrl.MEDICINE_ORDER_PAYMENT}/$invoiceId$q',
      data: <String, dynamic>{},
    );
    return _unwrapMap(r.data);
  }

  /// `PATCH /patient/medicine/order/cancel/{id}`
  Future<void> cancelMedicineOrder(
    String invoiceId,
    Map<String, dynamic> body,
  ) async {
    await apiService.patch(
      '${ApiUrl.MEDICINE_ORDER_CANCEL}/$invoiceId',
      data: body,
    );
  }

  /// `PATCH /patient/medicine/order/confirm/{id}`
  Future<void> confirmMedicineOrder(
    String invoiceId,
    Map<String, dynamic> body,
  ) async {
    await apiService.patch(
      '${ApiUrl.MEDICINE_ORDER_CONFIRM}/$invoiceId',
      data: body,
    );
  }

  /// Razorpay success — `PATCH /patient/medicine/order/paymentverify`
  Future<Map<String, dynamic>> verifyMedicineOrderPayment(
    Map<String, dynamic> body,
  ) async {
    final Response r = await apiService.patch(
      ApiUrl.MEDICINE_ORDER_PAYMENT_VERIFY,
      data: body,
    );
    return _unwrapMap(r.data);
  }

  /// Lab collection sub-order — confirm center after reschedule/reassign
  /// (patient_app `PATCH …/lab/order/confirm/{id}`).
  Future<Map<String, dynamic>> confirmLabSubOrder(String subOrderId) async {
    if (subOrderId.isEmpty) {
      throw AppException(message: 'Invalid order id');
    }
    try {
      final Response r = await apiService.patch(
        '${ApiUrl.LAB_SUB_ORDER_CONFIRM}/$subOrderId',
        data: <String, dynamic>{},
      );
      if (r.statusCode != 200 || r.data is! Map) {
        throw AppException(
          message: 'Could not confirm center details',
          statusCode: r.statusCode,
        );
      }
      final root = r.data as Map<String, dynamic>;
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Confirmation failed',
        );
      }
      return root;
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('confirmLabSubOrder error: $e');
      throw AppException(message: 'Confirmation failed: $e');
    }
  }

  /// `PATCH /patient/lab/order/payment/{invoiceInfoId}?useWallet=&status=confirm?`
  /// Returns payment quote (`confirm: false`) or finalize result (`confirm: true`).
  Future<Map<String, dynamic>> patchLabOrderPayment({
    required String invoiceInfoId,
    required bool confirm,
    required bool useWallet,
  }) async {
    if (invoiceInfoId.isEmpty) {
      throw AppException(message: 'Invalid order id');
    }
    final q = confirm
        ? '?status=confirm&useWallet=$useWallet'
        : '?useWallet=$useWallet';
    final Response r = await apiService.patch(
      '${ApiUrl.LAB_ORDER_PAYMENT}/$invoiceInfoId$q',
      data: <String, dynamic>{},
    );
    if (r.statusCode != 200 || r.data is! Map) {
      throw AppException(
        message: 'Could not process lab payment',
        statusCode: r.statusCode,
      );
    }
    final root = r.data as Map<String, dynamic>;
    if (root['status'] == false) {
      throw AppException(
        message: root['message']?.toString() ?? 'Payment failed',
      );
    }
    return root;
  }

  /// `PATCH /patient/lab/cancel/{invoiceInfoId}`
  Future<void> cancelLabOrder(
    String invoiceInfoId,
    Map<String, dynamic> body,
  ) async {
    if (invoiceInfoId.isEmpty) {
      throw AppException(message: 'Invalid order id');
    }
    final Response r = await apiService.patch(
      '${ApiUrl.LAB_ORDER_CANCEL}/$invoiceInfoId',
      data: body,
    );
    if (r.statusCode != 200 || r.data is! Map) {
      throw AppException(
        message: 'Could not cancel lab order',
        statusCode: r.statusCode,
      );
    }
    final root = r.data as Map<String, dynamic>;
    if (root['status'] == false) {
      throw AppException(
        message: root['message']?.toString() ?? 'Cancellation failed',
      );
    }
  }

  /// `PATCH /patient/lab/order/reschedule/{subOrderId}`
  Future<void> rescheduleLabSubOrder({
    required String subOrderId,
    required Map<String, dynamic> body,
  }) async {
    if (subOrderId.isEmpty) {
      throw AppException(message: 'Invalid sub-order id');
    }
    final Response r = await apiService.patch(
      '${ApiUrl.LAB_ORDER_RESCHEDULE}/$subOrderId',
      data: body,
    );
    if (r.statusCode != 200 || r.data is! Map) {
      throw AppException(
        message: 'Could not reschedule booking',
        statusCode: r.statusCode,
      );
    }
    final root = r.data as Map<String, dynamic>;
    if (root['status'] == false) {
      throw AppException(
        message: root['message']?.toString() ?? 'Reschedule failed',
      );
    }
  }

  /// Uses diagnostics slots endpoint for lab-detail reschedule.
  Future<LabSlotsResponse> getLabSlotsForReschedule({
    required String addressId,
    required String date,
    required String vendorCode,
    required String category,
  }) async {
    final response = await apiService.post(
      ApiUrl.DIAGNOSTICS_SLOTS,
      data: {
        'address_id': addressId,
        'date': date,
        'vendor_code': vendorCode,
        'package': 'special',
        'category': category,
      },
    );
    if (response.statusCode != 200 || response.data is! Map) {
      throw AppException(
        message: 'Failed to fetch slots',
        statusCode: response.statusCode,
      );
    }
    final root = response.data as Map<String, dynamic>;
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    return LabSlotsResponse.fromJson(data);
  }

  Map<String, dynamic> _unwrapMap(dynamic raw) {
    if (raw is! Map) return {};
    final m = Map<String, dynamic>.from(raw);
    final inner = m['data'];
    if (inner is Map) return Map<String, dynamic>.from(inner);
    return m;
  }

  List<FAQItem> getFAQs() {
    return [
      FAQItem(
        question: 'Do I need to order all the medicine in the prescription?',
        answer:
            'No, you don\'t need to order all medicines. Our medicine partner will contact you to confirm the required medicines.',
      ),
      FAQItem(
        question: 'Can I change the quantity of medicines?',
        answer:
            'Yes, our medicine partner will contact you to confirm the medicines and quantities before delivery.',
      ),
      FAQItem(
        question: 'How do I know the price of medicines?',
        answer:
            'Once the order is confirmed, our medicine partner will share the price details with you before delivery.',
      ),
    ];
  }
}
