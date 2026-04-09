import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/views/daignostics/widgets/my_orders_button.dart';

class LabTestOverviewScreen extends GetView<LabTestController> {
  const LabTestOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Review Booking',
        showBackButton: true,
        actions: [const MyOrdersButton()],
      ),
      body: Obx(() {
        if (controller.isOverviewLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final overview = controller.bookingOverview.value;
        if (overview == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48.rs, color: AppColors.textQuaternary),
                SizedBox(height: 12.rh),
                CommonText('Failed to load overview',
                    fontSize: 14.rf, color: AppColors.textSecondary),
                SizedBox(height: 16.rh),
                TextButton(
                  onPressed: controller.fetchBookingOverview,
                  child: CommonText('Retry',
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.rs, 12.rh, 16.rs, 16.rh),
                children: [
                  if (overview.user != null)
                    FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      child: _buildCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Patient',
                        child: _buildPatientInfo(overview.user!),
                      ),
                    ),
                  SizedBox(height: 12.rh),
                  if (overview.address != null)
                    FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      delay: const Duration(milliseconds: 50),
                      child: _buildCard(
                        icon: Icons.location_on_outlined,
                        title: 'Collection Address',
                        child: _buildAddressInfo(overview.address!),
                      ),
                    ),
                  SizedBox(height: 12.rh),
                  FadeInUp(
                    duration: const Duration(milliseconds: 200),
                    delay: const Duration(milliseconds: 80),
                    child: _buildCard(
                      icon: Icons.phone_outlined,
                      title: 'Alternative Phone (Optional)',
                      child: CustomTextField(
                        label: '',
                        hint: 'Enter alternative phone number',
                        controller: controller.altPhoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 12.rw, right: 4.rw),
                          child: CommonText('+91',
                              fontSize: 14.rf,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.rh),
                  if (overview.slot != null)
                    FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      delay: const Duration(milliseconds: 120),
                      child: _buildCard(
                        icon: Icons.schedule_rounded,
                        title: 'Appointment',
                        child: _buildSlotInfo(overview.slot!),
                      ),
                    ),
                  SizedBox(height: 12.rh),
                  FadeInUp(
                    duration: const Duration(milliseconds: 200),
                    delay: const Duration(milliseconds: 170),
                    child: _buildCard(
                      icon: Icons.science_outlined,
                      title: 'Tests (${overview.items.length})',
                      child: _buildItemsList(overview.items),
                    ),
                  ),
                  SizedBox(height: 12.rh),
                  if (overview.pricingDetails != null)
                    FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      delay: const Duration(milliseconds: 200),
                      child: _buildPricingCard(overview.pricingDetails!),
                    ),
                ],
              ),
            ),
            Obx(() => SafeBottomPadding(
                  child: ActionButton(
                    text: 'Place Order',
                    isLoading: controller.isPlacingOrder.value,
                    onPressed: controller.placeOrder,
                  ),
                )),
          ],
        );
      }),
    );
  }

  // -----------------------------------------------------------------------
  // Shared card wrapper
  // -----------------------------------------------------------------------

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.rs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.rs),
                ),
                child: Icon(icon, size: 16.rs, color: AppColors.primary),
              ),
              SizedBox(width: 10.rw),
              CommonText(
                title,
                fontSize: 12.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: 10.rh),
          Padding(padding: EdgeInsets.only(left: 2.rw), child: child),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Patient
  // -----------------------------------------------------------------------

  Widget _buildPatientInfo(BookingUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          user.userName,
          fontSize: 13.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        if (user.userPhone != null) ...[
          SizedBox(height: 2.rh),
          CommonText(
            '+91 ${user.userPhone}',
            fontSize: 12.rf,
            color: AppColors.textSecondary,
          ),
        ],
        if (user.userEmail != null && user.userEmail!.isNotEmpty) ...[
          SizedBox(height: 1.rh),
          CommonText(
            user.userEmail!,
            fontSize: 12.rf,
            color: AppColors.textSecondary,
          ),
        ],
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Address
  // -----------------------------------------------------------------------

  Widget _buildAddressInfo(BookingAddress address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 3.rh),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(4.rs),
              ),
              child: CommonText(
                address.tag,
                fontSize: 10.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.rh),
        CommonText(
          address.displayAddress,
          fontSize: 12.rf,
          color: AppColors.textSecondary,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          height: 1.4,
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Slot
  // -----------------------------------------------------------------------

  Widget _buildSlotInfo(BookingSlotInfo slot) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 6.rh),
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(8.rs),
          ),
          child: CommonText(
            slot.slotDate,
            fontSize: 12.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 10.rw),
        CommonText(
          slot.displayTime,
          fontSize: 13.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Test items
  // -----------------------------------------------------------------------

  Widget _buildItemsList(List<BookingItem> items) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: 8.rh),
          padding: EdgeInsets.all(10.rs),
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(10.rs),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.pricing?.vendor != null) ...[
                _buildVendorLogo(item.pricing!.vendor!),
                SizedBox(width: 10.rw),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      item.name,
                      fontSize: 12.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      height: 1.3,
                    ),
                    SizedBox(height: 3.rh),
                    Wrap(
                      spacing: 8.rw,
                      runSpacing: 2.rh,
                      children: [
                        if (item.pricing?.vendor != null)
                          CommonText(
                            item.pricing!.vendor!.name,
                            fontSize: 10.rf,
                            color: AppColors.textTertiary,
                          ),
                        CommonText(
                          item.category,
                          fontSize: 10.rf,
                          color: AppColors.textTertiary,
                        ),
                        if (item.user != null)
                          CommonText(
                            'for ${item.user!.name}',
                            fontSize: 10.rf,
                            color: AppColors.textTertiary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.rw),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (item.pricing != null)
                    CommonText(
                      '\u20B9${item.pricing!.offerPrice.toStringAsFixed(0)}',
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  if (item.free)
                    Container(
                      margin: EdgeInsets.only(top: 2.rh),
                      padding: EdgeInsets.symmetric(
                          horizontal: 5.rw, vertical: 1.rh),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(4.rs),
                      ),
                      child: CommonText('FREE',
                          fontSize: 9.rf,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success),
                    ),
                  if (item.pricing != null && item.pricing!.saved > 0) ...[
                    SizedBox(height: 2.rh),
                    CommonText(
                      'saved \u20B9${item.pricing!.saved.toStringAsFixed(0)}',
                      fontSize: 9.rf,
                      color: AppColors.success,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVendorLogo(BookingItemVendor vendor) {
    if (vendor.logo == null) {
      return Container(
        width: 32.rs,
        height: 32.rs,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.rs),
        ),
        child: Center(
          child: CommonText(
            vendor.name.isNotEmpty ? vendor.name[0].toUpperCase() : 'V',
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    final url = vendor.logo!.startsWith('http')
        ? vendor.logo!
        : '${ApiUrl.kImageUrl}${vendor.logo}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.rs),
      child: Image.network(
        url,
        width: 32.rs,
        height: 32.rs,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          width: 32.rs,
          height: 32.rs,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.rs),
          ),
          child: Center(
            child: CommonText(
              vendor.name.isNotEmpty ? vendor.name[0].toUpperCase() : 'V',
              fontSize: 14.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Pricing
  // -----------------------------------------------------------------------

  Widget _buildPricingCard(BookingPricingDetails pricing) {
    return Container(
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText('Payment Summary',
              fontSize: 12.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary),
          SizedBox(height: 10.rh),
          _pricingRow('Subtotal',
              '\u20B9${pricing.totalGross.toStringAsFixed(0)}'),
          if (pricing.saved > 0)
            _pricingRow(
              'Discount',
              '- \u20B9${pricing.saved.toStringAsFixed(0)}',
              valueColor: AppColors.success,
            ),
          if (pricing.collectionCharges > 0)
            _pricingRow('Collection Charges',
                '\u20B9${pricing.collectionCharges.toStringAsFixed(0)}'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.rh),
            child: const Divider(height: 1, color: AppColors.borderLight),
          ),
          _pricingRow(
            'Net Amount',
            '\u20B9${pricing.netAmount.toStringAsFixed(0)}',
            bold: true,
          ),
          if (pricing.opdWallet != null) ...[
            SizedBox(height: 6.rh),
            Container(
              padding: EdgeInsets.all(10.rs),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(8.rs),
              ),
              child: Column(
                children: [
                  _pricingRow(
                    'OPD Wallet Balance',
                    '\u20B9${pricing.opdWallet!.available.toStringAsFixed(0)}',
                    valueColor: AppColors.success,
                  ),
                  _pricingRow(
                    'Paid from Wallet',
                    '\u20B9${pricing.opdWallet!.paidAmount.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
          ],
          if (pricing.amountToPay == 0) ...[
            SizedBox(height: 10.rh),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.rh),
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
                  CommonText(
                    'Covered by wallet - No payment needed',
                    fontSize: 11.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(height: 10.rh),
            _pricingRow(
              'Amount to Pay',
              '\u20B9${pricing.amountToPay.toStringAsFixed(0)}',
              bold: true,
              valueColor: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _pricingRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.rh),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(label,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400),
          CommonText(value,
              fontSize: bold ? 14.rf : 12.rf,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary),
        ],
      ),
    );
  }
}
