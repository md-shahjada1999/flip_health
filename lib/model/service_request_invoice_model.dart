/// Invoice payload from `GET /patient/invoice/{id}` for service requests
/// (dental / vision / vaccine).
class ServiceRequestInvoice {
  ServiceRequestInvoice._(this.raw);

  final Map<String, dynamic> raw;

  factory ServiceRequestInvoice.fromJson(Map<String, dynamic> json) {
    return ServiceRequestInvoice._(Map<String, dynamic>.from(json));
  }

  String? get transactionType => raw['transaction_type']?.toString();

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

  Map<String, dynamic>? get additionalInfo {
    final v = raw['additional_info'];
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
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
}
