import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/address%20models/address_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class AddressSelectionSheet {
  AddressSelectionSheet._();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400),
      ),
      builder: (_) => const _AddressSheetBody(),
    );
  }
}

class _AddressSheetBody extends StatefulWidget {
  const _AddressSheetBody();

  @override
  State<_AddressSheetBody> createState() => _AddressSheetBodyState();
}

class _AddressSheetBodyState extends State<_AddressSheetBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    Get.find<AddressController>().loadAddresses(forceRefresh: true);
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: ResponsiveHelper.screenHeight * 0.65,
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
          _buildHeader(context),
          const Divider(height: 1, color: AppColors.borderLight),
          Flexible(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (controller.addresses.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.rs,
                  vertical: 12.rs,
                ),
                itemCount: controller.addresses.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.rh),
                itemBuilder: (context, index) {
                  final address = controller.addresses[index];
                  final delay = (0.15 * index).clamp(0.0, 1.0);

                  return AnimatedBuilder(
                    animation: _staggerController,
                    builder: (context, child) {
                      final progress = Curves.easeOutCubic.transform(
                        (_staggerController.value - delay).clamp(0.0, 1.0),
                      );
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - progress)),
                        child: Opacity(opacity: progress, child: child),
                      );
                    },
                    child: Obx(() => _AddressTile(
                      address: address,
                      isSelected:
                          controller.selectedAddress.value?.id == address.id,
                      onTap: () {
                        controller.selectAddress(address);
                        Navigator.pop(context);
                      },
                      onDelete: () => controller.deleteAddress(address.id),
                    )),
                  );
                },
              );
            }),
          ),
          _buildAddNewButton(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: EdgeInsets.only(top: 12.rh),
      child: Container(
        width: 40.rw,
        height: 4.rh,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rs, vertical: 16.rs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            'Select Address',
            fontSize: 18.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
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
              child: Icon(
                Icons.close,
                size: 18.rs,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(40.rs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48.rs,
            color: AppColors.textQuaternary,
          ),
          SizedBox(height: 16.rh),
          CommonText(
            'No saved addresses',
            fontSize: 16.rf,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 8.rh),
          CommonText(
            'Add an address to get started',
            fontSize: 14.rf,
            color: AppColors.textQuaternary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.rs, 8.rs, 20.rs, 16.rs),
        child: SizedBox(
          width: double.infinity,
          height: 48.rh,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.addAddress);
            },
            icon: Icon(Icons.add, size: 20.rs, color: AppColors.primary),
            label: CommonText(
              'Add New Address',
              fontSize: 14.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.rs),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  IconData get _typeIcon {
    switch (address.tag.toUpperCase()) {
      case 'HOME':
        return Icons.home_outlined;
      case 'WORK':
        return Icons.business_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(16.rs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14.rs),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.rw,
              height: 42.rh,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(12.rs),
              ),
              child: Icon(
                _typeIcon,
                size: 22.rs,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 14.rw),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    address.displayLabel,
                    fontSize: 15.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 4.rh),
                  CommonText(
                    address.fullAddress,
                    fontSize: 13.rf,
                    color: AppColors.textTertiary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.rw),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22.rw,
              height: 22.rh,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 6 : 2,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
