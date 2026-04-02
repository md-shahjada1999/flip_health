import 'dart:async';
import 'dart:io';

import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/splash_repository.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreenController extends GetxController {
  final SplashRepository repository;

  SplashScreenController({required this.repository});

  final RxDouble progress = 0.0.obs;
  final RxBool forceUpdate = false.obs;
  final RxString updateMessage = ''.obs;

  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();
    _startProgressAnimation();
    _startFlow();
  }

  void _startProgressAnimation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (progress.value < 0.9) {
        progress.value += 0.015;
      }
    });
  }

  void _completeProgress() {
    _progressTimer?.cancel();
    progress.value = 1.0;
  }

  Future<void> _startFlow() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final packageInfo = await PackageInfo.fromPlatform();
      final buildNumber = packageInfo.buildNumber;
      PrintLog.printLog('Build number: $buildNumber');

      final versionResult = await repository.checkVersion(buildNumber);
      PrintLog.printLog('Update available: ${versionResult.updateAvailable}');

      if (versionResult.updateAvailable) {
        _completeProgress();
        forceUpdate.value = true;
        updateMessage.value = versionResult.message;
        return;
      }

      final noticeBoardResult = await repository.getNoticeBoard();
      if (noticeBoardResult.hasBanners) {
        PrintLog.printLog('Banners found: ${noticeBoardResult.banners!.length}');
        // TODO: Navigate to notice board screen when built
      }

      await _loadScreen();
    } catch (e) {
      PrintLog.printLog('Splash flow error: $e');
      await _loadScreen();
    }
  }

  Future<void> _loadScreen() async {
    _completeProgress();
    await Future.delayed(const Duration(milliseconds: 300));

    final isLoggedIn = AppSecureStorage.isLoggedIn();
    PrintLog.printLog('isLoggedIn: $isLoggedIn');

    if (!isLoggedIn) {
      final onboardingDone = AppSecureStorage.isOnboardingDone();
      if (!onboardingDone) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
      return;
    }

    final healthStatus = AppSecureStorage.getHealthStatus();
    PrintLog.printLog('healthStatus: $healthStatus');

    if (healthStatus != 1) {
      Get.offAllNamed(AppRoutes.healthScore);
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  String get storeUrl {
    if (Platform.isIOS) {
      return 'https://apps.apple.com/app/flip-health/id0000000000';
    }
    return 'https://play.google.com/store/apps/details?id=com.flip.health';
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    super.onClose();
  }
}
