import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/add_address_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/address%20models/address_model.dart';

class AddressFormScreen extends GetView<AddAddressController> {
  const AddressFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: CommonText(
          'Enter Address Details',
          fontSize: 18.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.rs, vertical: 12.rs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected address display
            _buildAddressPreview(),
            SizedBox(height: 24.rh),

            // House / Flat / Floor
            _buildLabel('House / Flat / Floor No.'),
            SizedBox(height: 8.rh),
            _buildTextField(
              controller: controller.houseController,
              hint: 'e.g. Flat 301, 3rd Floor',
            ),
            SizedBox(height: 20.rh),

            // Landmark
            _buildLabel('Landmark (Optional)'),
            SizedBox(height: 8.rh),
            _buildTextField(
              controller: controller.landmarkController,
              hint: 'e.g. Near City Mall',
            ),
            SizedBox(height: 24.rh),

            // Address type selector
            _buildLabel('Save As'),
            SizedBox(height: 12.rh),
            _buildTypeSelector(),
            SizedBox(height: 40.rh),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildAddressPreview() {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 22.rs,
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Delivering to',
                  fontSize: 12.rf,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4.rh),
                Obx(() => CommonText(
                      controller.currentAddress.value,
                      fontSize: 14.rf,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )),
                Obx(() {
                  final parts = <String>[];
                  if (controller.currentCity.value.isNotEmpty) {
                    parts.add(controller.currentCity.value);
                  }
                  if (controller.currentPincode.value.isNotEmpty) {
                    parts.add(controller.currentPincode.value);
                  }
                  if (parts.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: 2.rh),
                    child: CommonText(
                      parts.join(' - '),
                      fontSize: 12.rf,
                      color: AppColors.textTertiary,
                    ),
                  );
                }),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: CommonText(
              'Change',
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return CommonText(
      text,
      fontSize: 14.rf,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.rf,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.rf,
            color: AppColors.textQuaternary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.rs,
            vertical: 16.rs,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Obx(() => Row(
          children: AddressType.values.map((type) {
            final isSelected = controller.selectedType.value == type;
            return Padding(
              padding: EdgeInsets.only(right: 6.rw),
              child: GestureDetector(
                onTap: () => controller.selectedType.value = type,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.rs,
                    vertical: 10.rs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(24.rs),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconForType(type),
                        size: 16.rs,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.rw),
                      CommonText(
                        _labelForType(type),
                        fontSize: 13.rf,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  IconData _iconForType(AddressType type) {
    switch (type) {
      case AddressType.home:
        return Icons.home_outlined;
      case AddressType.office:
        return Icons.business_outlined;
      case AddressType.other:
        return Icons.location_on_outlined;
    }
  }

  String _labelForType(AddressType type) {
    switch (type) {
      case AddressType.home:
        return 'Home';
      case AddressType.office:
        return 'Office';
      case AddressType.other:
        return 'Other';
    }
  }

  Widget _buildSaveButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.rs, 8.rs, 20.rs, 16.rs),
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
                    borderRadius: BorderRadius.circular(12.rs),
                  ),
                ),
                child: controller.isSaving.value
                    ? SizedBox(
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
