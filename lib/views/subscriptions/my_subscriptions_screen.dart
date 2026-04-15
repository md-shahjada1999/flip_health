import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/controllers/subscriptions/my_subscriptions_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/helpers/subscription_helper.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';

/// Patient user IDs already assigned to this subscription (matches API `members` + `patients`).
Set<String> _assignedPatientIdSet(Map<String, dynamic> sub) {
  final ids = <String>{};
  for (final e in sub['members'] as List? ?? []) {
    if (e is Map && e['id'] != null) {
      ids.add(e['id'].toString());
    }
  }
  for (final e in sub['patients'] as List? ?? []) {
    if (e is! Map) continue;
    final m = SubscriptionHelper.asStringKeyMap(e);
    if (m['patient_id'] != null) {
      ids.add(m['patient_id'].toString());
    }
    final p = m['patient'];
    if (p is Map) {
      final pm = SubscriptionHelper.asStringKeyMap(p);
      if (pm['id'] != null) ids.add(pm['id'].toString());
    }
  }
  return ids;
}

String _friendlySlotType(String rawKey) {
  final k = rawKey.trim().toLowerCase();
  switch (k) {
    case 'employee':
      return 'Primary member';
    case 'spouse':
      return 'Spouse';
    case 'child':
      return 'Child';
    case 'parent':
      return 'Parent';
    default:
      if (rawKey.isEmpty) return 'Member';
      return rawKey[0].toUpperCase() + rawKey.substring(1).toLowerCase();
  }
}

int _countPatientsForType(Map<String, dynamic> sub, String typeKey) {
  final list = sub['patients'] as List? ?? [];
  var n = 0;
  for (final e in list) {
    if (e is Map && e['dependent_type']?.toString() == typeKey) {
      n++;
    }
  }
  return n;
}

int _totalSlots(Map<String, dynamic> memberType) {
  var t = 0;
  memberType.forEach((_, v) {
    t += int.tryParse(v.toString()) ?? 0;
  });
  return t;
}

