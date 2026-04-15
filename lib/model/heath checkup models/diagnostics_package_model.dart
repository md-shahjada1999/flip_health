import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// DiagnosticsPackage — from GET /diagnostics/packages?type=special
// ---------------------------------------------------------------------------

class DiagnosticsPackage {
  final int id;
  final String name;
  final String? tags;
  final String type;
  final String category;
  final int fastingTime;
  final int tat;
  final AhcPackagePricing? pricing;

  const DiagnosticsPackage({
    required this.id,
    required this.name,
    this.tags,
    required this.type,
    required this.category,
    required this.fastingTime,
    required this.tat,
    this.pricing,
  });

  factory DiagnosticsPackage.fromJson(Map<String, dynamic> json) {
    return DiagnosticsPackage(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tags: json['tags'] as String?,
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      fastingTime: json['fasting_time'] as int? ?? 0,
      tat: json['tat'] as int? ?? 0,
      pricing: json['pricing'] is Map<String, dynamic>
          ? AhcPackagePricing.fromJson(json['pricing'])
          : null,
    );
  }

  String get fastingLabel => fastingTime > 0
      ? '$fastingTime hrs Fasting Required'
      : 'No Fasting Required';

  String get tatLabel {
    if (tat <= 0) return '';
    if (tat < 24) return 'Reports in $tat hrs';
    final days = tat ~/ 24;
    return days == 1 ? 'Reports in 1 day' : 'Reports in $days days';
  }

  bool get isPathology => category == 'pathology';
  bool get isRadiology => category == 'radiology';
  bool get isGroup => category == 'group';
}

// ---------------------------------------------------------------------------
// Inline pricing inside DiagnosticsPackage
// ---------------------------------------------------------------------------

class AhcPackagePricing {
  final int id;
  final int? fastingTime;
  final int? tat;
  final int parameterCount;
  final AhcPricingVendor? vendor;

  const AhcPackagePricing({
    required this.id,
    this.fastingTime,
    this.tat,
    required this.parameterCount,
    this.vendor,
  });

  factory AhcPackagePricing.fromJson(Map<String, dynamic> json) {
    return AhcPackagePricing(
      id: json['id'] as int? ?? 0,
      fastingTime: json['fasting_time'] as int?,
      tat: json['tat'] as int?,
      parameterCount: json['parameter_count'] as int? ?? 0,
      vendor: json['vendor'] is Map<String, dynamic>
          ? AhcPricingVendor.fromJson(json['vendor'])
          : null,
    );
  }
}

class AhcPricingVendor {
  final String name;
  final String code;
  final String? logo;

  const AhcPricingVendor({
    required this.name,
    required this.code,
    this.logo,
  });

