import 'package:get/get.dart';
import 'package:flip_health/bindings/address%20bindings/add_address_binding.dart';
import 'package:flip_health/bindings/address%20bindings/address_book_binding.dart';
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
import 'package:flip_health/bindings/health_score%20bindings/health_score_binding.dart';
import 'package:flip_health/bindings/vision%20bindings/vision_binding.dart';
import 'package:flip_health/bindings/mental%20wellness%20bindings/mental_wellness_binding.dart';
import 'package:flip_health/bindings/vaccine%20bindings/vaccine_binding.dart';
import 'package:flip_health/bindings/gym%20bindings/gym_binding.dart';
import 'package:flip_health/bindings/consultation_order_detail_binding.dart';
import 'package:flip_health/bindings/pharmacy_order_detail_binding.dart';
import 'package:flip_health/bindings/gym_membership_order_detail_binding.dart';
import 'package:flip_health/bindings/wellness_order_detail_binding.dart';
import 'package:flip_health/bindings/service_request_order_detail_binding.dart';
import 'package:flip_health/bindings/orders%20bindings/orders_binding.dart';
import 'package:flip_health/bindings/razor_pay_binding.dart';
import 'package:flip_health/bindings/video_call_binding.dart';
import 'package:flip_health/bindings/dashboard%20bindings/wallet_binding.dart';
import 'package:flip_health/bindings/profile%20bindings/profile_binding.dart';
import 'package:flip_health/bindings/subscriptions/my_subscriptions_binding.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/health_score/health_score_view.dart';
import 'package:flip_health/views/address/address_form_screen.dart';
import 'package:flip_health/views/address/address_book_screen.dart';
import 'package:flip_health/views/address/map_picker_screen.dart';
import 'package:flip_health/views/auth/login/login_screen.dart';
import 'package:flip_health/views/auth/login/otp_screen.dart';
import 'package:flip_health/views/consultation/consultation_overview_screen.dart';
import 'package:flip_health/views/dashboard/dashboard_screen.dart';
import 'package:flip_health/views/dashboard/view_more_services.dart';
import 'package:flip_health/views/daignostics/health_checkup/add_family_member_page.dart';
import 'package:flip_health/views/daignostics/health_checkup/add_family_member_success_screen.dart';
import 'package:flip_health/views/daignostics/health_checkup/health_checkup_screen.dart';
import 'package:flip_health/views/daignostics/lab_test/lab_test_member_selection_screen.dart';
import 'package:flip_health/views/daignostics/lab_test/lab_test_search_screen.dart';
import 'package:flip_health/views/dental/dental_member_selection_screen.dart';
import 'package:flip_health/views/mental_wellness/mental_wellness_screen.dart';
import 'package:flip_health/views/mental_wellness/wellness_order_detail_screen.dart';
import 'package:flip_health/views/mental_wellness/wellness_request_success_screen.dart';
import 'package:flip_health/views/claims/claims_list_screen.dart';
import 'package:flip_health/views/claims/add_bank_screen.dart';
import 'package:flip_health/views/claims/bank_list_screen.dart';
import 'package:flip_health/views/pharmacy/pharmacy_main_screen.dart';
import 'package:flip_health/views/pharmacy/pharmacy_order_detail_screen.dart';
import 'package:flip_health/views/pharmacy/pharmacy_payment_success_screen.dart';
import 'package:flip_health/views/gym/gym_membership_order_detail_screen.dart';
import 'package:flip_health/views/service_request/service_request_order_detail_screen.dart';
import 'package:flip_health/views/service_request/service_request_payment_success_screen.dart';
import 'package:flip_health/views/splash/onboarding_screen.dart';
import 'package:flip_health/views/splash/splash_screen.dart';
import 'package:flip_health/views/vision/vision_member_selection_screen.dart';
import 'package:flip_health/views/vaccine/vaccine_member_selection_screen.dart';
import 'package:flip_health/views/gym/gym_membership_screen.dart';
import 'package:flip_health/views/gym/gym_membership_payment_success_screen.dart';
import 'package:flip_health/views/consultation/consultation_order_detail_screen.dart';
import 'package:flip_health/views/consultation/consultation_payment_success_screen.dart';
import 'package:flip_health/views/consultation/video_call_screen.dart';
import 'package:flip_health/views/orders/orders_screen.dart';
import 'package:flip_health/views/razor_pay/razor_pay_screen.dart';
import 'package:flip_health/views/dashboard/wallet/wallet_screen.dart';
import 'package:flip_health/views/profile/profile_screen.dart';
import 'package:flip_health/views/subscriptions/my_subscriptions_screen.dart';

class AppPages {
  static final AppPages _singleton = AppPages._internal();
  factory AppPages() => _singleton;
  AppPages._internal();

  static const String initial = AppRoutes.splash;

  static final routes = [
    // Auth flow
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
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OTPScreen(),
      binding: OTPBinding(),
    ),

    // Health Score (includes BMI)
    GetPage(
      name: AppRoutes.healthScore,
      page: () => const HealthScoreView(),
      binding: HealthScoreBinding(),
    ),

    // Dashboard
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardMainScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(name: AppRoutes.allServices, page: () => ServicesScreen()),

