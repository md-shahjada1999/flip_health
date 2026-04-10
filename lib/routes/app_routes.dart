class AppRoutes {
  // Authentication Routes
  static const String splash = '/splash';
   static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';

  static const String healthScore = '/health-score';

  static const String signup = '/signup';
  static const String resetPassword = '/reset-password';
  static const String forgotPasswordOtp = '/forgot-password-OTP';

  // Main App Routes
  static const String dashboard = '/dashboard';
    static const String allServices = '/all-services';
  static const String healthCheckups = '/health-checkups';
  static const String addFamilyMember = '/add-family-member';

  // Address Routes
  static const String addressBook = '/address-book';
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

  // Mental Wellness & nutrition (same flow as patient_app TRIJOG)
  static const String mentalWellness = '/mental-wellness';
  static const String wellnessRequestSuccess = '/wellness-request-success';

  // Claims Routes
  static const String claims = '/claims';
  static const String bankDetails = '/bank-details';
  static const String addBank = '/add-bank';

  // Vaccine Routes
  static const String vaccine = '/vaccine';

  // Gym Routes
  static const String gym = '/gym';

  // Orders
  static const String orders = '/orders';

  // Profile
  static const String profile = '/profile';

  // Wallet
  static const String wallet = '/wallet';

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