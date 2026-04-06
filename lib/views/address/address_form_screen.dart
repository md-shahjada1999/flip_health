import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/add_address_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_family.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';

class AddressFormScreen extends GetView<AddAddressController> {
  const AddressFormScreen({super.key});

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
          'Add New Address',
          fontSize: 18.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.rs, vertical: 12.rs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressPreview(),
              SizedBox(height: 24.rh),
              _buildTextField(
                label: 'Address *',
                hint: 'Enter complete address',
                controller: controller.addressLine1Ctrl,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.rw, top: 6.rh),
                child: CommonText(
                  'Add complete address for best delivery results',
                  fontSize: 11.rf,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: 20.rh),
              _buildTextField(
                label: 'Pincode *',
                hint: 'Pincode',
                controller: controller.pincodeCtrl,
                readOnly: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 20.rh),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'City *',
                      hint: 'Enter city',
                      controller: controller.cityCtrl,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  SizedBox(width: 12.rw),
                  Expanded(child: _buildStateSelector(context)),
                ],
              ),
              SizedBox(height: 20.rh),
              _buildTextField(
                label: 'Landmark (Optional)',
                hint: 'e.g. Near City Mall',
                controller: controller.landmarkCtrl,
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 28.rh),
              _buildSectionLabel('Address Type *'),
              SizedBox(height: 12.rh),
              _buildTypeSelector(),
              Obx(() {
                if (controller.selectedTag.value != 'OTHER') {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 20.rh),
                  child: _buildTextField(
                    label: 'Name *',
                    hint: 'e.g. Mom\'s House',
                    controller: controller.addressNameCtrl,
                    textCapitalization: TextCapitalization.words,
                  ),
                );
              }),
              SizedBox(height: 40.rh),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable form field
  // ---------------------------------------------------------------------------

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.fontName,
            fontSize: 13.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.rh),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          style: TextStyle(
            fontFamily: FontFamily.fontName,
            fontSize: 15.rf,
            fontWeight: FontWeight.w500,
            color: readOnly ? AppColors.textTertiary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: FontFamily.fontName,
              fontSize: 14.rf,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: readOnly ? AppColors.backgroundTertiary : AppColors.surface,
            counterText: '',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.rw,
              vertical: 16.rh,
            ),
            border: _fieldBorder(),
            enabledBorder: _fieldBorder(),
            focusedBorder: _fieldBorder(color: AppColors.primary, width: 1.5),
            disabledBorder: _fieldBorder(),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _fieldBorder({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.rs),
      borderSide: BorderSide(color: color ?? AppColors.borderLight, width: width),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: FontFamily.fontName,
        fontSize: 13.rf,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Address preview
  // ---------------------------------------------------------------------------

  Widget _buildAddressPreview() {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.rw,
            height: 36.rh,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.rs),
            ),
            child: Icon(Icons.location_on, color: AppColors.primary, size: 20.rs),
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Selected Location',
                  fontSize: 11.rf,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4.rh),
                Obx(() => CommonText(
                      controller.currentAddress.value.isEmpty
                          ? 'Move pin on map to select'
                          : controller.currentAddress.value,
                      fontSize: 13.rf,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                Obx(() {
                  final parts = <String>[];
                  if (controller.city.value.isNotEmpty) parts.add(controller.city.value);
                  if (controller.pincode.value.isNotEmpty) parts.add(controller.pincode.value);
                  if (parts.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: 2.rh),
                    child: CommonText(
                      parts.join(' • '),
                      fontSize: 11.rf,
                      color: AppColors.textTertiary,
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(width: 8.rw),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 6.rh),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.rs),
              ),
              child: CommonText(
                'Change',
                fontSize: 12.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State selector (tappable field → opens searchable dialog)
  // ---------------------------------------------------------------------------

  Widget _buildStateSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State',
          style: TextStyle(
            fontFamily: FontFamily.fontName,
            fontSize: 13.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.rh),
        Obx(() {
          final hasValue = controller.state.value.isNotEmpty;
          return GestureDetector(
            onTap: () => _showStateDialog(context),
            child: Container(
              height: 52.rh,
              padding: EdgeInsets.symmetric(horizontal: 16.rw),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.rs),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? controller.state.value : 'Select state',
                      style: TextStyle(
                        fontFamily: FontFamily.fontName,
                        fontSize: hasValue ? 15.rf : 14.rf,
                        fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                        color: hasValue
                            ? AppColors.textPrimary
                            : AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 22.rs,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showStateDialog(BuildContext context) {
    controller.filterStates('');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StateSelectionSheet(controller: controller),
    );
  }

  // ---------------------------------------------------------------------------
  // Address type chips
  // ---------------------------------------------------------------------------

  Widget _buildTypeSelector() {
    return Obx(() => Wrap(
          spacing: 10.rw,
          runSpacing: 10.rh,
          children: AddAddressController.addressTags.map((tag) {
            final isSelected = controller.selectedTag.value == tag;
            return GestureDetector(
              onTap: () => controller.selectedTag.value = tag,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20.rs, vertical: 11.rs),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24.rs),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForTag(tag),
                      size: 17.rs,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    SizedBox(width: 6.rw),
                    CommonText(
                      _displayForTag(tag),
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
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

  // ---------------------------------------------------------------------------
  // Save button
  // ---------------------------------------------------------------------------

  Widget _buildSaveButton() {
    return SafeBottomPadding(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.rs, 12.rs, 20.rs, 16.rs),
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
        child: SizedBox(
          width: double.infinity,
          height: 52.rh,
          child: Obx(() => ElevatedButton(
                onPressed:
                    controller.isSaving.value ? null : controller.saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: AppColors.textQuaternary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.rs),
                  ),
                ),
                child: controller.isSaving.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : CommonText(
                        'Save Address',
                        fontSize: 16.rf,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
              )),
        ),
      ),
    );
  }
}

// =============================================================================
// State selection bottom sheet (enhanced UI)
// =============================================================================

class _StateSelectionSheet extends StatefulWidget {
  final AddAddressController controller;
  const _StateSelectionSheet({required this.controller});

  @override
  State<_StateSelectionSheet> createState() => _StateSelectionSheetState();
}

class _StateSelectionSheetState extends State<_StateSelectionSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: ResponsiveHelper.screenHeight * 0.7,
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
          // Handle bar
          Padding(
            padding: EdgeInsets.only(top: 12.rh),
            child: Container(
              width: 40.rw,
              height: 4.rh,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.rs, 16.rs, 20.rs, 12.rs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.map_outlined,
                        color: AppColors.primary, size: 22.rs),
                    SizedBox(width: 10.rw),
                    CommonText(
                      'Select State',
                      fontSize: 18.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32.rw,
                    height: 32.rh,
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close,
                        size: 18.rs, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.rs),
            child: Container(
              height: 48.rh,
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(12.rs),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: widget.controller.filterStates,
                style: TextStyle(
                  fontFamily: FontFamily.fontName,
                  fontSize: 14.rf,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search state...',
                  hintStyle: TextStyle(
                    fontFamily: FontFamily.fontName,
                    fontSize: 14.rf,
                    color: AppColors.textQuaternary,
                  ),
                  prefixIcon: Icon(Icons.search,
                      size: 20.rs, color: AppColors.textTertiary),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchCtrl,
                    builder: (_, value, __) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          widget.controller.filterStates('');
                        },
                        child: Icon(Icons.close,
                            size: 18.rs, color: AppColors.textTertiary),
                      );
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.rh),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.rh),

          Divider(height: 1, color: AppColors.borderLight),

          // State list
          Flexible(
            child: Obx(() {
              final states = widget.controller.filteredStates;
              if (states.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(40.rs),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off,
                          size: 40.rs, color: AppColors.textQuaternary),
                      SizedBox(height: 12.rh),
                      CommonText(
                        'No states found',
                        fontSize: 14.rf,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 4.rh),
                itemCount: states.length,
                itemBuilder: (context, index) {
                  final stateName = states[index];
                  final isSelected =
                      widget.controller.state.value == stateName;
                  return InkWell(
                    onTap: () {
                      widget.controller.selectState(stateName);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.rw, vertical: 14.rh),
                      color: isSelected
                          ? AppColors.primaryLight
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Container(
                            width: 32.rw,
                            height: 32.rh,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.backgroundTertiary,
                              borderRadius: BorderRadius.circular(8.rs),
                            ),
                            child: Center(
                              child: CommonText(
                                stateName.substring(0, 1),
                                fontSize: 14.rf,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(width: 14.rw),
                          Expanded(
                            child: CommonText(
                              stateName,
                              fontSize: 14.rf,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 24.rw,
                              height: 24.rh,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check,
                                  size: 14.rs, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
