// ignore_for_file: public_member_api_docs

class OrderItem {
  final String name;
  final double price;

  const OrderItem({required this.name, required this.price});
}

class Order {
  final String id;
  final String type;
  final String patientName;
  final DateTime date;
  final double amount;
  final String status;
  final String vendorName;
  final List<OrderItem> items;

  /// Original invoice row from `/patient/invoice` list (for navigation / detail).
  final Map<String, dynamic>? rawJson;

  Order({
    required this.id,
    required this.type,
    required this.patientName,
    required this.date,
    required this.amount,
    required this.status,
    required this.vendorName,
    required this.items,
    this.rawJson,
  });

  factory Order.fromInvoiceJson(Map<String, dynamic> json) {
    var info = _asMap(json['info']);
    if (info.isEmpty) {
      info = _asMap(json['invoice']);
    }
    final id = _firstNonEmpty([
      info['id']?.toString(),
      json['id']?.toString(),
      json['invoice_id']?.toString(),
      json['invoiceId']?.toString(),
    ]);
    final tx = _transactionType(json);

    final date = _parseDate(json, info);
    final amount = _parseAmount(json);
    final patientName = _patientName(json, info);
    final vendorName = _vendorName(info);
    final items = _buildLineItems(json, info, amount, tx);
    final status = _mapStatus(json, info, tx);

    return Order(
      id: id.isEmpty ? '—' : id,
      type: _displayType(tx),
      patientName: patientName,
      date: date,
      amount: amount,
      status: status,
      vendorName: vendorName.isEmpty ? '—' : vendorName,
      items: items,
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  /// Show list price only once the order is in a paid / confirmed state (not pending quotes).
  bool get shouldShowPaidAmount {
    final s = status.toLowerCase();
    if (s.contains('cancelled') ||
        s.contains('expired') ||
        s.contains('refund') ||
        s.contains('failed')) {
      return false;
    }
    return s.contains('completed') ||
        s.contains('confirmed') ||
        s.contains('booked') ||
        s.contains('upcoming session');
  }
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return {};
}

String _firstNonEmpty(List<String?> parts) {
  for (final p in parts) {
    if (p != null && p.trim().isNotEmpty) return p.trim();
  }
  return '';
}

String _transactionType(Map<String, dynamic> json) {
  final raw = _firstNonEmpty([
    json['transaction_type']?.toString(),
    json['transactionType']?.toString(),
    json['service_type']?.toString(),
    json['serviceType']?.toString(),
    json['category']?.toString(),
    json['type']?.toString(),
  ]);
  if (raw.isEmpty) return '';
  return raw.replaceAll(' ', '_').replaceAll('-', '_').toUpperCase();
}

DateTime _parseDate(Map<String, dynamic> json, Map<String, dynamic> info) {
  final created = _firstNonEmpty([
    json['createdAt']?.toString(),
    json['created_at']?.toString(),
    json['invoice_date']?.toString(),
    json['created']?.toString(),
  ]);
  if (created.isNotEmpty) {
    final d = DateTime.tryParse(created);
    if (d != null) return d.toLocal();
  }
  final dateStr = info['date']?.toString();
  final timeStr = info['time']?.toString();
  if (dateStr != null && dateStr.isNotEmpty) {
    final combined = timeStr != null && timeStr.isNotEmpty
        ? '${dateStr}T$timeStr'
        : dateStr;
    final d = DateTime.tryParse(combined);
    if (d != null) return d.toLocal();
  }
  return DateTime.now();
}

double _parseAmount(Map<String, dynamic> json) {
  final keys = [
    'net_amount',
    'netAmount',
    'total',
    'total_amount',
    'totalAmount',
    'amount',
    'grand_total',
  ];
  for (final k in keys) {
    final n = json[k];
    if (n is num) return n.toDouble();
    if (n is String) {
      final v = double.tryParse(n);
      if (v != null) return v;
    }
  }
  return 0;
}

String? _trimName(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

String _patientName(Map<String, dynamic> json, Map<String, dynamic> info) {
  final u = _asMap(json['user']);
  final m = _asMap(json['member']);
  final iu = _asMap(info['user']);
  final im = _asMap(info['member']);
  final patientObj = _asMap(info['patient']);
  if (patientObj.isEmpty) {
    // `patient` may be a string in some payloads
    final pRaw = info['patient'];
    if (pRaw is String && pRaw.trim().isNotEmpty) return pRaw.trim();
  }
  final details = _asMap(info['details']);
  final add = _asMap(info['additional_info']);

  final candidates = <String?>[
    _trimName(u['name']?.toString()),
    _trimName(iu['name']?.toString()),
    _trimName(m['name']?.toString()),
    _trimName(im['name']?.toString()),
    _trimName(patientObj['name']?.toString()),
    _trimName(patientObj['full_name']?.toString()),
    _trimName(details['patient_name']?.toString()),
    _trimName(_asMap(details['patient'])['name']?.toString()),
    _trimName(add['patient_name']?.toString()),
    _trimName(json['patient_name']?.toString()),
    _trimName(json['patientName']?.toString()),
    _trimName(info['patient_name']?.toString()),
    _trimName(info['member_name']?.toString()),
    _trimName(info['name']?.toString()),
    _trimName(json['name']?.toString()),
  ];
  for (final c in candidates) {
    if (c != null) return c;
  }
  return '—';
}

String _vendorName(Map<String, dynamic> info) {
  final keys = [
    'hospital_name',
    'hospital',
    'lab_name',
    'vendor_name',
    'vendor',
    'source',
    'clinic_name',
  ];
  for (final k in keys) {
    final v = info[k]?.toString();
    if (v != null && v.trim().isNotEmpty) return v.trim();
  }
  return '';
}

String _displayType(String tx) {
  switch (tx) {
    case 'CONSULTATION':
      return 'Consultation';
    case 'LABTEST':
      return 'Lab Test';
    case 'PHARMACY':
    case 'CHRONIC_MED':
      return 'Pharmacy';
    case 'DENTAL':
      return 'Dental';
    case 'VISION':
      return 'Vision';
    case 'VACCINE':
      return 'Vaccine';
    case 'GYM_OPT_IN':
    case 'GYM':
      return 'Gym';
    case 'MENTALWELLNESS':
    case 'YOGA':
      return 'Mental Wellness';
    case 'NUTRITION':
      return 'Nutrition';
    case 'PLAN':
      return 'Subscriptions';
    case 'CHRONIC_OPT_IN':
      return 'Chronic';
    default:
      if (tx.isEmpty) return 'Order';
      return tx
          .split('_')
          .map(
            (w) => w.isEmpty
                ? ''
                : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
          )
          .join(' ');
  }
}

String _mapStatus(
  Map<String, dynamic> json,
  Map<String, dynamic> info,
  String tx,
) {
  final payment = json['status']?.toString().toLowerCase() ?? '';
  if (['cancelled', 'canceled', 'failed', 'refunded'].contains(payment)) {
    return 'Cancelled';
  }
  if (['success', 'paid', 'completed', 'complete'].contains(payment)) {
    return 'Completed';
  }
  if (['pending', 'created', 'processing'].contains(payment)) {
    return payment == 'processing' ? 'Processing' : 'Pending';
  }

  final st = info['status'];
  if (st is int) {
    switch (st) {
      case 1:
        return 'Completed';
      case 2:
        return 'Cancelled';
      case 9:
        return 'Expired';
      case 4:
        return 'Payment pending';
      case 5:
        return 'Confirmed';
      case 3:
        return 'Confirm details';
      case 0:
        return 'Awaiting confirmation';
      case 6:
        return 'In progress';
      case 7:
      case 8:
        return 'Processing';
      default:
        break;
    }
  }

  final stStr = info['status']?.toString().toLowerCase() ?? '';
  if (stStr.contains('cancel')) return 'Cancelled';
  if (stStr.contains('complete') || stStr.contains('paid')) {
    return 'Completed';
  }

  if (tx == 'CONSULTATION' && info['date'] == null) {
    return 'Pending';
  }

  return 'Processing';
}

List<OrderItem> _buildLineItems(
  Map<String, dynamic> json,
  Map<String, dynamic> info,
  double amount,
  String tx,
) {
  final orders = json['orders'];
  if (orders is List && orders.isNotEmpty) {
    final out = <OrderItem>[];
    for (final o in orders) {
      final m = _asMap(o);
      final name = m['name']?.toString() ?? m['title']?.toString() ?? 'Item';
      final p = m['price'];
      final price = p is num
          ? p.toDouble()
          : double.tryParse(p?.toString() ?? '') ?? 0;
      out.add(OrderItem(name: name, price: price));
    }
    if (out.isNotEmpty) return out;
  }

  final label = info['service']?.toString() ??
      info['plan']?.toString() ??
      _displayType(tx);
  return [
    OrderItem(
      name: label.isEmpty ? 'Service' : label,
      price: amount,
    ),
  ];
}
