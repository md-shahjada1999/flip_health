import 'package:flutter/material.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/services/permission_service.dart';
import 'package:flip_health/core/utils/consultation_invoice_summary.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/consultation_order_repository.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:get/get.dart';

class ConsultationOrderDetailController extends GetxController {
  ConsultationOrderDetailController({
    required ConsultationOrderRepository repository,
  }) : _repository = repository;

  final ConsultationOrderRepository _repository;

  final invoiceDetail = <String, dynamic>{}.obs;
  final detailsFetched = false.obs;
  final isLoading = false.obs;
  final attachments = <dynamic>[].obs;
  final reports = <dynamic>[].obs;

  final cancellationController = TextEditingController();
  final useFlipCash = true.obs;

  /// Latest `PATCH ... offline payment` quote (`confirm: false`), for booking sheet UI.
  final paymentQuote = Rxn<Map<String, dynamic>>();

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

  @override
  void onClose() {
    cancellationController.dispose();
    super.onClose();
  }

  Map<String, dynamic>? get _info => invoiceDetail['info'] is Map
      ? Map<String, dynamic>.from(invoiceDetail['info'] as Map)
      : null;

  String get communication =>
      _info?['communication']?.toString().toUpperCase() ?? '';

  bool get isOnline => communication == 'ONLINE';
  bool get isOffline => communication == 'OFFLINE';

  int get infoStatus {
    final s = _info?['status'];
    if (s is int) return s;
    if (s is String) return int.tryParse(s) ?? -1;
    return -1;
  }

  /// Matches [patient_app] `consultation_detail_view`: invoice block only when
  /// `info.status != 0` and `details` has at least one row.
  bool get showInvoiceSection {
    if (infoStatus == 0) return false;
    final d = invoiceDetail['details'];
    return d is List && d.isNotEmpty;
  }

  /// Matches patient_app: payment block only when `payments` is non-empty.
  bool get showPaymentsSection {
    final p = invoiceDetail['payments'];
    return p is List && p.isNotEmpty;
  }

  /// [patient_app] `custom_attachement`: grid / add affordance when list non-empty
  /// OR `info.status` is 5 or 6.
  bool get showAttachmentsBody {
    if (attachments.isNotEmpty) return true;
    return infoStatus == 5 || infoStatus == 6;
  }

  /// [patient_app] `custom_attachments.dart` add control: ONLINE/OFFLINE → status 5 or 6;
  /// otherwise → status 5 only.
  bool get canAddAttachment {
    if (isOnline || isOffline) {
      return infoStatus == 5 || infoStatus == 6;
    }
    return infoStatus == 5;
  }

  /// [patient_app] bottom `Complete payment`: status 4, non-FLIPHEALTH source,
  /// `additional_info.payment_required`, `net_amount` > 0.
  bool get showPayConfirmBooking {
    if (infoStatus != 4) return false;
    final add = _info?['additional_info'];
    final payReq = add is Map && add['payment_required'] == true;
    final net = invoiceDetail['net_amount'];
    final netNum = net is num
        ? net.toDouble()
        : double.tryParse(net?.toString() ?? '') ?? 0;
    return payReq && netNum > 0;
  }

  String get source => _info?['source']?.toString() ?? 'FLIPHEALTH';

  /// [patient_app] `consultation_detail_view` floatingActionButton (~600): book follow-up when
  /// ONLINE + FLIPHEALTH + completed (`status == 1`) + appointment [date] within 14 days of now.
  bool get showBookFollowUp {
    if (!isOnline) return false;
    if (source != 'FLIPHEALTH') return false;
    if (infoStatus != 1) return false;
    final info = _info;
    if (info == null) return false;
    final dateStr = info['date']?.toString();
    if (dateStr == null || dateStr.trim().isEmpty) return false;
    try {
      final d = DateTime.parse(dateStr.trim());
      return d.difference(DateTime.now()).inDays < 14;
    } catch (_) {
      return false;
    }
  }

