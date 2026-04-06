import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/common%20models/upload_response_model.dart';

class UploadRepository {
  final ApiService apiService;
  UploadRepository({required this.apiService});

  /// Upload a file to the server.
  /// [type] determines the category: "prescription", "bank", "reimbursement", etc.
  Future<UploadResponse> uploadFile({
    required String filePath,
    required String type,
  }) async {
    try {
      final token = AppSecureStorage.getToken();
      if (token == null || token.isEmpty) {
        throw AppException(message: 'Please log in to upload documents.');
      }

      final filename = filePath.split('/').last;
      final formData = FormData.fromMap({
        'token': token,
        'type': type,
        'file': await MultipartFile.fromFile(filePath, filename: filename),
      });

      final response = await apiService.postMultipart(
        ApiUrl.UPLOAD_ATTACHMENT,
        formData: formData,
      );
      PrintLog.printLog('UploadRepository.uploadFile status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ?? 'Upload failed')
              : 'Upload failed',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is Map<String, dynamic>) {
        final data = root['data'];
        if (data is Map<String, dynamic>) {
          return UploadResponse.fromJson(data);
        }
      }

      throw AppException(message: 'Unexpected upload response format');
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('UploadRepository.uploadFile error: $e');
      throw AppException(message: 'Upload failed: $e');
    }
  }
}
