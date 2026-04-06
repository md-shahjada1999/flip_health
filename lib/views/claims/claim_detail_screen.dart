import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ClaimDetailScreen extends GetView<ClaimsController> {
  const ClaimDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final claim = controller.selectedClaim.value;
      if (claim == null) {
        return const SafeScreenWrapper(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final d = controller.claimDetailData.value;
      final loading = controller.isClaimDetailLoading.value && d == null;
      final status = d != null
          ? (int.tryParse(d['reimbursement_status']?.toString() ?? '') ??
              claim.status)
          : claim.status;
      final config = ClaimStatusConfig.fromStatus(status);

      return DefaultTabController(
        length: 3,
        child: SafeScreenWrapper(
          backgroundColor: AppColors.surfaceLight,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: config.color,
            title: CommonText(
              '${AppString.kMyClaims} (#${claim.id})',
              fontSize: 16.rf,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: loading
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ClaimSummaryHeader(
                      claim: claim,
                      data: d,
                      status: status,
                      config: config,
                      onDisputeTap: () => _showDisputeSheet(controller),
                    ),
                    Material(
                      color: AppColors.surface,
                      child: TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          Tab(text: AppString.kClaimHistory),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppString.kBankDetailsTab),
                                if (_bankNeedsAttention(d)) ...[
                                  SizedBox(width: 6.rw),
                                  Icon(Icons.info_outline, size: 16.rs, color: AppColors.primary),
                                ],
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppString.kDocumentsTab),
                                if (_documentsNeedAttention(d)) ...[
                                  SizedBox(width: 6.rw),
                                  Icon(Icons.info_outline, size: 16.rs, color: AppColors.primary),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _HistoryTab(
                            steps: controller.claimStatusSteps.toList(),
                            statusForLabel: status,
                          ),
                          const _BankTab(),
                          _DocumentsTab(data: d),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  bool _bankNeedsAttention(Map<String, dynamic>? d) {
    final b = d?['bank_details'];
    if (b is Map) {
      return b['verify_status'] == 2;
    }
    return false;
  }

  bool _documentsNeedAttention(Map<String, dynamic>? d) {
    if (d == null) return false;
    final st = int.tryParse(d['reimbursement_status']?.toString() ?? '') ?? -1;
    bool anyMissing(List? list) {
      if (list == null) return false;
      for (final e in list) {
        if (e is Map && e['status'] == 0) return true;
      }
      return false;
    }

    bool invalidBill(Map b) =>
        b['verify_status'] == 3 && b['status'] == 1;

    final bills = d['reimbursement_bills'];
    if (bills is List) {
      for (final e in bills) {
        if (e is Map && invalidBill(Map<String, dynamic>.from(e))) {
          return true;
        }
      }
    }
    if (st == 3) {
      return anyMissing(d['reimbursement_bills'] as List?) ||
          anyMissing(d['reimbursement_bill_payment_files'] as List?) ||
          anyMissing(d['reimbursement_report_files'] as List?) ||
          anyMissing(d['reimbursement_other_files'] as List?);
    }
    return false;
  }
}

class _ClaimSummaryHeader extends StatelessWidget {
  const _ClaimSummaryHeader({
    required this.claim,
    required this.data,
    required this.status,
    required this.config,
    required this.onDisputeTap,
  });

  final ClaimModel claim;
  final Map<String, dynamic>? data;
  final int status;
  final ClaimStatusConfig config;
  final VoidCallback onDisputeTap;

  double _readAmt(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = data?['user'];
    var name = claim.userName;
    var phone = claim.userPhone;
    if (user is Map) {
      name = user['name']?.toString() ?? name;
      phone = user['phone']?.toString() ?? phone;
    }
    final alt = data?['alternative_phone']?.toString();
    final claimAmt = _readAmt(data?['claim_amount'] ?? claim.claimAmount);
    final approved = _readAmt(data?['approved_amount']);
    final showApproved = status == 1 || status == 5 || status == 8;
    final canDispute =
        status == 2 &&
        (data?['can_dispute'] == true ||
            data?['can_dispute'] == 1 ||
            claim.canDispute);
    final created =
        data?['createdAt']?.toString() ?? claim.createdAt.split('T').first;
    final serviceTypes = data?['service_types'];
    String serviceLabel = claim.serviceType ?? '';
    if (serviceTypes is List && serviceTypes.isNotEmpty) {
      final parts = <String>[];
      for (final e in serviceTypes) {
        if (e is Map) {
          final v = e['value']?.toString();
          final k = e['key']?.toString() ?? '';
          parts.add((v != null && v.isNotEmpty) ? v : k.replaceAll('_', ' '));
        }
      }
      if (parts.isNotEmpty) serviceLabel = parts.join(', ');
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.rw, 12.rh, 16.rw, 16.rh),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [config.color, config.color.withValues(alpha: 0.85)],
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.rs,
                  height: 48.rs,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14.rs),
                  ),
                  child: Center(
                    child: CommonText(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      fontSize: 20.rf,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(name, fontSize: 17.rf, fontWeight: FontWeight.w700, color: Colors.white),
                      SizedBox(height: 4.rh),
                      CommonText(
                        '${AppString.kPhoneNumber}: $phone',
                        fontSize: 12.rf,
                        color: Colors.white70,
                      ),
                      if (alt != null && alt.isNotEmpty)
                        CommonText(
                          '${AppString.kAlternatePhoneNumber}: $alt',
                          fontSize: 12.rf,
                          color: Colors.white70,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 6.rh),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.rs),
                  ),
                  child: CommonText(
                    config.label,
                    fontSize: 11.rf,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.rh),
            Row(
              children: [
                Expanded(
                  child: _amtCol(
                    AppString.kClaimedLabel,
                    '₹${claimAmt.toStringAsFixed(0)}',
                    Colors.white,
                  ),
                ),
                Expanded(
                  child: _amtCol(
                    AppString.kApprovedLabel,
                    showApproved ? '₹${approved.toStringAsFixed(0)}' : '—',
                    Colors.white,
                  ),
                ),
                Expanded(
                  child: _amtCol(
                    AppString.kDateLabel,
                    created,
                    Colors.white,
                  ),
                ),
              ],
            ),
            if (serviceLabel.isNotEmpty) ...[
              SizedBox(height: 10.rh),
              CommonText(
                '${AppString.kServiceTypeLabel}: $serviceLabel',
                fontSize: 12.rf,
                color: Colors.white70,
              ),
            ],
            if (status == 1) ...[
              SizedBox(height: 10.rh),
              Container(
                padding: EdgeInsets.all(10.rs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.rs),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18.rs, color: Colors.white),
                    SizedBox(width: 8.rw),
                    Expanded(
                      child: CommonText(
                        '${AppString.kUtrNumber}: ${data?['utr'] ?? '—'}',
                        fontSize: 12.rf,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (data?['settled_date'] != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.rh),
                  child: CommonText(
                    '${AppString.kSettledDate}: ${data?['settled_date']}',
                    fontSize: 12.rf,
                    color: Colors.white70,
                  ),
                ),
            ],
            if (status == 2 || status == 5 || status == 8) ...[
              SizedBox(height: 10.rh),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.rs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.rs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      AppString.kClaimReasonTitle,
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    SizedBox(height: 6.rh),
                    CommonText(
                      data?['reimbursement_status_reason']?.toString() ?? '—',
                      fontSize: 12.rf,
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ],
                ),
              ),
            ],
            if (canDispute) ...[
              SizedBox(height: 12.rh),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onDisputeTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 10.rh),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.rs)),
                  ),
                  child: CommonText(
                    AppString.kDisputeClaim,
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
    );
  }

  Widget _amtCol(String label, String value, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 10.rf, color: Colors.white70),
        SizedBox(height: 4.rh),
        CommonText(value, fontSize: 14.rf, fontWeight: FontWeight.w700, color: c),
      ],
    );
  }
}

