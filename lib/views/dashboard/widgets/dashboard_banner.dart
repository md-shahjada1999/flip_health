import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';

class NutritionBanner extends StatefulWidget {
  final VoidCallback? onJoinPressed;

  const NutritionBanner({
    Key? key,
    this.onJoinPressed,
  }) : super(key: key);

  @override
  State<NutritionBanner> createState() => _NutritionBannerState();
}

class _NutritionBannerState extends State<NutritionBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _bannerImages = [
    AppString.kNutritionBanner1,
    AppString.kNutritionBanner2,
    AppString.kNutritionBanner3,
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll carousel
    Future.delayed(Duration(seconds: 3), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;

    Future.delayed(Duration(seconds: 3), () {
      if (!mounted || !_pageController.hasClients) return;

      int nextPage = (_currentPage + 1) % _bannerImages.length;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _autoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return ResponsiveScreen(
      child: Container(
        height: 180.rh,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.rs),
        ),
        child: Stack(
          children: [
            // Carousel
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16.rs),
                  child: Image.asset(
                    _bannerImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.rs),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4A9B8E),
                              Color(0xFF6BB6A8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.rs),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),

            // Content overlay
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(15.rs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RText(
                            AppString.kNutritionWebinar,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnPrimary,
                          ),
                          RSizedBox.vertical(8),
                          RText(
                            AppString.kWebinarDate,
                            fontSize: 14,
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          RText(
                            AppString.kWebinarTime,
                            fontSize: 14,
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    Align(alignment: AlignmentGeometry.topRight,
                      child: Container(
                        width: 80.rw,
                        height: 36.rh,
                        decoration: BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.circular(8.rs),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onJoinPressed,
                            borderRadius: BorderRadius.circular(8.rs),
                            child: Center(
                              child: RText(
                                AppString.kJoin,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Page indicators
            Positioned(
              bottom: 12.rh,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _bannerImages.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.rs),
                    width: _currentPage == index ? 20.rw : 8.rw,
                    height: 8.rh,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.rs),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
