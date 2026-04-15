// ignore_for_file: constant_identifier_names

class ApiUrl {
  static final ApiUrl _singleton = ApiUrl._internal();
  factory ApiUrl() {
    return _singleton;
  }
  ApiUrl._internal();

  /// Dev server base URL
  // static const kDomain = "http://122.175.52.41:2017";
  static const kDomain = "http://192.168.1.88:2017";
  static const kBaseUrlDomain = "";

  static const kImageUrl =
      "https://flip-api-public.s3.ap-south-1.amazonaws.com/development";

  static const BASE_URL = kDomain + kBaseUrlDomain;

  // Auth
  static const String LOGIN = "/patient/login";
  static const String REGISTER = "/patient/register";
  static const String VERIFY_OTP = "/patient/verify";
  static const String RESEND_OTP = "/patient/resendotp";
  static const String LINK = "/patient/link";
  static const String VERIFY_LINK = "/patient/vlink";

  // Splash / Startup (root domain, not under /patient)
  static const String VERSION_CHECK = "/version/patient/";
  static const String NOTICE_BOARD = "/notice-board";

  // Members
  static const String GET_MEMBERS = "/patient/member";

  /// Request OTP on mobile when adding a dependent — same as patient_app
  /// `AllProviders.getOTP` → `POST /patient/otp` with `{ "key": "<10-digit>", "action": "MEMBER" }`.
  static const String MEMBER_OTP = "/patient/otp";

  /// Relationship options for dependents — `GET /patient/dependent/types` (patient_app `AllProviders.relations`).
  static const String DEPENDENT_TYPES = "/patient/dependent/types";

  // Consultation — Online / Virtual
  static const String ISSUES = "/patient/issues";
  static const String SPECIALITY_DOCTORS = "/patient/speciality";
  static const String AVAILABLE_SLOTS = "/patient/availableSlots";
  static const String BOOK_APPOINTMENT = "/patient/appointment/book";

  // Consultation — Offline / Hospital
  static const String SPECIALTIES = "/patient/specialties";
  static const String NETWORK_SLOTS = "/patient/network/slots";
  static const String NETWORK_BOOK = "/patient/appointment/network_book";

  // Address
  static const String ADDRESS = "/patient/address";
  static const String ADDRESS_UPDATE = "/patient/v1/customer/address/";
  static const String ADDRESS_PRIMARY = "/patient/address/primary/";

  /// VVD network (dental / vision / vaccine clinics) — `GET ?location=lat,lng&service=dental`
  static const String NETWORK_LIST = "/patient/network/list";

  /// Dental service booking request
  static const String DENTAL_SERVICE_REQUEST =
      "/patient/service/dental/request";

  /// Vaccine service types — `GET ?search=service_type:vaccine`
  static const String NETWORK_SERVICES = "/patient/services";

  /// Vaccine service booking request
  static const String VACCINE_SERVICE_REQUEST =
      "/patient/service/vaccine/request";

  /// Vision / VVD service slots — `GET`
  static const String SERVICE_SLOTS = "/patient/service/slots";

  /// Vision service booking request
  static const String VISION_SERVICE_REQUEST =
      "/patient/service/vision/request";

  /// Service request payment / confirm / cancel (dental, vision, vaccine)
  static const String SERVICE_REQUEST_PAYMENT =
      "/patient/service/request/payment";
  static const String SERVICE_REQUEST_PAYMENT_VERIFY =
      "/patient/service/request/paymentverify";
  static const String SERVICE_REQUEST_CANCEL =
      "/patient/service/request/cancel";
  static const String SERVICE_REQUEST_CONFIRM =
      "/patient/service/request/confirm";

  /// Pharmacy — place medicine order (upload / flip health / OTC)
  static const String MEDICINE_ORDER = "/patient/medicine";

  /// Pharmacy order payment / cancel / confirm — same paths as patient_app `Apis` under `/patient`.
  static const String MEDICINE_ORDER_PAYMENT =
      "/patient/medicine/order/payment";
  static const String MEDICINE_ORDER_CANCEL = "/patient/medicine/order/cancel";
  static const String MEDICINE_ORDER_CONFIRM =
      "/patient/medicine/order/confirm";
  static const String MEDICINE_ORDER_PAYMENT_VERIFY =
      "/patient/medicine/order/paymentverify";

  /// Gym membership order APIs.
  static const String GYM_MEMBERSHIP_CHECK = "/patient/gym/check";
  static const String GYM_MEMBERSHIP_OPTIN = "/patient/gym/optIn";
  static const String GYM_OPTIN_PAYMENT_VERIFY = "/patient/gym/payment_verify";

  /// Flip Health prescriptions — `GET` all, `GET /{id}` single
  static const String PRESCRIPTIONS = "/patient/prescriptions";

  // Health Score
  static const String HEALTH_SCORE = "/patient/healthscore";

  /// Home dashboard — same path as patient_app `Apis.dashboard` (`/patient` + `/dashboard`).
  static const String DASHBOARD = "/patient/dashboard";

  /// OPD wallet — same paths as patient_app `Apis.OPDwallet` / `OPDwalletTransactions`.
  static const String OPD_WALLET = "/patient/opd/wallet";
  static const String OPD_WALLET_TRANSACTIONS =
      "/patient/opd/wallet/transactions";

  /// Flip Cash / app wallet (recharge flow) — patient_app `Apis.wallet`, `create_wallet`.
  static const String WALLET = "/patient/wallet";
  static const String WALLET_CREATE = "/patient/wallet/create";

