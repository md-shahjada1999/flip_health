import 'package:intl/intl.dart';
import 'package:flip_health/model/service_request_invoice_model.dart';

/// Prefer `slot` (date + start/end); else human-readable `preferred_date_time` / `booking_time`.
String formatServiceRequestPreferredSlot(Map<String, dynamic> details) {
  final slotRaw = details['slot'];
  if (slotRaw is Map) {
    final slot = Map<String, dynamic>.from(slotRaw);
    final dateStr = slot['slot_date']?.toString().trim() ?? '';
    final start = slot['start_time']?.toString().trim() ?? '';
    final end = slot['end_time']?.toString().trim() ?? '';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(
          dateStr.contains('T') ? dateStr : '${dateStr}T12:00:00',
        );
        final dateFmt = DateFormat('dd MMM yyyy').format(dt.toLocal());
        if (start.isNotEmpty && end.isNotEmpty) {
          return '$dateFmt · $start – $end';
        }
        if (start.isNotEmpty) return '$dateFmt · $start';
        return dateFmt;
      } catch (_) {}
    }
    if (start.isNotEmpty || end.isNotEmpty) {
      if (start.isNotEmpty && end.isNotEmpty) return '$start – $end';
      return start.isNotEmpty ? start : end;
    }
  }
  final raw = details['preferred_date_time']?.toString() ??
      details['booking_time']?.toString();
  return _formatServiceRequestDateTimeHuman(raw);
}

String _formatServiceRequestDateTimeHuman(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final s = raw.trim();
  var d = DateTime.tryParse(s);
  if (d == null && s.contains(' ') && !s.contains('T')) {
    d = DateTime.tryParse(s.replaceFirst(' ', 'T'));
  }
  if (d == null) return raw;
  return DateFormat('dd MMM yyyy, hh:mm a').format(d.toLocal());
}

double? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

String _formatRupee(double? x) {
  if (x == null) return '—';
  if (x % 1 == 0) return '₹${x.toInt()}';
  return '₹${x.toStringAsFixed(2)}';
}

double? _pickPaidAmount(Map<String, dynamic> merged) {
  final pending = _num(merged['pending_amount']);
  if (pending != null && pending > 0) return pending;
  final price = _num(merged['price']);
  if (price != null && price > 0) return price;
  return _num(merged['net_amount']) ??
      _num(merged['amount']) ??
      _num(merged['paid_amount']);
}

/// Snapshot for [ServiceRequestPaymentSuccessScreen] after wallet or Razorpay.
Map<String, dynamic> buildServiceRequestPaymentSuccessSummary({
  required ServiceRequestInvoice invoice,
  required String serviceTitle,
  required String serviceRouteKey,
  Map<String, dynamic>? paymentQuote,
  Map<String, dynamic>? confirmResponse,
}) {
  final info = invoice.info ?? {};
  final detailsRaw = info['details'];
  final detailsMap = detailsRaw is Map
      ? Map<String, dynamic>.from(detailsRaw)
      : <String, dynamic>{};

  final invoiceId = invoice.raw['id']?.toString() ?? '';
  final orderId = info['id']?.toString();
  final visitRaw = info['visit_type']?.toString();
  final visitLabel =
      visitRaw == null || visitRaw.isEmpty ? '—' : visitRaw.replaceAll('_', ' ');

  final merged = <String, dynamic>{};
  if (paymentQuote != null) merged.addAll(paymentQuote);
  if (confirmResponse != null) merged.addAll(confirmResponse);

  final paid = _pickPaidAmount(merged);

  return <String, dynamic>{
    'invoice_id': invoiceId,
    if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
    'service_title': serviceTitle,
    'service': serviceRouteKey,
    'visit_type': visitLabel,
    'preferred_slot': formatServiceRequestPreferredSlot(detailsMap),
    'amount_paid': paid,
    'amount_paid_display': _formatRupee(paid),
  };
}
