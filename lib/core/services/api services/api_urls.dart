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

  // Consultation
  static const String GET_SPECIALITIES = "/patient/speciality";
  static const String GET_DOCTORS = "/patient/doctor";
  static const String GET_HOSPITALS = "/patient/hospital";

  // Address
  static const String ADDRESS = "/patient/address";

  /// VVD network (dental / vision / vaccine clinics) — `GET ?location=lat,lng&service=dental`
  static const String NETWORK_LIST = "/patient/network/list";

  /// Dental service booking request
  static const String DENTAL_SERVICE_REQUEST = "/patient/service/dental/request";

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

  /// Mental wellness & nutrition (Trijog) — same paths as patient_app `Apis`
  static const String WELLNESS_SESSION = "/patient/wellness/session";
  static const String MENTAL_WELLNESS_TYPES = "/patient/mental_wellness/type";

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
