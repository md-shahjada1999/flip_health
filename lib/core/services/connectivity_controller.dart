import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flip_health/core/services/global_error_controller.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  final RxBool isConnected = true.obs;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = Connectivity().onConnectivityChanged.listen(_update);
    Connectivity().checkConnectivity().then(_update);
  }

  void _update(List<ConnectivityResult> results) {
    final connected =
        results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
    final wasDisconnected = !isConnected.value;
    isConnected.value = connected;

    if (connected && wasDisconnected) {
      try {
        Get.find<GlobalErrorController>().clearError();
      } catch (_) {}
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
