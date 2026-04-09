class DiagnosticsPackage {
  final int id;
  final String name;
  final String? tags;
  final String type;
  final String category;
  final int fastingTime;
  final int tat;

  const DiagnosticsPackage({
    required this.id,
    required this.name,
    this.tags,
    required this.type,
    required this.category,
    required this.fastingTime,
    required this.tat,
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
}

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
