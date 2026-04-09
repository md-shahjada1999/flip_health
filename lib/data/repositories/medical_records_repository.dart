import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/medical%20records%20models/consultation_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/lab_test_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/prescription_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/health_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/condition_record_model.dart';
import 'package:flip_health/model/medical%20records%20models/service_request_model.dart';

class MedicalRecordsRepository {
  final ApiService apiService;

  MedicalRecordsRepository({required this.apiService});

  Future<List<ConsultationRecordModel>> getConsultations() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}consultations');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ConsultationRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getConsultations error: $e');
      rethrow;
    }
  }

  Future<List<LabTestRecordModel>> getLabTests() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}labtest');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return LabTestRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getLabTests error: $e');
      rethrow;
    }
  }

  Future<List<PrescriptionRecordModel>> getPrescriptions() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}prescriptions');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PrescriptionRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getPrescriptions error: $e');
      rethrow;
    }
  }

  Future<List<HealthRecordModel>> getVitals() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}vitals');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return HealthRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getVitals error: $e');
      rethrow;
    }
  }

  Future<List<HealthRecordModel>> getSymptoms() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}symptoms');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return HealthRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getSymptoms error: $e');
      rethrow;
    }
  }

  Future<List<HealthRecordModel>> getMedicines() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}medicines');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return HealthRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getMedicines error: $e');
      rethrow;
    }
  }

  Future<List<HealthRecordModel>> getMoods() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}moods');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return HealthRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getMoods error: $e');
      rethrow;
    }
  }

  Future<List<HealthRecordModel>> getMeasurements() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}measurements');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return HealthRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getMeasurements error: $e');
      rethrow;
    }
  }

  Future<List<HealthRecordModel>> getWomens() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}womens');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return HealthRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getWomens error: $e');
      rethrow;
    }
  }

  Future<List<ConditionRecordModel>> getConditions() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}conditions');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ConditionRecordModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getConditions error: $e');
      rethrow;
    }
  }

  Future<List<ServiceRequestModel>> getMentalWellness() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}mentalwellness');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ServiceRequestModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getMentalWellness error: $e');
      rethrow;
    }
  }

  Future<List<ServiceRequestModel>> getNutrition() async {
    try {
      final response =
          await apiService.get('${ApiUrl.MEDICAL_RECORDS}nutrition');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ServiceRequestModel.fromResultsList(data);
      }
      return [];
    } catch (e) {
      PrintLog.printLog('MedicalRecordsRepository.getNutrition error: $e');
      rethrow;
    }
  }
}
