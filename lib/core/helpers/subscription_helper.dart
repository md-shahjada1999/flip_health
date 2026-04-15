import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/model/user%20models/user_model.dart';

/// Mirrors patient_app [SubscriptionHelper] using cached profile (`UserModel.subscription`)
/// and live subscription list from [MySubscriptionsController] when needed.
///
/// `plan.dependent_add` — whether the user may add dependents under that plan.
class SubscriptionHelper {
  SubscriptionHelper._();

  /// Dio/JSON often yields `Map<dynamic, dynamic>`; normalize for safe lookups/casts.
  static Map<String, dynamic> asStringKeyMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static UserModel? get _user => AppSecureStorage.getSavedUser();

  static bool get isUserSubscribed => _user?.isSubscribed ?? false;

  /// Same rules as patient_app `SubscriptionHelper.canUserAdd`: if subscribed, at least one
  /// plan must have `dependent_add == true` when any subscription row exists; otherwise allow.
  static bool canUserAddDependent() {
    final user = _user;
    if (user == null) return true;
    if (!user.isSubscribed) return true;
    final subs = user.subscriptions;
    if (subs.isEmpty) return true;
    final flags = <bool>[];
    for (final s in subs) {
      final plan = asStringKeyMap(s['plan']);
      if (plan.isNotEmpty) {
        flags.add(plan['dependent_add'] == true);
      }
    }
    if (flags.isEmpty) return true;
    return flags.contains(true);
  }

  /// After adding a member, show CTA to open subscriptions / activation when subscribed.
  static bool shouldOfferSubscriptionActivationCta() => isUserSubscribed;

  /// Whether any loaded subscription [plan] allows assigning dependents (from API list).
  static bool planAllowsDependentAdd(Map<String, dynamic>? subscription) {
    if (subscription == null) return false;
    final plan = asStringKeyMap(subscription['plan']);
    return plan['dependent_add'] == true;
  }
}
