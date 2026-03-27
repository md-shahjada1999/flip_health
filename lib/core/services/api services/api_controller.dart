
// ignore: library_prefixes
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/routes/app_routes.dart';
import '../../../main.dart';

import 'package:get/get.dart' as g;

class ApiController {
  final Dio _dio = Dio();

  Map<String, String> getHeader(){
     return {
       "Content-type": "application/json",
       // "Authkey": WebApiConstant.AUTH_KEY,
       "Authorization": "Bearer $accessToken",
       "Connection": "Keep-Alive",
       // "Keep-Alive": "timeout=5, max=1000",
     };
  }

  Future<void> checkTokenStatus({required Response<dynamic> response})async{
    if(accessToken != ""){
      bool isTokenExpired = response.data.toString().contains("unauthorized");
      String fcmTokenLocal = AppSecureStorage.getStringFromSharedPref(variableName: AppSecureStorage.kFcmToken) ?? "";
      String userId = AppSecureStorage.getStringFromSharedPref(variableName: AppSecureStorage.kUserId) ?? "";
      if(isTokenExpired){
        AppSecureStorage.clearSharedPref().then((value) async {
          g.Get.offAllNamed(AppRoutes.login);
          g.Get.deleteAll();
          accessToken = "";
          await AppSecureStorage.addStringValueToSharedPref(variableName: AppSecureStorage.kFcmToken, variableValue: fcmTokenLocal);
          await AppSecureStorage.addStringValueToSharedPref(variableName: AppSecureStorage.kUserId, variableValue: userId);
        });
      }
    }
  }

  /// Google Address Api
  // Future<GoogleAddressApiResponse?> getGoogleAddressApi({String? address,bool? findAddress, double? lat,double? lng}) async {
  //   GoogleAddressApiResponse? result;
  //   if (await ConnectionValidator().check()) {
  //     try {
  //       var encodedAddressData = Uri.encodeComponent(address ?? "");
  //       String url = "https://maps.google.com/maps/api/geocode/json?key=${ApiUrl.GOOGLE_MAP_KEY}&address=$encodedAddressData";
  //       if(findAddress == true){
  //         url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${ApiUrl.GOOGLE_MAP_KEY}";
  //       }
  //       Response response = await _dio.get(url, options: Options(followRedirects: false, validateStatus: (status) => true));
  //       PrintLog.printLog("Response:: $response");
  //       if (response.data != null && response.statusCode == 200) {
  //         result = GoogleAddressApiResponse.fromJson(response.data);
  //         return result;
  //       } else {
  //         ToastCustom.showToast(msg:response.statusMessage.toString());
  //       }
  //       checkTokenStatus(response: response);
  //     } catch (error) {
  //       PrintLog.printLog("Exception_Main: $error");
  //       return result;
  //     }
  //   } else {
  //     ToastCustom.showToast(msg: AppString.kInternetCheck);
  //   }
  //   return null;
  // }
  //
  // /// Google direction api
  // Future<Map<String, dynamic>?> getRouteDetails({required LatLng origin, required String url}) async {
  //
  //   try{
  //     Response response = await _dio.get(url, options: Options(followRedirects: false, validateStatus: (status) => true));
  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       return data;
  //
  //       // You can display it on the UI
  //     } else {
  //       throw Exception('Failed to load route details');
  //     }
  //   }catch(e){
  //     ToastCustom.showSnackBar(subtitle: "$e");
  //     PrintLog.printLog("Exception : $e");
  //   }
  //   return null;
  // }

