import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/splash%20models/notice_board_model.dart';
import 'package:flip_health/model/splash%20models/version_check_model.dart';

class SplashRepository {
  final ApiService apiService;

  SplashRepository({required this.apiService});

  Future<VersionCheckResponse> checkVersion(String buildNumber) async {
    try {
      final response = await apiService.get(
        '${ApiUrl.VERSION_CHECK}38',
      );
      PrintLog.printLog('VersionCheck status: ${response.statusCode}');

      if (response.data is Map<String, dynamic>) {
        return VersionCheckResponse.fromJson(response.data);
      }
      return const VersionCheckResponse(updateAvailable: false, message: '');
    } catch (e) {
      PrintLog.printLog('VersionCheck error: $e');
      return const VersionCheckResponse(updateAvailable: false, message: '');
    }
  }

  Future<NoticeBoardResponse> getNoticeBoard() async {
    try {
      final response = await apiService.get(
        ApiUrl.NOTICE_BOARD,
      );
      PrintLog.printLog('NoticeBoard status: ${response.statusCode}');

      if (response.data is Map<String, dynamic>) {
        return NoticeBoardResponse.fromJson(response.data);
      }
      return const NoticeBoardResponse();
    } catch (e) {
      PrintLog.printLog('NoticeBoard error: $e');
      return const NoticeBoardResponse();
    }
  }
}
