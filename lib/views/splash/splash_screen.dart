import 'dart:math';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/controllers/splash%20controller/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const _ParticleField(),
            _buildContent(),
            _buildForceUpdateOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildForceUpdateOverlay() {
    return Obx(() {
      if (!controller.forceUpdate.value) return const SizedBox.shrink();

      return Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Update Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  controller.updateMessage.value.isNotEmpty
                      ? controller.updateMessage.value
                      : 'A new version of the app is available. Please update to continue.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Open store URL via url_launcher
                      // launchUrl(Uri.parse(controller.storeUrl));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildContent() {
    return Obx(() {
      final p = controller.progress.value;
      return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Spacer(flex: 3),
            AnimatedScale(
              scale: p > 0.05 ? 1.0 : 0.6,
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              child: AnimatedOpacity(
                opacity: p > 0.02 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Image.asset(
                  "assets/png/fliphealth_name_pdf.png",
                  width: 280,
                  height: 140,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildGlowingProgress(p),
            const Spacer(flex: 2),
            AnimatedOpacity(
              opacity: p > 0.5 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text(
                  'Your Health, Simplified',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    letterSpacing: 2,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGlowingProgress(double p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: p.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFFF8A65)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticleField extends StatefulWidget {
  const _ParticleField();

  @override
  State<_ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<_ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _particles = [];
  }

  void _initParticles(Size size) {
    if (_particles.isNotEmpty) return;
    _particles = List.generate(60, (_) => _Particle.random(_random, size));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initParticles(size);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            for (final p in _particles) {
              p.update(size);
            }
            return CustomPaint(
              size: size,
              painter: _ParticlePainter(_particles),
            );
          },
        );
      },
    );
  }
}

class _Particle {
  double x, y, vx, vy, radius, opacity;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
    required this.color,
  });

  factory _Particle.random(Random rng, Size size) {
    final colors = [
      AppColors.primary.withValues(alpha: 0.15),
      const Color(0xFFFF8A65).withValues(alpha: 0.12),
      const Color(0xFFFFAB91).withValues(alpha: 0.1),
      AppColors.accent.withValues(alpha: 0.08),
      const Color(0xFFE0E0E0).withValues(alpha: 0.15),
    ];
    return _Particle(
      x: rng.nextDouble() * size.width,
      y: rng.nextDouble() * size.height,
      vx: (rng.nextDouble() - 0.5) * 0.6,
      vy: (rng.nextDouble() - 0.5) * 0.6,
      radius: rng.nextDouble() * 3.5 + 1,
      opacity: rng.nextDouble() * 0.4 + 0.1,
      color: colors[rng.nextInt(colors.length)],
    );
  }

  void update(Size size) {
    x += vx;
    y += vy;

    if (x < 0) x = size.width;
    if (x > size.width) x = 0;
    if (y < 0) y = size.height;
    if (y > size.height) y = 0;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..strokeWidth = 0.3;

    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.8);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);

      final solidPaint = Paint()
        ..color = p.color.withValues(alpha: p.opacity * 0.6);
      canvas.drawCircle(Offset(p.x, p.y), p.radius * 0.5, solidPaint);

      for (int j = i + 1; j < particles.length; j++) {
        final q = particles[j];
        final dx = p.x - q.x;
        final dy = p.y - q.y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < 100) {
          final alpha = ((1 - dist / 100) * 0.08).clamp(0.0, 1.0);
          linePaint.color = AppColors.primary.withValues(alpha: alpha);
          canvas.drawLine(Offset(p.x, p.y), Offset(q.x, q.y), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