  /// GET
  Future<Response?> requestGetForApi({required String url, Map<String, dynamic>? dictParameter}) async {
    try {

      PrintLog.printLog("Url:  $url");
      PrintLog.printLog("AccessToken: $accessToken");
      PrintLog.printLog("DictParameter: $dictParameter");

      BaseOptions options = BaseOptions(
        baseUrl: ApiUrl.BASE_URL, 
        receiveTimeout: const Duration(minutes: 1), 
        connectTimeout: const Duration(seconds: 40), 
        headers: getHeader(), 
        validateStatus: (_) => true);

      _dio.options = options;
      Response response = await _dio.get(url, queryParameters: dictParameter);
      PrintLog.printLog("Response_headers: ${response.headers}");
      PrintLog.printLog("Response_data: ${response.data}");
      printCurl(response.requestOptions);
      checkTokenStatus(response: response);

      if(response.data['status'] != true){
        ToastCustom.showSnackBar(subtitle: response.data['message'] ?? "");
      }

      if(response.toString().contains('!DOCTYPE')){
        ToastCustom.showSnackBar(subtitle: 'Something went wrong, Please try again.');
      }

      return response;
    } catch (error) {
      if(error.toString().trim().contains("connection timeout")){
        ToastCustom.showSnackBar(subtitle: "Request Timeout");
      }else{
        ToastCustom.showSnackBar(subtitle: error.toString());
      }
      PrintLog.printLog("Exception_Main: $error");
      return null;
    }
  }

  /// POST
  Future<Response?> requestPostForApi({required String url, required Map<String, dynamic> dictParameter}) async {
    try {

      PrintLog.printLog("Url:  $url");
      PrintLog.printLog("Token:  $accessToken");
      PrintLog.printLog("DictParameter: $dictParameter");

      BaseOptions options = BaseOptions(
          baseUrl: ApiUrl.BASE_URL,
          receiveTimeout: const Duration(minutes: 1),
          connectTimeout: const Duration(seconds: 40),
          headers: getHeader()
      );
      _dio.options = options;
      Response response = await _dio.post(url, data: dictParameter, options: Options(followRedirects: false, validateStatus: (status) => true, headers: getHeader()));

      PrintLog.printLog("Response: $response");
      PrintLog.printLog("Response_headers: ${response.headers}");
      printCurl(response.requestOptions);
      // PrintLog.printLog("Response_real_url: ${response.realUri}");
       checkTokenStatus(response: response);

       if(response.data['status'] != true){
         ToastCustom.showSnackBar(subtitle: response.data['message'] ?? "");
       }

      return response;
    } catch (error) {
      if(error.toString().trim().contains("connection timeout")){
        ToastCustom.showSnackBar(subtitle: "Request Timeout");
      }else{
        ToastCustom.showSnackBar(subtitle: error.toString());
      }
      PrintLog.printLog("Exception_Main: $error");
      return null;
    }
  }

  /// MULTIPART
  Future<Response?> requestMultipartApi({String? url,FormData? formData}) async {
    try {

      PrintLog.printLog("Url:  $url");
      PrintLog.printLog("accessToken:  $accessToken");
      PrintLog.printLog("formData fields: ${formData?.fields}");
      PrintLog.printLog("formData files: ${formData?.files}");

      BaseOptions options = BaseOptions(
        baseUrl: ApiUrl.BASE_URL, 
        receiveTimeout: const Duration(minutes: 1), 
        connectTimeout: const Duration(seconds: 40), 
        headers: getHeader());

      _dio.options = options;
      Response response = await _dio.post(url!,
          data: formData,
          options: Options(
            followRedirects: false,
            validateStatus: (status) => true,
            headers: getHeader(),
          ));

      PrintLog.printLog("Response: $response");
      printCurl(response.requestOptions);
      checkTokenStatus(response: response);

      if(response.data['status'] != true){
        ToastCustom.showSnackBar(subtitle: response.data['message'] ?? "");
      }

      return response;
    } catch (error) {
      if(error.toString().trim().contains("connection timeout")){
        ToastCustom.showSnackBar(subtitle: "Request Timeout");
      }else{
        ToastCustom.showSnackBar(subtitle: error.toString());
      }
      PrintLog.printLog("Exception_Main: $error");
      return null;
    }
  }

