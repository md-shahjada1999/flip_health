class LabTestModel {
  final String id;
  final String name;
  final String reportTime;
  final String? iconPath;
  final double? price;

  const LabTestModel({
    required this.id,
    required this.name,
    required this.reportTime,
    this.iconPath,
    this.price,
  });

  LabTestModel copyWith({
    String? id,
    String? name,
    String? reportTime,
    String? iconPath,
    double? price,
  }) {
    return LabTestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      reportTime: reportTime ?? this.reportTime,
      iconPath: iconPath ?? this.iconPath,
      price: price ?? this.price,
    );
  }
}

enum CollectionType { home, center, radiology }

class LabPackageModel {
  final String id;
  final String name;
  final double price;
  final List<String> includedTests;
  final CollectionType collectionType;

  const LabPackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.includedTests,
    this.collectionType = CollectionType.home,
  });
}

class LabTestPrice {
  final String testId;
  final String testName;
  final double price;

  const LabTestPrice({
    required this.testId,
    required this.testName,
    required this.price,
  });
}

class LabModel {
  final String id;
  final String name;
  final String logoPath;
  final String rating;
  final String? address;
  final String? distance;
  final List<LabTestPrice> testPrices;
  final double homeCollectionCharge;
  final List<CollectionType> supportedTypes;

  const LabModel({
    required this.id,
    required this.name,
    required this.logoPath,
    required this.rating,
    this.address,
    this.distance,
    required this.testPrices,
    this.homeCollectionCharge = 0,
    this.supportedTypes = const [CollectionType.home],
  });

  double get totalTestPrice =>
      testPrices.fold(0, (sum, tp) => sum + tp.price);

  double get totalPayable => totalTestPrice + homeCollectionCharge;
}
