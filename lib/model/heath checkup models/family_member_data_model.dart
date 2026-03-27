class FamilyMember {
  final String id;
  final String name;
  final bool isSponsored;
  final String? sponsoredBy;
  final bool hasPackages;

  FamilyMember({
    required this.id,
    required this.name,
    this.isSponsored = false,
    this.sponsoredBy,
    this.hasPackages = false,
  });

  // Factory constructor for JSON
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isSponsored: json['isSponsored'] ?? false,
      sponsoredBy: json['sponsoredBy'],
      hasPackages: json['hasPackages'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isSponsored': isSponsored,
      'sponsoredBy': sponsoredBy,
      'hasPackages': hasPackages,
    };
  }
}
