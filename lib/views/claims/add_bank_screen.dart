import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_pdf_viewer.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/core/utils/file_preview_dialog.dart';
class AddBankScreen extends GetView<ClaimsController> {
  const AddBankScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop && controller.editingBankId.value != null) {
          controller.clearEditBankMode();
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Obx(
          () => CommonText(
            controller.editingBankId.value != null
                ? AppString.kEditBankAccount
                : AppString.kAddBankAccount,
            fontSize: 18.rf,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.rs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                    label: '${AppString.kBankName} *',
                    child: _buildBankNameSelector(),
                  ),
                  SizedBox(height: 20.rh),
                  CustomTextField(
                    label: '${AppString.kAccountHolderName} *',
                    hint: 'Enter account holder name',
                    controller: controller.holderNameController,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      size: 20.rs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.rh),
                  CustomTextField(
                    label: '${AppString.kAccountNumber} *',
                    hint: 'Enter account number',
                    controller: controller.accountNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: Icon(
                      Icons.credit_card_outlined,
                      size: 20.rs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.rh),
                  CustomTextField(
                    obscureText: true,
                    label: '${AppString.kConfirmAccountNumber} *',
                    hint: 'Re-enter account number',
                    controller: controller.confirmAccountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: Icon(
                      Icons.credit_card_outlined,
                      size: 20.rs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.rh),
                  CustomTextField(
                    label: '${AppString.kIFSCCode} *',
                    hint: 'Enter IFSC code',
                    controller: controller.ifscController,
                    textCapitalization: TextCapitalization.characters,
                    prefixIcon: Icon(
                      Icons.pin_outlined,
                      size: 20.rs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.rh),
                  CustomTextField(
                    label: '${AppString.kBranch} *',
                    hint: 'Enter branch name',
                    controller: controller.branchController,
                    prefixIcon: Icon(
                      Icons.location_city_outlined,
                      size: 20.rs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.rh),
                  _buildChequeUpload(),
                  SizedBox(height: 20.rh),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 12.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 8.rh),
        child,
      ],
    );
  }

  Widget _buildBankNameSelector() {
    return Obx(() {
      final bankName = controller.selectedBankName.value;
      return GestureDetector(
        onTap: () => _showBankSearchSheet(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 20.rs,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: CommonText(
                  bankName.isEmpty ? AppString.kSelectBank : bankName,
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w500,
                  color: bankName.isEmpty
                      ? AppColors.textSecondary.withValues(alpha: 0.6)
                      : AppColors.textPrimary,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 24.rs,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showBankSearchSheet() {
    controller.prepareBankPicker();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.rh),
              width: 40.rw,
              height: 4.rh,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.rs),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.rs),
              child: Row(
                children: [
                  CommonText(
                    AppString.kSelectBank,
                    fontSize: 18.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(6.rs),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundTertiary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20.rs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.rw),
              child: TextField(
                onChanged: controller.scheduleBankSearch,
                style: TextStyle(fontSize: 14.rf, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search bank...',
                  hintStyle: TextStyle(
                    fontSize: 13.rf,
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20.rs,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.rw,
                    vertical: 12.rh,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.rs),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.rs),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.rs),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.rh),
            Expanded(
              child: Obx(() {
                if (controller.banksLoading.value &&
                    controller.bankDirectory.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (!controller.banksLoading.value &&
                    controller.bankDirectory.isEmpty) {
                  return Center(
                    child: CommonText(
                      'No banks found',
                      fontSize: 14.rf,
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 80) {
                      controller.loadBanks(reset: false);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount:
                        controller.bankDirectory.length +
                        (controller.banksHasMore.value ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i >= controller.bankDirectory.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.rh),
                          child: Center(
                            child: controller.banksLoading.value
                                ? CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }
                      final item = controller.bankDirectory[i];
                      final label =
                          item['value']?.toString() ??
                          item['name']?.toString() ??
                          item['label']?.toString() ??
                          item['bank_name']?.toString() ??
                          '';
                      final bankKey =
                          item['key']?.toString() ??
                          item['id']?.toString() ??
                          '';
                      return ListTile(
                        leading: Container(
                          width: 38.rs,
                          height: 38.rs,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundTertiary,
                            borderRadius: BorderRadius.circular(10.rs),
                          ),
                          child: Icon(
                            Icons.account_balance_outlined,
                            size: 18.rs,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        title: CommonText(
                          label.isEmpty ? bankKey : label,
                          fontSize: 14.rf,
                          color: AppColors.textPrimary,
                        ),
                        onTap: () {
                          controller.selectedBankKey.value = bankKey;
                          controller.selectedBankName.value = label.isEmpty
                              ? bankKey
                              : label;
                          controller.bankNameController.text = label.isEmpty
                              ? bankKey
                              : label;
                          Get.back();
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildChequeUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.rs),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.rs),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 18.rs,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 10.rw),
            CommonText(
              '${AppString.kCancelledCheque} *',
              fontSize: 14.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ],
        ),
        SizedBox(height: 12.rh),
        Obx(() {
          if (controller.chequeFiles.isEmpty) {
            return GestureDetector(
              onTap: controller.pickChequeImage,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32.rh),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14.rs),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 36.rs,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 8.rh),
                    CommonText(
                      AppString.kUploadChequePhoto,
                      fontSize: 13.rf,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 4.rh),
                    CommonText(
                      'JPG, PNG or PDF',
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            );
          }
          return Wrap(
            spacing: 10.rw,
            runSpacing: 10.rh,
            children: controller.chequeFiles.asMap().entries.map((entry) {
              final file = entry.value;
              final isNetwork = file['isNetwork'] == true;
              final isImage = file['isImage'] == true;
              final path = file['path'] as String? ?? '';
              final isPdf = path.toLowerCase().endsWith('.pdf');
              final name = file['name'] as String? ?? '';
              return GestureDetector(
                onTap: () => _openChequePreview(
                  path: path,
                  isNetwork: isNetwork,
                  isImage: isImage,
                  isPdf: isPdf,
                  name: name.isNotEmpty ? name : 'Cheque ${entry.key + 1}',
                  index: entry.key,
                ),
                child: Stack(
                children: [
                  Container(
                    width: 100.rs,
                    height: 100.rs,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.rs),
                      border: Border.all(color: AppColors.borderLight),
                      color: AppColors.backgroundTertiary,
                    ),
                    child: isNetwork
                        ? (isPdf
                            ? Center(
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  size: 40.rs,
                                  color: AppColors.primary,
                                ),
                              )
                            : (isImage && path.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12.rs),
                                    child: Image.network(
                                      path,
                                      fit: BoxFit.cover,
                                      width: 100.rs,
                                      height: 100.rs,
                                      errorBuilder: (_, __, ___) => _fileFallback(file),
                                    ),
                                  )
                                : _fileFallback(file)))
                        : (isImage && path.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.rs),
                                child: Image.file(
                                  File(path),
                                  fit: BoxFit.cover,
                                  width: 100.rs,
                                  height: 100.rs,
                                  errorBuilder: (_, __, ___) => _fileFallback(file),
                                ),
                              )
                            : _fileFallback(file)),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => controller.removeChequeImage(entry.key),
                      child: Container(
                        width: 22.rs,
                        height: 22.rs,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14.rs,
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  void _openChequePreview({
    required String path,
    required bool isNetwork,
    required bool isImage,
    required bool isPdf,
    required String name,
    required int index,
  }) {
    if (path.isEmpty) return;

    if (isNetwork) {
      if (isPdf) {
        Get.to(() => CommonPdfViewer(url: path, title: name));
      } else {
        Get.dialog(
          _NetworkChequePreview(url: path),
          barrierColor: Colors.black87,
          useSafeArea: false,
        );
      }
    } else {
      if (isPdf) {
        Get.to(() => CommonPdfViewer(url: 'file://$path', title: name));
      } else {
        FilePreviewDialog.show(PickedFileInfo(
          id: 'cheque_$index',
          name: name,
          path: path,
          isImage: true,
        ));
      }
    }
  }

  Widget _fileFallback(Map<String, dynamic> file) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 28.rs,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 4.rh),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.rw),
            child: CommonText(
              file['name'] ?? '',
              fontSize: 8.rf,
              color: AppColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.rs),
      child: Obx(() {
        final isLoading = controller.isAddingBank.value;
        final isValid = controller.isBankFormValid.value;
        final enabled = isValid && !isLoading;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1.0 : 0.45,
          child: ElevatedButton(
            onPressed: enabled
                ? () {
                    if (controller.editingBankId.value != null) {
                      controller.updateBankAccount();
                    } else {
                      controller.addBankAccount();
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 16.rh),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.rs),
              ),
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            ),
            child: isLoading
                ? SizedBox(
                    height: 22.rs,
                    width: 22.rs,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : CommonText(
                    controller.editingBankId.value != null
                        ? AppString.kUpdateBankAccount
                        : AppString.kSaveBankAccount,
                    fontSize: 15.rf,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
          ),
        );
      }),
    );
  }
}

class _NetworkChequePreview extends StatefulWidget {
  final String url;
  const _NetworkChequePreview({required this.url});

  @override
  State<_NetworkChequePreview> createState() => _NetworkChequePreviewState();
}

class _NetworkChequePreviewState extends State<_NetworkChequePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  final _transformCtrl = TransformationController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  void _close() async {
    await _animCtrl.reverse();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: _close,
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.url,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (_, __, ___) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_rounded,
                            size: 48.rs, color: Colors.white38),
                        SizedBox(height: 12.rh),
                        CommonText(
                          'Unable to load image',
                          fontSize: 14.rf,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.rh,
              left: 12.rw,
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  width: 40.rs,
                  height: 40.rs,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12.rs),
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 22.rs, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