  factory AhcPricingVendor.fromJson(Map<String, dynamic> json) {
    return AhcPricingVendor(
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      logo: json['logo'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Package detail (from GET /diagnostics/packages/{id})
// ---------------------------------------------------------------------------

class PackageParameter {
  final String name;

  const PackageParameter({required this.name});

  factory PackageParameter.fromJson(Map<String, dynamic> json) {
    return PackageParameter(name: json['name'] as String? ?? '');
  }
}

class PackageVendor {
  final String name;
  final String? logo;

  const PackageVendor({required this.name, this.logo});

  factory PackageVendor.fromJson(Map<String, dynamic> json) {
    return PackageVendor(
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
    );
  }
}

class PackageInfo {
  final int id;
  final String name;
  final String? tags;
  final String type;
  final String category;

  const PackageInfo({
    required this.id,
    required this.name,
    this.tags,
    required this.type,
    required this.category,
  });

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tags: json['tags'] as String?,
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }
}

class DiagnosticsPackageDetail {
  final int id;
  final String name;
  final int parameterCount;
  final List<PackageParameter> parameters;
  final String? details;
  final int fastingTime;
  final int? tat;
  final double b2cPrice;
  final double b2cMrp;
  final PackageInfo? info;
  final PackageVendor? vendor;

  const DiagnosticsPackageDetail({
    required this.id,
    required this.name,
    required this.parameterCount,
    required this.parameters,
    this.details,
    required this.fastingTime,
    this.tat,
    required this.b2cPrice,
    required this.b2cMrp,
    this.info,
    this.vendor,
  });

  factory DiagnosticsPackageDetail.fromJson(Map<String, dynamic> json) {
    return DiagnosticsPackageDetail(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      parameterCount: json['parameter_count'] as int? ?? 0,
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((e) => PackageParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      details: json['details'] as String?,
      fastingTime: json['fasting_time'] as int? ?? 0,
      tat: json['tat'] as int?,
      b2cPrice: (json['b2c_price'] as num?)?.toDouble() ?? 0,
      b2cMrp: (json['b2c_mrp'] as num?)?.toDouble() ?? 0,
      info: json['info'] != null
          ? PackageInfo.fromJson(json['info'] as Map<String, dynamic>)
          : null,
      vendor: json['vendor'] != null
          ? PackageVendor.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Vendor/Pricing response (from POST /diagnostics/sponsored/pricing)
// ---------------------------------------------------------------------------

class AhcVendorPricingResponse {
  final List<AhcVendor> pathologyVendors;
  final List<AhcVendor> radiologyVendors;
  final bool pathologyCategoryExists;
  final bool radiologyCategoryExists;

  const AhcVendorPricingResponse({
    required this.pathologyVendors,
    required this.radiologyVendors,
    required this.pathologyCategoryExists,
    required this.radiologyCategoryExists,
  });

  factory AhcVendorPricingResponse.fromJson(Map<String, dynamic> json) {
    final rawPath = json['pathology_vendor'];
    final rawRad = json['radiology_vendor'];

    return AhcVendorPricingResponse(
      pathologyVendors: _parseVendors(rawPath),
      radiologyVendors: _parseVendors(rawRad),
      pathologyCategoryExists: _vendorPayloadExists(rawPath),
      radiologyCategoryExists: _vendorPayloadExists(rawRad),
    );
  }

  /// Sponsored pricing may return a single vendor [Map] or a [List] (patient_app `ahcVendorDetails`).
  static bool _vendorPayloadExists(dynamic raw) {
    if (raw is List) return raw.isNotEmpty;
    if (raw is Map) return raw.isNotEmpty;
    return false;
  }

  static List<AhcVendor> _parseVendors(dynamic raw) {
    final maps = <Map<String, dynamic>>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          maps.add(e);
        } else if (e is Map) {
          maps.add(Map<String, dynamic>.from(e));
        }
      }
    } else if (raw is Map && raw.isNotEmpty) {
      maps.add(Map<String, dynamic>.from(raw));
    }
    return maps
        .map(AhcVendor.fromJson)
        .where((v) => v.code != 'unknown')
        .toList();
  }

  /// Whether selectable (non-unknown) vendors exist for display
  bool get hasSelectablePathology => pathologyVendors.isNotEmpty;
  bool get hasSelectableRadiology => radiologyVendors.isNotEmpty;

  /// Whether the category exists at all in the response (even if only unknown vendors)
  bool get hasPathology => pathologyCategoryExists;
  bool get hasRadiology => radiologyCategoryExists;
}

class AhcVendor {
  final int id;
  final String name;
  final String code;
  final String? logo;
  final String category;
  final double price;
  final List<AhcVendorPackage> packages;

  const AhcVendor({
    required this.id,
    required this.name,
    required this.code,
    this.logo,
    required this.category,
    required this.price,
    required this.packages,
  });

  factory AhcVendor.fromJson(Map<String, dynamic> json) {
    final rawList = json['packages'] as List<dynamic>?;
    final packages = <AhcVendorPackage>[];
    if (rawList != null) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          packages.add(AhcVendorPackage.fromJson(e));
        } else if (e is Map) {
          packages.add(
              AhcVendorPackage.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return AhcVendor(
      id: AhcVendorPackage._parseInt(json['id']),
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      logo: json['logo']?.toString(),
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      packages: packages,
    );
  }
}

class AhcVendorPackage {
  final int id;
  final String name;
  final String category;
  final bool free;
  final int qty;
  final AhcVendorUser? user;
  final AhcVendorItemPricing? pricing;

  const AhcVendorPackage({
    required this.id,
    required this.name,
    required this.category,
    this.free = false,
    this.qty = 1,
    this.user,
    this.pricing,
  });

  /// Display name for UI — API may use `name`, `package_name`, nested `package`, or `title`.
  static String _parsePackageName(Map<String, dynamic> json) {
    String? trimStr(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    final direct = trimStr(json['name']);
    if (direct != null) return direct;
    final packageName = trimStr(json['package_name']);
    if (packageName != null) return packageName;
    final title = trimStr(json['title']);
    if (title != null) return title;

    final pkg = json['package'];
    if (pkg is Map) {
      final m = Map<String, dynamic>.from(pkg);
      final n = trimStr(m['name']) ?? trimStr(m['title']);
      if (n != null) return n;
    }
    final info = json['info'];
    if (info is Map) {
      final m = Map<String, dynamic>.from(info);
      final n = trimStr(m['name']);
      if (n != null) return n;
    }
    return '';
  }

  static int _parseInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  factory AhcVendorPackage.fromJson(Map<String, dynamic> json) {
    return AhcVendorPackage(
      id: _parseInt(json['id']),
      name: _parsePackageName(json),
      category: json['category'] as String? ?? '',
      free: json['free'] == true,
      qty: _parseInt(json['qty'], 1),
      user: json['user'] is Map<String, dynamic>
          ? AhcVendorUser.fromJson(json['user'])
          : json['user'] is Map
              ? AhcVendorUser.fromJson(
                  Map<String, dynamic>.from(json['user'] as Map))
              : null,
      pricing: json['pricing'] is Map<String, dynamic>
          ? AhcVendorItemPricing.fromJson(json['pricing'])
          : json['pricing'] is Map
              ? AhcVendorItemPricing.fromJson(
                  Map<String, dynamic>.from(json['pricing'] as Map))
              : null,
    );
  }
}

class AhcVendorUser {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? dob;
  final String? gender;
  final int age;

  const AhcVendorUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.dob,
    this.gender,
    this.age = 0,
  });

  factory AhcVendorUser.fromJson(Map<String, dynamic> json) {
    return AhcVendorUser(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone']?.toString(),
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int? ?? 0,
    );
  }
}

class AhcVendorItemPricing {
  final int id;
  final int? fastingTime;
  final int? tat;
  final int parameterCount;
  final double b2cPrice;

  const AhcVendorItemPricing({
    required this.id,
    this.fastingTime,
    this.tat,
    required this.parameterCount,
    required this.b2cPrice,
  });

  factory AhcVendorItemPricing.fromJson(Map<String, dynamic> json) {
    return AhcVendorItemPricing(
      id: json['id'] as int? ?? 0,
      fastingTime: json['fasting_time'] as int?,
      tat: json['tat'] as int?,
      parameterCount: json['parameter_count'] as int? ?? 0,
      b2cPrice: (json['b2c_price'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Slot response (from POST /diagnostics/slots)
// ---------------------------------------------------------------------------

class AhcSlot {
  final String slotId;
  final String vendorCode;
  final String slotDate;
  final String startTime;
  final String endTime;

  const AhcSlot({
    required this.slotId,
    required this.vendorCode,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
  });

  factory AhcSlot.fromJson(Map<String, dynamic> json) {
    return AhcSlot(
      slotId: json['slot_id']?.toString() ?? '',
      vendorCode: json['vendor_code'] as String? ?? '',
      slotDate: json['slot_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'slot_id': slotId,
        'vendor_code': vendorCode,
        'slot_date': slotDate,
        'start_time': startTime,
        'end_time': endTime,
      };

  String get displayTime => '$startTime - $endTime';

  /// e.g. "Tuesday, 15 April 2025"
  String get formattedScheduleDate {
    if (slotDate.isEmpty) return '—';
    try {
      final d = DateTime.parse(slotDate);
      return DateFormat('EEEE, d MMMM y').format(d);
    } catch (_) {
      return slotDate;
    }
  }

  /// e.g. "9:00 AM – 10:00 AM"
  String get formattedScheduleTimeRange {
    final s = _parseClock(startTime);
    final e = _parseClock(endTime);
    if (s != null && e != null) {
      final ds = DateTime(1970, 1, 1, s.$1, s.$2, s.$3);
      final de = DateTime(1970, 1, 1, e.$1, e.$2, e.$3);
      return '${DateFormat.jm().format(ds)} – ${DateFormat.jm().format(de)}';
    }
    return displayTime;
  }

  static (int, int, int)? _parseClock(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final parts = t.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    var sec = 0;
    if (parts.length > 2) {
      sec = int.tryParse(parts[2].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return (h, m, sec);
  }
}

class AhcSlotsResponse {
  final List<AhcSlot> morning;
  final List<AhcSlot> afternoon;
  final List<AhcSlot> evening;

  const AhcSlotsResponse({
    required this.morning,
    required this.afternoon,
    required this.evening,
  });

  factory AhcSlotsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    List<AhcSlot> parse(String key) => (data[key] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => AhcSlot.fromJson(e))
            .toList() ??
        [];

    return AhcSlotsResponse(
      morning: parse('morning'),
      afternoon: parse('afternoon'),
      evening: parse('evening'),
    );
  }

  bool get isEmpty => morning.isEmpty && afternoon.isEmpty && evening.isEmpty;

  List<Map<String, dynamic>> toSlotMaps(List<AhcSlot> slots) {
    return slots
        .map((s) => <String, dynamic>{
              'time': s.displayTime,
              'isDisabled': false,
              'slot': s,
            })
        .toList();
  }
}
