import 'dart:math' show pi, sin;
import 'dart:ui' show lerpDouble;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/daignostics/widgets/my_orders_button.dart';

class LabTestScreen extends StatefulWidget {
  const LabTestScreen({super.key});

  @override
  State<LabTestScreen> createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreen>
    with TickerProviderStateMixin {
  late final LabTestController controller;
  final _cartBarKey = GlobalKey();

  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LabTestController>();
    controller.fetchLabTests(reset: true);

    _bounceCtrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.07), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.07, end: 0.96), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Fly-to-cart animation
  // -------------------------------------------------------------------------

  void _flyToCart(int productId, Offset startGlobal) {
    final cartRender =
        _cartBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (cartRender == null || !cartRender.attached) {
      controller.addToCart(productId);
      return;
    }

    final cartCenter = cartRender.localToGlobal(
      Offset(46.rs, cartRender.size.height / 2),
    );

    final overlay = Overlay.of(context);
    final flyCtrl = AnimationController(
      duration: const Duration(milliseconds: 480),
      vsync: this,
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyingIcon(
        animation: flyCtrl,
        startPos: startGlobal,
        endPos: cartCenter,
      ),
    );

    overlay.insert(entry);
    controller.addToCart(productId);

    flyCtrl.forward().then((_) {
      entry.remove();
      flyCtrl.dispose();
      if (mounted) _bounceCtrl.forward(from: 0);
    });
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Lab Tests',
        showBackButton: true,
        actions: [const MyOrdersButton()],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const LocationHeaderBar(),
              _buildSearchBar(),
              Expanded(child: _buildTestList()),
            ],
          ),
          _buildBlinKitCart(),
          Obx(() => controller.isSearching.value
              ? _SearchOverlay(controller: controller)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Search bar (tap to open overlay)
  // -------------------------------------------------------------------------

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.rs, 8.rh, 16.rs, 6.rh),
      child: GestureDetector(
        onTap: controller.openSearch,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.rs, vertical: 12.rs),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  color: AppColors.textQuaternary, size: 20.rs),
              SizedBox(width: 10.rw),
              CommonText(
                'Search lab tests...',
                fontSize: 13.rf,
                color: AppColors.textQuaternary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Paginated test list
  // -------------------------------------------------------------------------

  Widget _buildTestList() {
    return Obx(() {
      if (controller.isLoading.value && controller.labTests.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.labTests.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.science_outlined,
                  size: 48.rs, color: AppColors.textQuaternary),
              SizedBox(height: 12.rh),
              CommonText('No tests available',
                  fontSize: 14.rf, color: AppColors.textSecondary),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.only(top: 4.rh, bottom: 100.rh),
        itemCount:
            controller.labTests.length + (controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.labTests.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.rh),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            );
          }
          return _LabTestTile(
            test: controller.labTests[index],
            controller: controller,
            onAdd: _flyToCart,
          );
        },
      );
    });
  }

  // -------------------------------------------------------------------------
  // Blinkit-style floating cart bar
  // -------------------------------------------------------------------------

  Widget _buildBlinKitCart() {
    return Obx(() {
      final count = controller.cartItemCount;
      final items = controller.cart.value?.items ?? [];

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        left: 80.rs,
        right: 80.rs,
        bottom:
            count > 0 ? MediaQuery.of(context).padding.bottom + 12.rh : -90.rh,
        child: ScaleTransition(
          scale: _bounceAnim,
          child: GestureDetector(
            key: _cartBarKey,
            onTap: controller.goToCart,
            child: Container(
              height: 58.rh,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(16.rs),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.rw),
                  _buildStackedIcons(items),
                  SizedBox(width: 14.rw),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'View cart',
                          fontSize: 14.rf,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        CommonText(
                          '$count item${count != 1 ? 's' : ''}',
                          fontSize: 11.rf,
                          fontWeight: FontWeight.w400,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32.rs,
                    height: 32.rs,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        size: 14.rs, color: Colors.white),
                  ),
                  SizedBox(width: 14.rw),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStackedIcons(List<LabCartItem> items) {
    final show = items.take(3).toList();
    final count = show.length.clamp(1, 3);
    final iconSize = 34.rs;
    final overlap = 14.rs;
    final totalWidth = iconSize + (count - 1) * overlap;

    if (items.isEmpty) {
      return Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.shopping_cart_rounded,
            size: 16.rs, color: Colors.white),
      );
    }

    return SizedBox(
      width: totalWidth,
      height: iconSize,
      child: Stack(
        children: List.generate(count, (i) {
          return Positioned(
            left: i * overlap,
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color(0xFF1B1B1B), width: 2.5),
              ),
              child: Center(
                child: Icon(
                  Icons.science_rounded,
                  size: 15.rs,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ===========================================================================
// Flying icon (overlay animation)
// ===========================================================================

class _FlyingIcon extends AnimatedWidget {
  final Offset startPos;
  final Offset endPos;

  const _FlyingIcon({
    required Animation<double> animation,
    required this.startPos,
    required this.endPos,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;

    final x = lerpDouble(startPos.dx, endPos.dx, t)!;
    final baseY = lerpDouble(startPos.dy, endPos.dy, t)!;
    final dist = (endPos.dy - startPos.dy).abs();
    final arcHeight = dist * 0.25;
    final y = baseY - arcHeight * sin(pi * t);

    final scale = 1.0 - 0.55 * t;
    final opacity = (1.0 - 0.4 * t).clamp(0.0, 1.0);

    return Positioned(
      left: x - 16.rs,
      top: y - 16.rs,
      child: IgnorePointer(
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 32.rs,
              height: 32.rs,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(Icons.science_rounded,
                  size: 14.rs, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Search overlay
// ===========================================================================

class _SearchOverlay extends StatelessWidget {
  final LabTestController controller;
  const _SearchOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 150),
      child: Material(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.rs, vertical: 8.rh),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: controller.closeSearch,
                      child: Padding(
                        padding: EdgeInsets.all(4.rs),
                        child: Icon(Icons.arrow_back_rounded,
                            size: 22.rs, color: AppColors.textPrimary),
                      ),
                    ),
                    SizedBox(width: 8.rw),
                    Expanded(
                      child: Container(
                        height: 42.rh,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.rs),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: TextField(
                          controller: controller.searchTextController,
                          onChanged: controller.onSearchChanged,
                          autofocus: true,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.rf,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search lab tests...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.rf,
                              color: AppColors.textQuaternary,
                            ),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: AppColors.textQuaternary, size: 20.rs),
                            suffixIcon: Obx(() =>
                                controller.searchQuery.value.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          controller.searchTextController
                                              .clear();
                                          controller.onSearchChanged('');
                                        },
                                        child: Icon(Icons.close_rounded,
                                            size: 18.rs,
                                            color: AppColors.textSecondary),
                                      )
                                    : const SizedBox.shrink()),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12.rs),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isSearchLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }

                  if (controller.searchQuery.value.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded,
                              size: 40.rs,
                              color: AppColors.textQuaternary),
                          SizedBox(height: 12.rh),
                          CommonText(
                            'Search for tests, packages...',
                            fontSize: 13.rf,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 40.rs,
                              color: AppColors.textQuaternary),
                          SizedBox(height: 12.rh),
                          CommonText(
                            'No results for "${controller.searchQuery.value}"',
                            fontSize: 13.rf,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: 100.rh),
                    itemCount: controller.searchResults.length,
                    itemBuilder: (_, index) {
                      return FadeInUp(
                        duration: const Duration(milliseconds: 120),
                        delay:
                            Duration(milliseconds: 30 * (index % 10)),
                        child: _LabTestTile(
                          test: controller.searchResults[index],
                          controller: controller,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Test tile
// ===========================================================================

class _LabTestTile extends StatelessWidget {
  final LabTest test;
  final LabTestController controller;
  final void Function(int testId, Offset globalPosition)? onAdd;

  const _LabTestTile({
    required this.test,
    required this.controller,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final inCart = controller.isInCart(test.id);

      return GestureDetector(
        onTapUp: (details) {
          if (inCart) {
            controller.toggleCart(test.id);
          } else if (onAdd != null) {
            onAdd!(test.id, details.globalPosition);
          } else {
            controller.toggleCart(test.id);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.rs, vertical: 12.rs),
          decoration: const BoxDecoration(
            border: Border(
                bottom:
                    BorderSide(color: AppColors.borderLight, width: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36.rs,
                height: 36.rs,
                decoration: BoxDecoration(
                  color: inCart
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(8.rs),
                ),
                child: Icon(
                  test.category == 'radiology'
                      ? Icons.medical_services_outlined
                      : Icons.science_outlined,
                  size: 18.rs,
                  color: inCart ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(
                      test.name,
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      height: 1.3,
                    ),
                    SizedBox(height: 3.rh),
                    Wrap(
                      spacing: 6.rw,
                      runSpacing: 2.rh,
                      children: [
                        _metaChip(test.fastingLabel),
                        if (test.tatLabel.isNotEmpty)
                          _metaChip(test.tatLabel),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.rw),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 22.rs,
                height: 22.rs,
                decoration: BoxDecoration(
                  color: inCart ? Colors.black : Colors.transparent,
                  border: Border.all(
                    color: inCart ? Colors.black : AppColors.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4.rs),
                ),
                child: inCart
                    ? Icon(Icons.check_rounded,
                        size: 14.rs, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _metaChip(String text) {
    return CommonText(
      text,
      fontSize: 10.5.rf,
      color: AppColors.textTertiary,
      height: 1.4,
    );
  }
}
