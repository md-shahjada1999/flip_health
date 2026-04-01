import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health_score%20controllers/health_score_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/routes/app_routes.dart';

class HealthScoreResult extends StatefulWidget {
  const HealthScoreResult({Key? key}) : super(key: key);

  @override
  State<HealthScoreResult> createState() => _HealthScoreResultState();
}

class _HealthScoreResultState extends State<HealthScoreResult>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideUp;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  final controller = Get.find<HealthScoreController>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideUp = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
          parent: _animController,
          curve: const Interval(0, 0.6, curve: Curves.easeOutCubic)),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animController,
          curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );
    _scaleIn = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.2, 0.7, curve: Curves.elasticOut)),
    );
    _animController.addListener(() => setState(() {}));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.rw),
                  child: Column(
                    children: [
                      SizedBox(height: 20.rh),
                      Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: Opacity(
                          opacity: _fadeIn.value,
                          child: _buildHeroCard(),
                        ),
                      ),
                      SizedBox(height: 24.rh),
                      Opacity(
                        opacity: _fadeIn.value,
                        child: _buildBmiAxis(),
                      ),
                      SizedBox(height: 24.rh),
                      Transform.scale(
                        scale: _scaleIn.value,
                        child: Opacity(
                          opacity: _fadeIn.value,
                          child: _buildStatusMessage(),
                        ),
                      ),
                      SizedBox(height: 24.rh),
                      Opacity(
                        opacity: _fadeIn.value,
                        child: _buildInfoCards(),
                      ),
                      SizedBox(height: 100.rh),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Obx(() => Container(
          width: double.infinity,
          height: 200.rh,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20.rs),
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(double.infinity, 200.rh),
                painter: _CurvePainter(color: AppColors.primary),
              ),
              Positioned(
                top: 16.rh,
                left: 20.rw,
                child: Image.asset(
                  'assets/png/logo.png',
                  height: 28.rh,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Positioned(
                top: 16.rh,
                right: 20.rw,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.rf,
                        color: Colors.white70),
                    children: [
                      const TextSpan(text: "here's your\n"),
                      TextSpan(
                        text: 'Body Mass Index',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.rf,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.rh),
                    CommonText(
                      controller.bmiValue.value.toStringAsFixed(1),
                      fontSize: 56.rf,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    CommonText(
                      'BMI Score',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildBmiAxis() {
    const categories = [
      ('Underweight', Color(0xFF42A5F5)),
      ('Healthy', Color(0xFF4CAF50)),
      ('Overweight', Color(0xFFFF9800)),
      ('Obese', Color(0xFFF44336)),
    ];
    const labels = ['0', '18.5', '25', '30+'];

    return Column(
      children: [
        Row(
          children: categories.map((c) {
            return Expanded(
              child: Container(
                height: 8.rh,
                margin: EdgeInsets.symmetric(horizontal: 2.rw),
                decoration: BoxDecoration(
                  color: c.$2,
                  borderRadius: BorderRadius.circular(4.rs),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 6.rh),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map((l) => CommonText(l,
                  fontSize: 10.rf, color: AppColors.textSecondary))
              .toList(),
        ),
        SizedBox(height: 10.rh),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: categories
              .map((c) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.rs,
                        height: 8.rs,
                        decoration:
                            BoxDecoration(color: c.$2, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 4.rw),
                      CommonText(c.$1,
                          fontSize: 10.rf, color: AppColors.textSecondary),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    return Obx(() {
      final isHealthy =
          controller.bmiValue.value >= 18.5 && controller.bmiValue.value < 25;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.rs),
        decoration: BoxDecoration(
          color: isHealthy
              ? const Color(0xFF4CAF50).withOpacity(0.08)
              : const Color(0xFFF44336).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14.rs),
          border: Border.all(
            color: isHealthy
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : const Color(0xFFF44336).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isHealthy ? Icons.check_circle : Icons.info_outline,
              color: isHealthy
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
              size: 28.rs,
            ),
            SizedBox(width: 12.rw),
            Expanded(
              child: CommonText(
                isHealthy
                    ? 'You are healthy! Keep maintaining your current lifestyle.'
                    : 'Your BMI is outside the healthy range. Consider consulting a nutritionist.',
                fontSize: 13.rf,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoCards() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _infoCard(
                Icons.monitor_weight_outlined,
                'Ideal Weight',
                controller.idealWeightRange,
                const Color(0xFF4CAF50),
              ),
            ),
            SizedBox(width: 12.rw),
            Expanded(
              child: _infoCard(
                Icons.straighten,
                'Height',
                '${controller.bmiHeightCm.value.toStringAsFixed(1)} cm',
                const Color(0xFF42A5F5),
              ),
            ),
          ],
        ));
  }

  Widget _infoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22.rs, color: color),
          SizedBox(height: 10.rh),
          CommonText(label, fontSize: 11.rf, color: AppColors.textSecondary),
          SizedBox(height: 4.rh),
          CommonText(value,
              fontSize: 14.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.rs, 12.rs, 20.rs, 20.rs),
      child: ElevatedButton(
        onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16.rh),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.rs),
          ),
        ),
        child: CommonText(
          'Continue',
          fontSize: 16.rf,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  final Color color;
  _CurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.45,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.7,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(20),
      ),
      Paint()..color = Colors.transparent,
    );
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.color != color;
}
