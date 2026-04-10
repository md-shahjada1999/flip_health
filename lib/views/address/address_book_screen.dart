import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_family.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_dialog.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/address%20models/address_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class AddressBookScreen extends GetView<AddressController> {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: CommonText(
          'My Addresses',
          fontSize: 18.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.addresses.isEmpty) {
                return _buildLoadingState();
              }
              if (controller.addresses.isEmpty) {
                return _buildEmptyState();
              }
              return _buildAddressList();
            }),
          ),
          _buildAddNewButton(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36.rs,
            height: 36.rs,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.rh),
          CommonText(
            'Loading addresses...',
            fontSize: 14.rf,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state with illustration
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.rw),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIllustration(),
              SizedBox(height: 28.rh),
              CommonText(
                'No addresses yet',
                fontSize: 20.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 8.rh),
              CommonText(
                'Add your first address to get started\nwith quick deliveries and appointments.',
                fontSize: 13.rf,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
                height: 1.6,
              ),
              SizedBox(height: 28.rh),
              _buildAddAddressChip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 140.rs,
      height: 140.rs,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 18.rs,
            left: 22.rs,
            child: _floatingDot(8.rs, AppColors.primary.withValues(alpha: 0.2)),
          ),
          Positioned(
            bottom: 24.rs,
            right: 18.rs,
            child: _floatingDot(6.rs, AppColors.info.withValues(alpha: 0.3)),
          ),
          Positioned(
            top: 40.rs,
            right: 24.rs,
            child: _floatingDot(5.rs, AppColors.success.withValues(alpha: 0.3)),
          ),
          Container(
            width: 72.rs,
            height: 72.rs,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.rs),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 36.rs,
                  color: AppColors.primary,
                ),
                Positioned(
                  top: 12.rs,
                  right: 12.rs,
                  child: Container(
                    width: 14.rs,
                    height: 14.rs,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildAddAddressChip() {
    return GestureDetector(
      onTap: _goToAddAddress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.rw, vertical: 12.rh),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30.rs),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 20.rs, color: Colors.white),
            SizedBox(width: 8.rw),
            CommonText(
              'Add Address',
              fontSize: 14.rf,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Address list
  // ---------------------------------------------------------------------------

  Widget _buildAddressList() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => controller.loadAddresses(forceRefresh: true),
      child: Obx(() {
        final addresses = controller.addresses;
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16.rw, 8.rh, 16.rw, 16.rh),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              duration: Duration(milliseconds: 300 + (index * 60)),
              from: 20,
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.rh),
                child: _AddressCard(
                  address: addresses[index],
                  onSetPrimary: () =>
                      _onSetPrimary(addresses[index]),
                  onEdit: () => _onEdit(addresses[index]),
                  onDelete: () => _onDelete(addresses[index]),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Add new address button
  // ---------------------------------------------------------------------------

  Widget _buildAddNewButton() {
    return SafeBottomPadding(
      child: Container(
        padding: EdgeInsets.fromLTRB(16.rw, 12.rh, 16.rw, 16.rh),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: _goToAddAddress,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.rh),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14.rs),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28.rs,
                  height: 28.rs,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_rounded,
                      size: 18.rs, color: AppColors.primary),
                ),
                SizedBox(width: 10.rw),
                CommonText(
                  'Add New Address',
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _goToAddAddress() {
    Get.toNamed(AppRoutes.addAddress)?.then((_) {
      controller.loadAddresses(forceRefresh: true);
    });
  }

  void _onSetPrimary(AddressModel address) {
    if (address.isPrimary) return;
    controller.setPrimaryAddress(address.id);
  }

  Future<void> _onEdit(AddressModel address) async {
    final result = await Get.bottomSheet<Map<String, dynamic>>(
      _EditAddressSheet(address: address),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    if (result != null) {
      controller.updateAddress(id: address.id, data: result);
    }
  }

  Future<void> _onDelete(AddressModel address) async {
    final confirmed = await CommonDialog.error(
      title: 'Delete Address',
      message:
          'Are you sure you want to remove "${address.tag.capitalize}" address at ${address.line1}?',
      confirmText: 'Delete',
      cancelText: 'Keep',
    );
    if (confirmed == true) {
      controller.deleteAddress(address.id);
    }
  }
}

// =============================================================================
// Address Card
// =============================================================================

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onSetPrimary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onSetPrimary,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = address.isPrimary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(
          color: isPrimary
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.borderLight,
          width: isPrimary ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isPrimary),
          Padding(
            padding: EdgeInsets.fromLTRB(16.rw, 0, 16.rw, 14.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  address.fullAddress,
                  fontSize: 13.rf,
                  color: AppColors.textTertiary,
                  height: 1.5,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 14.rh),
                _buildActions(isPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isPrimary) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.rw, 14.rh, 16.rw, 10.rh),
      child: Row(
        children: [
          Container(
            width: 40.rs,
            height: 40.rs,
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(12.rs),
            ),
            child: Icon(
              _iconForTag(address.tag),
              size: 20.rs,
              color: isPrimary ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: CommonText(
                        address.tag.capitalize ?? address.tag,
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPrimary) ...[
                      SizedBox(width: 8.rw),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.rw, vertical: 3.rh),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.rs),
                        ),
                        child: CommonText(
                          'Primary',
                          fontSize: 10.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
                if (address.pincode.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2.rh),
                    child: CommonText(
                      '${address.city}${address.state != null ? ', ${address.state}' : ''} - ${address.pincode}',
                      fontSize: 12.rf,
                      color: AppColors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isPrimary) {
    return Row(
      children: [
        if (!isPrimary)
          _ActionChip(
            icon: Icons.star_outline_rounded,
            label: 'Set Primary',
            onTap: onSetPrimary,
            color: AppColors.warning,
          ),
        if (!isPrimary) SizedBox(width: 8.rw),
        _ActionChip(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: onEdit,
          color: AppColors.info,
        ),
        SizedBox(width: 8.rw),
        _ActionChip(
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          onTap: onDelete,
          color: AppColors.error,
        ),
        const Spacer(),
        if (isPrimary)
          Icon(Icons.verified_rounded,
              size: 20.rs,
              color: AppColors.success.withValues(alpha: 0.7)),
      ],
    );
  }

  IconData _iconForTag(String tag) {
    switch (tag.toUpperCase()) {
      case 'HOME':
        return Icons.home_outlined;
      case 'WORK':
        return Icons.business_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }
}

// =============================================================================
// Small action chip
// =============================================================================

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 6.rh),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.rs),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.rs, color: color),
            SizedBox(width: 4.rw),
            CommonText(
              label,
              fontSize: 11.rf,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Edit Address Bottom Sheet
// =============================================================================

class _EditAddressSheet extends StatefulWidget {
  final AddressModel address;
  const _EditAddressSheet({required this.address});

  @override
  State<_EditAddressSheet> createState() => _EditAddressSheetState();
}

class _EditAddressSheetState extends State<_EditAddressSheet> {
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _line2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  String _selectedTag = 'HOME';

  static const _tags = ['HOME', 'WORK', 'OTHER'];

  @override
  void initState() {
    super.initState();
    _line1Ctrl = TextEditingController(text: widget.address.line1);
    _line2Ctrl = TextEditingController(text: widget.address.line2 ?? '');
    _cityCtrl = TextEditingController(text: widget.address.city);
    _stateCtrl = TextEditingController(text: widget.address.state ?? '');
    _pincodeCtrl = TextEditingController(text: widget.address.pincode);
    _selectedTag = widget.address.tag.toUpperCase();
    if (!_tags.contains(_selectedTag)) _selectedTag = 'OTHER';
  }

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _line1Ctrl.text.trim().isNotEmpty &&
      _cityCtrl.text.trim().isNotEmpty &&
      _pincodeCtrl.text.trim().length >= 5;

  void _save() {
    if (!_isValid) return;
    final data = {
      'line_1': _line1Ctrl.text.trim(),
      'line_2': _line2Ctrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim(),
      'tag': _selectedTag,
      if (widget.address.location != null)
        'location': widget.address.location,
    };
    Get.back(result: data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: ResponsiveHelper.screenHeight * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.rs),
          topRight: Radius.circular(24.rs),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildSheetHeader(),
          Divider(height: 1, color: AppColors.borderLight),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.rw, 16.rh, 20.rw, 8.rh),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('Address Line 1 *', 'Enter address', _line1Ctrl,
                      maxLines: 2),
                  SizedBox(height: 16.rh),
                  _buildField('Address Line 2', 'Landmark, area', _line2Ctrl),
                  SizedBox(height: 16.rh),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField('City *', 'City', _cityCtrl),
                      ),
                      SizedBox(width: 12.rw),
                      Expanded(
                        child: _buildField('State', 'State', _stateCtrl),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.rh),
                  _buildField('Pincode *', '500001', _pincodeCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  SizedBox(height: 20.rh),
                  _buildTagLabel(),
                  SizedBox(height: 10.rh),
                  _buildTagSelector(),
                  SizedBox(height: 24.rh),
                ],
              ),
            ),
          ),
          _buildSaveBtn(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.rh),
        width: 40.rw,
        height: 4.rh,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.rw, 16.rh, 20.rw, 14.rh),
      child: Row(
        children: [
          Container(
            width: 36.rs,
            height: 36.rs,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.rs),
            ),
            child: Icon(Icons.edit_location_alt_outlined,
                size: 20.rs, color: AppColors.info),
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: CommonText(
              'Edit Address',
              fontSize: 17.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 32.rs,
              height: 32.rs,
              decoration: const BoxDecoration(
                color: AppColors.backgroundTertiary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 18.rs, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.fontName,
            fontSize: 12.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6.rh),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          style: TextStyle(
            fontFamily: FontFamily.fontName,
            fontSize: 14.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: FontFamily.fontName,
              fontSize: 13.rf,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            counterText: '',
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.rw, vertical: 14.rh),
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(color: AppColors.primary, width: 1.5),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.rs),
      borderSide: BorderSide(color: color ?? AppColors.borderLight, width: width),
    );
  }

  Widget _buildTagLabel() {
    return Text(
      'Address Type',
      style: TextStyle(
        fontFamily: FontFamily.fontName,
        fontSize: 12.rf,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTagSelector() {
    return Wrap(
      spacing: 10.rw,
      runSpacing: 8.rh,
      children: _tags.map((tag) {
        final selected = _selectedTag == tag;
        return GestureDetector(
          onTap: () => setState(() => _selectedTag = tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 18.rw, vertical: 10.rh),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(24.rs),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconForTag(tag),
                  size: 16.rs,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                SizedBox(width: 6.rw),
                CommonText(
                  _displayForTag(tag),
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForTag(String tag) {
    switch (tag) {
      case 'HOME':
        return Icons.home_outlined;
      case 'WORK':
        return Icons.business_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  String _displayForTag(String tag) {
    switch (tag) {
      case 'HOME':
        return 'Home';
      case 'WORK':
        return 'Work';
      default:
        return 'Other';
    }
  }

  Widget _buildSaveBtn() {
    final valid = _isValid;
    return SafeBottomPadding(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.rw, 10.rh, 20.rw, 14.rh),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: valid ? 1.0 : 0.45,
          child: SizedBox(
            width: double.infinity,
            height: 50.rh,
            child: ElevatedButton(
              onPressed: valid ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.rs),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 20.rs),
                  SizedBox(width: 8.rw),
                  CommonText(
                    'Save Changes',
                    fontSize: 15.rf,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
