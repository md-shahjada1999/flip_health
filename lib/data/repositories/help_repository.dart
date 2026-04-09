import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/support%20models/ticket_message_model.dart';
import 'package:flip_health/model/support%20models/ticket_model.dart';

class HelpRepository {
  final ApiService apiService;

  HelpRepository({required this.apiService});

  Future<List<TicketModel>> getTickets() async {
    final response = await apiService.get(ApiUrl.SUPPORT_TICKETS);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return TicketModel.fromListResponse(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createTicket({
    required String message,
    String language = 'English',
  }) async {
    final response = await apiService.post(
      ApiUrl.SUPPORT_TICKETS,
      data: {'message': message, 'language': language},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  Future<List<TicketMessageModel>> getTicketMessages(
    String ticketId, {
    int page = 1,
  }) async {
    final response = await apiService.get(
      '${ApiUrl.SUPPORT_TICKET_DETAIL}$ticketId',
      queryParameters: {'page': page},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return TicketMessageModel.fromListResponse(data);
    }
    return [];
  }

  Future<TicketMessageModel?> sendMessage(
    String ticketId,
    String message,
  ) async {
    final response = await apiService.post(
      '${ApiUrl.SUPPORT_TICKET_DETAIL}$ticketId',
      data: {'message': message},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['ticketMessage'] is Map) {
      return TicketMessageModel.fromJson(
        data['ticketMessage'] as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<TicketMessageModel?> sendAttachment(
    String ticketId,
    Map<String, dynamic> uploadData,
  ) async {
    final response = await apiService.post(
      '${ApiUrl.SUPPORT_TICKET_DETAIL}$ticketId',
      data: uploadData,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['ticketMessage'] is Map) {
      return TicketMessageModel.fromJson(
        data['ticketMessage'] as Map<String, dynamic>,
      );
    }
    return null;
  }

  /// Uploads a file and returns the raw upload response data to pass to [sendAttachment].
  Future<Map<String, dynamic>?> uploadFile(String filePath) async {
    final token = AppSecureStorage.getToken();
    if (token == null || token.isEmpty) return null;

    final filename = filePath.split('/').last;
    final formData = FormData.fromMap({
      'token': token,
      'type': 'document',
      'file': await MultipartFile.fromFile(filePath, filename: filename),
    });

    final response = await apiService.postMultipart(
      ApiUrl.UPLOAD_ATTACHMENT,
      formData: formData,
    );

    PrintLog.printLog('HelpRepository.uploadFile status: ${response.statusCode}');

    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] is Map) {
      return data['data'] as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> submitFeedback({
    required String ticketId,
    required int rating,
    String? description,
  }) async {
    final response = await apiService.post(
      ApiUrl.FEEDBACK,
      data: {
        'src': 'support',
        'src_id': ticketId,
        'rating': '$rating',
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    final data = response.data;
    return data is Map<String, dynamic> && data['message'] != null;
  }
}
