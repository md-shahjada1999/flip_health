import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';

class HealthCheckupRepository {
  final ApiService apiService;
  HealthCheckupRepository({required this.apiService});

  // -------------------------------------------------------------------------
  // GET packages for a specific user
  // -------------------------------------------------------------------------

  Future<List<DiagnosticsPackage>> getPackages({
    required int userId,
    String type = 'special',
    bool sponsored = false,
  }) async {
    try {
      final response = await apiService.get(
        ApiUrl.DIAGNOSTICS_PACKAGES,
        queryParameters: {'type': type, 'sponsored': sponsored, 'user': userId},
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch packages',
          statusCode: response.statusCode,
        );
      }

      final root = response.data as Map<String, dynamic>;
      final list = root['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => DiagnosticsPackage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getPackages error: $e');
      throw AppException(message: 'Failed to load packages: $e');
    }
  }

  // -------------------------------------------------------------------------
  // GET package detail
  // -------------------------------------------------------------------------

  /// Inclusions for a **pricing** row — patient_app `packageInclusions(id)` → `GET /patient/diagnostics/packages/{id}` with `id = pricing.id`.
  /// Response: `data.parameters` (list of groups with `name`, optional `package_detail`).
  Future<List<dynamic>> getPackageInclusions(int pricingId) async {
    if (pricingId <= 0) {
      throw AppException(message: 'Invalid pricing id');
    }
    try {
      final response = await apiService.get(
        '${ApiUrl.DIAGNOSTICS_PACKAGE_DETAIL}$pricingId',
      );
      final code = response.statusCode ?? 0;
      if (code < 200 || code >= 300 || response.data is! Map) {
        throw AppException(
          message: 'Failed to load inclusions',
          statusCode: response.statusCode,
        );
      }
      final root = response.data as Map<String, dynamic>;
      final data = root['data'];
      if (data is Map && data['parameters'] is List) {
        return List<dynamic>.from(data['parameters'] as List);
      }
      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getPackageInclusions error: $e');
      throw AppException(message: 'Failed to load inclusions: $e');
    }
  }

  Future<DiagnosticsPackageDetail> getPackageDetail(int packageId) async {
    try {
      final response = await apiService.get(
        '${ApiUrl.DIAGNOSTICS_PACKAGE_DETAIL}$packageId',
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch package details',
          statusCode: response.statusCode,
        );
      }

      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      return DiagnosticsPackageDetail.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getPackageDetail error: $e');
      throw AppException(message: 'Failed to load package details: $e');
    }
  }

  // -------------------------------------------------------------------------
  // POST vendor/pricing
  // -------------------------------------------------------------------------

  Future<AhcVendorPricingResponse> getVendorPricing({
    required String addressId,
    required bool sponsored,
    required List<Map<String, dynamic>> users,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiUrl.DIAGNOSTICS_SPONSORED_PRICING}?page=1',
        data: {'address_id': addressId, 'sponsored': sponsored, 'users': users},
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch vendor pricing',
          statusCode: response.statusCode,
        );
      }

      return AhcVendorPricingResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getVendorPricing error: $e');
      throw AppException(message: 'Failed to load vendor pricing: $e');
    }
  }

  // -------------------------------------------------------------------------
  // POST slots
  // -------------------------------------------------------------------------

  Future<AhcSlotsResponse> getSlots({
    required String addressId,
    required String date,
    required String vendorCode,
    required String category,
    String package = 'special',
  }) async {
    try {
      final response = await apiService.post(
        ApiUrl.DIAGNOSTICS_SLOTS,
        data: {
          'address_id': addressId,
          'date': date,
          'vendor_code': vendorCode,
          'package': package,
          'category': category,
        },
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch slots',
          statusCode: response.statusCode,
        );
      }

      return AhcSlotsResponse.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getSlots error: $e');
      throw AppException(message: 'Failed to load slots: $e');
    }
  }

  // -------------------------------------------------------------------------
  // POST order booking — `?overview=yes|no&useAppWallet=yes|no` (no `confirm` param)
  // -------------------------------------------------------------------------

  /// Preview — `overview=yes` loads pricing/items for overview.
  /// Finalize — `overview=no` places order (wallet optional).
  Future<DiagnosticsBookingApiResult> postDiagnosticsOrder({
    required Map<String, dynamic> body,
    required bool preview,
    String useAppWallet = 'no',
  }) async {
    try {
      final overviewFlag = preview ? 'yes' : 'no';
      final response = await apiService.post(
        '${ApiUrl.DIAGNOSTICS_BOOKING}?overview=$overviewFlag&useAppWallet=$useAppWallet',
        data: body,
      );

      print("postDiagnosticsOrder response: ${response.data}");

      PrintLog.printLog('postDiagnosticsOrder response: ${response.data}');

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Booking request failed',
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
      PrintLog.printLog('postDiagnosticsOrder error: $e');
      throw AppException(message: 'Booking failed: $e');
    }
  }

  /// Razorpay success — patient_app `confirmBookingApi` → POST [DIAGNOSTICS_ORDER_CONFIRM].
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
          message: 'Could not confirm payment',
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
