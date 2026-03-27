import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/routes/app_pages.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// // ////new FH main
String accessToken = "";
void main() {
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
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
      ),
    );
  }
}
