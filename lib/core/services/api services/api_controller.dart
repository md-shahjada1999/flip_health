import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:get/get.dart' as g;

import '../../../main.dart';

class ApiService {
  late final Dio dio;

  ApiService({Dio? dioClient}) {
    dio = dioClient ?? Dio();

    dio.options = BaseOptions(
      baseUrl: ApiUrl.BASE_URL,
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(minutes: 1),
      headers: {
        "Content-type": "application/json",
        "Connection": "Keep-Alive",
      },
      validateStatus: (_) => true,
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
      _LoggingInterceptor(),
    ]);
  }

  /// GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      _checkHtmlError(response);
      return response;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST
  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await dio.post(path, data: data);
      _checkHtmlError(response);
      return response;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// PUT
  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await dio.put(path, data: data);
      _checkHtmlError(response);
      return response;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// DELETE
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.delete(path, queryParameters: queryParameters);
      _checkHtmlError(response);
      return response;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// MULTIPART
  Future<Response> postMultipart(
    String path, {
    required FormData formData,
  }) async {
    try {
      final response = await dio.post(path, data: formData);
      _checkHtmlError(response);
      return response;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  void _checkHtmlError(Response response) {
    if (response.toString().contains('!DOCTYPE')) {
      throw AppException.server('Something went wrong, Please try again.');
    }
  }

  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException.timeout();
      case DioExceptionType.connectionError:
        return AppException.network();
      default:
        return AppException.unknown(e.message);
    }
  }
}

/// Attaches Bearer token to every request & handles 401 token expiry
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _handleTokenExpiry(response);
    handler.next(response);
  }

  void _handleTokenExpiry(Response response) {
    if (accessToken.isEmpty) return;

    final isExpired = response.data.toString().contains('unauthorized');

    if (isExpired) {
      final fcm = AppSecureStorage.getStringFromSharedPref(
              variableName: AppSecureStorage.kFcmToken) ??
          '';
      final userId = AppSecureStorage.getStringFromSharedPref(
              variableName: AppSecureStorage.kUserId) ??
          '';

      AppSecureStorage.clearSharedPref().then((_) async {
        g.Get.offAllNamed(AppRoutes.login);
        g.Get.deleteAll();
        accessToken = '';
        await AppSecureStorage.addStringValueToSharedPref(
            variableName: AppSecureStorage.kFcmToken, variableValue: fcm);
        await AppSecureStorage.addStringValueToSharedPref(
            variableName: AppSecureStorage.kUserId, variableValue: userId);
      });
    }
  }
}

/// Shows snackbar on error responses (status != true)
class _ErrorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data['status'] != true) {
        final msg = data['message'] as String? ?? '';
        // if (msg.isNotEmpty) {
        //   ToastCustom.showSnackBar(subtitle: msg);
        // }
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = err.type.toString().contains('timeout')
        ? 'Request Timeout'
        : err.message ?? 'Something went wrong';
    ToastCustom.showSnackBar(subtitle: message);
    handler.next(err);
  }
}

/// Logs request/response details and generates cURL commands
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    PrintLog.printLog('Url: ${options.uri}');
    PrintLog.printLog('AccessToken: $accessToken');
    if (options.data != null) {
      PrintLog.printLog('Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      PrintLog.printLog('QueryParams: ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    PrintLog.printLog('Response_headers: ${response.headers}');
    PrintLog.printLog('Response_data: ${response.data}');
    _printCurl(response.requestOptions);
    handler.next(response);
  }

  static void _printCurl(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write("curl -X ${options.method} '${options.uri}'");
    options.headers.forEach((key, value) {
      buffer.write(" -H '$key: $value'");
    });
    if (options.data != null) {
      if (options.data is FormData) {
        FormData formData = options.data as FormData;
        for (var field in formData.fields) {
          buffer.write(" -F '${field.key}=${field.value}'");
        }
        for (var file in formData.files) {
          buffer.write(" -F '${file.key}=@${file.value.filename}'");
        }
      } else if (options.data is Map) {
        buffer.write(" -d '${jsonEncode(options.data)}'");
      } else {
        buffer.write(" -d '${options.data}'");
      }
    }
    PrintLog.printLog("cURL:- $buffer");
  }
}
