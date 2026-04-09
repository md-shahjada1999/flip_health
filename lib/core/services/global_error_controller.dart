import 'package:get/get.dart';

enum GlobalErrorType { none, serverError, notFound, timeout }

class GlobalErrorController extends GetxController {
  final Rx<GlobalErrorType> errorType = GlobalErrorType.none.obs;
  final RxString errorMessage = ''.obs;

  bool get hasError => errorType.value != GlobalErrorType.none;

  void showError(GlobalErrorType type, [String? message]) {
    errorType.value = type;
    errorMessage.value = message ?? '';
  }

  void clearError() {
    errorType.value = GlobalErrorType.none;
    errorMessage.value = '';
  }
}
