import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class NoConnectionScreen extends StatefulWidget {
  const NoConnectionScreen({super.key});

  @override
  State<NoConnectionScreen> createState() => _NoConnectionScreenState();
}

class _NoConnectionScreenState extends State<NoConnectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.rw),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => _WifiOffIllustration(
                    breathValue: _controller.value,
                  ),
                ),
                SizedBox(height: 40.rh),
                CommonText(
                  'No Internet Connection',
                  fontSize: 20.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.rh),
                CommonText(
                  'Please check your Wi-Fi or mobile data\nand try again.',
                  fontSize: 14.rf,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                  height: 1.5,
                ),
                SizedBox(height: 32.rh),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 8.rs, color: Colors.redAccent),
                    SizedBox(width: 8.rw),
                    CommonText(
                      'Waiting for connection...',
                      fontSize: 12.rf,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WifiOffIllustration extends StatelessWidget {
  final double breathValue;

  const _WifiOffIllustration({required this.breathValue});

  @override
  Widget build(BuildContext context) {
    final size = 160.rs;
    final offset = breathValue * 6 - 3;

    return Transform.translate(
      offset: Offset(0, offset),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _WifiOffPainter(breathValue: breathValue),
        ),
      ),
    );
  }
}

class _WifiOffPainter extends CustomPainter {
  final double breathValue;

  _WifiOffPainter({required this.breathValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;
    final baseAlpha = 0.15 + breathValue * 0.1;

    final circlePaint = Paint()
      ..color = const Color(0xFFE8EDF2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx, size.height / 2),
      size.width * 0.45,
      circlePaint,
    );

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    for (int i = 3; i >= 1; i--) {
      final radius = 22.0 + i * 18;
      final alpha = (baseAlpha + (3 - i) * 0.2).clamp(0.0, 0.5);
      arcPaint.color = const Color(0xFF90A4AE).withValues(alpha: alpha);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        -pi * 0.75,
        pi * 0.5,
        false,
        arcPaint,
      );
    }

    final dotPaint = Paint()
      ..color = const Color(0xFF90A4AE).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 6, dotPaint);

    final slashPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 30, cy - 30),
      Offset(cx + 30, cy + 30),
      slashPaint,
    );
  }

  @override
  bool shouldRepaint(_WifiOffPainter old) => old.breathValue != breathValue;
}
