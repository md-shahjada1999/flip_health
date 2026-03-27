import 'package:get/get.dart';
import 'package:flip_health/controllers/auth%20controllers/login_controller.dart';
import 'package:flip_health/controllers/auth%20controllers/otp_controllers.dart' show OTPController;


class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization of controllers
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<OTPController>(() => OTPController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

class OTPBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OTPController>(() => OTPController());
  }
}