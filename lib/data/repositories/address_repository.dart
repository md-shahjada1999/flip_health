import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/address%20models/address_model.dart';

class AddressRepository {
  final ApiService apiService;

  AddressRepository({required this.apiService});

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await apiService.get(ApiUrl.ADDRESS);
      PrintLog.printLog('AddressRepository.getAddresses status: ${response.statusCode}');
      PrintLog.printLog('AddressRepository.getAddresses data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return AddressModel.fromListResponse(data);
        }
        PrintLog.printLog('AddressRepository: unexpected data type: ${data.runtimeType}');
      }

      throw AppException(
        message: response.data?['message'] ?? 'Failed to fetch addresses',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('AddressRepository.getAddresses error: $e');
      throw AppException(message: 'Failed to load addresses: $e');
    }
  }

  Future<AddressModel> addAddress({required Map<String, dynamic> data}) async {
    try {
      final response = await apiService.post(
        ApiUrl.ADDRESS,
        data: data,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return AddressModel.fromSingleResponse(response.data);
      }

      throw AppException(
        message: response.data?['message'] ?? 'Failed to add address',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('AddressRepository.addAddress error: $e');
      throw AppException(message: 'Failed to add address: $e');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      final response = await apiService.delete('${ApiUrl.ADDRESS}/$id');

      if (response.statusCode != 200) {
        throw AppException(
          message: response.data?['message'] ?? 'Failed to delete address',
          statusCode: response.statusCode,
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('AddressRepository.deleteAddress error: $e');
      throw AppException(message: 'Failed to delete address: $e');
    }
  }
}
