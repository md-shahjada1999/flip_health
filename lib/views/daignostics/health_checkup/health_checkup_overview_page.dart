import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';

class HealthCheckupOverviewScreen extends StatelessWidget {
  const HealthCheckupOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HealthCheckupsController>();

    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: 'Booking Overview'),
      body: Obx(() {
        if (c.isBookingPreviewLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final o = c.bookingPreview.value;
        if (o == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.rs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    'Could not load booking details',
                    fontSize: 15.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.rh),
                  TextButton(
                    onPressed: () => c.refreshBookingPreview(),
                    child: CommonText(
                      'Retry',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.rs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: _buildCard(
                        title: 'Members & Packages',
                        icon: Icons.people_outline,
                        child: _buildMemberPackages(c),
                      ),
                    ),
                    if (_hasSelectableVendors(c)) ...[
                      SizedBox(height: 16.rh),
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        delay: const Duration(milliseconds: 100),
                        child: _buildCard(
                          title: 'Vendors',
                          icon: Icons.local_hospital_outlined,
                          child: _buildVendors(c),
                        ),
                      ),
                    ],
                    SizedBox(height: 16.rh),
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 200),
                      child: _buildCard(
                        title: 'Scheduled Slots',
                        icon: Icons.schedule_outlined,
                        child: _buildSlotsSection(c, o),
                      ),
                    ),
                    if (o.pricingDetails != null) ...[
                      SizedBox(height: 16.rh),
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        delay: const Duration(milliseconds: 250),
                        child: _buildCard(
                          title: 'Payment',
                          icon: Icons.payments_outlined,
                          child: _buildPricingSummary(o.pricingDetails!),
                        ),
                      ),
                    ],
                    SizedBox(height: 16.rh),
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 280),
                      child: _buildCard(
                        title: 'Alternative phone (optional)',
                        icon: Icons.phone_outlined,
                        child: CustomTextField(
                          label: '',
                          hint: 'Alternate contact number',
                          controller: c.altPhoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 12.rw, right: 4.rw),
                            child: CommonText(
                              '+91',
                              fontSize: 14.rf,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.rh),
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 300),
                      child: _buildCard(
                        title: 'Address',
                        icon: Icons.location_on_outlined,
                        child: _buildAddressSection(o),
                      ),
                    ),
                    SizedBox(height: 16.rh),
                  ],
                ),
              ),
            ),
            Obx(
              () => SafeBottomPadding(
                child: ActionButton(
                  text: 'Continue',
                  isLoading: c.isPlacingOrder.value,
                  onPressed: c.isPlacingOrder.value
                      ? null
                      : () => _showPaymentBottomSheet(c),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showPaymentBottomSheet(HealthCheckupsController c) {
    final o = c.bookingPreview.value;
    if (o == null) return;

    Get.bottomSheet<void>(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.rs, 0, 12.rs, 12.rh),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.rs),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(18.rs, 12.rh, 18.rs, 18.rh),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        'Confirm booking',
                        fontSize: 17.rf,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.rh),
                  if (o.pricingDetails != null)
                    _buildPricingSummary(o.pricingDetails!),
                  if (o.pricingDetails != null &&
                      (o.pricingDetails!.amountToPay) > 0) ...[
                    SizedBox(height: 8.rh),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: CommonText(
                        'Use Flip wallet (OPD)',
                        fontSize: 13.rf,
                        color: AppColors.textPrimary,
                      ),
                      value: c.useAppWalletForBooking.value,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => c.useAppWalletForBooking.value = v,
                    ),
                  ],
                  SizedBox(height: 12.rh),
                  ActionButton(
                    text: _confirmButtonLabel(o),
                    isLoading: c.isPlacingOrder.value,
                    onPressed: c.isPlacingOrder.value
                        ? null
                        : () {
                            Get.back();
                            c.finalizeHealthCheckupBooking();
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _confirmButtonLabel(BookingOverviewResponse o) {
    final p = o.pricingDetails;
    if (p == null) return 'Confirm booking';
    if (p.amountToPay <= 0) return 'Confirm booking';
    return 'Pay ₹${p.amountToPay.toStringAsFixed(0)}';
  }

  Widget _buildPricingSummary(BookingPricingDetails pricing) {
    final opd = pricing.opdWallet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _prRow('Subtotal', '₹${pricing.totalGross.toStringAsFixed(0)}'),
        if (pricing.saved > 0)
          _prRow(
            'Discount',
            '- ₹${pricing.saved.toStringAsFixed(0)}',
            valueColor: AppColors.success,
          ),
        if (pricing.collectionCharges > 0)
          _prRow(
            'Collection',
            '₹${pricing.collectionCharges.toStringAsFixed(0)}',
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.rh),
          child: const Divider(height: 1, color: AppColors.borderLight),
        ),
        _prRow(
          'Net amount',
          '₹${pricing.netAmount.toStringAsFixed(0)}',
          bold: true,
        ),
        if (opd != null) ...[
          SizedBox(height: 8.rh),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.rs),
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(8.rs),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Flip wallet (OPD)',
                  fontSize: 11.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 6.rh),
                _prRow(
                  'Available balance',
                  '₹${opd.available.toStringAsFixed(0)}',
                  valueColor: AppColors.success,
                ),
                _prRow(
                  'Paid from wallet',
                  '₹${opd.paidAmount.toStringAsFixed(0)}',
                ),
              ],
            ),
          ),
        ],
        if (pricing.amountToPay == 0) ...[
          SizedBox(height: 10.rh),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.rh, horizontal: 10.rw),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8.rs),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 14.rs, color: AppColors.success),
                SizedBox(width: 6.rw),
                Expanded(
                  child: CommonText(
                    'Covered by wallet — no payment needed',
                    fontSize: 11.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(height: 10.rh),
          _prRow(
            'Pay from pocket',
            '₹${pricing.amountToPay.toStringAsFixed(0)}',
            bold: true,
            valueColor: AppColors.primary,
          ),
        ],
      ],
    );
  }

  Widget _prRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.rh),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            label,
            fontSize: 12.rf,
            color: AppColors.textSecondary,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
          CommonText(
            value,
            fontSize: bold ? 14.rf : 12.rf,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.rs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.rs),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18.rs),
              ),
              SizedBox(width: 10.rw),
              CommonText(
                title,
                fontSize: 15.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: 14.rh),
          Divider(color: AppColors.borderLight, height: 1),
          SizedBox(height: 14.rh),
          child,
        ],
      ),
    );
  }

  Widget _buildMemberPackages(HealthCheckupsController c) {
    return Column(
      children: c.selectedMembers.map((m) {
        final pkgId = c.memberPackageMap[m.id];
        String pkgName = 'Not selected';
        if (pkgId != null) {
          final cached = c.currentPackages.firstWhereOrNull((p) => p.id == pkgId);
          pkgName = cached?.name ?? 'Package #$pkgId';
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 10.rh),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16.rs,
                backgroundColor: AppColors.backgroundSecondary,
                child: CommonText(
                  m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 10.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      m.name,
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    CommonText(
                      pkgName,
                      fontSize: 12.rf,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static bool _isSelectableVendor(AhcVendor? v) {
    if (v == null) return false;
    final code = v.code.trim().toLowerCase();
    return code.isNotEmpty && code != 'unknown';
  }

  static bool _hasSelectableVendors(HealthCheckupsController c) {
    return _isSelectableVendor(c.selectedPathologyVendor.value) ||
        _isSelectableVendor(c.selectedRadiologyVendor.value);
  }

  Widget _buildVendors(HealthCheckupsController c) {
    final items = <Widget>[];

    if (_isSelectableVendor(c.selectedPathologyVendor.value)) {
      final v = c.selectedPathologyVendor.value!;
      items.add(_vendorRow('Pathology', v, '₹${v.price.toStringAsFixed(0)}'));
    }
    if (_isSelectableVendor(c.selectedRadiologyVendor.value)) {
      final v = c.selectedRadiologyVendor.value!;
      items.add(_vendorRow('Radiology', v, '₹${v.price.toStringAsFixed(0)}'));
    }

    return Column(children: items);
  }

  Widget _vendorRow(String category, AhcVendor vendor, String price) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OverviewVendorAvatar(logo: vendor.logo, name: vendor.name),
          SizedBox(width: 10.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.rw, vertical: 3.rh),
                      decoration: BoxDecoration(
                        color: category == 'Pathology'
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.rs),
                      ),
                      child: CommonText(
                        category,
                        fontSize: 11.rf,
                        fontWeight: FontWeight.w600,
                        color: category == 'Pathology'
                            ? Colors.blue
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.rh),
                CommonText(
                  vendor.name,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CommonText(
            price,
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsSection(
      HealthCheckupsController c, BookingOverviewResponse o) {
    if (o.slot != null) {
      return _apiSlotRow(o.slot!);
    }
    return _buildSlotsFromSelection(c);
  }

  Widget _apiSlotRow(BookingSlotInfo slot) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.event_outlined, size: 16.rs, color: AppColors.textSecondary),
        SizedBox(width: 8.rw),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                slot.displayTime,
                fontSize: 13.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 2.rh),
              CommonText(
                slot.slotDate,
                fontSize: 12.rf,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlotsFromSelection(HealthCheckupsController c) {
    final items = <Widget>[];

    if (c.selectedPathologySlot.value != null) {
      final s = c.selectedPathologySlot.value!;
      items.add(_slotRow('Pathology', s));
    }
    if (c.selectedRadiologySlot.value != null) {
      final s = c.selectedRadiologySlot.value!;
      items.add(_slotRow('Radiology', s));
    }

    if (items.isEmpty) {
      return CommonText(
        'No slots selected',
        fontSize: 13.rf,
        color: AppColors.textSecondary,
      );
    }

    return Column(children: items);
  }

  Widget _slotRow(String category, AhcSlot s) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_outlined, size: 16.rs, color: AppColors.textSecondary),
          SizedBox(width: 8.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  category,
                  fontSize: 11.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 4.rh),
                CommonText(
                  s.formattedScheduleDate,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  s.formattedScheduleTimeRange,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BookingOverviewResponse o) {
    if (o.address != null) {
      final a = o.address!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            a.tag,
            fontSize: 12.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 4.rh),
          CommonText(
            a.displayAddress,
            fontSize: 12.rf,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ],
      );
    }
    final ac = Get.find<AddressController>();
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            ac.displayLabel,
            fontSize: 14.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 4.rh),
          CommonText(
            ac.displayAddress,
            fontSize: 12.rf,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}

class _OverviewVendorAvatar extends StatelessWidget {
  final String? logo;
  final String name;

  const _OverviewVendorAvatar({required this.logo, required this.name});

  @override
  Widget build(BuildContext context) {
    final url = ApiUrl.publicFileUrl(logo);
    if (url == null || url.isEmpty) {
      return Container(
        width: 40.rs,
        height: 40.rs,
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(10.rs),
        ),
        child: Center(
          child: CommonText(
            name.isNotEmpty ? name[0].toUpperCase() : 'V',
            fontSize: 16.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.rs),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 40.rs,
        height: 40.rs,
        fit: BoxFit.contain,
        placeholder: (_, __) => Container(
          width: 40.rs,
          height: 40.rs,
          color: AppColors.backgroundTertiary,
          alignment: Alignment.center,
          child: SizedBox(
            width: 16.rs,
            height: 16.rs,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 40.rs,
          height: 40.rs,
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(10.rs),
          ),
          child: Center(
            child: CommonText(
              name.isNotEmpty ? name[0].toUpperCase() : 'V',
              fontSize: 16.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
