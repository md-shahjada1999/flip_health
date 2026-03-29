class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] ?? {};
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structured['main_text'] ?? '',
      secondaryText: structured['secondary_text'] ?? '',
    );
  }
}

class PlaceDetail {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String? city;
  final String? pincode;

  const PlaceDetail({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.city,
    this.pincode,
  });
}
