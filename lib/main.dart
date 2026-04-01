import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/app_page_transition.dart';
import 'package:flip_health/model/user%20models/user_model.dart';
import 'package:flip_health/routes/app_pages.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

String accessToken = "";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppSecureStorage.getInstance();

  // Restore saved auth token, or seed dev login data if first run
  final savedToken = AppSecureStorage.getToken();
  if (savedToken != null && savedToken.isNotEmpty) {
    accessToken = savedToken;
  } else {
    await _seedDevLoginData();
  }

  runApp(MyApp());
}

/// Seeds the dummy login response so the app can work while login API is in dev mode.
/// Remove this once real login flow is fully integrated.
Future<void> _seedDevLoginData() async {
  const devLoginResponse = {
    "token":
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTAwMzA4MCwicGhvbmUiOiI4MTQzMjA2OTY3IiwiZW1haWwiOiJrYXJ0aGlrLmFAZmxpcC5oZWFsdGgiLCJuYW1lIjoia2FydGhpayIsInByaW1hcnkiOiIxMDAzMDgwIiwidHlwZSI6InBhdGllbnQiLCJ1c2VyX3R5cGUiOiJwYXRpZW50IiwiY29ycG9yYXRlX2lkIjoyMTksImFjY2VzcyI6ImFjY2Vzc1Rva2VuIiwiaWF0IjoxNzc1MDM2ODA4LCJleHAiOjE3NzgxNDcyMDh9.Ns0kZJ0dt23Cs0ee8XnojG6OaS0sKKHUJW6Wa4ocpZ0",
    "user": {
      "name": "karthik",
      "email": "karthik.a@flip.health",
      "phone": "8143206967",
      "dob": "1995-10-04",
      "image": null,
      "gender": "male",
      "isBloodPressure": "no",
      "isDiabetic": "no",
      "bloodGroup": "B +ve",
      "occupation": null,
      "language": "English",
      "vip": false,
      "empId": "FH00017",
      "device_id": "AP3A.240905.015.A2",
      "platform": "android",
      "ref_code": "AINFLB",
      "relationship": "",
      "first_name": "karthik",
      "last_name": "",
      "age": 30,
      "id": 1003080,
      "type": "patient",
      "primary": "1003080",
      "freeConsultations": 0,
      "corporate_id": 219,
      "status": 1,
      "isSubscribed": true,
      "company": {"id": 219, "name": "Philips", "image": null, "code": "philips"},
      "health_score": {
        "value": 26.24,
        "unit": "bmi",
        "category": "bmi",
        "details": {"height": "5.7", "weight": 76}
      }
    }
  };

  final loginResponse = LoginResponse.fromJson(devLoginResponse);
  await AppSecureStorage.saveLoginResponse(loginResponse);
  accessToken = loginResponse.token;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return GetMaterialApp(
      title: 'FlipHealth',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      customTransition: AppPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
      ),
    );
  }
}




//bmi
//email login
//lens - vision
//mental wellness
//nutrition
//claims - bank '
// bill upload in claim screen