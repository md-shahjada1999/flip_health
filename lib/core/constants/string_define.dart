class AppString {
  static final AppString _singleton = AppString._internal();
  factory AppString() {
    return _singleton;
  }
  AppString._internal();

  static const String kIosAppVersion = "1";

  // Existing app strings
  static const String kOnboardingScreen1Title = 'Book Diagnostics';
  static const String kOnboardingScreen1Subtitle =
      'Book lab tests/health check ups';
  static const String kOnboardingScreen2Title = 'Chronic Medication';
  static const String kOnboardingScreen2Subtitle =
      'Dedicated chronic medication';
  static const String kOnboardingScreen3Title = 'Annual Health Checkup';
  static const String kOnboardingScreen3Subtitle =
      'Book annual health checkup and stay\nupdated';

  static const String kInternetCheck =
      'Please check network connection and try again!';
  static String kAllow = "Allow";
  static String kPermission = "Permission";
  static String kLocation = "Location";
  static String kCamera = "Camera";
  static String kMicrophone = "Microphone";
  static String kSMS = "SMS";
  static String kOk = "Ok";
  static String kPhotosAndMedia = "Photos & Media";
  static String kTitle = "Allow app permissions";
  static String kDoNotAllow = "Don't Allow";
  static String kSubTitle = "Allow permission for personalised experience";
  static String kAllMandateTitle =
      "Your Data is safe. All permissions are mandatory.";

  static String kCameraPermissionSubtitle =
      "We need camera access for the app's functionality, which enables you to capture profile image";
  static String kLocationPermissionSubtitle =
      "We need your location permission to help you discover nearby animals, log or upload new animal sightings, and display them on the map based on their upload location. Rest assured, your location data is used only for these purposes and is securely processed in compliance with privacy standards.";
  static String kMicroPhonePermissionSubtitle =
      "We need microphone access for using camera functionality.";
  static String kPhotosAndMedianPermissionSubtitle =
      "We need gallery access for the app's functionality, which enables you to upload your profile picture";

  // Login Screen Strings
  static const String kLoginTitle = 'Enter Mobile/Email\nto Login/Signup';
  static const String kLoginSubtitle = 'You will receive an OTP';
  static const String kMobileNumberLabel = 'Mobile Number / Email Id';
  static const String kPhoneHint = '9999999999';
  static const String kClickToAccept = 'Click here to accept ';
  static const String kTermsAndConditions = 'terms and conditions';
  static const String kConfirm = 'Confirm';

  // OTP Screen Strings
  static const String kOTPTitle = 'Enter OTP';
  static const String kOTPSubtitle =
      'An OTP has been sent to the\nbelow mobile number';
  static const String kEdit = 'edit';
  static const String kDidntGetOTP = "Didn't get the OTP? ";
  static const String kResend = 'Resend';

  // Dashboard Strings
  static const String kHome = 'Home';
  static const String kSearchPlaceholder = 'Search for Pharmacy';
  static const String kDiagnostics = 'Diagnostics';
  static const String kConsultation = 'Consultation';
  static const String kDental = 'Dental';
  static const String kVision = 'Vision';
  static const String kPharmacy = 'pharmacy';
  static const String kViewMore = 'VIEW MORE';
  static const String kNutritionWebinar = 'Nutrition\nWebinar';
  static const String kJoin = 'Join';
  static const String kServices = 'Services';
  static const String kMyOrders = 'My Orders';
  static const String kNeedHelp = 'Need Help?';

  // Service details
  static const String kSameDaySlotBooking = 'SAME DAY SLOT BOOKING';
  static const String kHomeCollection = 'home collection';
  static const String kAtCenter = 'at center';
  static const String kUpTo30Off = 'UP TO 30% OFF';
  static const String kUpTo20OffDiagnostics = 'UP TO 20% OFF';
  static const String kInstantAppointment = 'INSTANT APPOINTMENT';
  static const String kVirtual = 'virtual   .';
  static const String kByVirtual = 'by virtual';
  static const String k10Mins = '10 MINS';
  static const String kLoremIpsum = 'LOREM IPSUM';
  static const String kUpTo20Off = 'UP TO 20% OFF';

  // Webinar Details
  static const String kWebinarDate = 'August 22nd,';
  static const String kWebinarTime = '3:00 PM — 4:00 PM.';

  // New Service Feature Strings
  static const String k10Minutes = '10 MINS';
  static const String kAtCenterService = 'at center';

  // ==============================================
  // SERVICES SCREEN STRINGS
  // ==============================================

  // Tab Names
  static const String kOPDClaims = 'OPD Claims';
  static const String kAccountManagement = 'Account Management';
  static const String kHelpSupport = 'Help & Support';
  static const String kMedicalRecords = 'Medical Records';

  // Services Tab

  static const String kTabBarServices = 'Services';

  static const String kBookDiagnostics = 'Book Diagnostics';
  static const String kBookDiagnosticsSubtitle =
      'Book lab tests/health check ups';

  static const String kBookConsultation = 'Book Consultation';
  static const String kBookConsultationSubtitle =
      'Book virtual /Inperson Consultations';

  static const String kDentalServices = 'Dental Services';
  static const String kDentalServicesSubtitle = 'Book dental services';

  static const String kPrescribedPharmacy = 'Prescribed Pharmacy';
  static const String kPrescribedPharmacySubtitle =
      'Buy prescribed / OTC medicines';

  static const String kVaccinationServices = 'Vaccination Services';
  static const String kVaccinationServicesSubtitle =
      'Book vaccination at home/center';

  static const String kVisionServices = 'Vision Servives';
  static const String kVisionServicesSubtitle = 'Book vision services';

  static const String kMentalWellness = 'Mental Wellness';
  static const String kMentalWellnessSubtitle = 'Book mental wellness sessions';

  static const String kChronicManagement = 'Chronic Management';
  static const String kChronicManagementSubtitle =
      'Chronic medication and buy chronic medicine';

  static const String kNutritionServices = 'Nutrition Services';
  static const String kNutritionServicesSubtitle =
      'Nutrition and dietician expert service';

  static const String kGymFitness = 'Gym & Fitness';
  static const String kGymFitnessSubtitle =
      'Buy Gym memberships and fitness membership';

  // OPD Claims Tab
  static const String kClaims = 'Claims';
  static const String kClaimsSubtitle = 'Raise claims, check status';

  static const String kBankDetails = 'Bank Details';
  static const String kBankDetailsSubtitle = 'Add/edit bank details';

  // Account Management Tab
  static const String kProfile = 'Profile';
  static const String kProfileSubtitle = 'Manage profile details';

  static const String kSubscriptions = 'Subscriptions';
  static const String kSubscriptionsSubtitle = 'Manage subsriptions';

  static const String kFamilyAccounts = 'Family Accounts';
  static const String kFamilyAccountsSubtitle = 'Manage family members';

  static const String kAddressBook = 'Address Book';
  static const String kAddressBookSubtitle = 'Manage address details';

  static const String kOrders = 'Orders';
  static const String kOrdersSubtitle = 'Check order status';

  static const String kSetPassword = 'Set Password';
  static const String kSetPasswordSubtitle = 'Manage your passwords';

  static const String kDeleteAccount = 'Delete Account';
  static const String kDeleteAccountSubtitle =
      'Delete your and family accounts';

  static const String kInvoices = 'Invoices';
  static const String kInvoicesSubtitle = 'Check your all invoices here';

  // Help & Support Tab
  static const String kSupport = 'Support';
  static const String kSupportSubtitle = 'For any queries or support tickets';

  static const String kFAQ = 'FAQ';
  static const String kFAQSubtitle = 'Refer FAQs here';

  static const String kTC = 'T&C';
  static const String kTCSubtitle = 'Read all the Terms & Conditions here';

  static const String kPrivacyPolicies = 'Privacy Policies';
  static const String kPrivacyPoliciesSubtitle =
      'Refer all the privacy policies here';

  // Medical Records Tab
  static const String kMyAppointments = 'My Appointments';
  static const String kMyAppointmentsSubtitle =
      'Check your appointments history/status here';

  static const String kLabReports = 'Lab Reports';
  static const String kLabReportsSubtitle = 'Check your lab test reports here';

  static const String kMyPrescriptions = 'My Prescriptions';
  static const String kMyPrescriptionsSubtitle =
      'Check your prescriptions here';

  static const String kActivities = 'Activities';
  static const String kActivitiesSubtitle = 'Check your activities';

  // ==============================================
  // ASSET PATHS
  // ==============================================

  // Dashboard Images
  static const String kDashboardMicroscope =
      "assets/png/daignosticsCardDashbaord.png";
  static const String kDashboardDoctor =
      "assets/png/consultationCardDashbaord.png";
  static const String kDashboardDental =
      "assets/png/DentalCardDashboard.png";
  static const String kDashboardGlasses =
      "assets/png/VisionCardDashboard.png";
  static const String kDashboardPharmacy =
      "assets/png/pharmacyCardDashboard.png";

  // Nutrition Banner Images (Carousel)
  static const String kNutritionBanner1 =
      "assets/png/nutritionBanner1Dashbaord.png";
  static const String kNutritionBanner2 =
      "assets/png/nutritionBanner1Dashbaord.png";
  static const String kNutritionBanner3 =
      "assets/png/nutritionBanner1Dashbaord.png";

  // Legacy banner path
  static const String kNutritionBanner =
      "assets/png/nutrition_banner.png";

  // Service option icons
  static const String kHomeIcon = "assets/svg/daignosticsHome.svg";
  static const String kCenterIcon = "assets/svg/daignosticsCenter.svg";
  static const String kClockIcon = "assets/svg/sameDaySlotBook.svg";
  static const String kVirtualIcon =
      "assets/svg/virtualCardDashbaord.svg";
  static const String kBoltIcon = "assets/svg/bolt_icon.svg";

  // Bottom Navigation Icons
  static const String kIconCalendar = "assets/svg/wallet.svg";
  static const String kIconProfile = "assets/svg/profile.svg";
  static const String kIconMicrophone = "assets/svg/mic.svg";
  static const String kIconHome = "assets/svg/bottomNavBarHomeIcon.svg";
  static const String kIconServices =
      "assets/svg/services_bottom_navbar.svg";
  static const String kIconPharmacy =
      "assets/svg/pharmacy_bottom_navbar.svg";
  static const String kIconOrders =
      "assets/svg/my_orders_bottom_navbar.svg";
  static const String kIconHelp =
      "assets/svg/need_help_bottom_navbar.svg";

  // ==============================================
  // SERVICES SCREEN ICONS (All SVG)
  // ==============================================

  // Tab Bar Icons
  static const String kIconOPDClaims =
      "assets/svg/all services icons/tab_bar_icons/opd_claims.svg";
  static const String kIconAccountManagement =
      "assets/svg/all services icons/tab_bar_icons/account_management.svg";
  static const String kIconHelpSupport =
      "assets/svg/all services icons/help_and_support/support.svg";
  static const String kIconMedicalRecords =
      "assets/svg/all services icons/tab_bar_icons/medical_records.svg";
  static const String kIconServicesTabBar =
      "assets/svg/all services icons/tab_bar_icons/services.svg";

  // Services Tab Icons
  static const String kIconDiagnostics =
      "assets/svg/all services icons/services/bookDaignostics.svg";
  static const String kIconConsultation =
      "assets/svg/all services icons/services/bookConsultations.svg";
  static const String kIconDental =
      "assets/svg/all services icons/services/dentalServices.svg";
  static const String kIconPrescribedPharmacy =
      "assets/svg/all services icons/services/prescribedPharmacy.svg";
  static const String kIconVaccination =
      "assets/svg/all services icons/services/vaccinationServices.svg";
  static const String kIconVision =
      "assets/svg/all services icons/services/visionServices.svg";
  static const String kIconMentalWellness =
      "assets/svg/all services icons/services/mentalWellness.svg";
  static const String kIconChronicManagement =
      "assets/svg/all services icons/services/chronicManagement.svg";
  static const String kIconNutrition =
      "assets/svg/all services icons/services/nutritionServices.svg";
  static const String kIconGymFitness =
      "assets/svg/all services icons/services/gymAndFitness.svg";

  // OPD Claims Tab Icons
  static const String kIconClaims =
      "assets/svg/all services icons/opd/claims.svg";
  static const String kIconBankDetails =
      "assets/svg/all services icons/opd/bank_details.svg";

  // Account Management Tab Icons
  static const String kIconProfileSerices =
      "assets/svg/all services icons/account_management/profile.svg";
  static const String kIconSubscriptions =
      "assets/svg/all services icons/account_management/subscriptions.svg";
  static const String kIconFamilyAccounts =
      "assets/svg/all services icons/account_management/family_account.svg";
  static const String kIconAddressBook =
      "assets/svg/all services icons/account_management/address_book.svg";
  static const String kIconSetPassword =
      "assets/svg/all services icons/account_management/set_password.svg";
  static const String kIconDeleteAccount =
      "assets/svg/all services icons/account_management/delete_account.svg";
  static const String kIconInvoices =
      "assets/svg/all services icons/account_management/invoices.svg";
  static const String kIconOrdersServices =
      "assets/svg/all services icons/account_management/oders.svg";

  // Help & Support Tab Icons
  static const String kIconSupport =
      "assets/svg/all services icons/help_and_support/support.svg";
  static const String kIconFAQ =
      "assets/svg/all services icons/help_and_support/faq.svg";
  static const String kIconTC =
      "assets/svg/all services icons/help_and_support/terms_and_conditions.svg";
  static const String kIconPrivacyPolicies =
      "assets/svg/all services icons/help_and_support/privacy_policy.svg";

  // Medical Records Tab Icons
  static const String kIconMyAppointments =
      "assets/svg/all services icons/medical_records/my_appointments.svg";
  static const String kIconLabReports =
      "assets/svg/all services icons/medical_records/lab_reports.svg";
  static const String kIconMyPrescriptions =
      "assets/svg/all services icons/medical_records/my_prescription.svg";
  static const String kIconActivities =
      "assets/svg/all services icons/medical_records/activities.svg";

  // Diagnostics Options
  static const String kHealthCheckups = 'Health\nCheckups';
  static const String kHealthCheckupsSubtitle = 'Avail Free Health Checkups';

  static const String kLabTests = 'Lab\nTests';
  static const String kLabTestsSubtitle = 'Fully Sponsored';

  // ==============================================
  // DIAGNOSTICS ICONS (Add to icon section)
  // ==============================================

  static const String kIconLabTests =
      "assets/svg/all services icons/health_check_up.svg";
  static const String kIconFreeHealthCheckups =
      "assets/svg/all services icons/free_health_checkup.svg";
  static const String kIconFullSponsored =
      "assets/svg/all services icons/fully_sponsored.svg";

// ==============================================
  // HEALTH CHECKUPS SCREEN STRINGS
  // ==============================================

  static const String kHealthCheckupsTitle = 'Health Checkups';

  // Section Headers
  static const String kForYou = 'For you';
  static const String kForYourFamily = 'For your family';

  // Section Subtitles
  static const String kBookFreeHealthCheckups = 'Book free health checkups';
  static const String kBookPaidHealthCheckups =
      'Book paid health checkups for family members';

  // User Card Info
  static String kSponsoredByCompany(String companyName) =>
      'Sponsored by $companyName';
  static const String kPackagesAvailable = 'Packages available';

  // Actions
  static const String kAdd = 'Add';
  static const String kContinue = 'Continue';
  static const String kAddNewFamilyMember = 'Add new family member';

  // ==============================================
  // ASSET PATHS
  // ==============================================

// ==============================================
// ADD FAMILY MEMBER SCREEN STRINGS
// ==============================================

  static const String kAddNewFamilyMemberTitle = 'Add new family member';
  static const String kRelationship = 'Relationship';
  static const String kRelationshipHint = 'Select relationship';
  static const String kName = 'Name';
  static const String kNameHint = 'Enter full name';
  static const String kDateOfBirth = 'Date of birth';
  static const String kDateOfBirthHint = 'Select date of birth';
  static const String kGender = 'Gender';
  static const String kGenderHint = 'Select gender';
  static const String kPhoneNumber = 'Phone number';
  static const String kPhoneNumberHint = 'Enter phone number';
  static const String kSaveAndContinue = 'Save and continue';

// Disclaimer text
  static const String kFamilyMemberDisclaimer =
      'Lorem ipsum is simply dummy text of the printing and typesetting Lorem ipsum is simply dummy text of the printing and typesetting';

// Validation messages
  static const String kRelationshipRequired = 'Please select a relationship';
  static const String kNameRequired = 'Please enter name';
  static const String kDateOfBirthRequired = 'Please select date of birth';
  static const String kGenderRequired = 'Please select gender';
  static const String kPhoneNumberRequired = 'Please enter phone number';
  static const String kInvalidPhoneNumber =
      'Please enter a valid 10-digit phone number';

// Relationship options
  static const List<String> kRelationships = [
    'Spouse',
    'Son',
    'Daughter',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Other'
  ];

// ==============================================
// HEALTH CHECKUP SLOT SELECTION STRINGS
// ==============================================

// Location
  static const String kDefaultAddress =
      'Isprout, 7th floor, Plot No: 25, Divyasree trinity,';

// Date and Time Section
  static const String kChooseDateAndTime = 'Choose date and time';
  static const String kSeptemberIST = 'Sept 2025 ( IST )';

// Time Slot Sections
  static const String kMorning = 'Morning';
  static const String kAfternoon = 'Afternoon';

// Time Slots
  static const String kTimeSlot7to8AM = '7 AM-8 AM';
  static const String kTimeSlot8to9AM = '8 AM-9 AM';
  static const String kTimeSlot9to10AM = '9 AM-10 AM';
  static const String kTimeSlot10to11AM = '10 AM-11 AM';
  static const String kTimeSlot11to12PM = '11 AM-12 PM';

// Note Section
  static const String kTimeSlotNote =
      'Note : Time slot is indicative of the reporting time at the center. Appointment time may vary depending on ongoing appointments and doctors availability at center';

// Points to Remember
  static const String kPointsToRemember = 'Points to remember';
  static const String kPointToRemember1 =
      'Both Pathology and Radiology tests have to be completed within a span of 7 days';

// Weekdays
  static const String kMonday = 'Mon';
  static const String kTuesday = 'Tue';
  static const String kWednesday = 'Wed';
  static const String kThursday = 'Thu';
  static const String kFriday = 'Fri';
  static const String kSaturday = 'Sat';
  static const String kSunday = 'Sun';
// Gender options
  static const List<String> kGenders = ['Male', 'Female', 'Other'];





// ==============================================
// HEALTH CHECKUP OVERVIEW SCREEN STRINGS
// ==============================================

static const String kAddedItems = 'Added Items';
static const String kBookingUpdatesMessage = 'Booking related updates will be sent on this number';
static const String kAlternatePhoneNumber = 'Alternate Phone number';
static const String kAlternatePhoneHint = 'Enter your alternate number here';
static const String kDateAndTime = 'Date and time';

// Price Breakdown
static const String kTotalMRP = 'Total MRP';
static const String kHomeCollectionCharges = 'Home Collection Charges';
static const String kFromWallet = 'From Wallet';
static String kWalletLimit(String amount) => 'Wallet Limit : ₹ $amount';
static const String kNetPay = 'Net Pay';

// Flip Coins
static const String kFlipCoinsToBeEarned = 'Flip Coins to be earned (1%):';
static String kFlipCoinsWorth(String amount) => 'Worth ₹ $amount';
static const String kFlipCoinsNote = 'Note : Flip Coins will be credited after order completion';

// Actions
static const String kConfirmAndPay = 'Confirm and pay';

// Remarks
static const String kRemarks = 'Remarks :';
static const String kOrderCancellationWarning = 'Order cannot be cancelled once confirmed';

// Package Info
static const String kEmployeeAnnualHealthCheckup = 'Employee Annual Health Checkup';
static String kForPatient(String name) => 'For $name';



// ==============================================
// PAYMENT SUCCESS SCREEN STRINGS
// ==============================================

static const String kPaymentSuccessTitle = 'Payment Successful!';
static const String kPaymentSuccessMessage = 'Your health checkup has been booked successfully';

// Booking Details
static const String kBookingId = 'Booking ID';
static const String kPatientName = 'Patient Name';
static const String kTestName = 'Test Name';
static const String kScheduledDate = 'Scheduled Date';
static const String kCollectionType = 'Collection Type';

// Flip Coins
static const String kFlipCoinsEarned = 'Flip Coins Earned';

// Actions
static const String kViewBookingDetails = 'View Booking Details';
static const String kBackToHome = 'Back to Home';

  /// Images
  static const String logo = "assets/png/logo.png";

  /// Svg
  static const String arrowBack = "assets/svg/arrow_back.svg";
  static const String OnboardingScreen1Image =
      "assets/svg/onboarding_images/splash_image_1.svg";
  static const String OnboardingScreen2Image =
      "assets/svg/onboarding_images/splash_image_2.svg";
  static const String OnboardingScreen3Image =
      "assets/svg/onboarding_images/splash_image_3.svg";
  static const String reportsOntimeIcon =
      "assets/svg/report_time_icon.svg";
  static const String kNeubergLogo = "assets/png/neuberg_lab_logo.png";
  static const String kOrangeHealthLogo =
      "assets/png/orange_health_lab_logo.png";
  static const String kShoppingBagIcon = "assets/svg/my_orders_bag.svg";
  static const String kFlipCoinIcon = "assets/svg/flip_coin.svg";
}
