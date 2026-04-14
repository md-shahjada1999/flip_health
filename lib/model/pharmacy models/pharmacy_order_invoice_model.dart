/// Invoice payload from `GET /patient/invoice/{id}` for pharmacy / chronic medicine orders.
/// Mirrors the `data` object used in patient_app [PharmacyOrderDetailsController].
class PharmacyOrderInvoice {
  PharmacyOrderInvoice._(this.raw);

  /// Full `data` map from the invoice API.
  final Map<String, dynamic> raw;

  factory PharmacyOrderInvoice.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderInvoice._(Map<String, dynamic>.from(json));
  }

  String? get transactionType => raw['transaction_type']?.toString();

  Map<String, dynamic>? get info {
    final i = raw['info'];
    if (i is Map) return Map<String, dynamic>.from(i);
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

  double? get netAmount {
    final n = raw['net_amount'];
    if (n is num) return n.toDouble();
    return double.tryParse(n?.toString() ?? '');
  }

  double? get discount {
    final d = raw['discount'];
    if (d is num) return d.toDouble();
    return double.tryParse(d?.toString() ?? '');
  }
}
