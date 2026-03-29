enum ConsultationType { hospital, virtual_ }

class SpecialityModel {
  final String id;
  final String name;
  final String? iconPath;

  const SpecialityModel({
    required this.id,
    required this.name,
    this.iconPath,
  });
}

class HospitalModel {
  final String id;
  final String name;
  final String logoPath;
  final String? location;
  final String? distance;

  const HospitalModel({
    required this.id,
    required this.name,
    required this.logoPath,
    this.location,
    this.distance,
  });
}

class DoctorModel {
  final String id;
  final String name;
  final String qualification;
  final String? imageUrl;
  final String experience;
  final String hospitalName;
  final double consultationFee;
  final bool isCashless;
  final String? rating;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.qualification,
    this.imageUrl,
    required this.experience,
    required this.hospitalName,
    required this.consultationFee,
    this.isCashless = false,
    this.rating,
  });
}
