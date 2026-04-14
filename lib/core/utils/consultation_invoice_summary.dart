import 'package:intl/intl.dart';

/// Formats consultation date/time like [consultation_order_detail_screen].
String formatConsultationSchedule(String? date, String? time) {
  if (date == null || date.isEmpty) return '—';
  final t = time?.trim() ?? '';
  try {
    late DateTime dt;
    if (date.contains('T')) {
      dt = DateTime.parse(date);
    } else if (t.isNotEmpty) {
      final combined = '${date}T$t';
      dt = DateTime.parse(combined);
    } else {
      dt = DateTime.parse(date);
    }
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
  } catch (_) {
    return t.isNotEmpty ? '$date $t'.trim() : date;
  }
}

String? _pickVendor(
  Map<String, dynamic> inv,
  Map<String, dynamic> info,
) {
  Map<String, dynamic> u = {};
  Map<String, dynamic> m = {};
  if (inv['user'] is Map) {
    u = Map<String, dynamic>.from(inv['user'] as Map);
  }
  if (inv['member'] is Map) {
    m = Map<String, dynamic>.from(inv['member'] as Map);
  }
  for (final k in [
    'hospital_name',
    'vendor_name',
    'clinic_name',
    'hospital',
    'clinic',
  ]) {
    final v = u[k] ?? m[k] ?? info[k];
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}

String? _onlineDoctorName(Map<String, dynamic> info) {
  final doc = info['doctor'];
  if (doc is! Map) return null;
  final d = Map<String, dynamic>.from(doc);
  final rawName = d['name'];
  if (rawName is Map) {
    final m = Map<String, dynamic>.from(rawName);
    return m['name']?.toString() ??
        m['doctor_name']?.toString() ??
        m['full_name']?.toString();
  }
  final top = rawName?.toString();
  if (top != null && top.isNotEmpty) return top;
  return null;
}

String? _onlineDoctorSpecialty(Map<String, dynamic> info) {
  final doc = info['doctor'];
  if (doc is! Map) return null;
  final d = Map<String, dynamic>.from(doc);
  final rawName = d['name'];
  if (rawName is Map) {
    final m = Map<String, dynamic>.from(rawName);
    final sr = m['speciality'] ?? m['specialty'];
    if (sr is Map) {
      final n = sr['name']?.toString().trim();
      if (n != null && n.isNotEmpty) return n;
    }
  }
  try {
    final spec = d['speciality'] ?? d['specialty'];
    if (spec is Map) {
      final n = spec['name']?.toString().trim();
      if (n != null && n.isNotEmpty) return n;
    }
  } catch (_) {}
  return null;
}

/// Offline visit: same field resolution as the consultation order detail offline card.
Map<String, String?> _offlineBits(Map<String, dynamic> info) {
  final addl = info['additional_info'];
  final addMap = addl is Map
      ? Map<String, dynamic>.from(addl)
      : <String, dynamic>{};
  final booking = addMap['booking_details'];
  final bookMap = booking is Map
      ? Map<String, dynamic>.from(booking)
      : <String, dynamic>{};
  final clinic = addMap['clinic'];
  final clinMap = clinic is Map
      ? Map<String, dynamic>.from(clinic)
      : <String, dynamic>{};

  var specialty = '';
  final spec = addMap['speciality'];
  if (spec is Map && spec['specialty'] != null) {
    specialty = spec['specialty'].toString();
  }
  if (specialty.isEmpty) {
    specialty = clinMap['specialty']?.toString() ?? '';
  }
  if (specialty.isEmpty) {
    final specs = bookMap['specialties'];
    if (specs is List && specs.isNotEmpty) {
      specialty = specs.first.toString();
    }
  }

  final doctorName = bookMap['doctor_name']?.toString() ??
      bookMap['name']?.toString() ??
      clinMap['name']?.toString();

  final clinicName = bookMap['clinic_name']?.toString() ??
      clinMap['clinic_name']?.toString();

  final address = bookMap['clinic_address']?.toString() ??
      bookMap['address']?.toString() ??
      clinMap['address']?.toString();

  return {
    'doctor_name': doctorName,
    'specialty': specialty.isNotEmpty ? specialty : null,
    'hospital_name': clinicName,
    'address': (address != null && address.trim().isNotEmpty)
        ? address.trim()
        : null,
  };
}

/// Snapshot for the post-payment success screen (online & offline).
Map<String, dynamic> buildConsultationPaymentSuccessSummary(
  Map<String, dynamic> invoiceDetail,
) {
  final infoRaw = invoiceDetail['info'];
  if (infoRaw is! Map) return {};
  final info = Map<String, dynamic>.from(infoRaw);
  final comm = info['communication']?.toString().toUpperCase() ?? '';

  String visitType;
  if (comm == 'ONLINE') {
    visitType = 'Virtual consultation';
  } else if (comm == 'OFFLINE') {
    visitType = 'In-person visit';
  } else {
    visitType = comm.isNotEmpty ? comm : 'Consultation';
  }

  final schedule = formatConsultationSchedule(
    info['date']?.toString(),
    info['time']?.toString(),
  );

  String? doctorName;
  String? specialty;
  String? hospitalName;
  String? address;

  if (comm == 'OFFLINE') {
    final off = _offlineBits(info);
    doctorName = off['doctor_name'];
    specialty = off['specialty'];
    hospitalName = off['hospital_name'];
    address = off['address'];
  } else {
    doctorName = _onlineDoctorName(info);
    specialty = _onlineDoctorSpecialty(info);
    hospitalName = _pickVendor(invoiceDetail, info);
  }

  final purpose = info['purpose']?.toString().trim();
  final id = info['id']?.toString();

  final invoiceId = invoiceDetail['id']?.toString();
  final amountPaid = _consultationAmountPaid(invoiceDetail);

  return {
    'schedule': schedule,
    'visit_type': visitType,
    'is_virtual': comm == 'ONLINE',
    if (doctorName != null && doctorName.isNotEmpty) 'doctor_name': doctorName,
    if (specialty != null && specialty.isNotEmpty) 'specialty': specialty,
    if (hospitalName != null && hospitalName.isNotEmpty)
      'hospital_name': hospitalName,
    if (address != null && address.isNotEmpty) 'address': address,
    if (purpose != null && purpose.isNotEmpty) 'purpose': purpose,
    if (id != null && id.isNotEmpty) 'appointment_id': id,
    if (invoiceId != null && invoiceId.isNotEmpty) 'invoice_id': invoiceId,
    if (amountPaid != null) 'amount_paid': amountPaid,
    'amount_paid_display': _formatRupee(amountPaid),
  };
}

double? _consultationAmountPaid(Map<String, dynamic> invoiceDetail) {
  double? n(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  final paid = n(invoiceDetail['paid_amount']);
  if (paid != null && paid > 0) return paid;
  final net = n(invoiceDetail['net_amount']);
  if (net != null && net > 0) return net;
  final pending = n(invoiceDetail['pending_amount']);
  if (pending != null && pending > 0) return pending;
  return net ?? paid ?? pending;
}

String _formatRupee(double? x) {
  if (x == null) return '—';
  if (x % 1 == 0) return '₹${x.toInt()}';
  return '₹${x.toStringAsFixed(2)}';
}
