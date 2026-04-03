import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/claims%20models/bank_account_model.dart';
import 'package:flip_health/model/claims%20models/claim_detail_bundle.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';

String _fileBasename(String path) {
  final normalized = path.replaceAll('\\', '/');
  final i = normalized.lastIndexOf('/');
  return i >= 0 ? normalized.substring(i + 1) : normalized;
}

class ClaimsRepository {
  final ApiService apiService;

  ClaimsRepository({required this.apiService});

  /// Paginated list — `GET /patient/reimbursement?page=` (patient_app: `getAllClaims`).
  Future<({List<ClaimModel> items, bool hasMore})> fetchClaimsPage(
    int page,
  ) async {
    try {
      final response = await apiService.get(
        ApiUrl.REIMBURSEMENT,
        queryParameters: {'page': '$page'},
      );
      PrintLog.printLog('ClaimsRepository.fetchClaimsPage: ${response.data}');

      if (response.statusCode == 200 && response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final raw = map['data'];
        final out = <ClaimModel>[];
        if (raw is List) {
          for (final e in raw) {
            if (e is Map) {
              final m = ClaimModel.fromApiMap(Map<String, dynamic>.from(e));
              if (m.id.isNotEmpty) out.add(m);
            }
          }
        }
        final hasMore = raw is List && raw.length >= 20;
        return (items: out, hasMore: hasMore);
      }

      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ??
                  'Failed to load claims'
            : 'Failed to load claims',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.fetchClaimsPage error: $e');
      throw AppException(message: 'Failed to load claims: $e');
    }
  }

  /// Detail + timeline — `GET /patient/reimbursement/:id`.
  Future<ClaimDetailBundle> fetchClaimDetail(String id) async {
    try {
      final response = await apiService.get('${ApiUrl.REIMBURSEMENT}/$id');
      PrintLog.printLog('ClaimsRepository.fetchClaimDetail: ${response.data}');

      if (response.statusCode == 200 && response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final rawData = map['data'];
        if (rawData is! Map) {
          throw AppException(message: 'Invalid claim detail response');
        }
        final dataMap = Map<String, dynamic>.from(rawData);
        final steps = <Map<String, dynamic>>[];
        final stepsRaw = map['status_steps'];
        if (stepsRaw is List) {
          for (final s in stepsRaw) {
            if (s is Map) steps.add(Map<String, dynamic>.from(s));
          }
        }
        return ClaimDetailBundle(data: dataMap, statusSteps: steps);
      }

      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ??
                  'Failed to load claim'
            : 'Failed to load claim',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.fetchClaimDetail error: $e');
      throw AppException(message: 'Failed to load claim: $e');
    }
  }

  /// Dispute — `PATCH /patient/reimbursement/status/:id` with `{ status, reason }`.
  Future<void> disputeClaim(
    String id, {
    required int status,
    required String reason,
  }) async {
    try {
      final response = await apiService.patch(
        '${ApiUrl.REIMBURSEMENT_STATUS}$id',
        data: {'status': status, 'reason': reason},
      );
      if (response.statusCode == 200) {
        if (response.data is Map) {
          final m = Map<String, dynamic>.from(response.data as Map);
          if (m.containsKey('status') && m['status'] != true) {
            throw AppException(
              message: m['message']?.toString() ?? 'Request failed',
              statusCode: response.statusCode,
            );
          }
        }
        return;
      }
      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ?? 'Request failed'
            : 'Request failed',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.disputeClaim error: $e');
      throw AppException(message: 'Failed to submit dispute: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMembers() async {
    try {
      final response = await apiService.get(ApiUrl.GET_MEMBERS);
      final code = response.statusCode ?? 0;
      final ok = code == 200 || code == 201;
      if (!ok || response.data is! Map) {
        throw AppException(
          message: response.data is Map
              ? (response.data as Map)['message']?.toString() ??
                    'Failed to load members'
              : 'Failed to load members',
          statusCode: response.statusCode,
        );
      }
      final root = Map<String, dynamic>.from(response.data as Map);
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Failed to load members',
          statusCode: response.statusCode,
        );
      }
      Map<String, dynamic> payload = root;
      if (root['status'] == true && root['data'] != null) {
        final d = root['data'];
        if (d is Map<String, dynamic>) {
          payload = d;
        } else if (d is Map) {
          payload = Map<String, dynamic>.from(d);
        }
      }
      final raw = payload['members'];
      if (raw is List) {
        return raw
            .map((e) {
              if (e is Map<String, dynamic>) return e;
              if (e is Map) return Map<String, dynamic>.from(e);
              return <String, dynamic>{};
            })
            .where((m) => m.isNotEmpty)
            .toList();
      }
      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.getMembers error: $e');
      throw AppException(message: 'Failed to load members: $e');
    }
  }

