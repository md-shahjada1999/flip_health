import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/routes/app_routes.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({Key? key}) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _circleController;
  late AnimationController _confettiController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _checkmarkAnimation;
  late Animation<double> _circleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();

    // Circle animation controller
    _circleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Checkmark animation controller
    _checkmarkController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Confetti animation controller
    _confettiController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Slide animation controller
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation controller
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    // Circle animation
    _circleAnimation = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    );

    // Checkmark animation
    _checkmarkAnimation = CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    );

    // Slide animation
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    // Scale animation
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    // Generate confetti particles
    _generateConfetti();

    // Start animations sequence
    _startAnimations();
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(
        ConfettiParticle(
          x: random.nextDouble(),
          y: random.nextDouble() * -0.1,
          color: [
            AppColors.primary,
            AppColors.accent,
            AppColors.warning,
            AppColors.success,
            Colors.purple,
            Colors.pink,
          ][random.nextInt(6)],
          size: random.nextDouble() * 10 + 5,
          rotation: random.nextDouble() * math.pi * 2,
          velocityY: random.nextDouble() * 2 + 1,
          velocityX: (random.nextDouble() - 0.5) * 0.5,
        ),
      );
    }
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _circleController.forward();

    await Future.delayed(Duration(milliseconds: 400));
    _checkmarkController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    _confettiController.forward();

    await Future.delayed(Duration(milliseconds: 400));
    _slideController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _circleController.dispose();
    _confettiController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
    
      body: SafeArea(
        child: Stack(
          children: [
            

            // Main Content
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10.rh),
                        
                        // Success Animation
                        _buildSuccessAnimation(),

                        SizedBox(height: 10.rh),

                        // Success Text
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_slideAnimation),
                          child: FadeTransition(
                            opacity: _slideAnimation,
                            child: Column(
                              children: [
                                CommonText(
                                  AppString.kPaymentSuccessTitle,
                                  fontSize: 28.rf,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                  height: 1.3,
                                ),
                                SizedBox(height: 12.rh),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 40.rw),
                                  child: CommonText(
                                    AppString.kPaymentSuccessMessage,
                                    textAlign: TextAlign.center,
                                    fontSize: 15.rf,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 40.rh),

                        // Booking Details Card
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildBookingDetailsCard(),
                        ),

                        SizedBox(height: 20.rh),

                        // Flip Coins Earned
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildFlipCoinsCard(),
                        ),

                         // Bottom Buttons
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildBottomButtons(),
                ),
                      ],
                    ),
                  ),
                ),

               
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return SizedBox(
      width: 150.rs,
      height: 150.rs,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing circles in background
          AnimatedBuilder(
            animation: _circleController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse circle
                  Opacity(
                    opacity: 1 - _circleController.value,
                    child: Container(
                      width: 200.rs * (1 + _circleController.value * 0.5),
                      height: 200.rs * (1 + _circleController.value * 0.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                  // Inner pulse circle
                  Opacity(
                    opacity: 1 - _circleController.value * 0.7,
                    child: Container(
                      width: 180.rs * (1 + _circleController.value * 0.3),
                      height: 180.rs * (1 + _circleController.value * 0.3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Main success circle with checkmark
          AnimatedBuilder(
            animation: _circleAnimation,
            builder: (context, child) {
              return Container(
                width: 150.rs,
                height: 150.rs,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _checkmarkAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CheckmarkPainter(
                        progress: _checkmarkAnimation.value,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.rw),
      padding: EdgeInsets.all(20.rs),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            AppString.kBookingId,
            'BK123456789',
            isHighlighted: true,
          ),
          SizedBox(height: 16.rh),
          Divider(height: 1, color: AppColors.borderLight),
          SizedBox(height: 16.rh),
          _buildDetailRow(
            AppString.kPatientName,
            'Kalyan',
          ),
          SizedBox(height: 12.rh),
          _buildDetailRow(
            AppString.kTestName,
            'Employee Annual Health Checkup',
          ),
          SizedBox(height: 12.rh),
          _buildDetailRow(
            AppString.kScheduledDate,
            'April 10, 2024 | 2PM-3PM',
          ),
          SizedBox(height: 12.rh),
          _buildDetailRow(
            AppString.kCollectionType,
            'Home Collection',
            icon: Icons.home_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlighted = false,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 13.rf,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(width: 16.rw),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.rs, color: AppColors.primary),
                SizedBox(width: 6.rw),
              ],
              Flexible(
                child: CommonText(
                  value,
                  textAlign: TextAlign.right,
                  fontSize: isHighlighted ? 15.rf : 13.rf,
                  color: isHighlighted
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlipCoinsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.rw),
      padding: EdgeInsets.all(12.rs),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.rs,
            height: 40.rs,
            decoration: BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 24.rs,
            ),
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  AppString.kFlipCoinsEarned,
                  fontSize: 13.rf,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 4.rh),
                Row(
                  children: [
                    CommonText(
                      '400 Coins',
                      fontSize: 18.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    SizedBox(width: 8.rw),
                    CommonText(
                      '(Worth ₹40)',
                      fontSize: 13.rf,
                      color: AppColors.success,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(20.rs),
      decoration: BoxDecoration(
        color: AppColors.background,
       
        
      ),
      child: Column(
        children: [
          
          // Back to Home Button
          ActionButton(
            text: AppString.kBackToHome,
            onPressed: () {
              Get.offAllNamed(AppRoutes.dashboard);
            },
          ),
        ],
      ),
    );
  }
}

// Checkmark Painter
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Checkmark path
    final startX = centerX - size.width * 0.2;
    final startY = centerY;
    final middleX = centerX - size.width * 0.05;
    final middleY = centerY + size.height * 0.15;
    final endX = centerX + size.width * 0.25;
    final endY = centerY - size.height * 0.2;

    path.moveTo(startX, startY);

    if (progress <= 0.5) {
      // First half: draw to middle point
      final t = progress * 2;
      path.lineTo(
        startX + (middleX - startX) * t,
        startY + (middleY - startY) * t,
      );
    } else {
      // Second half: draw to end point
      path.lineTo(middleX, middleY);
      final t = (progress - 0.5) * 2;
      path.lineTo(
        middleX + (endX - middleX) * t,
        middleY + (endY - middleY) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Confetti Particle
class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  double rotation;
  final double velocityY;
  final double velocityX;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.velocityY,
    required this.velocityX,
  });
}