  Future<Response?> requestPutForApi({required String url,Map<String, dynamic>? dictParameter}) async {
    try {
      PrintLog.printLog("Url:  $url");
      PrintLog.printLog("AccessToken:  $accessToken");
      PrintLog.printLog("DictParameter: $dictParameter");

      BaseOptions options = BaseOptions(
        baseUrl: ApiUrl.BASE_URL,
        receiveTimeout: const Duration(minutes: 1),
        connectTimeout: const Duration(minutes: 1),
        headers: getHeader(),
        validateStatus: (_) => true,
      );

      _dio.options = options;

      Response response = await _dio.put(url,data: dictParameter);

      PrintLog.printLog("Response_headers: ${response.headers}");
      PrintLog.printLog("Response_data: ${response.data}");

      printCurl(response.requestOptions);
      checkTokenStatus(response: response);

      if (response.data['status'] != true) {
        ToastCustom.showSnackBar(subtitle: response.data['message'] ?? "");
      }

      return response;
    } catch (error) {
      PrintLog.printLog("Exception_Main: $error");
      return null;
    }
  }

  Future<Response?> requestDeleteForApi({required context,String? url,Map<String, dynamic>? dictParameter,String? token}) async{
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authkey": ApiUrl.BASE_URL,
        "Authorization": "Bearer $accessToken",
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
      };
      PrintLog.printLog("Headers: $headers");
      PrintLog.printLog("Url:  $url");
      PrintLog.printLog("Token:  $token");
      PrintLog.printLog("DictParameter: $dictParameter");

      BaseOptions options = BaseOptions(
          baseUrl: ApiUrl.BASE_URL,
          receiveTimeout: const Duration(minutes: 1),
          connectTimeout: const Duration(minutes: 1),
          headers: headers,
          validateStatus: (_) => true
      );

      _dio.options = options;
      Response response = await _dio.delete(url!, queryParameters: dictParameter);
      PrintLog.printLog("Response_headers: ${response.headers}");
      PrintLog.printLog("Response_data: ${response.data}");

      if(response.data['status'] != true){
        ToastCustom.showSnackBar(subtitle: response.data['message'] ?? "");
      }
      
      return response;

    } catch (error) {
      PrintLog.printLog("Exception_Main: $error");
      return null;
    }
  }

  static printCurl(RequestOptions requestOptions) async {
    final buffer = StringBuffer();
    buffer.write("curl -X ${requestOptions.method} '${requestOptions.uri}'");
  
    // Add headers
    requestOptions.headers.forEach((key, value) {
      buffer.write(" -H '$key: $value'");
    });
  
    // Add request body (handle FormData correctly)
    if (requestOptions.data != null) {
      if (requestOptions.data is FormData) {
        FormData formData = requestOptions.data as FormData;
        for (var field in formData.fields) {
          buffer.write(" -F '${field.key}=${field.value}'");
        }
        for (var file in formData.files) {
          buffer.write(" -F '${file.key}=@${file.value.filename}'");
        }
      } else if (requestOptions.data is Map) {
        buffer.write(" -d '${jsonEncode(requestOptions.data)}'");
      } else {
        buffer.write(" -d '${requestOptions.data}'");
      }
    }
    PrintLog.printLog("cURL:- $buffer");
  }
 

  /// Download
  // Future<String?> downLoadFile({required String url,required String certificateName})async {
  //   PrintLog.printLog("File Name is:$certificateName");
  //   await FileDownloader.downloadFile(
  //       url: url,
  //       name: certificateName,
  //       onProgress: (String? fileName, double? progress) {
  //         PrintLog.printLog('FILE fileName HAS PROGRESS $progress');
  //       },
  //       onDownloadCompleted: (String? path) async {
  //         PrintLog.printLog('FILE DOWNLOADED TO PATH: $path');
  //         if(path != null) {
  //           var status = androidVersion > 10 ? await Permission.manageExternalStorage.status:await Permission.storage.status;
  //           if (status != PermissionStatus.granted) {
  //             status = androidVersion > 10 ? await Permission.manageExternalStorage.request():await Permission.storage.request();
  //           }
  //           await OpenFile.open(path).then((value){
  //             PrintLog.printLog("Message:${value.message}.....\n Type:${value.type}");
  //           });

  //         }
  //         return 'success';
  //       },
  //       onDownloadError: (String error) {
  //         PrintLog.printLog('DOWNLOAD ERROR: $error');
  //         return error;
  //       });
  //       return '';
  // }
}