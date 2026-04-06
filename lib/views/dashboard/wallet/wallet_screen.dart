import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/dashboard%20controllers/wallet_controller.dart';
import 'package:flip_health/views/dashboard/wallet/wallet_all_transactions_screen.dart';
import 'package:flip_health/views/dashboard/wallet/widgets/wallet_module_card.dart';
import 'package:flip_health/views/dashboard/wallet/widgets/wallet_transaction_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  final controller = Get.find<WalletController>();

  late AnimationController _heroController;
  late AnimationController _gridController;
  late AnimationController _listController;

  late Animation<double> _heroSlide;
  late Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _heroSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );
    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    _heroController.addListener(() => setState(() {}));

    ever(controller.walletDataFetched, (fetched) {
      if (fetched) _startAnimations();
    });

    if (controller.walletDataFetched.value) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _gridController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _listController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _gridController.dispose();
    _listController.dispose();
    super.dispose();
  }

  static const _moduleColors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    AppColors.error,
    AppColors.warning,
    AppColors.info,
  ];

  static const _moduleIcons = <String, String>{
    'Consultation': AppString.kIconConsultation,
    'Lab': AppString.kIconDiagnostics,
    'Pharmacy': AppString.kIconPrescribedPharmacy,
    'Dental': AppString.kIconDental,
    'Vision': AppString.kIconVision,
    'Vaccine': AppString.kIconVaccination,
  };

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      appBar: CommonAppBar.build(title: AppString.kOPDWallet),
      body: Obx(() {
        if (!controller.walletDataFetched.value) {
          return _buildShimmer();
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.rs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.rh),
              _buildBalanceHeroCard(),
              SizedBox(height: 24.rh),
              _buildModuleBreakup(),
              SizedBox(height: 24.rh),
              _buildRecentTransactions(),
              SizedBox(height: 24.rh),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: EdgeInsets.all(16.rs),
      child: Column(
        children: [
          _shimmerBox(height: 180.rh, borderRadius: 20.rs),
          SizedBox(height: 24.rh),
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.rs),
                  child: _shimmerBox(height: 120.rh, borderRadius: 16.rs),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.rh),
          ...List.generate(
            4,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 10.rh),
              child: _shimmerBox(height: 68.rh, borderRadius: 14.rs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, double borderRadius = 12}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _buildBalanceHeroCard() {
    final data = controller.wallet.value;
    final available = data.available;
    final total = data.total > 0 ? data.total : 1;
    final progress = total > 0 ? (available / total).clamp(0.0, 1.0) : 0.0;

    return Transform.translate(
      offset: Offset(0, _heroSlide.value),
      child: Opacity(
        opacity: _heroFade.value,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.rs),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primaryDark.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20.rs),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.rs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.rs),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 22.rs,
                    ),
                  ),
                  SizedBox(width: 12.rs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          AppString.kAvailableBalance,
                          fontSize: 12.rf,
                          color: Colors.white70,
                        ),
                        SizedBox(height: 2.rh),
                        CommonText(
                          '₹ ${_formatCurrency(available)}',
                          fontSize: 26.rf,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.rh),
              ClipRRect(
                borderRadius: BorderRadius.circular(6.rs),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 6.rh,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 14.rh),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeroStat(
                    AppString.kTotalBalance,
                    '₹ ${_formatCurrency(total)}',
                  ),
                  _buildHeroStat(
                    AppString.kValidTill,
                    data.expiresAt,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 11.rf, color: Colors.white54),
        SizedBox(height: 2.rh),
        CommonText(
          value,
          fontSize: 13.rf,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildModuleBreakup() {
    final moduleEntries = controller.wallet.value.module.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          AppString.kModuleBreakup,
          fontSize: 16.rf,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 12.rh),
        LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 3;
            final spacing = 8.rs;
            final cardWidth =
                (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                    crossAxisCount;
            final cardHeight = cardWidth * 1.15;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: cardWidth / cardHeight,
              ),
              itemCount: moduleEntries.length,
              itemBuilder: (context, index) {
                final entry = moduleEntries[index];
                final mod = entry.value;
                final avail = mod.availableInt;
                final total = mod.totalInt;
                final color = _moduleColors[index % _moduleColors.length];

                final icon = _moduleIcons[entry.key] ??
                    AppString.kIconDiagnostics;

                return _buildStaggeredChild(
                  index: index,
                  child: WalletModuleCard(
                    moduleName: entry.key,
                    svgIcon: icon,
                    available: avail,
                    total: total,
                    color: color,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStaggeredChild({required int index, required Widget child}) {
    final interval = Interval(
      (index * 0.1).clamp(0.0, 0.6),
      ((index * 0.1) + 0.5).clamp(0.0, 1.0),
      curve: Curves.easeOutBack,
    );
    return AnimatedBuilder(
      animation: _gridController,
      builder: (context, ch) {
        final value = interval.transform(_gridController.value);
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: ch),
        );
      },
      child: child,
    );
  }

  Widget _buildRecentTransactions() {
    final txList = controller.transactions.take(10).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              AppString.kRecentTransactions,
              fontSize: 16.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            GestureDetector(
              onTap: () => Get.to(() => const WalletAllTransactionsScreen()),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12.rs, vertical: 6.rs),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20.rs),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(
                      AppString.kViewAll,
                      fontSize: 12.rf,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.rs),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 12.rs, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.rh),
        if (txList.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.rh),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 48.rs, color: AppColors.textSecondary),
                  SizedBox(height: 12.rh),
                  CommonText(
                    AppString.kNoTransactionsYet,
                    fontSize: 14.rf,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          )
        else
          ...txList.asMap().entries.map((entry) {
            final interval = Interval(
              (entry.key * 0.08).clamp(0.0, 0.5),
              ((entry.key * 0.08) + 0.5).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            );
            return AnimatedBuilder(
              animation: _listController,
              builder: (context, ch) {
                final val = interval.transform(_listController.value);
                return Opacity(
                  opacity: val.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - val)),
                    child: ch,
                  ),
                );
              },
              child: WalletTransactionCard(
                transaction: entry.value,
                index: entry.key,
              ),
            );
          }),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    final num? n = value is num ? value : num.tryParse(value.toString());
    if (n == null) return '0';
    final amount = n.round();
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    }
    final str = amount.toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result.write(str[i]);
      count++;
      if (count == 3 && i > 0) {
        result.write(',');
      } else if (count > 3 && (count - 3) % 2 == 0 && i > 0) {
        result.write(',');
      }
    }
    return result.toString().split('').reversed.join('');
  }
}
