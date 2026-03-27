// ignore_for_file: constant_identifier_names

class ApiUrl {
  static final ApiUrl _singleton = ApiUrl._internal();
  factory ApiUrl() {
    return _singleton;
  }
  ApiUrl._internal();

  /// Base Live
  static const kDomain = "";
  static const kBaseUrlDomain = "";

  static const BASE_URL = kDomain + kBaseUrlDomain;

  // static const String SIGNUP_API_URL                   = "${BASE_URL}signup";
  // static const String LOGIN_API_URL                    = "${BASE_URL}log_in";
  // static const String SIGN_VERIFY_OTP_API_URL          = "${BASE_URL}signverifyotp";
  // static const String VERIFY_OTP_API_URL               = "${BASE_URL}verify_otp";
  // static const String FORGOT_PASSWORD_API_URL          = "${BASE_URL}forgot_password";
  // static const String RESET_PASSWORD_API_URL           = "${BASE_URL}reset_password";
  // static const String RESEND_OTP_API_URL               = "${BASE_URL}resendotp";
  // static const String UPDATE_PROFILE_API_URL           = "${BASE_URL}update_profile";
 
  static const TERMS_AND_CONDITIONS_URL          = "${kDomain}terms-and-conditions";
  static const PRIVACY_POLICY_URL                = "${kDomain}privacy-policy";
  
}