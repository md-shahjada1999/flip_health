/// Response model for PATCH /healthscore
///
/// Example response:
/// ```json
/// {
///   "health_score": {
///     "bmi": 25.55,
///     "height": "5.7",
///     "weight": 74,
///     "patient_id": 1002908,
///     "nutrition_suggestion": true
///   },
///   "message": "Record successfully updated"
/// }
/// ```
class HealthScoreApiResponse {
  final HealthScoreData healthScore;
  final String message;

  const HealthScoreApiResponse({
    required this.healthScore,
    required this.message,
  });

  factory HealthScoreApiResponse.fromJson(Map<String, dynamic> json) =>
      HealthScoreApiResponse(
        healthScore:
            HealthScoreData.fromJson(json['health_score'] as Map<String, dynamic>? ?? {}),
        message: json['message']?.toString() ?? '',
      );
}

class HealthScoreData {
  final double bmi;
  final String height;
  final double weight;
  final int patientId;
  final bool nutritionSuggestion;

  const HealthScoreData({
    required this.bmi,
    required this.height,
    required this.weight,
    required this.patientId,
    required this.nutritionSuggestion,
  });

  factory HealthScoreData.fromJson(Map<String, dynamic> json) =>
      HealthScoreData(
        bmi: _toDouble(json['bmi']),
        height: json['height']?.toString() ?? '0',
        weight: _toDouble(json['weight']),
        patientId: _toInt(json['patient_id']),
        nutritionSuggestion: json['nutrition_suggestion'] == true,
      );

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
