/// Parsed item from `/patient/opd/wallet/transactions/{subscription_id}?page=`.
class OpdWalletTransaction {
  OpdWalletTransaction({
    required this.id,
    required this.paymentDate,
    required this.refType,
    required this.type,
    required this.amount,
    required this.status,
    this.note,
    required this.raw,
  });

  final String id;
  final String paymentDate;
  final String refType;
  /// `CREDIT` or `DEBIT`
  final String type;
  final num amount;
  /// Normalized: `success`, `refunded`, etc.
  final String status;
  final String? note;
  final Map<String, dynamic> raw;

  static String _normalizeStatus(dynamic raw) {
    final s = (raw ?? '').toString().toLowerCase();
    if (s == 'success' ||
        s == 'refunded' ||
        s == 'pending' ||
        s == 'failed') {
      return s;
    }
    if (s.contains('refund')) return 'refunded';
    if (s.contains('success') || s == 'completed' || s == 'paid') {
      return 'success';
    }
    return s.isNotEmpty ? s : 'success';
  }

  factory OpdWalletTransaction.fromJson(Map<String, dynamic> json) {
    String paymentDate = '';
    if (json['payment_date'] != null) {
      paymentDate = json['payment_date'].toString();
    } else if (json['createdAt'] != null) {
      paymentDate = json['createdAt'].toString();
    } else if (json['created_at'] != null) {
      paymentDate = json['created_at'].toString();
    }

    final typeRaw = (json['type'] ?? 'DEBIT').toString().toUpperCase();
    final type = typeRaw == 'CREDIT' ? 'CREDIT' : 'DEBIT';

    final refType = (json['ref_type'] ??
            json['module'] ??
            json['purpose'] ??
            '')
        .toString();

    num amount = 0;
    final a = json['amount'];
    if (a is num) {
      amount = a;
    } else if (a != null) {
      amount = num.tryParse(a.toString()) ?? 0;
    }

    final id = (json['id'] ?? json['transaction_id'] ?? json['_id'] ?? '')
        .toString();

    return OpdWalletTransaction(
      id: id.isEmpty ? paymentDate + refType : id,
      paymentDate: paymentDate,
      refType: refType,
      type: type,
      amount: amount,
      status: _normalizeStatus(json['status']),
      note: json['note']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
