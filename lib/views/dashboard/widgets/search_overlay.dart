import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/controllers/search%20controllers/search_controller.dart';

class SearchOverlay extends StatelessWidget {
  final AppSearchController controller;
  const SearchOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final focused = controller.isSearchFocused.value;
      final q = controller.query.value;
      if (!focused) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.rw),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(maxHeight: 350.rh),
            margin: EdgeInsets.only(top: 6.rh),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.rs),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: q.isEmpty
                ? _RecentsSection(controller: controller)
                : _ResultsSection(controller: controller),
          ),
        ),
      );
    });
  }
}

class _RecentsSection extends StatelessWidget {
  final AppSearchController controller;
  const _RecentsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recents = controller.recentSearches;
      if (recents.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 20.rh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_rounded, size: 32.rs, color: AppColors.iconDisabled),
              SizedBox(height: 8.rh),
              CommonText(
                'Search for services, medicines, tests...',
                fontSize: 12.rf,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 16.rw,
              right: 16.rw,
              top: 14.rh,
              bottom: 6.rh,
            ),
            child: Row(
              children: [
                CommonText(
                  'Recent Searches',
                  fontSize: 12.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => controller.clearAllRecents(),
                  child: CommonText(
                    'Clear all',
                    fontSize: 11.rf,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 8.rh),
              itemCount: recents.length,
              itemBuilder: (_, i) {
                final recent = recents[i];
                return _RecentTile(
                  text: recent,
                  onTap: () => controller.onRecentTapped(recent),
                  onRemove: () => controller.removeRecent(recent),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _RecentTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentTile({
    required this.text,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
        child: Row(
          children: [
            Icon(Icons.history_rounded, size: 18.rs, color: AppColors.textSecondary),
            SizedBox(width: 12.rw),
            Expanded(
              child: CommonText(
                text,
                fontSize: 13.rf,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 16.rs, color: AppColors.iconTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  final AppSearchController controller;
  const _ResultsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final res = controller.results;
      if (res.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 24.rh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 32.rs, color: AppColors.iconDisabled),
              SizedBox(height: 8.rh),
              CommonText(
                'No results found',
                fontSize: 13.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 2.rh),
              CommonText(
                'Try different keywords',
                fontSize: 11.rf,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        );
      }

      String? lastCategory;
      return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 8.rh),
        itemCount: res.length,
        itemBuilder: (_, i) {
          final r = res[i];
          final showCategory = r.action.category != lastCategory;
          lastCategory = r.action.category;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCategory)
                Padding(
                  padding: EdgeInsets.only(
                    left: 16.rw,
                    right: 16.rw,
                    top: i == 0 ? 4.rh : 10.rh,
                    bottom: 4.rh,
                  ),
                  child: CommonText(
                    r.action.category.toUpperCase(),
                    fontSize: 10.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              _ResultTile(
                result: r,
                onTap: () => controller.onResultTapped(r),
              ),
            ],
          );
        },
      );
    });
  }
}

class _ResultTile extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const _ResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final action = result.action;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
        child: Row(
          children: [
            Container(
              width: 36.rs,
              height: 36.rs,
              padding: EdgeInsets.all(8.rs),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10.rs),
              ),
              child: SvgPicture.asset(
                action.iconPath,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 12.rw),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    action.title,
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.rh),
                  CommonText(
                    action.subtitle,
                    fontSize: 11.rf,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.north_west_rounded,
              size: 14.rs,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
