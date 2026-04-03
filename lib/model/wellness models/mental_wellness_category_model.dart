/// Item from GET `/patient/mental_wellness/type` → `data[]` (patient_app uses `value`).
class MentalWellnessCategoryModel {
  final String value;

  const MentalWellnessCategoryModel({required this.value});

  factory MentalWellnessCategoryModel.fromJson(Map<String, dynamic> json) {
    return MentalWellnessCategoryModel(
      value: json['value']?.toString() ?? '',
    );
  }
}
