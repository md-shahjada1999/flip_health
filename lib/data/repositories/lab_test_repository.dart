import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';

class LabTestRepository {
  final ApiService apiService;
  LabTestRepository({required this.apiService});

  // -----------------------------------------------------------------------
  // Lab tests / packages (paginated, searchable)
  // -----------------------------------------------------------------------

  Future<List<LabTest>> getLabTests({
    required String addressId,
    String name = '',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'loc': addressId,
        'page': page,
        'limit': limit,
      };
      if (name.isNotEmpty) params['name'] = name;

      final response = await apiService.get(
        ApiUrl.DIAGNOSTICS_PACKAGES,
        queryParameters: params,
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch lab tests',
          statusCode: response.statusCode,
        );
      }

      final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
      return list.map((e) => LabTest.fromJson(e as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getLabTests error: $e');
      throw AppException(message: 'Failed to load lab tests: $e');
    }
  }

  // -----------------------------------------------------------------------
  // Vendors
  // -----------------------------------------------------------------------

  Future<List<LabVendor>> getVendors({required String addressId}) async {
    try {
      final response = await apiService.post(
        ApiUrl.DIAGNOSTICS_VENDORS,
        data: {'address_id': addressId},
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch vendors',
          statusCode: response.statusCode,
        );
      }

      final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
      return list.map((e) => LabVendor.fromJson(e as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getVendors error: $e');
      throw AppException(message: 'Failed to load vendors: $e');
    }
  }

  // -----------------------------------------------------------------------
  // Slots
  // -----------------------------------------------------------------------

  Future<LabSlotsResponse> getSlots({
    required String addressId,
    required String date,
    required String vendorCode,
    String package = 'test',
  }) async {
    try {
      final response = await apiService.post(
        ApiUrl.DIAGNOSTICS_SLOTS,
        data: {
          'address_id': addressId,
          'date': date,
          'vendor_code': vendorCode,
          'package': package,
        },
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch slots',
          statusCode: response.statusCode,
        );
      }

      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      return LabSlotsResponse.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getSlots error: $e');
      throw AppException(message: 'Failed to load slots: $e');
    }
  }

  // -----------------------------------------------------------------------
  // Cart
  // -----------------------------------------------------------------------

  Future<LabCartResponse> getCart() async {
    try {
      final response = await apiService.get(ApiUrl.CART_LAB);

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch cart',
          statusCode: response.statusCode,
        );
      }

      return LabCartResponse.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getCart error: $e');
      throw AppException(message: 'Failed to load cart: $e');
    }
  }

  Future<void> addToCart(int productId) async {
    try {
      final response = await apiService.post(
        ApiUrl.CART_ADD,
        data: {'product_id': productId, 'type': 'lab'},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppException(
          message: 'Failed to add item to cart',
          statusCode: response.statusCode,
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('addToCart error: $e');
      throw AppException(message: 'Failed to add to cart: $e');
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      final response = await apiService.delete(
        '${ApiUrl.CART_REMOVE_LAB}$cartItemId',
      );

      if (response.statusCode != 200) {
        throw AppException(
          message: 'Failed to remove item from cart',
          statusCode: response.statusCode,
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('removeFromCart error: $e');
      throw AppException(message: 'Failed to remove from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final response = await apiService.delete(ApiUrl.CART_CLEAR_LAB);

      if (response.statusCode != 200) {
        throw AppException(
          message: 'Failed to clear cart',
          statusCode: response.statusCode,
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('clearCart error: $e');
      throw AppException(message: 'Failed to clear cart: $e');
    }
  }

  // -----------------------------------------------------------------------
  // Booking overview + place order
  // -----------------------------------------------------------------------

  Future<BookingOverviewResponse> getBookingOverview({
    required Map<String, dynamic> body,
    String useAppWallet = 'no',
  }) async {
    try {
      final response = await apiService.post(
        '${ApiUrl.DIAGNOSTICS_BOOKING}?overview=yes&useAppWallet=$useAppWallet',
        data: body,
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch booking overview',
          statusCode: response.statusCode,
        );
      }

      final root = response.data as Map<String, dynamic>;
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Overview failed',
          statusCode: response.statusCode,
        );
      }

      return BookingOverviewResponse.fromJson(root);
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getBookingOverview error: $e');
      throw AppException(message: 'Failed to load overview: $e');
    }
  }

  /// Finalize lab booking — `overview=no` (same contract as [HealthCheckupRepository.postDiagnosticsOrder]).
  Future<DiagnosticsBookingApiResult> placeOrder({
    required Map<String, dynamic> body,
    String useAppWallet = 'no',
  }) async {
    try {
      final response = await apiService.post(
        '${ApiUrl.DIAGNOSTICS_BOOKING}?overview=no&useAppWallet=$useAppWallet',
        data: body,
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to place order',
          statusCode: response.statusCode,
        );
      }

      final root = response.data as Map<String, dynamic>;
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Booking failed',
          statusCode: response.statusCode,
        );
      }

      return DiagnosticsBookingApiResult.fromJson(root);
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('placeOrder error: $e');
      throw AppException(message: 'Failed to place order: $e');
    }
  }

  /// Wallet / Razorpay success — `POST` [ApiUrl.DIAGNOSTICS_ORDER_CONFIRM] (patient_app `confirmBookingApi`).
  Future<Map<String, dynamic>> postDiagnosticsOrderConfirm(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await apiService.post(
        ApiUrl.DIAGNOSTICS_ORDER_CONFIRM,
        data: body,
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Could not confirm booking',
          statusCode: response.statusCode,
        );
      }

      final root = response.data as Map<String, dynamic>;
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Confirmation failed',
        );
      }
      return root;
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('postDiagnosticsOrderConfirm error: $e');
      throw AppException(message: 'Confirmation failed: $e');
    }
  }
}
