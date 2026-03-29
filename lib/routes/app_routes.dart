class AppRoutes {
  // Authentication Routes
  static const String splash = '/splash';
   static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';

  static const String signup = '/signup';
  static const String resetPassword = '/reset-password';
  static const String forgotPasswordOtp = '/forgot-password-OTP';

  // Main App Routes
  static const String dashboard = '/dashboard';
    static const String allServices = '/all-services';
  static const String healthCheckups = '/health-checkups';
  static const String addFamilyMember = '/add-family-member';

  // Address Routes
  static const String addAddress = '/add-address';
  static const String addressForm = '/address-form';

  // Lab Test Routes
  static const String labTests = '/lab-tests';
  static const String labTestSearch = '/lab-test-search';

  // Consultation Routes
  static const String consultation = '/consultation';

  // Dental Routes
  static const String dental = '/dental';

  // Vision Routes
  static const String vision = '/vision';

  // Pharmacy Routes
  static const String pharmacy = '/pharmacy';

  // Claims Routes
  static const String claims = '/claims';

  // Error Routes
  static const String notFound = '/404';
  static const String error = '/error';

  // Get all routes as a list for easy reference
  static List<String> get allRoutes => [
    splash,
    login,
    signup,
    resetPassword,
    dashboard,

    notFound,
    error,

  ];
}