void _showDisputeSheet(ClaimsController c) {
  Get.bottomSheet(
    Container(
      padding: EdgeInsets.all(20.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonText(
                AppString.kDisputeClaim,
                fontSize: 18.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 12.rh),
              TextField(
                controller: c.disputeReasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppString.kDisputeReasonHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.rs)),
                ),
              ),
              SizedBox(height: 16.rh),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        c.disputeReasonController.clear();
                        Get.back();
                      },
                      child: CommonText(AppString.kBack, color: AppColors.textSecondary),
                    ),
                  ),
                  SizedBox(width: 12.rw),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await c.submitDispute();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.rh),
                      ),
                      child: CommonText(AppString.kSubmit, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({
    required this.steps,
    required this.statusForLabel,
  });

  final List<Map<String, dynamic>> steps;
  final int statusForLabel;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Center(
        child: CommonText(
          AppString.kNoClaimHistory,
          fontSize: 14.rf,
          color: AppColors.textSecondary,
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.rs),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final rs = int.tryParse(step['reimbursement_status']?.toString() ?? '') ??
            statusForLabel;
        final cfg = ClaimStatusConfig.fromStatus(rs);
        final created = step['createdAt']?.toString() ?? '';
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22.rs,
                    height: 22.rs,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 36.rh,
                      color: AppColors.borderLight,
                      margin: EdgeInsets.symmetric(vertical: 6.rh),
                    ),
                ],
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20.rh),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        cfg.label,
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(height: 4.rh),
                      CommonText(
                        created,
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BankTab extends GetView<ClaimsController> {
  const _BankTab();

  @override
  Widget build(BuildContext context) {
    final data = controller.claimDetailData.value;
    final bd = data?['bank_details'];
    if (bd is! Map) {
      return Center(
        child: CommonText(
          AppString.kNoBankAccounts,
          fontSize: 14.rf,
          color: AppColors.textSecondary,
        ),
      );
    }
    final m = Map<String, dynamic>.from(bd);
    final verify = m['verify_status'];
    final needsFix = verify == 2;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.rs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (needsFix)
            Container(
              padding: EdgeInsets.all(12.rs),
              margin: EdgeInsets.only(bottom: 12.rh),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12.rs),
                border: Border.all(color: const Color(0xFFFFB74D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 22.rs),
                  SizedBox(width: 10.rw),
                  Expanded(
                    child: CommonText(
                      AppString.kBankRejectedUpdateHint,
                      fontSize: 12.rf,
                      color: const Color(0xFF5D4037),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          _infoCard(
            title: AppString.kBankDetailsLabel,
            rows: [
              (AppString.kAccountHolderName, m['account_holder_name']?.toString() ?? '--'),
              (AppString.kBankName, m['bank_name']?.toString() ?? '--'),
              (AppString.kAccountNumber, m['account_number']?.toString() ?? '--'),
              (AppString.kBranch, m['branch']?.toString() ?? '--'),
              (AppString.kIFSCCode, m['ifsc_code']?.toString() ?? '--'),
            ],
          ),
          if (needsFix) ...[
            SizedBox(height: 16.rh),
            Obx(() {
              final busy = controller.isBankDetailLoading.value;
              return ElevatedButton(
                onPressed: busy ? null : () => controller.openBankForClaimUpdate(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.rh),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.rs)),
                ),
                child: busy
                    ? SizedBox(
                        height: 22.rs,
                        width: 22.rs,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : CommonText(
                        AppString.kUpdateBankAccount,
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required List<(String, String)> rows,
  }) {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.rs),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: 16.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          Divider(height: 20.rh, color: AppColors.borderLight),
          ...rows.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 10.rh),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CommonText(e.$1, fontSize: 12.rf, color: AppColors.textSecondary),
                  ),
                  Expanded(
                    flex: 3,
                    child: CommonText(
                      e.$2,
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsTab extends GetView<ClaimsController> {
  const _DocumentsTab({required this.data});

  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final d = data!;
    final st = int.tryParse(d['reimbursement_status']?.toString() ?? '') ?? -1;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.rs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(AppString.kBillsLabel),
          ..._billTiles(d, st),
          _sectionTitle(AppString.kPaymentReceipts),
          ..._fileTiles(
            list: d['reimbursement_bill_payment_files'],
            type: 'PAYMENT',
            reimbursementStatus: st,
          ),
          _sectionTitle(AppString.kMedicalReports),
          ..._fileTiles(
            list: d['reimbursement_report_files'],
            type: 'REPORT',
            reimbursementStatus: st,
          ),
          _sectionTitle(AppString.kOtherDocuments),
          ..._fileTiles(
            list: d['reimbursement_other_files'],
            type: 'OTHER',
            reimbursementStatus: st,
          ),
          SizedBox(height: 24.rh),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: EdgeInsets.only(top: 8.rh, bottom: 10.rh),
      child: CommonText(t, fontSize: 15.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    );
  }

  List<Widget> _billTiles(Map<String, dynamic> d, int st) {
    final raw = d['reimbursement_bills'];
    if (raw is! List || raw.isEmpty) {
      return [
        CommonText(
          '—',
          fontSize: 13.rf,
          color: AppColors.textSecondary,
        ),
      ];
    }
    return raw.map<Widget>((e) {
      if (e is! Map) return const SizedBox.shrink();
      final bill = Map<String, dynamic>.from(e);
      final missing = st == 3 && bill['status'] == 0;
      final invalid = bill['verify_status'] == 3 && bill['status'] == 1;
      final files = bill['reimbursement_bill_files'];
      return Container(
        margin: EdgeInsets.only(bottom: 10.rh),
        padding: EdgeInsets.all(12.rs),
        decoration: BoxDecoration(
          color: missing ? const Color(0xFFFFEBEE) : AppColors.surface,
          borderRadius: BorderRadius.circular(12.rs),
          border: Border.all(
            color: missing ? Colors.red.shade200 : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CommonText(
                    '${AppString.kBillNumber}: ${bill['bill_number'] ?? '--'}',
                    fontSize: 14.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (missing)
                  _badge(AppString.kMissingDocsShort, Colors.red.shade700),
                if (invalid) _badge(AppString.kInvalidBillShort, AppColors.primary),
              ],
            ),
            SizedBox(height: 6.rh),
            CommonText(
              '${bill['clinic_name'] ?? ''} • ${bill['bill_date'] ?? ''}',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
            if (files is List && files.isNotEmpty) ...[
              SizedBox(height: 10.rh),
              ...files.map<Widget>((f) {
                if (f is! Map) return const SizedBox.shrink();
                final fm = Map<String, dynamic>.from(f);
                return _fileRow(
                  title: fm['title']?.toString() ?? AppString.kBillImages,
                  path: fm['path']?.toString(),
                  onOpen: () => _openAttachment(fm['path']?.toString()),
                );
              }),
            ],
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _fileTiles({
    required dynamic list,
    required String type,
    required int reimbursementStatus,
  }) {
    if (list is! List || list.isEmpty) {
      return [
        CommonText(
          '—',
          fontSize: 13.rf,
          color: AppColors.textSecondary,
        ),
      ];
    }
    return list.map<Widget>((e) {
      if (e is! Map) return const SizedBox.shrink();
      final m = Map<String, dynamic>.from(e);
      final missing = reimbursementStatus == 3 && m['status'] == 0;
      final canOpen = m['status'] == 1 && m['path'] != null;
      return Container(
        margin: EdgeInsets.only(bottom: 10.rh),
        padding: EdgeInsets.all(12.rs),
        decoration: BoxDecoration(
          color: missing ? const Color(0xFFFFEBEE) : AppColors.surface,
          borderRadius: BorderRadius.circular(12.rs),
          border: Border.all(
            color: missing ? Colors.red.shade200 : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CommonText(
                    m['title']?.toString() ?? type,
                    fontSize: 14.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (missing) _badge(AppString.kMissingDocsShort, Colors.red.shade700),
                if (canOpen)
                  TextButton(
                    onPressed: () => _openAttachment(m['path']?.toString()),
                    child: CommonText(AppString.kOpenFile, fontSize: 12.rf, color: AppColors.primary),
                  ),
              ],
            ),
            CommonText(
              _serviceSummary(m['service_types']),
              fontSize: 11.rf,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _badge(String text, Color c) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 4.rh),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.rs),
      ),
      child: CommonText(text, fontSize: 10.rf, fontWeight: FontWeight.w600, color: c),
    );
  }

  Widget _fileRow({required String title, required String? path, required VoidCallback onOpen}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.rh),
      child: Row(
        children: [
          Icon(Icons.attach_file, size: 18.rs, color: AppColors.textSecondary),
          SizedBox(width: 8.rw),
          Expanded(child: CommonText(title, fontSize: 12.rf, color: AppColors.textPrimary)),
          TextButton(
            onPressed: path == null || path.isEmpty ? null : onOpen,
            child: CommonText(AppString.kOpenFile, fontSize: 12.rf, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  String _serviceSummary(dynamic st) {
    if (st is! List || st.isEmpty) return '';
    final parts = <String>[];
    for (final e in st) {
      if (e is Map) {
        final v = e['value']?.toString();
        final k = e['key']?.toString() ?? '';
        parts.add((v != null && v.isNotEmpty) ? v : k.replaceAll('_', ' '));
      }
    }
    if (parts.isEmpty) return '';
    return '${AppString.kServiceTypeLabel}: ${parts.join(', ')}';
  }
}

Future<void> _openAttachment(String? path) async {
  if (path == null || path.isEmpty) return;
  final url = ApiUrl.publicFileUrl(path);
  if (url == null || url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
