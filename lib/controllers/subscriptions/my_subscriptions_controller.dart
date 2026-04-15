import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/helpers/subscription_helper.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/data/repositories/subscription_repository.dart';

class MySubscriptionsController extends GetxController {
  MySubscriptionsController({required SubscriptionRepository repository})
      : _repository = repository;

  final SubscriptionRepository _repository;

  final isLoading = true.obs;
  final subscriptionRows = <Map<String, dynamic>>[].obs;
  final isSubscribedResponse = false.obs;
  final currentIndex = 0.obs;

  int? get primaryUserId => AppSecureStorage.getSavedUser()?.id;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final body = await _repository.fetchMySubscriptions();
      isSubscribedResponse.value = body['isSubscribed'] == true;
      final data = body['data'];
      if (data is List) {
        subscriptionRows.assignAll(
          data.map((e) => SubscriptionHelper.asStringKeyMap(e)).toList(),
        );
      } else {
        subscriptionRows.clear();
      }
      if (Get.isRegistered<MemberController>()) {
        await Get.find<MemberController>().loadMembers();
      }
    } on AppException catch (e) {
      AppToast.error(title: 'Subscriptions', message: e.message);
      subscriptionRows.clear();
    } catch (_) {
      subscriptionRows.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activateMemberOnPlan({
    required int memberId,
    required String subscriptionId,
    required String dependentType,
  }) async {
    try {
      await _repository.activateMemberOnPlan(
        memberId: memberId,
        subscriptionId: subscriptionId,
        dependentType: dependentType,
      );
      Get.back();
      AppToast.success(
        title: 'Success',
        message: AppString.kMemberActivatedSuccess,
      );
      await load();
      if (Get.isRegistered<MemberController>()) {
        await Get.find<MemberController>().loadMembers();
      }
    } on AppException catch (e) {
      AppToast.error(title: 'Activation', message: e.message);
    }
  }
}
