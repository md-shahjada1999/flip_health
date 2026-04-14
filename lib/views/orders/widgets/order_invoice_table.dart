import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

/// Invoice lines + totals shared across order types (pharmacy, chronic, service request, wellness, etc.).
class OrderInvoiceTable extends StatelessWidget {
  const OrderInvoiceTable({
    super.key,
    required this.lines,
    required this.invoice,
  });

  final List<dynamic> lines;
  final Map<String, dynamic> invoice;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return _SectionCard(
        title: 'Invoice details',
        child: CommonText(
          'No line items',
          fontSize: 12.rf,
          color: AppColors.textSecondary,
        ),
      );
    }

    final rows = <TableRow>[
      TableRow(
        decoration: BoxDecoration(color: AppColors.backgroundSecondary),
        children: [
          _h('Description'),
          _h('MRP', end: true),
          _h('Price', end: true),
          _h('Qty', end: true),
          _h('Amount', end: true),
        ],
      ),
    ];

    for (final line in lines) {
      if (line is! Map) continue;
      final m = Map<String, dynamic>.from(line);
      final cells = _lineCells(m);
      rows.add(
        TableRow(
          children: [
            _desc(cells.description, message: cells.paymentMessage),
            _c(cells.mrp, end: true),
            _c(cells.price, end: true),
            _c(cells.qty, end: true),
            _c(cells.amount, end: true),
          ],
        ),
      );
    }

    final summary = _Totals.compute(lines: lines, invoice: invoice);

    return _SectionCard(
      title: 'Invoice details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(2.6),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(0.75),
                      4: FlexColumnWidth(1.15),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(color: AppColors.divider),
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                    children: rows,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12.rh),
          Divider(height: 1, color: AppColors.divider),
          _sum('Total', _fmtRupee(summary.itemsTotal)),
          _sum(
            'Convenience charges',
            '+ ${_fmtRupee(summary.convenienceCharges)}',
          ),
          if (_Totals._deliveryFor(invoice) > 0)
            _sum(
              'Delivery charges',
              '+ ${_fmtRupee(_Totals._deliveryFor(invoice))}',
            ),
          _sum('Saved', '- ${_fmtRupee(summary.saved)}'),
          SizedBox(height: 8.rh),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 12.rh),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12.rs),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  'Net amount',
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                CommonText(
                  _fmtRupee(summary.netAmount),
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _h(String t, {bool end = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 6.rw),
      child: Align(
        alignment: end ? Alignment.centerRight : Alignment.centerLeft,
        child: CommonText(
          t,
          fontSize: 11.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  static Widget _c(String t, {bool end = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 6.rw),
      child: Align(
        alignment: end ? Alignment.centerRight : Alignment.centerLeft,
        child: CommonText(t, fontSize: 11.rf, color: AppColors.textPrimary),
      ),
    );
  }

  static Widget _desc(String title, {String? message}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 6.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: 11.rf, color: AppColors.textPrimary),
          if (message != null && message.isNotEmpty) ...[
            SizedBox(height: 2.rh),
            CommonText(
              message,
              fontSize: 10.rf,
              fontWeight: FontWeight.w500,
              color: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  static Widget _sum(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 8.rh),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(label, fontSize: 12.rf, color: AppColors.textSecondary),
          CommonText(
            value,
            fontSize: 12.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _LineCells {
  _LineCells({
    required this.description,
    required this.mrp,
    required this.price,
    required this.qty,
    required this.amount,
    this.paymentMessage,
  });

  final String description;
  final String mrp;
  final String price;
  final String qty;
  final String amount;
  final String? paymentMessage;
}

_LineCells _lineCells(Map<String, dynamic> line) {
  double? n(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  final productName = line['product_name']?.toString().trim();
  final description = (productName != null && productName.isNotEmpty)
      ? productName
      : _lineTitle(line);

  final mrpVal = n(line['price']);
  final offerVal = n(line['offer_price']);
  final qtyRaw = n(line['qty']);
  final qtyNeg = qtyRaw != null && qtyRaw < 0;

  final mrpStr = mrpVal != null ? _fmtRupee(mrpVal) : '—';
  final priceStr = offerVal != null ? _fmtRupee(offerVal) : '—';
  final qtyStr = qtyNeg ? '—' : (qtyRaw == null ? '—' : _fmtQty(qtyRaw));

  String amountStr;
  if (qtyNeg || offerVal == null || qtyRaw == null) {
    amountStr = '—';
  } else {
    amountStr = _fmtRupee(qtyRaw * offerVal);
  }

  final paymentMessage = _linePaymentMessage(line);

  return _LineCells(
    description: description,
    mrp: mrpStr,
    price: priceStr,
    qty: qtyStr,
    amount: amountStr,
    paymentMessage: paymentMessage,
  );
}

String? _linePaymentMessage(Map<String, dynamic> line) {
  bool? asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return null;
  }

  const keys = <String>[
    'payment_required',
    'is_payment_required',
    'isPaymentRequired',
    'payment_pending',
    'paymentPending',
  ];
  for (final k in keys) {
    final b = asBool(line[k]);
    if (b == true) return 'Payment required for this item';
  }

  final statusRaw = line['status'];
  if (statusRaw is int && statusRaw == 4) {
    return 'Payment required for this item';
  }
  if (statusRaw is String) {
    final s = statusRaw.trim().toLowerCase();
    if (s == 'payment_pending' ||
        s == 'pending_payment' ||
        s == 'unpaid' ||
        s == 'pending') {
      return 'Payment required for this item';
    }
  }

  return null;
}

String _lineTitle(Map<String, dynamic> line) {
  final n = line['name'];
  if (n is Map) {
    final m = Map<String, dynamic>.from(n);
    return m['title']?.toString() ??
        m['product_name']?.toString() ??
        m['name']?.toString() ??
        'Item';
  }
  return line['product_name']?.toString() ??
      n?.toString() ??
      line['title']?.toString() ??
      'Item';
}

String _fmtQty(double? q) {
  if (q == null) return '0';
  if (q % 1 == 0) return q.toInt().toString();
  return q.toString();
}

String _fmtRupee(double? x) {
  if (x == null) return '—';
  if (x % 1 == 0) return '₹${x.toInt()}';
  return '₹${x.toStringAsFixed(2)}';
}

class _Totals {
  _Totals({
    required this.itemsTotal,
    required this.convenienceCharges,
    required this.saved,
    required this.netAmount,
  });

  final double itemsTotal;
  final double convenienceCharges;
  final double saved;
  final double netAmount;

  static double _deliveryFor(Map<String, dynamic> invoice) {
    final add = invoice['additional_info'];
    final addMap = add is Map
        ? Map<String, dynamic>.from(add)
        : <String, dynamic>{};
    final tt = invoice['transaction_type']?.toString() ?? '';
    double? n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    if (tt == 'PHARMACY' || tt == 'CHRONIC_MED') {
      return n(addMap['delivery_charges']) ?? 0;
    }
    return 0;
  }

  static _Totals compute({
    required List<dynamic> lines,
    required Map<String, dynamic> invoice,
  }) {
    double? n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    double itemsSum = 0;
    for (final line in lines) {
      if (line is! Map) continue;
      final m = Map<String, dynamic>.from(line);
      final offer = n(m['offer_price']);
      final qty = n(m['qty']);
      if (offer == null || qty == null || qty < 0) continue;
      itemsSum += qty * offer;
    }

    final add = invoice['additional_info'];
    final addMap = add is Map
        ? Map<String, dynamic>.from(add)
        : <String, dynamic>{};
    final tt = invoice['transaction_type']?.toString() ?? '';

    final delivery = (tt == 'PHARMACY' || tt == 'CHRONIC_MED')
        ? (n(addMap['delivery_charges']) ?? 0)
        : 0.0;
    final collection = tt == 'LABTEST'
        ? (n(addMap['collection_fee']) ?? 0)
        : 0.0;
    final convenience = n(addMap['processing_fee']) ?? 0.0;
    final discount = n(invoice['discount']) ?? 0.0;

    final netComputed =
        itemsSum + convenience + delivery + collection - discount;

    final netApi = n(invoice['net_amount']);
    final netAmount = netApi ?? netComputed;

    return _Totals(
      itemsTotal: itemsSum,
      convenienceCharges: convenience,
      saved: discount,
      netAmount: netAmount,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            title,
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          Divider(height: 20.rh, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}
