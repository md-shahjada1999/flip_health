import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/data/repositories/health_checkup_repository.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';

class SelectPlanPage extends StatefulWidget {
  const SelectPlanPage({Key? key}) : super(key: key);

  @override
  State<SelectPlanPage> createState() => _SelectPlanPageState();
}

class _SelectPlanPageState extends State<SelectPlanPage> {
  late final HealthCheckupsController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<HealthCheckupRepository>()) {
      Get.lazyPut<HealthCheckupRepository>(
          () => HealthCheckupRepository(apiService: Get.find()));
    }
    controller =
        Get.put(HealthCheckupsController(repository: Get.find()));
    controller.fetchPackages();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: AppString.kHealthCheckupsTitle,
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.packages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            _buildLocationHeader(),
            Expanded(
              child: controller.packages.isEmpty
                  ? Center(
                      child: CommonText(
                        'No packages available',
                        fontSize: 14.rf,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 16.rh),
                      itemCount: controller.packages.length,
                      itemBuilder: (context, index) {
                        final pkg = controller.packages[index];
                        return _PackageCard(
                          package: pkg,
                          controller: controller,
                          index: index,
                        );
                      },
                    ),
            ),
            SafeBottomPadding(
              child: _buildBottomButton(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 12.rh),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary, size: 20.rs),
          SizedBox(width: 8.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Home',
                  fontSize: 14.rf,
                  color: AppColors.textPrimary,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        'Isprout, 7th floor, Plot No: 25, Divyasree trinity,',
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16.rs, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return ActionButton(
      text: "Continue",
      onPressed: controller.continueWithPlanSelection,
    );
  }
}

class _PackageCard extends StatelessWidget {
  final DiagnosticsPackage package;
  final HealthCheckupsController controller;
  final int index;

  const _PackageCard({
    required this.package,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.expandedPackageId.value == package.id;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 6.rh),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.rs),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: name + fasting badge
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    package.name,
                    fontSize: 15.rf,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  SizedBox(height: 6.rh),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.category_outlined,
                        label: package.category,
                      ),
                      SizedBox(width: 8.rw),
                      _InfoChip(
                        icon: Icons.science_outlined,
                        label: package.type,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // "See what's included" tap area
            GestureDetector(
              onTap: () => controller.fetchPackageDetail(package.id),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.rw),
                child: Row(
                  children: [
                    CommonText(
                      "See what's included",
                      fontSize: 12.rf,
                      color: AppColors.accent,
                      decoration: TextDecoration.underline,
                      style: TextStyle(
                        decorationColor: AppColors.accent,
                        decorationThickness: 1.5,
                      ),
                    ),
                    SizedBox(width: 4.rw),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16.rs,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.rh),

            // Expandable detail
            if (isExpanded) _buildExpandedDetail(),

            // Fasting info
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.rw),
              height: 25.rh,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xffF4F4F4),
                  Color(0xff000000),
                ]),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.primary, size: 12),
                        SizedBox(width: 4.rw),
                        CommonText(
                          package.fastingLabel,
                          fontSize: 10.rf,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.rh),

            // Feature items
            _buildFeatureItem(
              Icons.access_time,
              package.tatLabel.isNotEmpty
                  ? package.tatLabel
                  : 'Reports within 48 hours',
              AppColors.warning.withValues(alpha: 0.7),
              AppString.reportsOntimeIcon,
            ),
            _buildFeatureItem(
              Icons.bolt,
              'Instant confirmation',
              AppColors.primary,
              null,
            ),
            _buildFeatureItem(
              Icons.check,
              'From the comfort of your home',
              AppColors.success,
              null,
            ),

            SizedBox(height: 4.rh),

            // Home Collection footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 2.rh, horizontal: 17.rw),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.rs),
                  bottomRight: Radius.circular(12.rs),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(AppString.kHomeIcon,
                      width: 10.rw, height: 10.rh, color: Colors.white),
                  SizedBox(width: 8.rw),
                  CommonText(
                    'Home Collection',
                    fontSize: 9.rf,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFeatureItem(
      IconData icon, String text, Color iconColor, String? svgPath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 4.rh),
      child: Row(
        children: [
          svgPath != null
              ? SvgPicture.asset(
                  svgPath,
                  width: 10.rw,
                  height: 10.rh,
                  color: iconColor,
                )
              : Icon(icon, size: 12.rs, color: iconColor),
          SizedBox(width: 12.rw),
          Expanded(
            child: CommonText(
              text,
              fontSize: 10.rf,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetail() {
    return Obx(() {
      final isLoading = controller.isDetailLoading.value;
      final detail = controller.selectedPackageDetail.value;

      if (isLoading) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.rh),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        );
      }

      if (detail == null) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 12.rw),
        padding: EdgeInsets.all(12.rs),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12.rs),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor row
            if (detail.vendor != null) ...[
              Row(
                children: [
                  if (detail.vendor!.logo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.rs),
                      child: Image.network(
                        _resolveLogoUrl(detail.vendor!.logo!),
                        width: 40.rw,
                        height: 40.rh,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.local_hospital,
                          size: 28.rs,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  SizedBox(width: 10.rw),
                  Expanded(
                    child: CommonText(
                      detail.vendor!.name,
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.rh),
            ],

            // Price
            Row(
              children: [
                CommonText(
                  '\u20B9 ${detail.b2cPrice.toStringAsFixed(0)}',
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                if (detail.b2cMrp > detail.b2cPrice) ...[
                  SizedBox(width: 8.rw),
                  CommonText(
                    '\u20B9 ${detail.b2cMrp.toStringAsFixed(0)}',
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                    height: 1.3,
                  ),
                ],
              ],
            ),

            SizedBox(height: 10.rh),

            // Parameter count
            CommonText(
              '${detail.parameterCount} Parameters Included',
              fontSize: 12.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              height: 1.3,
            ),
            SizedBox(height: 8.rh),

            // Parameters list
            ...detail.parameters.map(
              (p) => Padding(
                padding: EdgeInsets.only(bottom: 4.rh),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 14.rs, color: AppColors.success),
                    SizedBox(width: 6.rw),
                    Expanded(
                      child: CommonText(
                        p.name,
                        fontSize: 11.rf,
                        color: AppColors.textTertiary,
                        height: 1.4,
                      ),
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

  String _resolveLogoUrl(String logo) {
    if (logo.startsWith('http://') || logo.startsWith('https://')) return logo;
    return '${ApiUrl.kImageUrl}$logo';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.rw, vertical: 2.rh),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8.rs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.rs, color: AppColors.textSecondary),
          SizedBox(width: 3.rw),
          CommonText(
            label,
            fontSize: 10.rf,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ],
      ),
    );
  }
}
