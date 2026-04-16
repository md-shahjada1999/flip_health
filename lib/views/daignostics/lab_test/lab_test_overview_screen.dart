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

class LabTestOverviewScreen extends GetView<LabTestController> {
  const LabTestOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Review Booking',
        showBackButton: true,
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
                  FadeInUp(
                    duration: const Duration(milliseconds: 200),
                    child: _buildCard(
                      icon: Icons.person_outline_rounded,
                      title: 'Contact & users',
                      child: _buildContactAndUsers(overview),
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
                        label: '+91',
                        hint: '10-digit mobile number',
                        controller: controller.altPhoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                      title:
                          'Tests & amounts (${overview.items.length})',
                      subtitle:
                          'Grouped by user. Each block lists that user\'s tests and a subtotal; the Payment card shows the full order total.',
                      child: _buildItemsGroupedByUser(overview.items),
                    ),
                  ),
                  SizedBox(height: 12.rh),
                  if (overview.pricingDetails != null)
                    FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      delay: const Duration(milliseconds: 200),
                      child: _buildCard(
                        icon: Icons.payments_outlined,
                        title: 'Payment',
                        child: _buildPricingSummary(overview.pricingDetails!),
                      ),
                    ),
                ],
              ),
            ),
            Obx(() => SafeBottomPadding(
                  child: ActionButton(
                    text: 'Continue',
                    isLoading: controller.isPlacingOrder.value,
                    onPressed: controller.isPlacingOrder.value
                        ? null
                        : () => _showPaymentBottomSheet(),
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
    String? subtitle,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      title,
                      fontSize: 12.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.rh),
                      CommonText(
                        subtitle,
                        fontSize: 10.rf,
                        color: AppColors.textTertiary,
                        height: 1.35,
                      ),
                    ],
                  ],
                ),
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
  // Account contact & users in booking
  // -----------------------------------------------------------------------

  List<BookingItemUser> _distinctItemUsers(List<BookingItem> items) {
    final seen = <int>{};
    final out = <BookingItemUser>[];
    for (final i in items) {
      final u = i.user;
      if (u == null) continue;
      if (seen.add(u.id)) out.add(u);
    }
    return out;
  }

  String _capitalizeWord(String? s) {
    if (s == null || s.trim().isEmpty) return '';
    final t = s.trim();
    return '${t[0].toUpperCase()}${t.length > 1 ? t.substring(1).toLowerCase() : ''}';
  }

  Widget _buildContactAndUsers(BookingOverviewResponse overview) {
    final fromItems = _distinctItemUsers(overview.items);
    final primary = overview.user;
    final primaryEmail = primary?.userEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fromItems.length > 1) ...[
          CommonText(
            'Users included in this booking:',
            fontSize: 11.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 6.rh),
          Wrap(
            spacing: 8.rw,
            runSpacing: 6.rh,
            children: fromItems
                .map(
                  (u) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.rw,
                      vertical: 4.rh,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(20.rs),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonText(
                          u.name,
                          fontSize: 11.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        if (u.gender != null && u.gender!.isNotEmpty) ...[
                          SizedBox(width: 6.rw),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.rw,
                              vertical: 2.rh,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.rs),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.45),
                              ),
                            ),
                            child: CommonText(
                              _capitalizeWord(u.gender),
                              fontSize: 9.rf,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 12.rh),
        ] else if (fromItems.length == 1) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CommonText(
                  fromItems.single.name,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (fromItems.single.gender != null &&
                  fromItems.single.gender!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.rw,
                    vertical: 2.rh,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.rs),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: CommonText(
                    _capitalizeWord(fromItems.single.gender),
                    fontSize: 9.rf,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.rh),
        ] else if (primary != null) ...[
          CommonText(
            primary.userName,
            fontSize: 13.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 4.rh),
        ],
        if (primary != null) ...[
          CommonText(
            'Phone number',
            fontSize: 11.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 2.rh),
          CommonText(
            primary.userPhone != null
                ? '+91 ${primary.userPhone}'
                : '—',
            fontSize: 12.rf,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 4.rh),
          CommonText(
            'Booking related updates will be sent on this number',
            fontSize: 10.rf,
            color: AppColors.textTertiary,
            height: 1.35,
          ),
        ],
        if (primaryEmail != null && primaryEmail.isNotEmpty) ...[
          SizedBox(height: 8.rh),
          CommonText(
            primaryEmail,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          slot.formattedScheduleDate,
          fontSize: 13.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 4.rh),
        CommonText(
          slot.formattedScheduleTimeRange,
          fontSize: 13.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Tests grouped by user (clear who pays for which tests)
  // -----------------------------------------------------------------------

  /// Preserves API order while grouping consecutive user buckets.
  List<MapEntry<BookingItemUser?, List<BookingItem>>> _groupItemsByUser(
    List<BookingItem> items,
  ) {
    final order = <int>[];
    final map = <int, List<BookingItem>>{};
    for (final item in items) {
      final id = item.user?.id ?? -1;
      if (!map.containsKey(id)) {
        order.add(id);
        map[id] = [];
      }
      map[id]!.add(item);
    }
    return order.map((id) {
      final list = map[id]!;
      return MapEntry(list.first.user, list);
    }).toList();
  }

  double _sumOfferPrices(List<BookingItem> list) => list.fold<double>(
        0,
        (a, i) => a + (i.pricing?.offerPrice ?? 0),
      );

  Widget _buildItemsGroupedByUser(List<BookingItem> items) {
    final groups = _groupItemsByUser(items);
    final hasNamedUsers = groups.any((g) => g.key != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          if (i > 0) SizedBox(height: 14.rh),
          _buildUserTestSection(
            user: groups[i].key,
            userItems: groups[i].value,
            showUserHeader: hasNamedUsers || groups.length > 1,
          ),
        ],
      ],
    );
  }

  Widget _buildUserTestSection({
    required BookingItemUser? user,
    required List<BookingItem> userItems,
    required bool showUserHeader,
  }) {
    final subtotal = _sumOfferPrices(userItems);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.rs),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showUserHeader && user != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.person_pin_outlined,
                  size: 18.rs,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        'User',
                        fontSize: 10.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: 2.rh),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CommonText(
                              user.name,
                              fontSize: 14.rf,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (user.gender != null && user.gender!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.rw,
                                vertical: 3.rh,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.rs),
                                border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: CommonText(
                                _capitalizeWord(user.gender),
                                fontSize: 10.rf,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.rh),
              child: Divider(height: 1, color: AppColors.borderLight),
            ),
          ] else if (showUserHeader && user == null) ...[
            Row(
              children: [
                Icon(Icons.list_alt_rounded,
                    size: 18.rs, color: AppColors.textTertiary),
                SizedBox(width: 8.rw),
                Expanded(
                  child: CommonText(
                    'Tests (user not specified on item)',
                    fontSize: 12.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.rh),
              child: Divider(height: 1, color: AppColors.borderLight),
            ),
          ],
          ...userItems.asMap().entries.map((e) {
            final last = e.key == userItems.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: last ? 10.rh : 12.rh),
              child: _buildTestLine(e.value),
            );
          }),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 10.rw),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.rs),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonText(
                    user != null
                        ? 'Subtotal for ${user.name}'
                        : 'Subtotal for these tests',
                    fontSize: 11.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    maxLines: 2,
                  ),
                ),
                CommonText(
                  '\u20B9${subtotal.toStringAsFixed(0)}',
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestLine(BookingItem item) {
    final price = item.pricing?.offerPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.pricing?.vendor != null) ...[
              _buildVendorLogo(item.pricing!.vendor!),
              SizedBox(width: 10.rw),
            ],
            Expanded(
              child: CommonText(
                item.name,
                fontSize: 13.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                height: 1.3,
              ),
            ),
            if (price != null)
              CommonText(
                '\u20B9${price.toStringAsFixed(0)}',
                fontSize: 14.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
          ],
        ),
        if (item.category.isNotEmpty || item.pricing?.vendor != null) ...[
          SizedBox(height: 4.rh),
          CommonText(
            [
              if (item.category.isNotEmpty) item.category,
              if (item.pricing?.vendor != null) item.pricing!.vendor!.name,
            ].join(' · '),
            fontSize: 10.rf,
            color: AppColors.textTertiary,
          ),
        ],
        if (item.free)
          Padding(
            padding: EdgeInsets.only(top: 4.rh),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.rw, vertical: 2.rh),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(4.rs),
              ),
              child: CommonText(
                'FREE',
                fontSize: 9.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        if (item.pricing != null && item.pricing!.saved > 0)
          Padding(
            padding: EdgeInsets.only(top: 2.rh),
            child: CommonText(
              'Saved \u20B9${item.pricing!.saved.toStringAsFixed(0)}',
              fontSize: 9.rf,
              color: AppColors.success,
            ),
          ),
      ],
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
  // Pricing (aligned with package / health checkup overview)
  // -----------------------------------------------------------------------

  void _showPaymentBottomSheet() {
    final o = controller.bookingOverview.value;
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
                        icon:
                            Icon(Icons.close, color: AppColors.textSecondary),
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
                      value: controller.useAppWalletForBooking.value,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) =>
                          controller.useAppWalletForBooking.value = v,
                    ),
                  ],
                  SizedBox(height: 12.rh),
                  ActionButton(
                    text: _confirmButtonLabel(o),
                    isLoading: controller.isPlacingOrder.value,
                    onPressed: controller.isPlacingOrder.value
                        ? null
                        : () {
                            Get.back();
                            controller.placeOrder();
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
}
