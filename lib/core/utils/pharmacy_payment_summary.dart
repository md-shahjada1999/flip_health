import 'package:flip_health/model/pharmacy%20models/pharmacy_order_invoice_model.dart';

/// Human-readable visit type for success / detail UIs.
String pharmacyVisitTypeLabel(String? raw) {
  final v = raw?.trim() ?? '';
  switch (v) {
    case 'HOME_DELIVERY':
      return 'Home delivery';
    case 'SELF_PICKUP':
      return 'Self pickup';
    case 'STORE_PICKUP':
      return 'Store pickup';
    default:
      return v.isEmpty ? '—' : v;
  }
}

double? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

/// Best-effort amount the user paid (Razorpay: [pending_amount] on quote; wallet-only: [price] / totals).
double? _pickPaidAmount(Map<String, dynamic> merged) {
  final pending = _num(merged['pending_amount']);
  if (pending != null && pending > 0) return pending;
  final price = _num(merged['price']);
  if (price != null && price > 0) return price;
  return _num(merged['net_amount']) ??
      _num(merged['amount']) ??
      _num(merged['paid_amount']);
}

String _formatRupee(double? x) {
  if (x == null) return '—';
  if (x % 1 == 0) return '₹${x.toInt()}';
  return '₹${x.toStringAsFixed(2)}';
}

/// Data for [PharmacyPaymentSuccessScreen] after wallet or Razorpay confirmation.
Map<String, dynamic> buildPharmacyPaymentSuccessSummary({
  required PharmacyOrderInvoice invoice,
  Map<String, dynamic>? paymentQuote,
  Map<String, dynamic>? confirmResponse,
}) {
  final info = invoice.info ?? {};
  final invoiceId = invoice.raw['id']?.toString() ?? '';
  final orderId = info['id']?.toString();
  final visitRaw = info['visit_type']?.toString();
  final visitLabel = pharmacyVisitTypeLabel(visitRaw);
  final chronic = invoice.transactionType == 'CHRONIC_MED';
  final orderKind = chronic ? 'Chronic medicine' : 'Pharmacy';

  final merged = <String, dynamic>{};
  if (paymentQuote != null) merged.addAll(paymentQuote);
  if (confirmResponse != null) merged.addAll(confirmResponse);

  final paid = _pickPaidAmount(merged);

  return <String, dynamic>{
    'invoice_id': invoiceId,
    if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
    'visit_type': visitLabel,
    'order_kind': orderKind,
    'amount_paid': paid,
    'amount_paid_display': _formatRupee(paid),
  };
}
