import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/controllers/subscriptions/my_subscriptions_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/subscription_repository.dart';

class MySubscriptionsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<SubscriptionRepository>(
      () => SubscriptionRepository(apiService: Get.find<ApiService>()),
    );
    if (!Get.isRegistered<MemberController>()) {
      Get.put<MemberController>(MemberController(), permanent: false);
    }
    Get.lazyPut<MySubscriptionsController>(
      () => MySubscriptionsController(
        repository: Get.find<SubscriptionRepository>(),
      ),
    );
  }
}
