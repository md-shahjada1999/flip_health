import 'package:get/get.dart';
import 'package:flip_health/bindings/address%20bindings/add_address_binding.dart';
import 'package:flip_health/bindings/auth%20bindings/auth_binding.dart';
import 'package:flip_health/bindings/consultation%20bindings/consultation_binding.dart';
import 'package:flip_health/bindings/dashboard%20bindings/dashboard_binding.dart';
import 'package:flip_health/bindings/dental%20bindings/dental_binding.dart';
import 'package:flip_health/bindings/health%20checkup%20bindings/add_family_member_binding.dart';
import 'package:flip_health/bindings/health%20checkup%20bindings/health_checkup_binding.dart';
import 'package:flip_health/bindings/health%20checkup%20bindings/lab_test_binding.dart';
import 'package:flip_health/bindings/claims%20bindings/claims_binding.dart';
import 'package:flip_health/bindings/pharmacy%20bindings/pharmacy_binding.dart';
import 'package:flip_health/bindings/splash%20binding/on_boarding_binding.dart';
import 'package:flip_health/bindings/splash%20binding/splash_binding.dart';
import 'package:flip_health/bindings/vision%20bindings/vision_binding.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/address/address_form_screen.dart';
import 'package:flip_health/views/address/map_picker_screen.dart';
import 'package:flip_health/views/auth/login/login_screen.dart';
import 'package:flip_health/views/auth/login/otp_screen.dart';
import 'package:flip_health/views/consultation/consultation_member_selection_screen.dart';
import 'package:flip_health/views/dashboard/dashboard_screen.dart';
import 'package:flip_health/views/dashboard/view_more_services.dart';
import 'package:flip_health/views/daignostics/health_checkup/add_family_member_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_checkup_screen.dart';
import 'package:flip_health/views/daignostics/lab_test/lab_test_member_selection_screen.dart';
import 'package:flip_health/views/daignostics/lab_test/lab_test_search_screen.dart';
import 'package:flip_health/views/dental/dental_member_selection_screen.dart';
import 'package:flip_health/views/claims/claims_list_screen.dart';
import 'package:flip_health/views/pharmacy/pharmacy_main_screen.dart';
import 'package:flip_health/views/splash/onboarding_screen.dart';
import 'package:flip_health/views/splash/splash_screen.dart';
import 'package:flip_health/views/vision/vision_member_selection_screen.dart';

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

    // Lab test pages
    GetPage(
      name: AppRoutes.labTests,
      page: () => const LabTestMemberSelectionScreen(),
      binding: LabTestBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.labTestSearch,
      page: () => const LabTestSearchScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Consultation pages
    GetPage(
      name: AppRoutes.consultation,
      page: () => const ConsultationMemberSelectionScreen(),
      binding: ConsultationBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Dental pages
    GetPage(
      name: AppRoutes.dental,
      page: () => const DentalMemberSelectionScreen(),
      binding: DentalBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Vision pages
    GetPage(
      name: AppRoutes.vision,
      page: () => const VisionMemberSelectionScreen(),
      binding: VisionBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Pharmacy pages
    GetPage(
      name: AppRoutes.pharmacy,
      page: () => const PharmacyMainScreen(),
      binding: PharmacyBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Claims pages
    GetPage(
      name: AppRoutes.claims,
      page: () => const ClaimsListScreen(),
      binding: ClaimsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Address pages
    GetPage(
      name: AppRoutes.addAddress,
      page: () => const MapPickerScreen(),
      binding: AddAddressBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.addressForm,
      page: () => const AddressFormScreen(),
      transition: Transition.rightToLeft,
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
