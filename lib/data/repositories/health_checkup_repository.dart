import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';

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
        queryParameters: {
          'type': type,
          'sponsored': sponsored,
          'user': userId,
        },
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
        data: {
          'address_id': addressId,
          'sponsored': sponsored,
          'users': users,
        },
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch vendor pricing',
          statusCode: response.statusCode,
        );
      }

      return AhcVendorPricingResponse.fromJson(
          response.data as Map<String, dynamic>);
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

      return AhcSlotsResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getSlots error: $e');
      throw AppException(message: 'Failed to load slots: $e');
    }
  }
}
