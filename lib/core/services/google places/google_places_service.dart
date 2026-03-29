import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flip_health/core/services/google%20places/place_prediction.dart';

class GooglePlacesService {
  GooglePlacesService._();
  static final GooglePlacesService instance = GooglePlacesService._();

  final Dio _dio = Dio();
  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static const _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<List<PlacePrediction>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        '$_baseUrl/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _apiKey,
          'components': 'country:in',
        },
      );

      if (response.statusCode == 200) {
        final predictions = response.data['predictions'] as List? ?? [];
        return predictions
            .map((p) => PlacePrediction.fromJson(p))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<PlaceDetail?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry,formatted_address,address_components',
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final result = response.data['result'];
        if (result == null) return null;

        final location = result['geometry']?['location'];
        if (location == null) return null;

        String? city;
        String? pincode;
        final components = result['address_components'] as List? ?? [];
        for (final comp in components) {
          final types = (comp['types'] as List?)?.cast<String>() ?? [];
          if (types.contains('locality')) {
            city = comp['long_name'];
          }
          if (types.contains('postal_code')) {
            pincode = comp['long_name'];
          }
        }

        return PlaceDetail(
          latitude: (location['lat'] as num).toDouble(),
          longitude: (location['lng'] as num).toDouble(),
          formattedAddress: result['formatted_address'] ?? '',
          city: city,
          pincode: pincode,
        );
      }
    } catch (_) {}

    return null;
  }
}
