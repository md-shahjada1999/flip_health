/// Invoice payload from `GET /patient/invoice/{id}` for
/// `MENTALWELLNESS` / `NUTRITION` / `YOGA` orders.
class WellnessOrderInvoice {
  WellnessOrderInvoice._(this.raw);

  /// Full `data` map from the invoice API.
  final Map<String, dynamic> raw;

  factory WellnessOrderInvoice.fromJson(Map<String, dynamic> json) {
    return WellnessOrderInvoice._(Map<String, dynamic>.from(json));
  }

  String? get transactionType => raw['transaction_type']?.toString();

  Map<String, dynamic>? get info {
    final i = raw['info'];
    if (i is Map) return Map<String, dynamic>.from(i);
    return null;
  }

  Map<String, dynamic>? get detailsMap {
    final d = info?['details'];
    if (d is Map) return Map<String, dynamic>.from(d);
    return null;
  }

  Map<String, dynamic>? get additionalInfo {
    final a = raw['additional_info'];
    if (a is Map) return Map<String, dynamic>.from(a);
    return null;
  }

  List<dynamic> get details {
    final d = raw['details'];
    return d is List ? d : const [];
  }

  List<dynamic> get payments {
    final p = raw['payments'];
    return p is List ? p : const [];
  }
}
