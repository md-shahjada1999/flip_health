import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/pharmacy_repository.dart';
import 'package:flip_health/model/pharmacy%20models/pharmacy_order_invoice_model.dart';
import 'package:get/get.dart';

/// Lab / diagnostics invoice detail — `GET /patient/invoice/{id}` with
/// `transaction_type: LABTEST`. Uses the same payload shape as pharmacy
/// ([PharmacyOrderInvoice]) with per-line `user` for multi-patient bookings.
class LabOrderDetailController extends GetxController {
  LabOrderDetailController({required PharmacyRepository repository})
      : _repository = repository;

  final PharmacyRepository _repository;

  final invoice = Rxn<PharmacyOrderInvoice>();
  final detailsFetched = false.obs;
  final isLoading = false.obs;

  final attachments = <dynamic>[].obs;
  final reports = <dynamic>[].obs;

  late final String invoiceId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['invoiceId'] != null) {
      invoiceId = args['invoiceId'].toString();
    } else {
      invoiceId = '';
    }
    if (invoiceId.isNotEmpty) {
      fetchDetail();
    }
  }

  Map<String, dynamic>? get _info => invoice.value?.info;

  int get infoStatus {
    final s = _info?['status'];
    if (s is int) return s;
    if (s is String) return int.tryParse(s) ?? -1;
    return -1;
  }

  /// Invoice `details` lines grouped by `user.id` (multi-patient lab orders).
  List<LabPatientLineGroup> get patientLineGroups {
    final inv = invoice.value;
    if (inv == null) return [];
    final details = inv.details;
    final byUser = <int, List<Map<String, dynamic>>>{};
    for (final line in details) {
      if (line is! Map) continue;
      final m = Map<String, dynamic>.from(line);
      final u = m['user'];
      var uid = 0;
      if (u is Map) {
        final id = u['id'];
        if (id is int) {
          uid = id;
        } else {
          uid = int.tryParse(id?.toString() ?? '') ?? 0;
        }
      }
      byUser.putIfAbsent(uid, () => []).add(m);
    }
    final keys = byUser.keys.toList()..sort();
    return [
      for (final k in keys)
        LabPatientLineGroup(userId: k, lines: byUser[k] ?? []),
    ];
  }

  bool get showInvoiceSection {
    final inv = invoice.value;
    if (inv == null) return false;
    return inv.details.isNotEmpty;
  }

  bool get showPaymentsSection => invoice.value?.payments.isNotEmpty ?? false;

  Future<void> fetchDetail() async {
    isLoading.value = true;
    detailsFetched.value = false;
    try {
      final inv = await _repository.getInvoiceDetail(invoiceId);
      invoice.value = inv;
      _syncAttachmentsAndReports(inv);
      detailsFetched.value = true;
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
      detailsFetched.value = false;
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
      detailsFetched.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _syncAttachmentsAndReports(PharmacyOrderInvoice inv) {
    final info = inv.info;
    if (info == null) return;

    final att = info['attachments'];
    if (att is List) {
      attachments.assignAll(
        att.where((e) => e is Map && e['status'] == 1).toList(),
      );
    } else {
      attachments.clear();
    }

    final rep = info['reports'];
    if (rep is List) {
      reports.assignAll(
        rep.where((e) => e is Map && e['status'] == 1).toList(),
      );
    } else {
      reports.clear();
    }
  }
}

class LabPatientLineGroup {
  const LabPatientLineGroup({
    required this.userId,
    required this.lines,
  });

  final int userId;
  final List<Map<String, dynamic>> lines;

  Map<String, dynamic>? get userMap {
    for (final line in lines) {
      final u = line['user'];
      if (u is Map) return Map<String, dynamic>.from(u);
    }
    return null;
  }

  String get displayName => userMap?['name']?.toString().trim() ?? 'Patient';

  String get subtitle {
    final u = userMap;
    if (u == null) return '';
    final parts = <String>[
      if (u['age'] != null) '${u['age']}',
      if (u['gender'] != null)
        u['gender'].toString().trim(),
    ];
    return parts.where((e) => e.isNotEmpty).join(' · ');
  }
}