  /// Bill / document service types — `GET /patient/reimbursement/service_types`.
  Future<List<Map<String, dynamic>>> getBillTypes() async {
    try {
      final response = await apiService.get(ApiUrl.REIMBURSEMENT_BILL_TYPES);
      if (response.statusCode == 200 && response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final raw = map['data'];
        if (raw is List) {
          return raw
              .map((e) {
                if (e is Map<String, dynamic>) return e;
                if (e is Map) return Map<String, dynamic>.from(e);
                return <String, dynamic>{};
              })
              .where((m) => m.isNotEmpty)
              .toList();
        }
        return [];
      }
      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ??
                  'Failed to load service types'
            : 'Failed to load service types',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.getBillTypes error: $e');
      throw AppException(message: 'Failed to load service types: $e');
    }
  }

  /// Claim file upload — patient_app: `type: reimbursement`, `ref_type`, `document_type`, `file`.
  Future<Map<String, dynamic>> uploadReimbursementFile(
    String filePath, {
    required String refType,
    String documentType = '',
  }) async {
    try {
      final token = AppSecureStorage.getToken();
      if (token == null || token.isEmpty) {
        throw AppException(message: 'Please log in to upload documents.');
      }
      final doc = documentType.trim();
      final docName = doc.isNotEmpty
          ? '${doc[0].toUpperCase()}${doc.substring(1)}'
          : '';

      final formData = FormData.fromMap({
        'token': token,
        'type': 'reimbursement',
        'ref_type': refType,
        'document_type': doc,
        'document_name': docName,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: _fileBasename(filePath),
        ),
      });

      final response = await apiService.postMultipart(
        ApiUrl.UPLOAD_ATTACHMENT,
        formData: formData,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        if (map.containsKey('status') && map['status'] != true) {
          throw AppException(
            message: map['message']?.toString() ?? 'Upload failed',
            statusCode: response.statusCode,
          );
        }
        final data = map['data'];
        String? relPath;
        String? id;
        if (data is Map) {
          id = data['id']?.toString();
          final msg = data['message'];
          if (msg is Map) {
            relPath = msg['path']?.toString();
          }
        }
        final ext = _fileBasename(filePath).split('.').last;
        final fullPath = relPath != null ? ApiUrl.publicFileUrl(relPath) : null;
        return {
          if (id != null) 'id': id,
          'path': fullPath ?? relPath ?? '',
          'file_type': ext.length <= 8 ? ext : 'file',
          'document_type': doc,
          'ref_type': refType,
        };
      }

      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ?? 'Upload failed'
            : 'Upload failed',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.uploadReimbursementFile error: $e');
      throw AppException(message: 'Failed to upload file: $e');
    }
  }

  Future<List<BankAccount>> getBankAccounts() async {
    try {
      final response = await apiService.get(ApiUrl.GET_BANK_DETAILS);
      PrintLog.printLog('ClaimsRepository.getBankAccounts: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is! Map) {
          throw AppException(message: 'Invalid bank accounts response');
        }
        final map = Map<String, dynamic>.from(body);
        final raw = map['data'];
        if (raw is List) {
          return raw
              .map((e) {
                if (e is Map<String, dynamic>) {
                  return BankAccount.fromJson(e);
                }
                if (e is Map) {
                  return BankAccount.fromJson(Map<String, dynamic>.from(e));
                }
                return null;
              })
              .whereType<BankAccount>()
              .toList();
        }
        return [];
      }

      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ??
                  'Failed to fetch bank accounts'
            : 'Failed to fetch bank accounts',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.getBankAccounts error: $e');
      throw AppException(message: 'Failed to load bank accounts: $e');
    }
  }

  /// Parses `/patient/type` list — Dio often gives [Map<dynamic, dynamic>], not [Map<String, dynamic>].
  static List<Map<String, dynamic>> _parseBankTypeRows(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      final out = <Map<String, dynamic>>[];
      for (final e in raw) {
        if (e is Map) {
          out.add(Map<String, dynamic>.from(e));
        }
      }
      return out;
    }
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      for (final k in <String>['items', 'rows', 'banks', 'list', 'results']) {
        final nested = m[k];
        if (nested is List) {
          return _parseBankTypeRows(nested);
        }
      }
    }
    return [];
  }

  /// Bank directory for dropdown / search — matches `AllProviders.getBanks(page, search)`.
  Future<List<Map<String, dynamic>>> getBanks(
    int page, {
    String search = '',
  }) async {
    try {
      final searchParam = search.isEmpty
          ? 'type:banks,'
          : 'type:banks,value:$search,';
      final response = await apiService.get(
        ApiUrl.GET_BANK_TYPES,
        queryParameters: {'search': searchParam, 'page': '$page'},
      );
      PrintLog.printLog('ClaimsRepository.getBanks: $response');

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is! Map) {
          PrintLog.printLog(
            'ClaimsRepository.getBanks: expected JSON object, got ${body.runtimeType}',
          );
          throw AppException(message: 'Invalid banks response');
        }
        final map = Map<String, dynamic>.from(body);
        final rows = _parseBankTypeRows(map['data']);
        PrintLog.printLog(
          'ClaimsRepository.getBanks: page=$page count=${rows.length}',
        );
        return rows;
      }

      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ??
                  'Failed to fetch banks'
            : 'Failed to fetch banks',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.getBanks error: $e');
      throw AppException(message: 'Failed to load banks: $e');
    }
  }

  /// Single saved bank — matches `AllProviders.getBankDetailsById(id)`.
  Future<BankAccount> getBankDetailsById(String id) async {
    try {
      final response = await apiService.get('${ApiUrl.GET_BANK_DETAILS}/$id');

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is! Map) {
          throw AppException(message: 'Invalid bank detail response');
        }
        final map = Map<String, dynamic>.from(body);
        final raw = map['data'];
        if (raw is Map<String, dynamic>) {
          return BankAccount.fromJson(raw);
        }
        if (raw is Map) {
          return BankAccount.fromJson(Map<String, dynamic>.from(raw));
        }
      }

      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ??
                  'Failed to fetch bank details'
            : 'Failed to fetch bank details',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.getBankDetailsById error: $e');
      throw AppException(message: 'Failed to load bank details: $e');
    }
  }

  /// Same as patient_app `POST {base}/upload` with fields `token`, `type: bank`, and multipart `file`.
  Future<String> uploadChequeAttachment(String filePath) async {
    try {
      final token = AppSecureStorage.getToken();
      if (token == null || token.isEmpty) {
        throw AppException(message: 'Please log in to upload documents.');
      }

      final formData = FormData.fromMap({
        'token': token,
        'type': 'bank',
        'file': await MultipartFile.fromFile(
          filePath,
          filename: _fileBasename(filePath),
        ),
      });

      final response = await apiService.postMultipart(
        ApiUrl.UPLOAD_ATTACHMENT,
        formData: formData,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        if (map.containsKey('status') && map['status'] != true) {
          throw AppException(
            message: map['message']?.toString() ?? 'Upload failed',
            statusCode: response.statusCode,
          );
        }
        final data = map['data'];
        if (data is Map) {
          final id = data['id'];
          if (id != null) return id.toString();
        }
      }

      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ?? 'Upload failed'
            : 'Upload failed',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.uploadChequeAttachment error: $e');
      throw AppException(message: 'Failed to upload cheque: $e');
    }
  }

  /// Create bank — matches `AllProviders.addBankDetails` (POST body: `bank_name`, `ifsc_code`, …).
  Future<void> addBankDetails(Map<String, dynamic> data) async {
    try {
      final response = await apiService.post(
        ApiUrl.GET_BANK_DETAILS,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          final m = response.data as Map<String, dynamic>;
          if (m.containsKey('status') && m['status'] != true) {
            throw AppException(
              message: m['message']?.toString() ?? 'Failed to add bank details',
              statusCode: response.statusCode,
            );
          }
        }
        return;
      }

      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ??
                  'Failed to add bank details'
            : 'Failed to add bank details',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.addBankDetails error: $e');
      throw AppException(message: 'Failed to add bank details: $e');
    }
  }

  /// Update bank — matches `AllProviders.updateBankDetails` (PATCH).
  Future<void> updateBankDetails(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiService.patch(
        '${ApiUrl.GET_BANK_DETAILS}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          final m = Map<String, dynamic>.from(response.data as Map);
          if (m.containsKey('status') && m['status'] != true) {
            throw AppException(
              message: m['message']?.toString() ?? 'Failed to update bank details',
              statusCode: response.statusCode,
            );
          }
        }
        return;
      }

      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ??
                  'Failed to update bank details'
            : 'Failed to update bank details',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.updateBankDetails error: $e');
      throw AppException(message: 'Failed to update bank details: $e');
    }
  }

  /// Create claim — `POST /patient/reimbursement/create` (patient_app: `claimNewReimbursementApi`).
  Future<void> createReimbursementClaim(Map<String, dynamic> body) async {
    try {
      final response = await apiService.post(
        ApiUrl.REIMBURSEMENT_CREATE,
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          final m = Map<String, dynamic>.from(response.data as Map);
          if (m.containsKey('status') && m['status'] != true) {
            throw AppException(
              message: m['message']?.toString() ?? 'Failed to submit claim',
              statusCode: response.statusCode,
            );
          }
        }
        return;
      }
      throw AppException(
        message: response.data is Map
            ? (response.data as Map)['message']?.toString() ??
                  'Failed to submit claim'
            : 'Failed to submit claim',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('ClaimsRepository.createReimbursementClaim error: $e');
      throw AppException(message: 'Failed to submit claim: $e');
    }
  }
}
