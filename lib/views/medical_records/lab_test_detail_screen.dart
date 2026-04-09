import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/medical%20records%20models/lab_test_record_model.dart';

class LabTestDetailScreen extends StatefulWidget {
  final LabTestRecordModel record;
  const LabTestDetailScreen({super.key, required this.record});

  @override
  State<LabTestDetailScreen> createState() => _LabTestDetailScreenState();
}

class _LabTestDetailScreenState extends State<LabTestDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;

    return SafeScreenWrapper(
      appBar: CommonAppBar.build(title: 'Lab Test Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
        child: Column(
          children: [
            _AnimatedSection(
              animation: _animController,
              start: 0.0,
              end: 0.25,
              child: _StatusBanner(record: r),
            ),
            SizedBox(height: 14.rh),
            _AnimatedSection(
              animation: _animController,
              start: 0.1,
              end: 0.4,
              child: _TestSummaryCard(record: r),
            ),
            SizedBox(height: 12.rh),
            _AnimatedSection(
              animation: _animController,
              start: 0.2,
              end: 0.55,
              child: _OrderDetailsCard(record: r),
            ),
            if (r.testCodes.isNotEmpty) ...[
              SizedBox(height: 12.rh),
              _AnimatedSection(
                animation: _animController,
                start: 0.35,
                end: 0.7,
                child: _TestCodesCard(testCodes: r.testCodes),
              ),
            ],
            if (r.displayAddress != null || r.centerName != null) ...[
              SizedBox(height: 12.rh),
              _AnimatedSection(
                animation: _animController,
                start: 0.5,
                end: 0.85,
                child: _LocationCard(record: r),
              ),
            ],
            SizedBox(height: 24.rh),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final LabTestRecordModel record;
  const _StatusBanner({required this.record});

  @override
  Widget build(BuildContext context) {
    final label = record.statusLabel;
    final isCancelled = label == 'Cancelled';
    final isPending = label == 'Pending';

    final color = isCancelled
        ? AppColors.error
        : isPending
            ? AppColors.warning
            : AppColors.success;
    final bgColor = isCancelled
        ? AppColors.errorLight
        : isPending
            ? AppColors.warningLight
            : AppColors.successLight;
    final icon = isCancelled
        ? Icons.cancel_rounded
        : isPending
            ? Icons.hourglass_top_rounded
            : Icons.check_circle_rounded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.rs),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28.rs),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  label,
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  record.visitTypeLabel,
                  fontSize: 12.rf,
                  color: color,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
          if (record.sponsored)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.rs),
              ),
              child: CommonText(
                'Sponsored',
                fontSize: 10.rf,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _TestSummaryCard extends StatelessWidget {
  final LabTestRecordModel record;
  const _TestSummaryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final isRadiology = record.category.toLowerCase() == 'radiology';

    return _InfoCard(
      title: 'Test Summary',
      child: Row(
        children: [
          Container(
            width: 50.rs,
            height: 50.rs,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isRadiology
                    ? [const Color(0xff7C4DFF), const Color(0xffB388FF)]
                    : AppColors.infoGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.rs),
            ),
            child: Icon(
              isRadiology ? Icons.monitor_heart_rounded : Icons.biotech_rounded,
              color: Colors.white,
              size: 24.rs,
            ),
          ),
          SizedBox(width: 14.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  record.displayTitle,
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  record.category.isNotEmpty
                      ? '${record.category[0].toUpperCase()}${record.category.substring(1)}'
                      : 'Lab Test',
                  fontSize: 12.rf,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                if (record.totalParameters > 0) ...[
                  SizedBox(height: 2.rh),
                  CommonText(
                    '${record.totalParameters} parameters',
                    fontSize: 11.rf,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _OrderDetailsCard extends StatelessWidget {
  final LabTestRecordModel record;
  const _OrderDetailsCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Order Details',
      child: Column(
        children: [
          _DetailRow(label: 'Date', value: record.displayDate),
          if (record.collectionSlotTime != null)
            _DetailRow(label: 'Time Slot', value: record.collectionSlotTime!),
          _DetailRow(label: 'Visit Type', value: record.visitTypeLabel),
          if (record.source != null)
            _DetailRow(label: 'Source', value: record.source!),
          if (record.orderId != null)
            _DetailRow(label: 'Order ID', value: record.orderId!),
          if (record.invoiceId != null)
            _DetailRow(
              label: 'Invoice ID',
              value: record.invoiceId!,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _TestCodesCard extends StatelessWidget {
  final List<LabTestCode> testCodes;
  const _TestCodesCard({required this.testCodes});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Tests Included',
      child: Column(
        children: List.generate(testCodes.length, (i) {
          final tc = testCodes[i];
          final isLast = i == testCodes.length - 1;
          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 10.rh),
            padding: EdgeInsets.all(10.rs),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10.rs),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.rs,
                  height: 32.rs,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.rs),
                  ),
                  child: Center(
                    child: CommonText(
                      '${i + 1}',
                      fontSize: 12.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.info,
                    ),
                  ),
                ),
                SizedBox(width: 10.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        tc.name,
                        fontSize: 12.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.rh),
                      Row(
                        children: [
                          if (tc.category.isNotEmpty)
                            CommonText(
                              '${tc.category[0].toUpperCase()}${tc.category.substring(1)}',
                              fontSize: 10.rf,
                              color: AppColors.textSecondary,
                            ),
                          if (tc.parameterCount > 0)
                            CommonText(
                              '  •  ${tc.parameterCount} params',
                              fontSize: 10.rf,
                              color: AppColors.textTertiary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (tc.offerPrice != null) ...[
                  SizedBox(width: 6.rw),
                  CommonText(
                    '₹${tc.offerPrice!.toStringAsFixed(0)}',
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final LabTestRecordModel record;
  const _LocationCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: record.isHomePickup ? 'Pickup Address' : 'Collection Center',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (record.centerName != null && record.centerName!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.local_hospital_rounded,
                  size: 16.rs,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6.rw),
                Expanded(
                  child: CommonText(
                    record.centerName!,
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.rh),
          ],
          if (record.centerAddress != null &&
              record.centerAddress!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.rs,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6.rw),
                Expanded(
                  child: CommonText(
                    record.centerAddress!,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.rh),
          ],
          if (record.displayAddress != null &&
              record.displayAddress!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.home_rounded,
                  size: 16.rs,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6.rw),
                Expanded(
                  child: CommonText(
                    record.displayAddress!,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Shared building blocks
// ──────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            title,
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          Divider(height: 20.rh, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.rw,
            child: CommonText(
              label,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: CommonText(
              value,
              fontSize: 12.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final Animation<double> animation;
  final double start;
  final double end;
  final Widget child;
  const _AnimatedSection({
    required this.animation,
    required this.start,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
