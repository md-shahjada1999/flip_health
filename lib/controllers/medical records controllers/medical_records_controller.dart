import 'package:get/get.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/medical_records_repository.dart';
import 'package:flip_health/model/medical%20records%20models/consultation_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/lab_test_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/prescription_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/health_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/condition_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/service_request_model.dart';

class MedicalRecordsController extends GetxController {
  final MedicalRecordsRepository _repository;

  MedicalRecordsController({required MedicalRecordsRepository repository})
      : _repository = repository;

  static const List<String> categories = [
    'Consultations',
    'Lab Tests',
    'Prescriptions',
    'Vitals',
    'Symptoms',
    'Medicines',
    'Moods',
    'Measurements',
    "Women's",
    'Conditions',
    'Mental Wellness',
    'Nutrition',
  ];

  final selectedCategory = 'Consultations'.obs;
  final isLoading = false.obs;

  final consultations = <ConsultationRecordModel>[].obs;
  final labTests = <LabTestRecordModel>[].obs;
  final prescriptions = <PrescriptionRecordModel>[].obs;
  final vitals = <HealthRecordModel>[].obs;
  final symptoms = <HealthRecordModel>[].obs;
  final medicines = <HealthRecordModel>[].obs;
  final moods = <HealthRecordModel>[].obs;
  final measurements = <HealthRecordModel>[].obs;
  final womens = <HealthRecordModel>[].obs;
  final conditions = <ConditionRecordModel>[].obs;
  final mentalWellness = <ServiceRequestModel>[].obs;
  final nutrition = <ServiceRequestModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchForCategory(selectedCategory.value);
  }

  void selectCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    _fetchForCategory(category);
  }

  Future<void> refresh() => _fetchForCategory(selectedCategory.value);

  Future<void> _fetchForCategory(String category) async {
    isLoading.value = true;
    try {
      switch (category) {
        case 'Consultations':
          consultations.value = await _repository.getConsultations();
          break;
        case 'Lab Tests':
          labTests.value = await _repository.getLabTests();
          break;
        case 'Prescriptions':
          prescriptions.value = await _repository.getPrescriptions();
          break;
        case 'Vitals':
          vitals.value = await _repository.getVitals();
          break;
        case 'Symptoms':
          symptoms.value = await _repository.getSymptoms();
          break;
        case 'Medicines':
          medicines.value = await _repository.getMedicines();
          break;
        case 'Moods':
          moods.value = await _repository.getMoods();
          break;
        case 'Measurements':
          measurements.value = await _repository.getMeasurements();
          break;
        case "Women's":
          womens.value = await _repository.getWomens();
          break;
        case 'Conditions':
          conditions.value = await _repository.getConditions();
          break;
        case 'Mental Wellness':
          mentalWellness.value = await _repository.getMentalWellness();
          break;
        case 'Nutrition':
          nutrition.value = await _repository.getNutrition();
          break;
      }
    } catch (e) {
      PrintLog.printLog('MedicalRecordsController._fetchForCategory error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