  /// Payload for `Get.toNamed(AppRoutes.consultation, arguments: ['follow_up', map])` —
  /// same keys as patient_app `Routes.BOOK_CONSULTATION` / `BookConsultationController` follow_up.
  Map<String, dynamic> followUpBookingArgs() {
    final info = _info ?? {};
    Map<String, dynamic>? issueMap;
    final issues = info['issues'];
    if (issues is Map) {
      issueMap = Map<String, dynamic>.from(issues);
    }
    Map<String, dynamic> doctorMap = {};
    final doctor = info['doctor'];
    if (doctor is Map) {
      doctorMap = Map<String, dynamic>.from(doctor);
    }
    String? specTitle;
    final spec = doctorMap['speciality'];
    if (spec is Map) {
      specTitle = spec['name']?.toString();
    }
    return <String, dynamic>{
      'image': issueMap?['image'],
      'speciality_id': info['speciality_id']?.toString() ?? '',
      'title': specTitle ?? '',
      'assessment_required': 0,
      'id': info['issue_id']?.toString() ?? '',
      'appointment_id': info['id']?.toString(),
      'doctor': doctorMap,
      'language':
          invoiceDetail['language']?.toString() ??
          info['language']?.toString() ??
          'English',
    };
  }

  /// [patient_app] cancel: non-FLIPHEALTH link uses status 0,3,4; FLIPHEALTH
  /// upcoming row uses `[0,3,4].contains(status)` — same set.
  bool get canCancel => [0, 3, 4].contains(infoStatus);

  /// Join video — matches patient_app `consultation_detail_view` + `status_helper.consultationStatus`:
  /// only when [source] is FLIPHEALTH, communication is ONLINE, status is **5** (confirmed
  /// upcoming), and the slot is not past **appointment + 10 minutes** (not "Expired").
  bool get canJoinCall {
    if (!isOnline) return false;
    if (source != 'FLIPHEALTH') return false;
    if (infoStatus != 5) return false;
    final info = _info;
    if (info == null) return false;
    final dateStr = info['date']?.toString();
    final timeStr = info['time']?.toString();
    if (dateStr == null || timeStr == null) return false;
    DateTime slotEnd;
    try {
      final slot = DateTime.parse('${dateStr.trim()} ${timeStr.trim()}');
      slotEnd = slot.add(const Duration(minutes: 10));
    } catch (_) {
      try {
        final slot = DateTime.parse('${dateStr}T$timeStr');
        slotEnd = slot.add(const Duration(minutes: 10));
      } catch (_) {
        return false;
      }
    }
    if (DateTime.now().isAfter(slotEnd)) return false;
    return true;
  }

  String get appointmentIdForCancel {
    final add = invoiceDetail['additional_info'];
    if (add is Map && add['appointment_id'] != null) {
      return add['appointment_id'].toString();
    }
    return _info?['id']?.toString() ?? invoiceId;
  }

