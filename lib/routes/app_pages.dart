import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flip_health/bindings/auth%20bindings/auth_binding.dart';
import 'package:flip_health/bindings/dashboard%20bindings/dashboard_binding.dart';
import 'package:flip_health/bindings/health%20checkup%20bindings/add_family_member_binding.dart';
import 'package:flip_health/bindings/health%20checkup%20bindings/health_checkup_binding.dart';
import 'package:flip_health/bindings/splash%20binding/on_boarding_binding.dart';
import 'package:flip_health/bindings/splash%20binding/splash_binding.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/auth/login/login_screen.dart';
import 'package:flip_health/views/auth/login/otp_screen.dart';
import 'package:flip_health/views/dashboard/dashboard_screen.dart';
import 'package:flip_health/views/dashboard/view_more_services.dart';
import 'package:flip_health/views/health%20checkup/add_family_member_page.dart';
import 'package:flip_health/views/health%20checkup/health_checkup_screen.dart';
import 'package:flip_health/views/splash/onboarding_screen.dart';
import 'package:flip_health/views/splash/splash_screen.dart';

class AppPages {
//singelton class for single instance
  static final AppPages _singleton = AppPages._internal();
  factory AppPages() {
    return _singleton;
  }
  AppPages._internal();
///////////////////

  static const String initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OTPScreen(),
      binding: OTPBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    //dashboards pages
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardMainScreen(),
      binding: DashboardBinding(),
      transition: Transition.leftToRight,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    //all services page
    GetPage(
      name: AppRoutes.allServices,
      page: () => ServicesScreen(),
      // binding: OTPBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    //health checkup pages
    GetPage(
      name: AppRoutes.healthCheckups,
      page: () => HealthCheckupsScreen(),
      binding: HealthCheckupsBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
      GetPage(
      name: AppRoutes.addFamilyMember,
      page: () => AddFamilyMemberScreen(),
      binding: AddFamilyMemberBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  //   // Main App Routes

  //   GetPage(
  //     name: AppRoutes.profile,
  //     page: () => ProfileScreen(),
  //     transition: Transition.rightToLeft,
  //     transitionDuration: Duration(milliseconds: 300),
  //   ),

  //   GetPage(
  //     name: AppRoutes.settings,
  //     page: () => SettingsScreen(),
  //     transition: Transition.rightToLeft,
  //     transitionDuration: Duration(milliseconds: 300),
  //   ),

  //   // Error Routes
  //   GetPage(
  //     name: AppRoutes.notFound,
  //     page: () => NotFoundScreen(),
  //     transition: Transition.fadeIn,
  //   ),

  //   GetPage(
  //     name: AppRoutes.error,
  //     page: () => ErrorScreen(),
  //     transition: Transition.fadeIn,
  //   ),

  // // Unknown Route Handler
  // static Route<dynamic> onUnknownRoute(RouteSettings settings) {
  //   return GetPageRoute(
  //     settings: settings,
  //     page: () => NotFoundScreen(),
  //     transition: Transition.fadeIn,
  //   );
  // }
}
