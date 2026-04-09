import 'package:intl/intl.dart';

class LabTestRecordModel {
  final String id;
  final int patientId;
  final String title;
  final String date;
  final String category;
  final int status;
  final String statusText;
  final String? visitType;
  final String? source;
  final bool sponsored;
  final String? invoiceId;
  final String? orderId;
  final String? jobId;
  final String? reportUrl;
  final String? trackingUrl;
  final String? cancellationReason;

  final String? collectionDate;
  final String? collectionSlotTime;
  final List<LabTestCode> testCodes;
  final String? displayAddress;
  final String? centerName;
  final String? centerAddress;
  final String? additionalStatus;

  final DateTime createdAt;
  final DateTime updatedAt;

  const LabTestRecordModel({
    required this.id,
    required this.patientId,
    required this.title,
    required this.date,
    this.category = '',
    required this.status,
    this.statusText = '',
    this.visitType,
    this.source,
    this.sponsored = false,
    this.invoiceId,
    this.orderId,
    this.jobId,
    this.reportUrl,
    this.trackingUrl,
    this.cancellationReason,
    this.collectionDate,
    this.collectionSlotTime,
    this.testCodes = const [],
    this.displayAddress,
    this.centerName,
    this.centerAddress,
    this.additionalStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayDate {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (testCodes.isNotEmpty) return testCodes.first.name;
    return 'Lab Test';
  }

  String get statusLabel {
    if (cancellationReason != null && cancellationReason!.isNotEmpty) {
      return 'Cancelled';
    }
    final st = (additionalStatus ?? statusText).toUpperCase();
    if (st.contains('COMPLETED') || st.contains('CONFIRMED')) return 'Confirmed';
    if (st.contains('PENDING')) return 'Pending';
    if (st.contains('CANCELLED')) return 'Cancelled';
    if (st.contains('COLLECTED')) return 'Collected';
    if (st.contains('REPORTED')) return 'Reported';
    if (status == 1) return 'Active';
    if (status == 0) return 'Pending';
    return statusText.isNotEmpty ? statusText : 'Unknown';
  }

  bool get isHomePickup =>
      visitType?.toUpperCase() == 'HOME_PICKUP';

  String get visitTypeLabel =>
      isHomePickup ? 'Home Pickup' : 'Self Visit';

  int get totalParameters {
    int count = 0;
    for (final t in testCodes) {
      count += t.parameterCount;
    }
    return count;
  }

  factory LabTestRecordModel.fromJson(Map<String, dynamic> json) {
    final additionalInfo =
        json['additional_info'] as Map<String, dynamic>? ?? {};
    final rawTestCodes = additionalInfo['test_codes'] as List? ?? [];
    final address = json['address'];
    final center = additionalInfo['center'] as Map<String, dynamic>? ?? {};

    String? dispAddress;
    if (address is Map<String, dynamic>) {
      dispAddress = address['display_address']?.toString();
    }

    String? centerDispAddress;
    if (center.isNotEmpty) {
      final cAddr = center['address'];
      if (cAddr is Map<String, dynamic>) {
        centerDispAddress = cAddr['display_address']?.toString() ??
            [cAddr['line_1'], cAddr['city'], cAddr['state']]
                .where((e) => e != null && e.toString().isNotEmpty)
                .join(', ');
      }
      centerDispAddress ??= center['display_address']?.toString();
    }

    return LabTestRecordModel(
      id: (json['id'] ?? '').toString(),
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id']?.toString() ?? '') ?? 0,
      title: (json['title'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      statusText: (json['statusText'] ?? '').toString(),
      visitType: json['visit_type']?.toString(),
      source: json['source']?.toString(),
      sponsored: json['sponsored'] == true,
      invoiceId: json['invoice_id']?.toString(),
      orderId: json['order_id']?.toString(),
      jobId: json['jobId']?.toString(),
      reportUrl: json['reportUrl']?.toString(),
      trackingUrl: json['trackingUrl']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),
      collectionDate: additionalInfo['collection_date']?.toString(),
      collectionSlotTime: additionalInfo['collection_slot_time']?.toString(),
      testCodes: rawTestCodes
          .map((e) => LabTestCode.fromJson(e as Map<String, dynamic>))
          .toList(),
      displayAddress: dispAddress,
      centerName: center['name']?.toString(),
      centerAddress: centerDispAddress,
      additionalStatus: additionalInfo['status']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static List<LabTestRecordModel> fromResultsList(Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return list
        .map((e) => LabTestRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class LabTestCode {
  final int id;
  final String name;
  final String type;
  final String category;
  final int parameterCount;
  final double? b2cPrice;
  final double? offerPrice;

  const LabTestCode({
    required this.id,
    required this.name,
    this.type = '',
    this.category = '',
    this.parameterCount = 0,
    this.b2cPrice,
    this.offerPrice,
  });

  factory LabTestCode.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] as Map<String, dynamic>? ?? {};
    return LabTestCode(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      parameterCount: pricing['parameter_count'] is int
          ? pricing['parameter_count']
          : int.tryParse(pricing['parameter_count']?.toString() ?? '') ?? 0,
      b2cPrice: _toDouble(pricing['b2c_price']),
      offerPrice: _toDouble(pricing['offer_price']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