  Future<void> fetchDetail() async {
    if (invoiceId.isEmpty) return;
    isLoading.value = true;
    detailsFetched.value = false;
    try {
      final data = await _repository.getInvoiceDetail(invoiceId);
      invoiceDetail.assignAll(data);
      _hydrateLists();
      detailsFetched.value = true;
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _hydrateLists() {
    final info = _info;
    if (info == null) return;
    final att = info['attachments'];
    if (att is List) {
      attachments.assignAll(att.where((e) => e is Map && e['status'] == 1));
    } else {
      attachments.clear();
    }
    final rep = info['reports'];
    if (rep is List) {
      reports.assignAll(rep.where((e) => e is Map && e['status'] == 1));
    } else {
      reports.clear();
    }
  }

  /// Payload for WebRTC signaling (patient_app `SocketView` / `Signaling`).
  Map<String, dynamic> buildVideoCallPayload() {
    final info = _info ?? {};
    final userId = invoiceDetail['user_id'];
    return {
      ...info,
      'id': info['id']?.toString() ?? invoiceId,
      'date': info['date']?.toString(),
      'time': info['time']?.toString(),
      'patient_id': userId?.toString() ?? info['patient_id']?.toString(),
      'doctor_id':
          info['doctor_id']?.toString() ??
          (info['doctor'] is Map ? (info['doctor'] as Map)['id'] : null)
              ?.toString(),
    };
  }

  Future<void> onJoinCallPressed() async {
    final info = _info;
    if (info == null) return;
    final dateStr = info['date']?.toString();
    final timeStr = info['time']?.toString();
    if (dateStr == null || timeStr == null) {
      ToastCustom.showSnackBar(subtitle: 'Missing appointment schedule');
      return;
    }
    final perm = PermissionService();
    final cam = await perm.requestCameraPermission();
    final mic = await perm.requestMicrophonePermission();
    if (!cam || !mic) {
      ToastCustom.showSnackBar(
        subtitle: 'Camera and microphone permission are required',
      );
      return;
    }
    DateTime slot;
    try {
      slot = DateTime.parse('${dateStr.trim()} ${timeStr.trim()}');
    } catch (_) {
      slot = DateTime.parse('${dateStr}T$timeStr');
    }
    if (slot.difference(DateTime.now()).inMinutes > 2) {
      ToastCustom.showSnackBar(
        subtitle: 'You can join within 2 minutes of the scheduled time',
      );
      return;
    }
    final roomId = info['id']?.toString() ?? invoiceId;
    try {
      await _repository.joinCall(roomId);
      final payload = buildVideoCallPayload();
      await Get.toNamed(
        AppRoutes.consultationVideoCall,
        arguments: <String, dynamic>{'data': payload},
      );
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  Future<void> cancelAppointment() async {
    final reason = cancellationController.text.trim();
    if (reason.isEmpty) {
      ToastCustom.showSnackBar(subtitle: 'Please enter a cancellation reason');
      return;
    }
    final id = appointmentIdForCancel;
    final body = <String, dynamic>{'cancellation_reason': reason};
    try {
      await _repository.cancelAppointment(id, body);
      ToastCustom.showSnackBar(
        subtitle: 'Appointment cancelled',
        isSuccess: true,
      );
      Get.back();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  /// Fetches payment breakdown (patient `bookAppointment` with `confirm: false`).
  Future<void> refreshPaymentQuote() async {
    final payId = invoiceDetail['id']?.toString() ?? invoiceId;
    if (payId.isEmpty) return;
    try {
      final res = await _repository.offlineAppointmentPayment(
        invoiceId: payId,
        confirm: false,
        useWallet: useFlipCash.value,
      );
      paymentQuote.value = res;
    } on AppException catch (e) {
      paymentQuote.value = null;
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      paymentQuote.value = null;
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }

  /// After booking sheet confirmation — patient `bookAppointment` with `confirm: true`.
  Future<void> confirmBookingPayment() async {
    final payId = invoiceDetail['id']?.toString() ?? invoiceId;
    try {
      final res = await _repository.offlineAppointmentPayment(
        invoiceId: payId,
        confirm: true,
        useWallet: useFlipCash.value,
      );
      if (res['paymentRequired'] == true && res['razorpay_payload'] != null) {
        final summary = buildConsultationPaymentSuccessSummary(
          Map<String, dynamic>.from(invoiceDetail),
        );
        await Get.toNamed(
          AppRoutes.razorPay,
          arguments: <dynamic>[
            'fromConsultationOrder',
            res['razorpay_payload'],
            summary,
          ],
        );
      } else if (res['paymentRequired'] == false) {
        await fetchDetail();
        final summary = buildConsultationPaymentSuccessSummary(
          Map<String, dynamic>.from(invoiceDetail),
        );
        Get.offNamed(AppRoutes.consultationPaymentSuccess, arguments: summary);
      }
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    }
  }
}
