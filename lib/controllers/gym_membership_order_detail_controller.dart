import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/gym_repository.dart';
import 'package:flip_health/model/gym%20models/gym_membership_invoice_model.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:get/get.dart';

class GymMembershipOrderDetailController extends GetxController {
  GymMembershipOrderDetailController({required GymRepository repository})
    : _repository = repository;

  final GymRepository _repository;

  final invoice = Rxn<GymMembershipInvoice>();
  final detailsFetched = false.obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

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

  Map<String, dynamic> get info => invoice.value?.info ?? <String, dynamic>{};

  int get infoStatus {
    final s = info['status'];
    if (s is int) return s;
    if (s is String) return int.tryParse(s) ?? -1;
    return -1;
  }

  bool get showContinuePayment => infoStatus == 4;

  Future<void> fetchDetail() async {
    if (invoiceId.isEmpty) return;
    isLoading.value = true;
    detailsFetched.value = false;
    try {
      invoice.value = await _repository.getInvoiceDetail(invoiceId);
      detailsFetched.value = true;
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> continuePayment() async {
    final current = invoice.value;
    if (current == null) return;
    isSubmitting.value = true;
    try {
      final res = await _repository.confirmGymMembershipPayment(
        <String, dynamic>{'invoice_id': current.id ?? invoiceId},
      );
      final paymentRequired = res['payment_required'] == true;
      final payload = res['razorpay_payload'];
      final id = (res['invoice_id'] ?? current.id ?? invoiceId).toString();
      if (paymentRequired && payload is Map) {
        await Get.toNamed(
          AppRoutes.razorPay,
          arguments: <dynamic>[
            'fromGymMembership',
            Map<String, dynamic>.from(payload),
            id,
          ],
        );
        return;
      }
      final ok = res['status'] == true || res['status'] == 1;
      if (ok) {
        Get.offNamed(
          AppRoutes.gymMembershipPaymentSuccess,
          arguments: _buildSuccessSummary(current),
        );
      } else {
        ToastCustom.showSnackBar(
          subtitle: res['message']?.toString() ?? 'Unable to continue payment',
        );
      }
      await fetchDetail();
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
}

Map<String, dynamic> _buildSuccessSummary(GymMembershipInvoice inv) {
  final info = inv.info ?? <String, dynamic>{};
  final details = info['details'] is Map
      ? Map<String, dynamic>.from(info['details'] as Map)
      : <String, dynamic>{};
  final memberInfo = details['info'] is Map
      ? Map<String, dynamic>.from(details['info'] as Map)
      : <String, dynamic>{};
  return <String, dynamic>{
    'invoice_id': info['id']?.toString() ?? inv.id ?? '',
    'name': memberInfo['name']?.toString() ?? '',
    'email': memberInfo['email']?.toString() ?? '',
    'phone': memberInfo['phone']?.toString() ?? '',
    'location':
        details['location']?.toString() ?? info['location']?.toString() ?? '',
    'start_date': details['start_date']?.toString() ?? '',
    'end_date': details['end_date']?.toString() ?? '',
  };
}
