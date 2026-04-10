import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_family.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/model/splash%20models/notice_board_model.dart';

class NoticeBoardScreen extends StatefulWidget {
  final NoticeBanner banner;

  /// null when blockLogin is true — user cannot proceed.
  final VoidCallback? onContinue;

  const NoticeBoardScreen({
    super.key,
    required this.banner,
    this.onContinue,
  });

  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _imageScale;
  late final Animation<double> _noteSlide;
  late final Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _imageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _noteSlide = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isBlocked => widget.onContinue == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _entryController,
          builder: (context, _) {
            return FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                   // _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.rw),
                        child: Column(
                          children: [
                            SizedBox(height: 20.rh),
                            _buildBannerImage(),
                            SizedBox(height: 18.rh),
                            _buildScheduleCard(),
                            SizedBox(height: 18.rh),
                            _buildNoteCard(),
                            SizedBox(height: 30.rh),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header with icon
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.rw, 16.rh, 20.rw, 0),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) {
              final scale = 1.0 + (_pulseController.value * 0.08);
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 42.rs,
              height: 42.rs,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning,
                    AppColors.warning.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.rs),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isBlocked
                    ? Icons.notifications_active_rounded
                    : Icons.campaign_rounded,
                size: 22.rs,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 14.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isBlocked ? 'Important Notice' : 'Announcement',
                  style: TextStyle(
                    fontFamily: FontFamily.fontName,
                    fontSize: 18.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.rh),
                Text(
                  _isBlocked
                      ? 'Please read before proceeding'
                      : 'Here\'s what\'s new',
                  style: TextStyle(
                    fontFamily: FontFamily.fontName,
                    fontSize: 12.rf,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_isBlocked)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 5.rh),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.rs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 13.rs, color: AppColors.error),
                  SizedBox(width: 4.rw),
                  Text(
                    'Blocked',
                    style: TextStyle(
                      fontFamily: FontFamily.fontName,
                      fontSize: 11.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Banner image with animated scale
  // ---------------------------------------------------------------------------

  Widget _buildBannerImage() {
    final imageUrl = ApiUrl.publicFileUrl(widget.banner.image);
    if (imageUrl == null) return _buildIllustrationFallback();

    return ScaleTransition(
      scale: _imageScale,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: 220.rh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.rs),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.rs),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _buildImagePlaceholder();
            },
            errorBuilder: (_, __, ___) => _buildIllustrationFallback(),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200.rh,
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(20.rs),
      ),
      child: Center(
        child: SizedBox(
          width: 28.rs,
          height: 28.rs,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildIllustrationFallback() {
    return Container(
      height: 200.rh,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.rs),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative circles
          Positioned(
            top: 20.rh,
            left: 30.rw,
            child: _decorCircle(40.rs, AppColors.warning.withValues(alpha: 0.15)),
          ),
          Positioned(
            bottom: 30.rh,
            right: 40.rw,
            child: _decorCircle(60.rs, AppColors.primary.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 50.rh,
            right: 60.rw,
            child: _decorCircle(24.rs, AppColors.info.withValues(alpha: 0.12)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.rs,
                height: 64.rs,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  size: 32.rs,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(height: 12.rh),
              Text(
                'Notice Board',
                style: TextStyle(
                  fontFamily: FontFamily.fontName,
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  // ---------------------------------------------------------------------------
  // Schedule / timeline card
  // ---------------------------------------------------------------------------

  Widget _buildScheduleCard() {
    final start = _tryParseDate(widget.banner.eventStart);
    final end = _tryParseDate(widget.banner.eventEnd);

    if (start == null && end == null) return const SizedBox.shrink();

    final dateFmt = DateFormat('dd MMM yyyy');
    final timeFmt = DateFormat('hh:mm a');

    final now = DateTime.now();
    final isOngoing = start != null && end != null && now.isAfter(start) && now.isBefore(end);
    final remaining = end != null && end.isAfter(now) ? end.difference(now) : null;

    return FadeTransition(
      opacity: _noteSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.rs),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.rs),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.rs,
                    height: 32.rs,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.rs),
                    ),
                    child: Icon(Icons.schedule_rounded,
                        size: 16.rs, color: AppColors.warning),
                  ),
                  SizedBox(width: 10.rw),
                  Expanded(
                    child: Text(
                      'Schedule',
                      style: TextStyle(
                        fontFamily: FontFamily.fontName,
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isOngoing)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.rw, vertical: 4.rh),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.rs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (_, __) {
                              return Container(
                                width: 6.rs,
                                height: 6.rs,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.lerp(
                                    AppColors.warning.withValues(alpha: 0.4),
                                    AppColors.warning,
                                    _pulseController.value,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 6.rw),
                          Text(
                            'Ongoing',
                            style: TextStyle(
                              fontFamily: FontFamily.fontName,
                              fontSize: 11.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.rh),

              // Timeline row
              IntrinsicHeight(
                child: Row(
                  children: [
                    if (start != null)
                      Expanded(
                        child: _buildDateBlock(
                          label: 'Starts',
                          date: dateFmt.format(start),
                          time: timeFmt.format(start),
                          color: AppColors.success,
                          icon: Icons.play_circle_outline_rounded,
                        ),
                      ),
                    if (start != null && end != null) ...[
                      SizedBox(width: 12.rw),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24.rs,
                            height: 24.rs,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundTertiary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 14.rs, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.rw),
                    ],
                    if (end != null)
                      Expanded(
                        child: _buildDateBlock(
                          label: 'Ends',
                          date: dateFmt.format(end),
                          time: timeFmt.format(end),
                          color: AppColors.error,
                          icon: Icons.stop_circle_outlined,
                        ),
                      ),
                  ],
                ),
              ),

              // Remaining time
              if (remaining != null && _isBlocked) ...[
                SizedBox(height: 16.rh),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 10.rh, horizontal: 14.rw),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10.rs),
                    border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_bottom_rounded,
                          size: 16.rs, color: AppColors.info),
                      SizedBox(width: 8.rw),
                      Text(
                        'Expected to resume in ${_formatDuration(remaining)}',
                        style: TextStyle(
                          fontFamily: FontFamily.fontName,
                          fontSize: 12.rf,
                          fontWeight: FontWeight.w500,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBlock({
    required String label,
    required String date,
    required String time,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12.rs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.rs, color: color),
              SizedBox(width: 6.rw),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontFamily.fontName,
                  fontSize: 11.rf,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.rh),
          Text(
            date,
            style: TextStyle(
              fontFamily: FontFamily.fontName,
              fontSize: 14.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.rh),
          Text(
            time,
            style: TextStyle(
              fontFamily: FontFamily.fontName,
              fontSize: 12.rf,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      final days = d.inDays;
      final hrs = d.inHours.remainder(24);
      if (hrs > 0) return '$days day${days > 1 ? 's' : ''} $hrs hr${hrs > 1 ? 's' : ''}';
      return '$days day${days > 1 ? 's' : ''}';
    }
    if (d.inHours > 0) {
      final hrs = d.inHours;
      final mins = d.inMinutes.remainder(60);
      if (mins > 0) return '$hrs hr${hrs > 1 ? 's' : ''} $mins min';
      return '$hrs hr${hrs > 1 ? 's' : ''}';
    }
    return '${d.inMinutes} min';
  }

  // ---------------------------------------------------------------------------
  // Note card with animated entrance
  // ---------------------------------------------------------------------------

  Widget _buildNoteCard() {
    if (widget.banner.note == null || widget.banner.note!.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _noteSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.rs),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.rs),
            border: Border.all(
              color: _isBlocked
                  ? AppColors.warning.withValues(alpha: 0.25)
                  : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                    width: 32.rs,
                    height: 32.rs,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.rs),
                    ),
                    child: Icon(Icons.description_outlined,
                        size: 16.rs, color: AppColors.info),
                  ),
                  SizedBox(width: 10.rw),
                  Text(
                    'Details',
                    style: TextStyle(
                      fontFamily: FontFamily.fontName,
                      fontSize: 15.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.rh),
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.borderLight,
              ),
              SizedBox(height: 14.rh),
              Text(
                widget.banner.note!,
                style: TextStyle(
                  fontFamily: FontFamily.fontName,
                  fontSize: 13.5.rf,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom section — skip button or blocked message
  // ---------------------------------------------------------------------------

  Widget _buildBottomSection() {
    return FadeTransition(
      opacity: _buttonFade,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.rw, 12.rh, 20.rw, 12.rh),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: _isBlocked ? _buildBlockedFooter() : _buildSkipButton(),
        ),
      ),
    );
  }

  Widget _buildBlockedFooter() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final t = _pulseController.value;
        final borderColor = Color.lerp(
          AppColors.error.withValues(alpha: 0.2),
          AppColors.error.withValues(alpha: 0.5),
          t,
        )!;
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16.rh, horizontal: 20.rw),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14.rs),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block_rounded, size: 20.rs, color: AppColors.error),
              SizedBox(width: 10.rw),
              Flexible(
                child: Text(
                  'Access is temporarily restricted. Please check back later.',
                  style: TextStyle(
                    fontFamily: FontFamily.fontName,
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: widget.onContinue,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.rh),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(14.rs),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                fontFamily: FontFamily.fontName,
                fontSize: 15.rf,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.rw),
            Icon(Icons.arrow_forward_rounded, size: 20.rs, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
