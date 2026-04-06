import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/data/repositories/member_repository.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class MemberController extends GetxController {
  late final MemberRepository _repository;

  final familyMembers = <FamilyMember>[].obs;
  final isLoading = false.obs;

  // Single-select
  final selectedUserId = ''.obs;

  // Multi-select
  final selectedMemberIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService());
    }
    _repository = MemberRepository(apiService: Get.find<ApiService>());
    loadMembers();
  }

  Future<void> loadMembers() async {
    isLoading.value = true;
    try {
      familyMembers.value = await _repository.getMembers();
    } catch (e) {
      AppToast.error(title: 'Error', message: 'Failed to load members');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Single-select ---

  void selectUser(String userId) {
    selectedUserId.value = userId;
  }

  bool isUserSelected(String userId) => selectedUserId.value == userId;

  FamilyMember? get selectedMember {
    final idx = familyMembers.indexWhere((m) => m.id == selectedUserId.value);
    return idx != -1 ? familyMembers[idx] : null;
  }

  // --- Multi-select ---

  void toggleMember(String memberId) {
    if (selectedMemberIds.contains(memberId)) {
      selectedMemberIds.remove(memberId);
    } else {
      selectedMemberIds.add(memberId);
    }
  }

  bool isMemberSelected(String memberId) =>
      selectedMemberIds.contains(memberId);

  List<FamilyMember> get selectedMembers =>
      familyMembers.where((m) => selectedMemberIds.contains(m.id)).toList();

  void addNewFamilyMember() {
    Get.toNamed(AppRoutes.addFamilyMember);
  }

  void resetSelection() {
    selectedUserId.value = '';
    selectedMemberIds.clear();
  }
}