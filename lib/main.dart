import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/app_page_transition.dart';
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

  final savedToken = AppSecureStorage.getToken();
  print("savedToken: $savedToken");
  if (savedToken != null && savedToken.isNotEmpty) {
    accessToken = savedToken;
  }

  runApp(MyApp());
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
      theme: ThemeData(primarySwatch: Colors.red, fontFamily: 'Poppins'),
    );
  }
}