  /// Plans & subscriptions — patient_app `AllProviders.getSubscriptionDetails` → `GET /subscription/plans`.
  static const String SUBSCRIPTION_PLANS = "/patient/subscription/plans";

  /// Assign a dependent to a plan slot — patient_app `activatePlanFamilyMember` → `POST /subscription/activate`.
  static const String SUBSCRIPTION_ACTIVATE = "/patient/subscription/activate";

  /// Mental wellness & nutrition (Trijog) — same paths as patient_app `Apis`
  static const String WELLNESS_SESSION = "/patient/wellness/session";
  static const String MENTAL_WELLNESS_TYPES = "/patient/mental_wellness/type";
  static const String JUMPING_MIND_ORDER_CANCEL =
      "/patient/jumping-mind/expert/order/cancel";
  static const String JUMPING_MIND_ORDER_RESCHEDULE =
      "/patient/jumping-mind/expert/order/reschedule";

  // Static pages
  static const TERMS_AND_CONDITIONS_URL = "${kDomain}/terms-and-conditions";
  static const PRIVACY_POLICY_URL = "${kDomain}/privacy-policy";

  // Bank details (claims / reimbursements) — same routes as patient_app AllProviders
  static const String GET_BANK_DETAILS = "/patient/bank_details";

  /// Paginated bank name list (`/type` + `search=type:banks,...`) — see `AllProviders.getBanks`
  static const String GET_BANK_TYPES = "/patient/type";

  /// Cheque / bank document upload (`type` field = `bank`) — same host as [BASE_URL], not under `/patient`
  static const String UPLOAD_ATTACHMENT = "/upload";

  /// Reimbursement (claims) — same routes as patient_app `Apis.reimbursements`
  static const String REIMBURSEMENT = "/patient/reimbursement";
  static const String REIMBURSEMENT_CREATE = "/patient/reimbursement/create";

  /// `PATCH /patient/reimbursement/status/{id}` — dispute / status updates
  static const String REIMBURSEMENT_STATUS = "/patient/reimbursement/status/";

  static const String REIMBURSEMENT_BILL_TYPES =
      "/patient/reimbursement/service_types";

  /// Required payment/report doc categories for selected service types — `GET …/multi_document/type?type=a,b`.
  static const String REIMBURSEMENT_MULTI_DOC_TYPES =
      "/patient/reimbursement/multi_document/type";

  /// Support tickets — GET all, POST create
  static const String SUPPORT_TICKETS = "/patient/support/ticket";

  /// Support ticket detail — append ticket ID for GET messages (?page=N) / POST message
  static const String SUPPORT_TICKET_DETAIL = "/patient/support/ticket/";

  /// Feedback — POST rating + description
  static const String FEEDBACK = "/patient/feedback";

  /// Medical records / history — `GET /history/type/{type}` (consultations, prescriptions, labtest, etc.)
  static const String MEDICAL_RECORDS = "/patient/history/type/";

  /// All orders / invoices — `GET ?type=&limit=20&page=1` (Bearer). Same as patient_app `Apis.invoice`.
  static const String INVOICE = "/patient/invoice";

  /// Single invoice / consultation detail — `GET /patient/invoice/{id}`
  static String invoiceById(String id) => "/patient/invoice/$id";

  /// Video call signaling — `PATCH /patient/joincall/{roomId}` (patient_app `join_call`)
  static String joinCall(String roomId) => "/patient/joincall/$roomId";

  /// End call — `PATCH /patient/endcall/{roomId}`
  static String endCall(String roomId) => "/patient/endcall/$roomId";

  /// Cancel consultation — `PATCH /patient/appointment/cancel/{appointmentId}`
  static String appointmentCancel(String appointmentId) =>
      "/patient/appointment/cancel/$appointmentId";

  /// Offline consultation payment confirm — `PATCH …/payment/{invoiceId}?useWallet=&status=confirm`
  static const String OFFLINE_APPOINTMENT_PAYMENT =
      "/patient/offline/appointment/payment";

  /// Razorpay verify after booking — `PATCH /patient/appointment/paymentverify`
  static const String APPOINTMENT_PAYMENT_VERIFY =
      "/patient/appointment/paymentverify";

  // Diagnostics
  static const String DIAGNOSTICS_PACKAGES = "/patient/diagnostics/packages";
  static const String DIAGNOSTICS_PACKAGE_DETAIL =
      "/patient/diagnostics/packages/";
  static const String DIAGNOSTICS_VENDORS =
      "/patient/diagnostics/packages/pricing";
  static const String DIAGNOSTICS_SPONSORED_PRICING =
      "/patient/diagnostics/sponsored/pricing";
  static const String DIAGNOSTICS_SLOTS = "/patient/diagnostics/slots";
  static const String DIAGNOSTICS_BOOKING =
      "/patient/diagnostics/order/booking";

  // Cart
  static const String CART_LAB = "/patient/cart/lab";
  static const String CART_ADD = "/patient/cart/add";
  static const String CART_REMOVE_LAB = "/patient/cart/remove/lab/";
  static const String CART_CLEAR_LAB = "/patient/cart/clear/lab";

  /// Resolve attachment path from API (relative or absolute) for [Image.network] / PDF viewer.
  static String? publicFileUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    if (p.startsWith('/')) {
      return '$kImageUrl$p';
    }
    return '$kImageUrl/$p';
  }
}
