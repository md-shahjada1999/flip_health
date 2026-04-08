import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';
import 'package:intl/intl.dart';

class AddClaimStep2 extends GetView<ClaimsController> {
  const AddClaimStep2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(20.rs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBillsSection(),
              SizedBox(height: 24.rh),
              _buildDocumentsSection(),
              SizedBox(height: 32.rh),
              _buildNavigationButtons(),
              SizedBox(height: 20.rh),
            ],
          ),
        ),
        Obx(
          () => controller.isClaimDocUploading.value
              ? Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildBillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppString.kMedicalBills, Icons.receipt_outlined),
        SizedBox(height: 12.rh),
        Obx(
          () => Column(
            children: [
              ...controller.bills.asMap().entries.map(
                (entry) => _buildBillCard(entry.key, entry.value),
              ),
              _buildAddBillButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillCard(int index, ClaimBill bill) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.rh),
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showAddBillSheet(editIndex: index),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.rs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.rs),
                    ),
                    child: Icon(
                      Icons.receipt_outlined,
                      size: 20.rs,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'Bill #${bill.billNumber}',
                          fontSize: 14.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 2.rh),
                        CommonText(
                          '${bill.clinicName} • ${bill.billDate}',
                          fontSize: 11.rf,
                          color: AppColors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  CommonText(
                    '₹${bill.billAmount.toStringAsFixed(0)}',
                    fontSize: 15.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: 8.rw),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.removeBill(index),
            child: Container(
              padding: EdgeInsets.all(6.rs),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16.rs, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBillButton() {
    return GestureDetector(
      onTap: () => _showAddBillSheet(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.rs),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14.rs),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
              size: 22.rs,
            ),
            SizedBox(width: 8.rw),
            CommonText(
              AppString.kAddMedicalBill,
              fontSize: 14.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBillSheet({int? editIndex}) {
    if (editIndex == null) {
      controller.prepareNewBillSheet();
    } else {
      controller.loadBillForEdit(editIndex);
    }

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
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
              padding: EdgeInsets.all(20.rs),
              child: Row(
                children: [
                  CommonText(
                    AppString.kAddMedicalBill,
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
            Divider(height: 1, color: AppColors.borderLight),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.rs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: AppString.kBillNumber,
                      hint: 'Enter bill number',
                      controller: controller.billNumberController,
                      prefixIcon: Icon(
                        Icons.tag,
                        size: 20.rs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.rh),
                    CustomTextField(
                      label: AppString.kBillDate,
                      hint: 'Select bill date',
                      controller: controller.billDateController,
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                        size: 20.rs,
                        color: AppColors.textSecondary,
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: Get.context!,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (date != null) {
                          // ISO yyyy-MM-dd (same as patient_app `dateFormat2`)
                          controller.billDateController.text =
                              DateFormat('yyyy-MM-dd').format(date);
                        }
                      },
                    ),
                    SizedBox(height: 16.rh),
                    CustomTextField(
                      label: AppString.kBillAmount,
                      hint: 'Enter bill amount',
                      controller: controller.billAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      prefixIcon: Icon(
                        Icons.currency_rupee,
                        size: 20.rs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.rh),
                    CustomTextField(
                      label: AppString.kClinicName,
                      hint: 'Enter clinic / hospital name',
                      controller: controller.clinicNameController,
                      prefixIcon: Icon(
                        Icons.local_hospital_outlined,
                        size: 20.rs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.rh),
                    CustomTextField(
                      label: AppString.kClinicAddress,
                      hint: 'Enter clinic address',
                      controller: controller.clinicAddressController,
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        size: 20.rs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.rh),
                    CustomTextField(
                      label: AppString.kDoctorName,
                      hint: 'Enter doctor name',
                      controller: controller.doctorNameController,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: 20.rs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.rh),
                    CustomTextField(
                      label: AppString.kDoctorRegistration,
                      hint: 'Enter doctor registration number',
                      controller: controller.doctorRegController,
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        size: 20.rs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.rh),
                    _buildBillImageUpload(),
                    SizedBox(height: 24.rh),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.onSaveMedicalBillPressed();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.rh),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.rs),
                          ),
                          elevation: 0,
                        ),
                        child: CommonText(
                          AppString.kSaveBill,
                          fontSize: 15.rf,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.rh),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDocumentsSection() {
    return Obx(() {
      if (controller.bills.isEmpty) {
        return const SizedBox.shrink();
      }
      final hasDynamic =
          controller.requiredPayments.isNotEmpty ||
          controller.requiredReports.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.rh),
          if (hasDynamic) ...[
            _buildSectionTitle(
              AppString.kPaymentReceipts,
              Icons.payment_outlined,
            ),
            SizedBox(height: 8.rh),
            CommonText(
              AppString.kPaymentReceiptsSeparateHint,
              fontSize: 11.rf,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8.rh),
            _buildGeneralPaymentUploadCard(),
            if (controller.requiredPayments.isNotEmpty) ...[
              SizedBox(height: 16.rh),
              ...List.generate(
                controller.requiredPayments.length,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: 12.rh),
                  child: _buildRequiredDocRow(i, 'PAYMENT'),
                ),
              ),
            ],
            SizedBox(height: 16.rh),
            _buildSectionTitle(
              AppString.kReportsAndPrescriptions,
              Icons.description_outlined,
            ),
            SizedBox(height: 4.rh),
            CommonText(
              AppString.kUploadReportsPrescriptionsHint,
              fontSize: 11.rf,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8.rh),
            ...List.generate(
              controller.requiredReports.length,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: 12.rh),
                child: _buildRequiredDocRow(i, 'REPORT'),
              ),
            ),
            SizedBox(height: 8.rh),
            _buildSectionTitle(
              AppString.kSupportingDocuments,
              Icons.attach_file_outlined,
            ),
            SizedBox(height: 8.rh),
            _buildDocCategory(
              AppString.kSupportingDocuments,
              'OTHER',
              Icons.attach_file_outlined,
              controller.otherFiles,
            ),
          ] else ...[
            _buildDocCategory(
              AppString.kPaymentReceipts,
              'PAYMENT',
              Icons.payment_outlined,
              controller.paymentFiles,
            ),
            SizedBox(height: 12.rh),
            _buildDocCategory(
              AppString.kMedicalReports,
              'REPORT',
              Icons.description_outlined,
              controller.reportFiles,
            ),
            SizedBox(height: 12.rh),
            _buildDocCategory(
              AppString.kOtherDocuments,
              'OTHER',
              Icons.attach_file_outlined,
              controller.otherFiles,
            ),
          ],
        ],
      );
    });
  }

  String _capitalizeWord(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }

  /// patient_app `claims_step_2` `reportDocuments2`: prescribed_vaccine + `vaccine_report` particular.
  bool _shouldShowVaccineReportNote(Map<String, dynamic> row, String refType) {
    if (refType != 'REPORT') return false;
    final particulars = row['particulars'];
    if (particulars is! Map) return false;
    if (particulars['key']?.toString() != 'vaccine_report') return false;
    final claimTypes = row['claim_type'];
    if (claimTypes is! List) return false;
    return claimTypes.any(
      (item) => item is Map && item['key']?.toString() == 'prescribed_vaccine',
    );
  }

  /// Matches patient_app `imagesWidget('PAYMENT')` without a category filter — `PAYMENT` or unset `document_type`.
  bool _paymentFileIsGeneral(Map<String, dynamic> f) {
    final dt = f['document_type']?.toString() ?? '';
    return dt.isEmpty || dt == 'PAYMENT';
  }

  Widget _buildGeneralPaymentUploadCard() {
    return Container(
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment_outlined,
                size: 18.rs,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.rw),
              Expanded(
                child: CommonText(
                  AppString.kPaymentUploadsGeneral,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    controller.pickFileForCategory('PAYMENT', 'PAYMENT'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.rw,
                    vertical: 6.rh,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.rs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14.rs, color: AppColors.primary),
                      SizedBox(width: 4.rw),
                      CommonText(
                        AppString.kUpload,
                        fontSize: 11.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFilteredClaimAttachments(
            files: controller.paymentFiles,
            refType: 'PAYMENT',
            extraFilter: _paymentFileIsGeneral,
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredDocRow(int index, String refType) {
    return Obx(() {
      final list = refType == 'PAYMENT'
          ? controller.requiredPayments
          : controller.requiredReports;
      if (index >= list.length) return const SizedBox.shrink();
      final raw = list[index];
      if (raw is! Map) return const SizedBox.shrink();
      final row = Map<String, dynamic>.from(raw);
      final category = row['category']?.toString() ?? '';
      final particulars = row['particulars'];
      final required = particulars is Map && particulars['required'] == true;
      final claimTypes = row['claim_type'];
      var mandateLine = '';
      if (claimTypes is List && claimTypes.isNotEmpty) {
        final parts = <String>[];
        for (final c in claimTypes) {
          if (c is Map && c['value'] != null) {
            parts.add(c['value'].toString());
          }
        }
        if (parts.isNotEmpty) {
          mandateLine = required
              ? '${AppString.kMandatoryFor}: ${parts.join(', ')}'
              : '${AppString.kOptionalForServiceTypes}: ${parts.join(', ')}';
        }
      }

      return Container(
        padding: EdgeInsets.all(14.rs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.rs),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              '${_capitalizeWord(category)}${required ? ' *' : ''}',
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            if (mandateLine.isNotEmpty) ...[
              SizedBox(height: 4.rh),
              CommonText(
                mandateLine,
                fontSize: 11.rf,
                color: AppColors.textSecondary,
              ),
            ],
            if (_shouldShowVaccineReportNote(row, refType)) ...[
              SizedBox(height: 8.rh),
              CommonText(
                AppString.kVaccineReportNote,
                fontSize: 12.rf,
                color: AppColors.primary,
              ),
            ],
            if (row['missingReports'] is List &&
                (row['missingReports'] as List).isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.rh),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.rs),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.rs),
                  ),
                  child: CommonText(
                    '${AppString.kMissingDocumentsLabel}: ${(row['missingReports'] as List).map((e) => e is Map ? (e['value'] ?? e['key'] ?? '') : '').join(', ')}',
                    fontSize: 11.rf,
                    color: AppColors.error,
                  ),
                ),
              ),
            _buildFilteredClaimAttachments(
              files: refType == 'PAYMENT'
                  ? controller.paymentFiles
                  : controller.reportFiles,
              refType: refType,
              categoryEquals: category,
            ),
            SizedBox(height: 8.rh),
            GestureDetector(
              onTap: () => controller.pickFileForCategory(refType, category),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.rh),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12.rs),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 18.rs, color: AppColors.primary),
                    SizedBox(width: 6.rw),
                    CommonText(
                      AppString.kAddFile,
                      fontSize: 12.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilteredClaimAttachments({
    required RxList<Map<String, dynamic>> files,
    required String refType,
    String? categoryEquals,
    bool Function(Map<String, dynamic>)? extraFilter,
  }) {
    return Obx(() {
      final tiles = <Widget>[];
      for (var i = 0; i < files.length; i++) {
        final f = files[i];
        if (categoryEquals != null &&
            (f['document_type']?.toString() ?? '') != categoryEquals) {
          continue;
        }
        if (extraFilter != null && !extraFilter(f)) continue;
        tiles.add(
          Padding(
            padding: EdgeInsets.only(bottom: 10.rh),
            child: _buildClaimAttachmentTile(
              file: f,
              index: i,
              refType: refType,
            ),
          ),
        );
      }
      if (tiles.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(top: 10.rh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: tiles,
        ),
      );
    });
  }

  Widget _buildClaimAttachmentTile({
    required Map<String, dynamic> file,
    required int index,
    required String refType,
  }) {
    final path = file['path']?.toString() ?? '';
    final isHttp = path.startsWith('http://') || path.startsWith('https://');
    final name = file['name']?.toString() ?? 'file';
    final isPdf =
        name.toLowerCase().endsWith('.pdf') ||
        path.toLowerCase().endsWith('.pdf');
    final st = file['service_types'];
    var stLine = '';
    if (st is List && st.isNotEmpty) {
      stLine = st
          .map((e) => e is Map ? (e['value'] ?? e['key'] ?? '').toString() : '')
          .where((s) => s.isNotEmpty)
          .join(', ');
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.openClaimAttachmentPreview(file),
        borderRadius: BorderRadius.circular(12.rs),
        child: Container(
          padding: EdgeInsets.all(10.rs),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56.rs,
                height: 56.rs,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.rs),
                  child: _claimDocThumbnail(path, isHttp, isPdf, file),
                ),
              ),
              SizedBox(width: 10.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      name,
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      maxLines: 2,
                    ),
                    if (stLine.isNotEmpty) ...[
                      SizedBox(height: 4.rh),
                      CommonText(
                        stLine,
                        fontSize: 10.rf,
                        color: AppColors.textSecondary,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 36.rs, minHeight: 36.rs),
                onPressed: () =>
                    controller.editClaimDocumentServiceTypes(refType, index),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20.rs,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 36.rs, minHeight: 36.rs),
                onPressed: () => controller.removeFile(refType, index),
                icon: Icon(
                  Icons.delete_outline,
                  size: 20.rs,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _claimDocThumbnail(
    String path,
    bool isHttp,
    bool isPdf,
    Map<String, dynamic> file,
  ) {
    if (isPdf) {
      return ColoredBox(
        color: AppColors.backgroundTertiary,
        child: Icon(
          Icons.picture_as_pdf_outlined,
          color: AppColors.error,
          size: 28.rs,
        ),
      );
    }
    if (isHttp) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
      );
    }
    if (path.isNotEmpty && File(path).existsSync() && file['isImage'] == true) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.insert_drive_file_outlined,
          color: AppColors.textSecondary,
        ),
      );
    }
    return ColoredBox(
      color: AppColors.backgroundTertiary,
      child: Icon(
        Icons.insert_drive_file_outlined,
        color: AppColors.textSecondary,
        size: 24.rs,
      ),
    );
  }

  Widget _buildDocCategory(
    String title,
    String type,
    IconData icon,
    RxList<Map<String, dynamic>> files,
  ) {
    return Container(
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.rs, color: AppColors.textSecondary),
              SizedBox(width: 8.rw),
              Expanded(
                child: CommonText(
                  title,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => controller.pickFile(type),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.rw,
                    vertical: 6.rh,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.rs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14.rs, color: AppColors.primary),
                      SizedBox(width: 4.rw),
                      CommonText(
                        AppString.kUpload,
                        fontSize: 11.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFilteredClaimAttachments(files: files, refType: type),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.rs),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.rs),
          ),
          child: Icon(icon, size: 18.rs, color: AppColors.primary),
        ),
        SizedBox(width: 10.rw),
        CommonText(
          title,
          fontSize: 16.rf,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildBillImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.image_outlined,
              size: 18.rs,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8.rw),
            CommonText(
              AppString.kBillImages,
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ],
        ),
        SizedBox(height: 10.rh),
        Obx(
          () => Wrap(
            spacing: 10.rw,
            runSpacing: 12.rh,
            children: [
              ...controller.billImageFiles.asMap().entries.map((entry) {
                final file = entry.value;
                final path = file['path']?.toString() ?? '';
                final displayName =
                    file['name']?.toString() ??
                    file['title']?.toString() ??
                    'file';
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.openClaimAttachmentPreview(
                              Map<String, dynamic>.from(file),
                            ),
                            borderRadius: BorderRadius.circular(10.rs),
                            child: Container(
                              width: 72.rs,
                              height: 72.rs,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.rs),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                ),
                                color: AppColors.backgroundTertiary,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.rs),
                                child: _billAttachmentThumbnail(file, path),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => controller.removeBillImage(entry.key),
                            child: Container(
                              width: 18.rs,
                              height: 18.rs,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12.rs,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.rh),
                    SizedBox(
                      width: 88.rw,
                      child: CommonText(
                        displayName,
                        fontSize: 9.rf,
                        color: AppColors.textSecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }),
              Obx(() {
                final busy = controller.isBillImageUploading.value;
                return GestureDetector(
                  onTap: busy ? null : controller.pickBillImage,
                  child: Container(
                    width: 72.rs,
                    height: 72.rs,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.rs),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        style: BorderStyle.solid,
                      ),
                      color: AppColors.primary.withValues(alpha: 0.04),
                    ),
                    child: busy
                        ? Center(
                            child: SizedBox(
                              width: 24.rs,
                              height: 24.rs,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 24.rs,
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 2.rh),
                              CommonText(
                                AppString.kUpload,
                                fontSize: 10.rf,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Thumbnail after upload (local path or CDN URL) — same cues as payment/report tiles.
  Widget _billAttachmentThumbnail(Map<String, dynamic> file, String path) {
    final name = '${file['name'] ?? ''}${file['title'] ?? ''}'.toLowerCase();
    final isPdf =
        name.endsWith('.pdf') ||
        path.toLowerCase().endsWith('.pdf') ||
        file['file_type']?.toString().toUpperCase() == 'PDF';
    if (isPdf) {
      return ColoredBox(
        color: AppColors.backgroundTertiary,
        child: Icon(
          Icons.picture_as_pdf_outlined,
          color: AppColors.error,
          size: 28.rs,
        ),
      );
    }
    final isHttp = path.startsWith('http://') || path.startsWith('https://');
    if (isHttp) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: 72.rs,
        height: 72.rs,
        errorBuilder: (_, __, ___) => Icon(
          Icons.broken_image_outlined,
          size: 24.rs,
          color: AppColors.textSecondary,
        ),
      );
    }
    if (path.isNotEmpty && File(path).existsSync() && file['isImage'] == true) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: 72.rs,
        height: 72.rs,
        errorBuilder: (_, __, ___) => Icon(
          Icons.insert_drive_file_outlined,
          size: 24.rs,
          color: AppColors.textSecondary,
        ),
      );
    }
    return ColoredBox(
      color: AppColors.backgroundTertiary,
      child: Icon(
        Icons.insert_drive_file_outlined,
        color: AppColors.textSecondary,
        size: 24.rs,
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => controller.goToStep(0),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.rh),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.rs),
              ),
              side: BorderSide(color: AppColors.borderLight),
            ),
            child: CommonText(
              AppString.kBack,
              fontSize: 15.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 12.rw),
        Expanded(
          flex: 2,
          child: Obx(() {
            final canReview =
                controller.bills.isNotEmpty &&
                controller.step2DocumentsValid.value;
            return ElevatedButton(
              onPressed: canReview ? () => controller.goToStep(2) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.borderLight,
                padding: EdgeInsets.symmetric(vertical: 16.rh),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.rs),
                ),
                elevation: 0,
              ),
              child: CommonText(
                AppString.kReviewClaim,
                fontSize: 15.rf,
                fontWeight: FontWeight.w600,
                color: canReview ? Colors.white : AppColors.textSecondary,
              ),
            );
          }),
        ),
      ],
    );
  }
}
