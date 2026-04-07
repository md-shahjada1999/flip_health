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
  static const String kLogin = 'Login';

  // Email Login Strings
  static const String kEmailLoginTitle = 'Enter Email\nto Login';
  static const String kEmailLoginSubtitle =
      'Login with your email and password';
  static const String kEmailLabel = 'Email Address';
  static const String kEmailHint = 'you@example.com';
  static const String kPasswordLabel = 'Password';
  static const String kPasswordHint = 'Enter your password';
  static const String kOrLoginWith = 'Or login with ';
  static const String kEmail = 'Email';
  static const String kLoginWithPhone = 'Login with ';
  static const String kMobile = 'Mobile';

  // BMI Strings
  static const String kBmiCalculator = 'BMI Calculator';
  static const String kCalculateBmi = 'Calculate BMI';
  static const String kYourBmiResult = 'Your BMI Result';

  // OTP Screen Strings
  static const String kOTPTitle = 'Enter OTP';
  static const String kOTPSubtitle =
      'An OTP has been sent to the\nbelow mobile number';
  static const String kEdit = 'edit';
  static const String kDidntGetOTP = "Didn't get the OTP? ";
  static const String kResend = 'Resend';

  // Dashboard Strings
  static const String kHome = 'Home';
  static const String kSearchPlaceholder =
      'Search services, medicines, tests...';
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

  static const String kGymFitness = 'Gym Membership';
  static const String kGymFitnessSubtitle = 'Buy Gym memberships';
  // OPD Claims Tab
  static const String kClaims = 'Claims';
  static const String kClaimsSubtitle = 'Raise claims, check status';

  static const String kBankDetails = 'Bank Details';
  static const String kBankDetailsSubtitle = 'Add/edit bank details';

  static const String kOPDWallet = 'OPD Wallet';
  static const String kOPDWalletSubtitle = 'View balance & transactions';

  // Wallet Screen
  static const String kAvailableBalance = 'Available Balance';
  static const String kTotalBalance = 'Total Balance';
  static const String kValidTill = 'Valid Till';
  static const String kModuleBreakup = 'Module Breakup';
  static const String kRecentTransactions = 'Recent Transactions';
  static const String kViewAll = 'View All';
  static const String kNoTransactionsYet = 'No transactions yet';
  static const String kAllTransactions = 'All Transactions';
  static const String kFilterTransactions = 'Filter Transactions';
  static const String kFilters = 'Filters:';
  static const String kClearAll = 'Clear All';
  static const String kApply = 'Apply';
  static const String kNoTransactionsFound = 'No transactions found';
  static const String kTryAdjustingFilters = 'Try adjusting your filters';
  static const String kStatusLabel = 'Status';
  static const String kSuccess = 'Success';
  static const String kRefunded = 'Refunded';

  // Account Management Tab
  static const String kProfile = 'Profile';
  static const String kProfileSubtitle = 'Manage profile details';

  static const String kSubscriptions = 'Subscriptions';
  static const String kSubscriptionsSubtitle = 'Manage subsriptions';

  static const String kFamilyAccounts = 'Family Accounts';
  static const String kFamilyAccountsSubtitle = 'Manage family members';
  static const String kSelectFamilyMember = 'Select family member';
  static const String kOrderingFor = 'Ordering for';

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
  static const String kDashboardDental = "assets/png/DentalCardDashboard.png";
  static const String kDashboardGlasses = "assets/png/VisionCardDashboard.png";
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
  static const String kNutritionBanner = "assets/png/nutrition_banner.png";

  // Service option icons
  static const String kHomeIcon = "assets/svg/daignosticsHome.svg";
  static const String kCenterIcon = "assets/svg/daignosticsCenter.svg";
  static const String kClockIcon = "assets/svg/sameDaySlotBook.svg";
  static const String kVirtualIcon = "assets/svg/virtualCardDashbaord.svg";
  static const String kBoltIcon = "assets/svg/bolt_icon.svg";

  // Bottom Navigation Icons
  static const String kIconCalendar = "assets/svg/wallet.svg";
  static const String kIconProfile = "assets/svg/profile.svg";
  static const String kIconMicrophone = "assets/svg/mic.svg";
  static const String kIconHome = "assets/svg/bottomNavBarHomeIcon.svg";
  static const String kIconServices = "assets/svg/services_bottom_navbar.svg";
  static const String kIconPharmacy = "assets/svg/pharmacy_bottom_navbar.svg";
  static const String kIconOrders = "assets/svg/my_orders_bottom_navbar.svg";
  static const String kIconHelp = "assets/svg/need_help_bottom_navbar.svg";

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
      "assets/svg/all services icons/medical_records.svg";
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
  static const String kIconUser = "assets/svg/profile.svg";

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
  static const String kAdded = 'Added';
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
    'Other',
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
  static const String kBookingUpdatesMessage =
      'Booking related updates will be sent on this number';
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
  static const String kFlipCoinsNote =
      'Note : Flip Coins will be credited after order completion';

  // Actions
  static const String kConfirmAndPay = 'Confirm and pay';

  // Remarks
  static const String kRemarks = 'Remarks :';
  static const String kOrderCancellationWarning =
      'Order cannot be cancelled once confirmed';

  // Package Info
  static const String kEmployeeAnnualHealthCheckup =
      'Employee Annual Health Checkup';
  static String kForPatient(String name) => 'For $name';

  // ==============================================
  // PAYMENT SUCCESS SCREEN STRINGS
  // ==============================================

  static const String kPaymentSuccessTitle = 'Payment Successful!';
  static const String kPaymentSuccessMessage =
      'Your health checkup has been booked successfully';

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
  static const String kAlright = 'Alright';

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
  static const String reportsOntimeIcon = "assets/svg/report_time_icon.svg";
  static const String kNeubergLogo = "assets/png/neuberg_lab_logo.png";
  static const String kOrangeHealthLogo =
      "assets/png/orange_health_lab_logo.png";
  static const String kShoppingBagIcon = "assets/svg/my_orders_bag.svg";
  static const String kFlipCoinIcon = "assets/svg/flip_coin.svg";

  // Lab Tests
  static const String kLabTestsTitle = 'Lab Tests';
  static const String kSearchAndBookLabTests = 'Search and book lab tests';
  static const String kPopularLabTests = 'Popular Lab Tests';
  static const String kBestInClassServiceRating =
      'Best in class service rating';
  static const String kTopLabsTrustedCare = 'Top Labs, Trusted Care';
  static const String kAvgUserRating = '4.5 Avg. user rating';
  static const String kReportsWithin48Hours = 'Reports within 48 hours';
  static const String kInstantConfirmation = 'Instant confirmation';
  static const String kFromComfortOfHome = 'From the comfort of your home';
  static const String kSeeWhatsIncluded = "See what's included";
  static const String kAddToCart = 'Add to cart';
  static const String kTopSearches = 'Top Searches';
  static const String kSearchResults = 'Search Results';
  static const String kViewCart = 'View cart';
  static const String kCartOverview = 'Cart Overview';
  static const String kOrderInfo = 'Order info';
  static const String kHomeCollectionTab = 'Home Collection';
  static const String kAtCenterTab = 'At Center';
  static const String kRadiologyTab = 'Radiology';
  static const String kToPayLabel = 'To Pay';
  static const String kHomeCollectionChargesLabel = 'Home Collection Charges';

  // Consultation
  static const String kAtHospitalConsultation = 'At Hospital Consultation';
  static const String kVirtualConsultation = 'Virtual Consultation';
  static const String kConsultTopDoctors = 'Consult Top Doctors';
  static const String kSearchSpecialities = 'Search Specialities';
  static const String kCommonSpecialities = 'Common Specialities';
  static const String kFeaturedHospitals = 'Featured Hospitals';
  static const String kSeeAll = 'See All';
  static const String kSortList = 'Sort List';
  static const String kRelevance = 'Relevance';
  static const String kDistance = 'Distance';
  static const String kExperience = 'Experience';
  static const String kConsultationFeeLowHigh =
      'Consultation Fees(Low to High)';
  static const String kConsultationFeeHighLow =
      'Consultation Fees(High to Low)';
  static const String kCashlessAvailable = 'Cashless Available';
  static const String kYourConsultationFee = 'Your Consultation Fee';
  static const String kBookAppointment = 'Book Appointment';
  static const String kDoctorsFee = "Doctor's Fee";
  static const String kTotalAmount = 'Total Amount';
  static const String kPatient = 'Patient';
  static const String kDisclaimer = 'Disclaimer';
  static const String kDisclaimerFees =
      'The Fees and Timings are tentative and may subject to change at the time of consultation';
  static const String kDisclaimerRegistration =
      'Registration fee charged by Clinic or Hospital are not covered under OPD Insurance and has to be borne by the insured';
  static const String kAppointmentNote =
      'Flip Health will call and try to schedule an appointment with the doctor on the selected date and time slot.';

  // Dental Module
  static const String kDentalService = 'Dental Service';
  static const String kBookFreeDentalServices =
      'Book free dental services for you';
  static const String kBookDentalForFamily =
      'Book dental services for your family members';
  static const String kDentalComprehensiveCheckup =
      'Dental Comprehensive Checkup';
  static const String kDentalOverview = 'Dental Overview';
  static const String kSelectDentalSlots = 'Select Your Dental Slots';
  static const String kBookingUpdatesNote =
      'Booking related updates will be sent on this number';
  static const String kEnterAlternateNumber =
      'Enter your alternate number here';
  static const String kRemarksLabel = 'Remarks :';
  static const String kOrderCannotBeCancelled =
      'Order cannot be cancelled once confirmed';

  // Diagnostics Bottom Sheet
  static const String kHealthCheckupsOption = 'Health Checkups';
  static const String kHealthCheckupsOptionDesc =
      'Avail free health\ncheckups at center';
  static const String kLabTestsOption = 'Lab Tests';
  static const String kLabTestsOptionDesc =
      'Book lab tests with\nhome collection';

  // Dental Bottom Sheet
  static const String kAtHospitalDental = 'At Hospital';
  static const String kAtHospitalDentalDesc = 'Visit a dentist\nat the clinic';
  static const String kVirtualDental = 'Virtual Consult';
  static const String kVirtualDentalDesc =
      'Consult a dentist\nonline from home';

  // Pharmacy Bottom Sheet
  static const String kPrescribedPharmacyOption = 'Prescribed';
  static const String kPrescribedPharmacyDesc =
      'Upload prescription\n& order medicines';
  static const String kOTCProducts = 'OTC Products';
  static const String kOTCProductsDesc =
      'Order over-the-counter\nproducts directly';

  // Service Type Sheet
  static const String kSelectServiceType = 'Select Service Type';
  static const String kAtHospitalDesc = 'Visit a doctor\nat the hospital';
  static const String kVirtualDesc = 'Consult a doctor\nonline from home';
  static const String kEyeCheckupDesc = 'Comprehensive eye\nexamination';
  static const String kGlassesLensDesc = 'Browse glasses &\ncontact lenses';

  // Vision Module
  static const String kVisionService = 'Vision Service';
  static const String kEyeCheckup = 'Eye Checkup';
  static const String kGlassesLens = 'Glasses/Lens';
  static const String kBookVisionServices = 'Book vision services for you';
  static const String kBookVisionForFamily =
      'Book vision services for your family members';
  static const String kSelectVisionSlots = 'Select Your Vision Slots';
  static const String kVisionOverview = 'Vision Overview';
  static const String kUploadPrescription = 'Upload Prescription';
  static const String kPrescriptionSafe = 'Your prescription is safe with us';
  static const String kUploadFromGallery = 'Upload from Gallery';
  static const String kTakePhoto = 'Take Photo';
  static const String kUploadedPrescriptions = 'Uploaded Prescriptions';
  static const String kNoPrescriptionsYet = 'No prescriptions uploaded yet';
  static const String kVisionComprehensiveCheckup =
      'Vision Comprehensive Checkup';

  // Pharmacy Module
  static const String kPharmacyService = 'Pharmacy';
  static const String kFlipHealthDelivery = 'Flip Health Delivery';
  static const String kSecureHomeDelivery = 'Secure home delivery';
  static const String kDeliveryInHours = 'Delivery in 24 hours';
  static const String kContactlessDelivery = 'Contactless delivery';
  static const String kMedicineDeliveryNote =
      'Medicines will be delivered within 24-48 hours of placing order';
  static const String kUploadPrescriptionTitle = 'Upload Prescription';
  static const String kPrescriptionIsSafe = 'Your prescription is safe with us';
  static const String kUploadImage = 'Image or File';
  static const String kFlipHealthPrescription = 'Fliphealth\nPrescription';
  static const String kRequestOTCProducts = 'Request OTC Products';
  static const String kFAQOrderAll =
      'Do I need to order all the medicine in the prescription?';
  static const String kFAQOrderAllAnswer =
      'No, you don\'t need to order all medicines. Our medicine partner will contact you to confirm the required medicines.';
  static const String kFAQChangeQty = 'Can I change the quantity of medicines?';
  static const String kFAQChangeQtyAnswer =
      'Yes, our medicine partner will contact you to confirm the medicines and quantities before delivery.';
  static const String kFAQPrice = 'How do I know the price of medicines?';
  static const String kFAQPriceAnswer =
      'Once the order is confirmed, our medicine partner will share the price details with you before delivery.';
  static const String kOrderGenerated = 'Order Generated\nSuccessfully';
  static const String kDone = 'Done';
  static const String kUpload = 'Upload';
  static const String kSelect = 'Select';
  static const String kSelectPrescription = 'Select Prescription';
  static const String kSelectedFiles = 'Selected Files';
  static const String kNoFilesSelected = 'No files selected';
  static const String kPlaceOrder = 'Place Order';
  static const String kAddPrescription = 'Add Prescription';
  static const String kUploading = 'Uploading...';
  static const String kUploadComplete = 'Upload complete';
  static const String kUploadFailed = 'Upload failed';
  static const String kPrescriptionDetail = 'Prescription Detail';
  static const String kMedicines = 'Medicines';
  static const String kDosageSchedule = 'Dosage Schedule';
  static const String kDays = 'Days';
  static const String kWeekly = 'Weekly';
  static const String kSelectAndOrder = 'Select & Place Order';
  static const String kPlacingOrder = 'Placing order...';
  static const String kNight = 'Night';
  static const String kDoctor = 'Doctor';
  static const String kSymptoms = 'Symptoms';
  static const String kDiagnosis = 'Diagnosis';
  static const String kRecommendation = 'Recommendation';
  static const String kNotes = 'Notes';
  static const String kChronic = 'Chronic';
  static const String kOther = 'Other';
  static const String kNoPrescriptionsAvailable = 'No prescriptions available';
  static const String kLoadingPrescriptions = 'Loading prescriptions...';
  static const String kPrescriptionBy = 'Prescription by';
  static const String kMedicineCount = 'medicines';
  static const String kTablet = 'Tablet';
  static const String kTimesPerWeek = 'times/week';
  static const String kOTCOrderConfirm =
      'Place an order for OTC products? Our team will contact you to confirm.';
  static const String kMedicineDeliveryImage = 'assets/png/medicine_delivery.png';
  static const String kUploadPrescriptionImage = 'assets/png/upload_prescription_illustration.png';
  static const String kFlipHealthPrescriptionImage = 'assets/png/flip_health_prescription_illustration.png';
  static const String kOTCProductsImage = 'assets/png/otc_products_illustration.png';
  static const String kPrescriptionDetailImage = 'assets/png/prescription_detail_illustration.png';

  // Dialog illustrations
  static const String kDialogConfirmImage = 'assets/png/dialog_confirm_illustration.png';
  static const String kDialogWarningImage = 'assets/png/dialog_warning_illustration.png';
  static const String kDialogErrorImage = 'assets/png/dialog_error_illustration.png';
  static const String kDialogInfoImage = 'assets/png/dialog_info_illustration.png';
  static const String kDialogSuccessImage = 'assets/png/dialog_success_illustration.png';

  // Consultation Module — Overview & Flows
  static const String kConsultationOverview = 'Consultation';
  static const String kOnlineConsultation = 'Online Consultation';
  static const String kAtHospital = 'At Hospital';
  static const String kOnlineConsultationDesc =
      'Consult top doctors online from the comfort of your home via video/audio call.';
  static const String kAtHospitalConsultDesc =
      'Visit a specialist at a nearby hospital or clinic for an in-person consultation.';
  static const String kSelectIssue = 'Select an Issue';
  static const String kSearchIssues = 'Search Issues';
  static const String kNoIssuesFound = 'No issues found';
  static const String kNoDoctorsFound = 'No doctors found';
  static const String kNoSlotsAvailable = 'No slots available for this date';
  static const String kSelectDayAndTime = 'Select Day & Time';
  static const String kNoScheduleAvailable = 'No schedule available';
  static const String kPurpose = 'Purpose (Optional)';
  static const String kPurposeHint = 'Briefly describe the reason for your visit';
  static const String kConsultationFAQ1 =
      'How does online consultation work?';
  static const String kConsultationFAQ1Answer =
      'Select an issue, choose a doctor, pick a time slot, and confirm your booking. The doctor will connect via video/audio call.';
  static const String kConsultationFAQ2 =
      'Can I book an in-person appointment?';
  static const String kConsultationFAQ2Answer =
      'Yes, select "At Hospital" to find nearby doctors and hospitals. Choose a specialist, check available schedules, and book.';
  static const String kConsultationFAQ3 =
      'What if I need to cancel my appointment?';
  static const String kConsultationFAQ3Answer =
      'You can cancel or reschedule your appointment from the "My Orders" section. Cancellation policies may vary.';
  static const String kConsultationPrice = 'Consultation Price';
  static const String kNextAvailable = 'Next available';
  static const String kEvening = 'Evening';
  static const String kConfirmBooking = 'Confirm Booking';
  static const String kBookingSummary = 'Booking Summary';
  static const String kSpeciality = 'Speciality';
  static const String kSchedule = 'Schedule';
  static const String kNearbyDoctors = 'Nearby Doctors';

  // Claims Module
  static const String kMyClaims = 'My Claims';
  static const String kNewClaim = 'New Claim';
  static const String kAddNewClaim = 'Add New Claim';
  static const String kFilterByStatus = 'Filter by Status';
  static const String kClaimsLabel = 'Claims';
  static const String kNoClaimsFound = 'No claims found';
  static const String kClaimedLabel = 'Claimed';
  static const String kApprovedLabel = 'Approved';
  static const String kDateLabel = 'Date';
  static const String kTypeLabel = 'Type';
  static const String kSubmittedLabel = 'Submitted';
  static const String kClaimDetails = 'Claim Details';
  static const String kClaimId = 'Claim ID';
  static const String kPatientNameLabel = 'Patient Name';
  static const String kServiceTypeLabel = 'Service Type';
  static const String kClaimedAmountLabel = 'Claimed Amount';
  static const String kApprovedAmountLabel = 'Approved Amount';
  static const String kBillsLabel = 'Bills';
  static const String kSelectPatient = 'Select Patient';
  static const String kContactDetails = 'Contact Details';
  static const String kEmailAddress = 'Email Address';
  static const String kBankDetailsLabel = 'Bank Details';
  static const String kSelectBank = 'Select Bank';
  static const String kTapToSelectBank = 'Tap to select bank account';
  static const String kAcceptTermsAndConditions =
      'I accept the Terms & Conditions for OPD claim reimbursement';
  static const String kStepPatient = 'Patient';
  static const String kStepBills = 'Bills';
  static const String kStepReview = 'Review';
  static const String kMedicalBills = 'Medical Bills';
  static const String kAddMedicalBill = 'Add Medical Bill';
  static const String kBillNumber = 'Bill Number';
  static const String kBillDate = 'Bill Date';
  static const String kBillAmount = 'Bill Amount';
  static const String kClinicName = 'Clinic Name';
  static const String kClinicAddress = 'Clinic Address';
  static const String kDoctorName = 'Doctor Name';
  static const String kDoctorRegistration = 'Doctor Reg. Number';
  static const String kSaveBill = 'Save Bill';
  static const String kSupportingDocuments = 'Supporting Documents';
  static const String kPaymentReceipts = 'Payment Receipts';
  static const String kMedicalReports = 'Medical Reports';
  static const String kOtherDocuments = 'Other Documents';
  static const String kBack = 'Back';
  static const String kReviewClaim = 'Review Claim';
  static const String kPatientDetails = 'Patient Details';
  static const String kTotalClaimAmount = 'Total Claim Amount';
  static const String kClaimDisclaimer =
      'Once submitted, your claim will be reviewed by our team. You will be notified about the status updates via SMS and email.';
  static const String kSubmitClaim = 'Submit Claim';
  static const String kClaimSubmitted = 'Claim Submitted!';
  static const String kClaimSubmittedMsg =
      'Your claim has been submitted successfully. You will receive updates on your registered phone number.';

  static const String kClaimHistory = 'History';
  static const String kBankDetailsTab = 'Bank';
  static const String kDocumentsTab = 'Documents';
  static const String kNoClaimHistory = 'No status history yet.';
  static const String kBankRejectedUpdateHint =
      'Bank verification was rejected. Please update your bank details and upload a valid cheque.';
  static const String kMissingDocsShort = 'Missing';
  static const String kInvalidBillShort = 'Invalid bill';
  static const String kOpenFile = 'Open';
  static const String kDisputeClaim = 'Dispute claim';
  static const String kDisputeReasonHint =
      'Briefly explain why you are disputing this decision';
  static const String kUtrNumber = 'UTR number';
  static const String kSettledDate = 'Settled date';
  static const String kClaimReasonTitle = 'Status note';

  // Bank Details
  static const String kBankAccounts = 'Bank Accounts';
  static const String kAddBankAccount = 'Add Bank Account';
  static const String kBankName = 'Bank Name';
  static const String kAccountHolderName = 'Account Holder Name';
  static const String kAccountNumber = 'Account Number';
  static const String kConfirmAccountNumber = 'Confirm Account Number';
  static const String kIFSCCode = 'IFSC Code';
  static const String kBranch = 'Branch';
  static const String kCancelledCheque = 'Cancelled Cheque / Passbook';
  static const String kUploadChequePhoto = 'Upload cheque or passbook photo';
  static const String kSaveBankAccount = 'Save Bank Account';
  static const String kUpdateBankAccount = 'Update Bank Account';
  static const String kEditBankAccount = 'Edit Bank Account';
  static const String kVerificationStatus = 'Verification status';
  static const String kBankDetailReadOnlyHint =
      'You can only change bank details when verification is rejected. Contact support if you need help.';
  static const String kStatusPending = 'Pending';
  static const String kStatusVerified = 'Verified';
  static const String kStatusRejected = 'Rejected';
  static const String kNoBankAccounts = 'No bank accounts added';
  static const String kAddBank = 'Add Bank';
  static const String kBillImages = 'Bill Images';

  // Mental Wellness
  static const String kMentalWellnessDescription =
      'Enter your details below, and once confirmed, our team will call you within 20 minutes to schedule a session with a specialist.';
  static const String kSelectService = 'Select Service';
  static const String kSelectCategory = 'Select Category';
  static const String kLanguage = 'Preferred Language';
  static const String kSelectLanguage = 'Select Language';
  static const String kMobileNumber = 'Mobile Number';
  static const String kConnect = 'Connect';
  static const String kDisclaimerEmergency =
      'Disclaimer: We do not handle emergencies. For urgent medical assistance, please contact your doctor or the nearest hospital.';
  static const String kDisclaimerServiceHours =
      'Service hours: 9:30 AM – 6:30 PM. Requests received after this time will be processed the next day.';
  static const String kTalkToNutritionist = 'Talk to a Nutritionist';
  static const String kNutritionConsultDescription =
      'Enter your details here and we will connect you to a nutritionist.';
  static const String kWellnessSuccessTitle = 'Thank you for your request';
  static const String kWellnessSuccessBody =
      'Our team will call you within 20 minutes to schedule your session.';
  static const String kWellnessSuccessBodyNutrition =
      'Our team will call you within 20 minutes to connect you with a nutritionist.';

  // Vaccine Module
  static const String kVaccineService = 'Vaccine Service';
  static const String kVaccineCare = 'Vaccine Care';
  static const String kBookFreeVaccineServices =
      'Book free vaccination services for you';
  static const String kBookVaccineForFamily =
      'Book vaccination services for your family';
  static const String kChooseVaccineType = 'Choose Vaccine Type';
  static const String kSelectedVaccines = 'Selected Vaccines';
  static const String kVaccineOverview = 'Vaccine Overview';
  static const String kSelectVaccineSlots = 'Select Your Vaccine Slots';
  static const String kVaccinationCenter = 'Vaccination Center';
  static const String kVaccineTypesLabel = 'Vaccine Types';
  static const String kSelectAtLeastOneVaccine =
      'Please select at least one vaccine';

  // Gym & Fitness Module
  static const String kGymMembership = 'Gym Membership';
  static const String kChooseMembershipPlan = 'Choose a membership plan';
  static const String kMonths = 'months';
  static const String kPerMember = 'per member';
  static const String kBenefits = 'Benefits';
  static const String kSelectMembers = 'Select Members';
  static const String kBookGymForYou = 'Buy gym membership for you';
  static const String kBookGymForFamily = 'Buy gym membership for your family';
  static const String kSelectCityAndCenter = 'Select City & Center';
  static const String kSelectCity = 'Select City';
  static const String kSelectGymCenter = 'Select Gym Center';
  static const String kNoCentersFound = 'No centers found for this city';
  static const String kGymOverview = 'Membership Overview';
  static const String kMembershipPlan = 'Membership Plan';
  static const String kSelectedMembers = 'Selected Members';
  static const String kCityAndCenter = 'City & Center';
  static const String kPaymentDetails = 'Payment Details';
  static const String kSubTotal = 'Sub Total';
  static const String kGST18 = 'GST (18%)';
  static const String kWalletDeduction = 'Wallet Deduction';
  static const String kTotalPayable = 'Total Payable';
  static const String kActivationNote =
      'Your membership will be activated within 72 hours of payment.';
  static const String kAcceptTermsGym =
      'I accept the Terms & Conditions for gym membership';
  static const String kClickToPay = 'Click to Pay';
  static const String kOff = 'OFF';
  static const String kViewBenefits = 'View Benefits';
  static const String kTaxesAndFees = 'taxes & fees';
  static const String kMembership = 'Membership';

  // Gym Asset Paths
  static const String kCultEliteBanner = 'assets/png/cult_elite_mem_banner.png';
  static const String kCultProBanner = 'assets/png/cult_pro_mem_banner.png';
  static const String kGymPrimaryBadge = 'assets/png/gym_primary.png';
  static const String kGymSecondaryBadge = 'assets/png/gym_secondary.png';

  // Orders Module Strings
  static const String kMyOrdersTitle = 'My Orders';
  static const String kOrderDetails = 'Order Details';
  static const String kOrderId = 'Order ID';
  static const String kOrderDate = 'Order Date';
  static const String kOrderStatus = 'Status';
  static const String kServiceType = 'Service Type';
  static const String kItemsOrdered = 'Items Ordered';
  static const String kVendor = 'Vendor';
  static const String kPending = 'Pending';
  static const String kCompleted = 'Completed';
  static const String kCancelled = 'Cancelled';
  static const String kProcessing = 'Processing';
  static const String kNoOrdersFound = 'No orders found';
  static const String kNoOrdersForFilter = 'No orders found for this category';
  static const String kAll = 'All';
  static const String kPaymentSummary = 'Payment Summary';
  static const String kServiceDetails = 'Service Details';

  // Help & Support Module Strings
  static const String kRaiseTicket = 'Raise Ticket';
  static const String kOpenTickets = 'Open';
  static const String kClosedTickets = 'Closed';
  static const String kDescribeYourIssue = 'Describe your issue';
  static const String kIssueHint =
      'E.g.: Connectivity issue, payment failed...';
  static const String kSubmit = 'Submit';
  static const String kNoActiveTicket = 'No active tickets';
  static const String kNoClosedTicket = 'No closed tickets';
  static const String kNoTicketsYet = 'No tickets raised yet!';
  static const String kTicketDetails = 'Ticket Details';
  static const String kTicketId = 'Ticket ID';
  static const String kTeamGetBack =
      'Our support team will get back to you within 24 hours';
  static const String kGiveFeedback = 'Give Feedback';
  static const String kContactSupport = 'Contact Support';
  static const String kContactSupportSubtitle = 'Talk to our support team';
  static const String kYourTickets = 'Your Tickets';
  static const String kOpenATicket = 'Open a Ticket';
  static const String kIssueDescription = 'Issue Description';
  static const String kRateExperience = 'Rate your experience';

  // Shared VVD Strings
  static const String kSelectCenter = 'Select a Center';
  static const String kNoClinicFound = 'No clinics found at this location';
  static const String kDirections = 'Directions';

  // Profile Screen
  static const String kProfileTitle = 'My Profile';
  static const String kEditPhoto = 'Edit Photo';
  static const String kPhone = 'Phone';
  static const String kBMI = 'BMI';
  static const String kBMICategory = 'Category';
  static const String kHealthOverview = 'Health Overview';
  static const String kQuickAccess = 'Quick Access';
  static const String kViewMedicalRecords = 'View Medical Records';
  static const String kViewPrescriptions = 'View Prescriptions';
  static const String kViewLabReports = 'View Lab Reports';
  static const String kNotAvailable = 'N/A';
  static const String kLogout = 'Log Out';
  static const String kEditProfile = 'Edit Profile';
}
