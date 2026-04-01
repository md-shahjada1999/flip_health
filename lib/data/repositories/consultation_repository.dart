import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/data/repositories/member_repository.dart';
import 'package:flip_health/model/consultation%20models/consultation_model.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';

class ConsultationRepository {
  final ApiService apiService;
  final MemberRepository memberRepository;

  ConsultationRepository({
    required this.apiService,
    required this.memberRepository,
  });

  Future<List<FamilyMember>> getFamilyMembers() async {
    return memberRepository.getMembers();
  }

  Future<List<SpecialityModel>> getSpecialities() async {
    try {
      // TODO: Replace with actual API call when endpoint is ready
      return const [
        SpecialityModel(id: '1', name: 'General Physician', iconPath: "assets/svg/all services icons/services/bookConsultations.svg"),
        SpecialityModel(id: '2', name: 'Dietician', iconPath: "assets/svg/doctor specialities/dietician.svg"),
        SpecialityModel(id: '3', name: 'Dematologist', iconPath: "assets/svg/doctor specialities/dermatologist.svg"),
        SpecialityModel(id: '4', name: 'Pulmonologist', iconPath: "assets/svg/doctor specialities/pulmonologist.svg"),
        SpecialityModel(id: '5', name: 'Cardiologist', iconPath: "assets/svg/doctor specialities/cardiologist.svg"),
        SpecialityModel(id: '6', name: 'Dentist', iconPath: "assets/svg/doctor specialities/dentist.svg"),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<DoctorModel>> getDoctors() async {
    try {
      // TODO: Replace with actual API call when endpoint is ready
      return const [
        DoctorModel(id: '1', name: 'Dr. Prananka Reddy', qualification: 'MBBS, MD', imageUrl: 'assets/png/hopitals/dr_prananka_reddy.png', experience: '10+ years exp', hospitalName: 'Medicover Hospital', consultationFee: 600, isCashless: true),
        DoctorModel(id: '2', name: 'Dr. Strange', qualification: 'MBBS, MD', imageUrl: 'assets/png/hopitals/dr_strange.png', experience: '10+ years exp', hospitalName: 'Yashoda Hospital', consultationFee: 600, isCashless: true),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<HospitalModel>> getFeaturedHospitals() async {
    try {
      // TODO: Replace with actual API call when endpoint is ready
      return const [
        HospitalModel(id: '1', name: 'Medicover Hospitals', logoPath: 'assets/png/hopitals/medicover_hospitals.png', location: 'HITEC City', distance: '1.2km'),
        HospitalModel(id: '2', name: 'KIMS Hospitals', logoPath: 'assets/png/hopitals/kims_hospitals.png', location: 'Gachibowli', distance: '1.6km'),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }
}