/// Lists active subscriptions and plan slots — aligned with patient_app `MySubscriptionsView`.
class MySubscriptionsScreen extends GetView<MySubscriptionsController> {
  const MySubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      appBar: CommonAppBar.build(
        title: AppString.kMySubscriptionsTitle,
        onBackPressed: () => Get.back(),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _LoadingState();
        }
        if (controller.subscriptionRows.isEmpty) {
          return _EmptyState(onRefresh: controller.load);
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColors.primary,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.rw, 8.rh, 16.rw, 24.rh),
            children: [
              _IntroBanner(),
              SizedBox(height: 16.rh),
              ...List.generate(
                controller.subscriptionRows.length,
                (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.rh),
                    child: _SubscriptionCard(
                      sub: controller.subscriptionRows[index],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36.rs,
            height: 36.rs,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 20.rh),
          CommonText(
            AppString.kMySubscriptionsLoading,
            fontSize: 15.rf,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 28.rw),
        children: [
          SizedBox(height: 80.rh),
          Icon(
            Icons.card_membership_rounded,
            size: 72.rs,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 24.rh),
          CommonText(
            AppString.kNoSubscriptionsTitle,
            fontSize: 20.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.rh),
          CommonText(
            AppString.kNoSubscriptionsBody,
            fontSize: 15.rf,
            height: 1.5,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.rh),
          CommonText(
            AppString.kNoSubscriptionsPullHint,
            fontSize: 13.rf,
            color: AppColors.textTertiary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _IntroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 22.rs,
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: CommonText(
              AppString.kMySubscriptionsIntro,
              fontSize: 13.rf,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends GetView<MySubscriptionsController> {
  const _SubscriptionCard({required this.sub});

  final Map<String, dynamic> sub;

  @override
  Widget build(BuildContext context) {
    final plan = SubscriptionHelper.asStringKeyMap(sub['plan']);
    final name = plan['name']?.toString().trim().isNotEmpty == true
        ? plan['name'].toString()
        : 'Plan';
    final daysLeft = sub['daysLeft'];
    final daysLeftStr =
        daysLeft != null ? daysLeft.toString() : '—';
    final expires = sub['expiresAt_display']?.toString() ?? '';
    final status = sub['status'];
    final isActive = status == 1 || status == true;

    final memberTypeRaw = plan['member_type'];
    final memberType = memberTypeRaw is Map
        ? SubscriptionHelper.asStringKeyMap(memberTypeRaw)
        : <String, dynamic>{};
    final totalSlots = memberType.isEmpty ? 0 : _totalSlots(memberType);
    final patients = sub['patients'] as List? ?? [];
    final filledSlots = patients.length;
    final progressLabel = totalSlots > 0
        ? '$filledSlots / $totalSlots ${AppString.kSubscriptionSlotsProgress.toLowerCase()}'
        : '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.rw, 14.rh, 12.rw, 14.rh),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CommonText(
                    name,
                    fontSize: 16.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.rw),
                if (isActive)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.rw,
                      vertical: 5.rh,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.rs),
                    ),
                    child: CommonText(
                      AppString.kSubscriptionStatusActive,
                      fontSize: 11.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.rs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.event_available_outlined,
                  label: AppString.kSubscriptionDaysLeft,
                  value: daysLeftStr,
                  emphasize: true,
                ),
                if (expires.isNotEmpty) ...[
                  SizedBox(height: 10.rh),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: AppString.kSubscriptionValidUntil,
                    value: expires,
                    emphasize: false,
                  ),
                ],
                if (progressLabel.isNotEmpty) ...[
                  SizedBox(height: 12.rh),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.rw,
                      vertical: 8.rh,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(10.rs),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pie_chart_outline_rounded,
                          size: 18.rs,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.rw),
                        Expanded(
                          child: CommonText(
                            progressLabel,
                            fontSize: 13.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!SubscriptionHelper.planAllowsDependentAdd(sub)) ...[
                  SizedBox(height: 12.rh),
                  _WarningNote(text: AppString.kDependentAddNotAllowed),
                ],
                SizedBox(height: 16.rh),
                CommonText(
                  AppString.kSubscriptionMembersTitle,
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 6.rh),
                CommonText(
                  AppString.kSubscriptionMembersSubtitle,
                  fontSize: 12.rf,
                  height: 1.4,
                  color: AppColors.textTertiary,
                ),
                SizedBox(height: 12.rh),
                _SlotList(sub: sub),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.emphasize,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.rs, color: AppColors.textSecondary),
        SizedBox(width: 10.rw),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                label,
                fontSize: 11.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 2.rh),
              CommonText(
                value,
                fontSize: emphasize ? 15.rf : 13.rf,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textPrimary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WarningNote extends StatelessWidget {
  const _WarningNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.rs),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 18.rs,
            color: AppColors.error.withValues(alpha: 0.85),
          ),
          SizedBox(width: 10.rw),
          Expanded(
            child: CommonText(
              text,
              fontSize: 12.rf,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotList extends GetView<MySubscriptionsController> {
  const _SlotList({required this.sub});

  final Map<String, dynamic> sub;

  @override
  Widget build(BuildContext context) {
    final plan = SubscriptionHelper.asStringKeyMap(sub['plan']);
    if (plan.isEmpty) return const SizedBox.shrink();
    final memberTypeRaw = plan['member_type'];
    if (memberTypeRaw is! Map) {
      return CommonText(
        '—',
        fontSize: 13.rf,
        color: AppColors.textTertiary,
      );
    }
    final memberType = SubscriptionHelper.asStringKeyMap(memberTypeRaw);

    final patients = List<dynamic>.from(sub['patients'] ?? []);
    final children = <Widget>[];

    final keys = memberType.keys.map((k) => k.toString()).toList()
      ..sort((a, b) {
        const order = ['employee', 'spouse', 'parent', 'child'];
        final ia = order.indexOf(a.toLowerCase());
        final ib = order.indexOf(b.toLowerCase());
        if (ia != -1 || ib != -1) {
          if (ia == -1) return 1;
          if (ib == -1) return -1;
          return ia.compareTo(ib);
        }
        return a.compareTo(b);
      });

    for (final typeKey in keys) {
      final value = memberType[typeKey];
      final slotCount = int.tryParse(value.toString()) ?? 0;
      if (slotCount <= 0) continue;

      final filledHere = _countPatientsForType(sub, typeKey);
      children.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8.rh, top: 4.rh),
          child: Row(
            children: [
              Expanded(
                child: CommonText(
                  _friendlySlotType(typeKey),
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 4.rh),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(8.rs),
                ),
                child: CommonText(
                  '$filledHere / $slotCount',
                  fontSize: 11.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );

      for (var i = 0; i < slotCount; i++) {
        final idx = patients.indexWhere(
          (u) =>
              u is Map &&
              u['dependent_type']?.toString() == typeKey,
        );
        if (idx >= 0) {
          final u = patients.removeAt(idx);
          children.add(
            Padding(
              padding: EdgeInsets.only(bottom: 10.rh),
              child: _FilledSlotTile(
                user: SubscriptionHelper.asStringKeyMap(u),
                typeLabel: _friendlySlotType(typeKey),
              ),
            ),
          );
        } else {
          children.add(
            Padding(
              padding: EdgeInsets.only(bottom: 10.rh),
              child: _EmptySlotTile(
                sub: sub,
                dependentTypeKey: typeKey,
                typeLabel: _friendlySlotType(typeKey),
              ),
            ),
          );
        }
      }
    }

    if (children.isEmpty) {
      return CommonText(
        '—',
        fontSize: 13.rf,
        color: AppColors.textTertiary,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _FilledSlotTile extends StatelessWidget {
  const _FilledSlotTile({
    required this.user,
    required this.typeLabel,
  });

  final Map<String, dynamic> user;
  final String typeLabel;

  String get _displayName {
    final nested = user['patient'];
    if (nested is Map) {
      final n = nested['name']?.toString();
      if (n != null && n.trim().isNotEmpty) return n.trim();
    }
    final top = user['name']?.toString();
    if (top != null && top.trim().isNotEmpty) return top.trim();
    return 'Member';
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 12.rh),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.rs),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 20.rs,
            ),
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  name,
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  typeLabel,
                  fontSize: 12.rf,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlotTile extends GetView<MySubscriptionsController> {
  const _EmptySlotTile({
    required this.sub,
    required this.dependentTypeKey,
    required this.typeLabel,
  });

  final Map<String, dynamic> sub;
  final String dependentTypeKey;
  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    final canTap = _canActivateHere(sub);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap
            ? () => _showMemberPicker(
                  controller,
                  sub,
                  dependentTypeKey,
                  typeLabel,
                )
            : null,
        borderRadius: BorderRadius.circular(14.rs),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 14.rh),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.rs),
            border: Border.all(
              color: canTap
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.borderLight,
              width: 1.4,
            ),
            color: canTap
                ? AppColors.primary.withValues(alpha: 0.04)
                : AppColors.backgroundTertiary.withValues(alpha: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: canTap ? AppColors.primary : AppColors.textTertiary,
                    size: 22.rs,
                  ),
                  SizedBox(width: 10.rw),
                  Expanded(
                    child: CommonText(
                      '${AppString.kSubscriptionAddToSlot} · $typeLabel',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w700,
                      color: canTap
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.rh),
              Padding(
                padding: EdgeInsets.only(left: 32.rw),
                child: CommonText(
                  canTap
                      ? AppString.kSubscriptionEmptySlotHint
                      : AppString.kSubscriptionSlotUnavailable,
                  fontSize: 12.rf,
                  height: 1.35,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canActivateHere(Map<String, dynamic> sub) {
    if (!SubscriptionHelper.planAllowsDependentAdd(sub)) return false;
    final buyerId = sub['patient_id'];
    final me = controller.primaryUserId;
    if (me == null) return false;
    if (sub['canActivate'] != true) return false;
    return buyerId?.toString() == me.toString();
  }
}

void _showMemberPicker(
  MySubscriptionsController controller,
  Map<String, dynamic> sub,
  String dependentType,
  String typeLabel,
) {
  final subId = sub['id']?.toString() ?? '';
  if (subId.isEmpty) return;

  final takenIds = _assignedPatientIdSet(sub);

  if (!Get.isRegistered<MemberController>()) {
    AppToast.error(title: 'Members', message: 'Family list not available');
    return;
  }

  Get.bottomSheet(
    SafeArea(
      child: Container(
        width: double.infinity,
        height: (Get.height * 0.58).clamp(320.0, 520.0),
        padding: EdgeInsets.fromLTRB(20.rw, 12.rh, 20.rw, 20.rh),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.rw,
                height: 4.rh,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 16.rh),
            CommonText(
              AppString.kSelectMemberForSlot,
              fontSize: 17.rf,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 6.rh),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.rw,
                    vertical: 4.rh,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.rs),
                  ),
                  child: CommonText(
                    typeLabel,
                    fontSize: 12.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8.rw),
                Expanded(
                  child: CommonText(
                    dependentType,
                    fontSize: 12.rf,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.rh),
            CommonText(
              AppString.kSelectMemberForSlotSubtitle,
              fontSize: 13.rf,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.rh),
            Expanded(
              child: Obx(() {
                final mc = Get.find<MemberController>();
                final list = mc.familyMembers
                    .where((m) => !takenIds.contains(m.id))
                    .toList();
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.rw),
                      child: CommonText(
                        AppString.kAddFamilyMemberFirstShort,
                        fontSize: 14.rf,
                        height: 1.45,
                        color: AppColors.textTertiary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.rh),
                  itemBuilder: (context, i) {
                    final m = list[i];
                    return _MemberPickRow(
                      member: m,
                      onTap: () {
                        final mid = int.tryParse(m.id) ?? 0;
                        if (mid <= 0) return;
                        controller.activateMemberOnPlan(
                          memberId: mid,
                          subscriptionId: subId,
                          dependentType: dependentType,
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _MemberPickRow extends StatelessWidget {
  const _MemberPickRow({required this.member, required this.onTap});

  final FamilyMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundTertiary,
      borderRadius: BorderRadius.circular(14.rs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.rs),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 14.rh),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.rs,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: CommonText(
                  member.name.isNotEmpty
                      ? member.name[0].toUpperCase()
                      : '?',
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      member.name,
                      fontSize: 15.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    if (member.relationship != null &&
                        member.relationship!.isNotEmpty)
                      CommonText(
                        member.relationship!,
                        fontSize: 12.rf,
                        color: AppColors.textTertiary,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 22.rs,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
