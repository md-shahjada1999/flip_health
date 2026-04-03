/// Parsed `/patient/opd/wallet` → `wallet` object (patient_app: `response['wallet']`).
class OpdWallet {
  OpdWallet({
    required this.available,
    required this.total,
    required this.expiresAt,
    required this.subscriptionId,
    required this.module,
    required this.raw,
  });

  final num available;
  final num total;
  final String expiresAt;
  final dynamic subscriptionId;
  final Map<String, OpdModuleLimit> module;
  final Map<String, dynamic> raw;

  bool get hasValidSubscription {
    final s = subscriptionId;
    if (s == null) return false;
    if (s == 0) return false;
    final t = s.toString().trim().toLowerCase();
    if (t.isEmpty || t == '0' || t == 'null') return false;
    return true;
  }

  /// Subscription id for `GET .../opd/wallet/transactions/{subscription_id}`.
  String get subscriptionIdForPath {
    if (!hasValidSubscription) return '';
    return subscriptionId.toString().trim();
  }

  static num _readNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  factory OpdWallet.fromJson(Map<String, dynamic> json) {
    final moduleRaw = json['module'];
    final modules = <String, OpdModuleLimit>{};
    if (moduleRaw is Map) {
      moduleRaw.forEach((key, value) {
        if (value is Map) {
          final m = Map<String, dynamic>.from(value);
          modules[key.toString()] = OpdModuleLimit(
            availableLimit: _readNum(m['available_limit']),
            totalLimit: _readNum(m['total_limit']),
          );
        }
      });
    }

    final expires = json['expiresAt'] ??
        json['expires_at'] ??
        json['expires_at_formatted'];

    return OpdWallet(
      available: _readNum(json['available']),
      total: _readNum(json['total']),
      expiresAt: expires?.toString() ?? '---',
      subscriptionId: json['subscription_id'],
      module: modules,
      raw: Map<String, dynamic>.from(json),
    );
  }

  /// Empty / error state for UI.
  factory OpdWallet.empty() {
    return OpdWallet(
      available: 0,
      total: 1,
      expiresAt: '---',
      subscriptionId: 0,
      module: {},
      raw: {},
    );
  }
}

class OpdModuleLimit {
  OpdModuleLimit({
    required this.availableLimit,
    required this.totalLimit,
  });

  final num availableLimit;
  final num totalLimit;

  int get availableInt => availableLimit.round();
  int get totalInt => totalLimit.round() == 0 ? 1 : totalLimit.round();
}