    // Diagnostics
    GetPage(
      name: AppRoutes.healthCheckups,
      page: () => HealthCheckupsScreen(),
      binding: HealthCheckupsBinding(),
    ),
    GetPage(
      name: AppRoutes.addFamilyMember,
      page: () => AddFamilyMemberScreen(),
      binding: AddFamilyMemberBinding(),
    ),
    GetPage(
      name: AppRoutes.addFamilyMemberSuccess,
      page: () => const AddFamilyMemberSuccessScreen(),
    ),
    GetPage(
      name: AppRoutes.mySubscriptions,
      page: () => const MySubscriptionsScreen(),
      binding: MySubscriptionsBinding(),
    ),
    GetPage(
      name: AppRoutes.labTests,
      page: () => const LabTestMemberSelectionScreen(),
      binding: LabTestBinding(),
    ),
    GetPage(
      name: AppRoutes.labTestSearch,
      page: () => const LabTestSearchScreen(),
    ),

    // Consultation
    GetPage(
      name: AppRoutes.consultation,
      page: () => const ConsultationOverviewScreen(),
      binding: ConsultationBinding(),
    ),

    // Dental
    GetPage(
      name: AppRoutes.dental,
      page: () => const DentalMemberSelectionScreen(),
      binding: DentalBinding(),
    ),

    // Vision
    GetPage(
      name: AppRoutes.vision,
      page: () => const VisionMemberSelectionScreen(),
      binding: VisionBinding(),
    ),

    // Pharmacy
    GetPage(
      name: AppRoutes.pharmacy,
      page: () => const PharmacyMainScreen(),
      binding: PharmacyBinding(),
      transition: Transition.rightToLeft,
    ),

    // Mental Wellness
    GetPage(
      name: AppRoutes.mentalWellness,
      page: () => const MentalWellnessScreen(),
      binding: MentalWellnessBinding(),
    ),
    GetPage(
      name: AppRoutes.wellnessRequestSuccess,
      page: () => const WellnessRequestSuccessScreen(),
    ),

    // Claims
    GetPage(
      name: AppRoutes.claims,
      page: () => const ClaimsListScreen(),
      binding: ClaimsBinding(),
    ),
    GetPage(
      name: AppRoutes.bankDetails,
      page: () => const BankListScreen(),
      binding: ClaimsBinding(),
    ),
    GetPage(
      name: AppRoutes.addBank,
      page: () => const AddBankScreen(),
      binding: ClaimsBinding(),
    ),

    // Vaccine
    GetPage(
      name: AppRoutes.vaccine,
      page: () => const VaccineMemberSelectionScreen(),
      binding: VaccineBinding(),
    ),

    // Gym
    GetPage(
      name: AppRoutes.gym,
      page: () => const GymMembershipScreen(),
      binding: GymBinding(),
    ),

    // Orders
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersScreen(),
      binding: OrdersBinding(),
    ),

    GetPage(
      name: AppRoutes.consultationOrderDetail,
      page: () => const ConsultationOrderDetailScreen(),
      binding: ConsultationOrderDetailBinding(),
    ),

    GetPage(
      name: AppRoutes.pharmacyOrderDetail,
      page: () => const PharmacyOrderDetailScreen(),
      binding: PharmacyOrderDetailBinding(),
    ),

    GetPage(
      name: AppRoutes.pharmacyPaymentSuccess,
      page: () => const PharmacyPaymentSuccessScreen(),
    ),

    GetPage(
      name: AppRoutes.gymMembershipOrderDetail,
      page: () => const GymMembershipOrderDetailScreen(),
      binding: GymMembershipOrderDetailBinding(),
    ),

    GetPage(
      name: AppRoutes.gymMembershipPaymentSuccess,
      page: () => const GymMembershipPaymentSuccessScreen(),
    ),

    GetPage(
      name: AppRoutes.wellnessOrderDetail,
      page: () => const WellnessOrderDetailScreen(),
      binding: WellnessOrderDetailBinding(),
    ),

    GetPage(
      name: AppRoutes.serviceRequestOrderDetail,
      page: () => const ServiceRequestOrderDetailScreen(),
      binding: ServiceRequestOrderDetailBinding(),
    ),

    GetPage(
      name: AppRoutes.serviceRequestPaymentSuccess,
      page: () => const ServiceRequestPaymentSuccessScreen(),
    ),

    GetPage(
      name: AppRoutes.consultationVideoCall,
      page: () => const ConsultationVideoCallScreen(),
      binding: VideoCallBinding(),
    ),

    GetPage(
      name: AppRoutes.razorPay,
      page: () => const RazorPayScreen(),
      binding: RazorPayBinding(),
    ),

    GetPage(
      name: AppRoutes.consultationPaymentSuccess,
      page: () => const ConsultationPaymentSuccessScreen(),
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),

    // Wallet
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletScreen(),
      binding: WalletBinding(),
    ),

    // Address
    GetPage(
      name: AppRoutes.addressBook,
      page: () => const AddressBookScreen(),
      binding: AddressBookBinding(),
    ),
    GetPage(
      name: AppRoutes.addAddress,
      page: () => const MapPickerScreen(),
      binding: AddAddressBinding(),
    ),
    GetPage(name: AppRoutes.addressForm, page: () => const AddressFormScreen()),
  ];
}
