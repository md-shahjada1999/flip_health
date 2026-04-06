import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';

/// A reusable scaffold wrapper that ensures content never overflows into the
/// status bar or the device navigation area (home indicator / software buttons).
///
/// **Usage guidelines:**
///
/// * **Scrollable body, no bottom bar** — use the defaults:
///   ```dart
///   SafeScreenWrapper(
///     appBar: CommonAppBar.build(title: 'Dental'),
///     body: SingleChildScrollView(child: ...),
///   )
///   ```
///
/// * **Body with a pinned bottom button** — set [bottomSafe] to `false` and
///   wrap the button with [SafeBottomPadding]:
///   ```dart
///   SafeScreenWrapper(
///     bottomSafe: false,
///     body: Column(
///       children: [
///         Expanded(child: scrollableContent),
///         SafeBottomPadding(child: ActionButton(...)),
///       ],
///     ),
///   )
///   ```
///
/// * **Screen with bottomNavigationBar** — set [bottomSafe] to `false`
///   because [Scaffold] already insets the nav bar:
///   ```dart
///   SafeScreenWrapper(
///     bottomSafe: false,
///     bottomNavigationBar: BottomNavigationBar(...),
///     body: ...,
///   )
///   ```
class SafeScreenWrapper extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  /// Whether to add bottom safe-area padding to the [body].
  ///
  /// Set to `false` when you have a [bottomNavigationBar] or you are manually
  /// handling bottom insets (e.g. via [SafeBottomPadding]).
  final bool bottomSafe;

  const SafeScreenWrapper({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.bottomSafe = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        bottom: bottomSafe,
        child: body,
      ),
    );
  }
}

/// Adds device-aware bottom padding so that pinned bottom widgets (action
/// buttons, toolbars) don't overlap the home indicator or software nav buttons.
///
/// Uses [MediaQuery.viewPadding] which stays constant even when the keyboard
/// is visible, unlike [MediaQuery.padding].
class SafeBottomPadding extends StatelessWidget {
  final Widget child;

  /// Extra padding added on top of the system inset.
  final double extraBottom;

  const SafeBottomPadding({
    super.key,
    required this.child,
    this.extraBottom = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + extraBottom),
      child: child,
    );
  }
}
