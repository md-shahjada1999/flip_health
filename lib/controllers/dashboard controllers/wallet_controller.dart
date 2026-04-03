import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/data/repositories/wallet_repository.dart';
import 'package:flip_health/model/wallet%20models/opd_wallet_model.dart';
import 'package:flip_health/model/wallet%20models/opd_wallet_transaction_model.dart';

class WalletController extends GetxController {
  WalletController({required WalletRepository repository})
      : _repository = repository;

  final WalletRepository _repository;

  final walletDataFetched = false.obs;
  final transDataFetched = false.obs;

  /// Parsed `/patient/opd/wallet` → `wallet` (balance, module, `subscription_id`).
  final wallet = OpdWallet.empty().obs;

  /// Parsed `/patient/opd/wallet/transactions/{wallet.subscription_id}`.
  final transactions = <OpdWalletTransaction>[].obs;

  final page = 1.obs;
  final hasNoMoreTransactions = false.obs;

  final statusSelected = ''.obs;
  final typeSelected = ''.obs;

  final List<String> statusFilters = ['Success', 'Refunded'];
  final List<String> typeFilters = [
    'Consultation',
    'Labtest',
    'Pharmacy',
    'Dental',
    'Vision',
    'Vaccine',
    'Nutrition',
    'Fitness',
    'Mental Wellness',
  ];

  @override
  void onInit() {
    super.onInit();
    loadWallet();
  }

  /// Loads OPD wallet, then transactions at
  /// `opd/wallet/transactions/{wallet['subscription_id']}?page=`.
  Future<void> loadWallet() async {
    walletDataFetched.value = false;
    transDataFetched.value = false;
    try {
      final rawWallet = await _repository.getWalletData();
      final parsed = OpdWallet.fromJson(rawWallet);
      wallet.value = parsed;
      walletDataFetched.value = true;

      page.value = 1;

      if (parsed.hasValidSubscription) {
        final subPath = parsed.subscriptionIdForPath;
        final rawTx = await _repository.getOpdWalletTransactions(
          subscriptionId: subPath,
          page: page.value,
        );
        transactions.assignAll(
          rawTx.map(OpdWalletTransaction.fromJson).toList(),
        );
        hasNoMoreTransactions.value = rawTx.length < 20;
      } else {
        transactions.clear();
        hasNoMoreTransactions.value = true;
      }
      transDataFetched.value = true;
    } catch (_) {
      wallet.value = OpdWallet.empty();
      transactions.clear();
      walletDataFetched.value = true;
      transDataFetched.value = true;
      hasNoMoreTransactions.value = true;
    }
  }

  List<OpdWalletTransaction> get filteredTransactions {
    return transactions.where((tx) {
      if (statusSelected.value.isNotEmpty &&
          tx.status != statusSelected.value.toLowerCase()) {
        return false;
      }
      if (typeSelected.value.isNotEmpty && tx.refType != typeSelected.value) {
        return false;
      }
      return true;
    }).toList();
  }

  void clearFilters() {
    statusSelected.value = '';
    typeSelected.value = '';
  }

  void showFilterSheet() {
    Get.bottomSheet(
      _FilterSheetContent(controller: this),
      isScrollControlled: true,
    );
  }
}

class _FilterSheetContent extends StatelessWidget {
  final WalletController controller;
  const _FilterSheetContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        padding: EdgeInsets.fromLTRB(20.rs, 12.rs, 20.rs, 24.rs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
        ),
        child: Obx(() => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40.rw,
                      height: 4.rh,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2.rs),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.rh),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        AppString.kFilterTransactions,
                        fontSize: 18.rf,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.close_rounded, size: 22.rs),
                      ),
                    ],
                  ),
                  Divider(color: AppColors.borderLight),
                  SizedBox(height: 16.rh),
                  CommonText(AppString.kStatusLabel,
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  SizedBox(height: 10.rh),
                  Wrap(
                    spacing: 10.rw,
                    children: controller.statusFilters
                        .map((s) => _buildChip(
                              label: s,
                              isSelected:
                                  controller.statusSelected.value == s,
                              onTap: () =>
                                  controller.statusSelected.value = s,
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 20.rh),
                  CommonText(AppString.kTypeLabel,
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  SizedBox(height: 10.rh),
                  Wrap(
                    spacing: 10.rw,
                    runSpacing: 10.rh,
                    children: controller.typeFilters
                        .map((t) => _buildChip(
                              label: t,
                              isSelected:
                                  controller.typeSelected.value == t,
                              onTap: () =>
                                  controller.typeSelected.value = t,
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 28.rh),
                  if (controller.statusSelected.value.isNotEmpty ||
                      controller.typeSelected.value.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.clearFilters();
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              padding:
                                  EdgeInsets.symmetric(vertical: 14.rh),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12.rs),
                              ),
                              side:
                                  BorderSide(color: AppColors.textPrimary),
                            ),
                            child: CommonText(AppString.kClearAll,
                                fontSize: 14.rf,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(width: 12.rw),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding:
                                  EdgeInsets.symmetric(vertical: 14.rh),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12.rs),
                              ),
                            ),
                            child: CommonText(AppString.kApply,
                                fontSize: 14.rf,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20.rs),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: CommonText(
          label,
          fontSize: 12.rf,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
