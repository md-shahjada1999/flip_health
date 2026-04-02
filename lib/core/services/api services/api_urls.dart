// ignore_for_file: constant_identifier_names

class ApiUrl {
  static final ApiUrl _singleton = ApiUrl._internal();
  factory ApiUrl() {
    return _singleton;
  }
  ApiUrl._internal();

  /// Dev server base URL
  static const kDomain = "http://192.168.1.88:2017";
  static const kBaseUrlDomain = "";

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

  // Static pages
  static const TERMS_AND_CONDITIONS_URL = "${kDomain}/terms-and-conditions";
  static const PRIVACY_POLICY_URL = "${kDomain}/privacy-policy";
}