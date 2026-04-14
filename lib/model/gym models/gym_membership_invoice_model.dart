/// Invoice payload from `GET /patient/invoice/{id}` for gym membership orders.
class GymMembershipInvoice {
  GymMembershipInvoice._(this.raw);

  final Map<String, dynamic> raw;

  factory GymMembershipInvoice.fromJson(Map<String, dynamic> json) {
    return GymMembershipInvoice._(Map<String, dynamic>.from(json));
  }

  String? get id => raw['id']?.toString();

  String? get transactionType => raw['transaction_type']?.toString();

  String? get status => raw['status']?.toString();

  Map<String, dynamic>? get info {
    final v = raw['info'];
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  List<dynamic> get details {
    final v = raw['details'];
    return v is List ? v : const [];
  }

  List<dynamic> get payments {
    final v = raw['payments'];
    return v is List ? v : const [];
  }

  double? get netAmount {
    final v = raw['net_amount'];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }

  double? get paidAmount {
    final v = raw['paid_amount'];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }

  double? get pendingAmount {
    final v = raw['pending_amount'];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }
}
