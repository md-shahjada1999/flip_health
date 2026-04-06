import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/dashboard%20controllers/wallet_controller.dart';
import 'package:flip_health/views/dashboard/wallet/widgets/wallet_transaction_card.dart';

class WalletAllTransactionsScreen extends StatefulWidget {
  const WalletAllTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<WalletAllTransactionsScreen> createState() =>
      _WalletAllTransactionsScreenState();
}

class _WalletAllTransactionsScreenState
    extends State<WalletAllTransactionsScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<WalletController>();
  late AnimationController _listAnimController;

  @override
  void initState() {
    super.initState();
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _listAnimController.forward();
  }

  @override
  void dispose() {
    _listAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      appBar: CommonAppBar.build(
        title: AppString.kAllTransactions,
        actions: [
          Obx(() {
            final hasFilter = controller.statusSelected.value.isNotEmpty ||
                controller.typeSelected.value.isNotEmpty;
            return Stack(
              children: [
                IconButton(
                  onPressed: () => controller.showFilterSheet(),
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 22.rs,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (hasFilter)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8.rs,
                      height: 8.rs,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        final filtered = controller.filteredTransactions;

        if (controller.statusSelected.value.isNotEmpty ||
            controller.typeSelected.value.isNotEmpty) {
          _listAnimController.reset();
          _listAnimController.forward();
        }

        return Column(
          children: [
            _buildActiveFilters(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.rw,
                        vertical: 8.rh,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final interval = Interval(
                          (index * 0.06).clamp(0.0, 0.5),
                          ((index * 0.06) + 0.5).clamp(0.0, 1.0),
                          curve: Curves.easeOutCubic,
                        );
                        return AnimatedBuilder(
                          animation: _listAnimController,
                          builder: (context, ch) {
                            final val =
                                interval.transform(_listAnimController.value);
                            return Opacity(
                              opacity: val.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - val)),
                                child: ch,
                              ),
                            );
                          },
                          child: WalletTransactionCard(
                            transaction: filtered[index],
                            index: index,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActiveFilters() {
    return Obx(() {
      final hasStatus = controller.statusSelected.value.isNotEmpty;
      final hasType = controller.typeSelected.value.isNotEmpty;

      if (!hasStatus && !hasType) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
        child: Row(
          children: [
            CommonText(
              AppString.kFilters,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8.rw),
            if (hasStatus)
              _buildFilterTag(
                controller.statusSelected.value,
                () => controller.statusSelected.value = '',
              ),
            if (hasType) ...[
              SizedBox(width: 6.rw),
              _buildFilterTag(
                controller.typeSelected.value,
                () => controller.typeSelected.value = '',
              ),
            ],
            const Spacer(),
            GestureDetector(
              onTap: () => controller.clearFilters(),
              child: CommonText(
                AppString.kClearAll,
                fontSize: 12.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterTag(String label, VoidCallback onClear) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.rs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonText(
            label,
            fontSize: 11.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          SizedBox(width: 4.rw),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close_rounded,
                size: 14.rs, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56.rs,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          SizedBox(height: 16.rh),
          CommonText(
            AppString.kNoTransactionsFound,
            fontSize: 16.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 8.rh),
          CommonText(
            AppString.kTryAdjustingFilters,
            fontSize: 13.rf,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
