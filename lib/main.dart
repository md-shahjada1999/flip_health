import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/connectivity_controller.dart';
import 'package:flip_health/core/services/global_error_controller.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/app_page_transition.dart';
import 'package:flip_health/routes/app_pages.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/common/no_connection_screen.dart';
import 'package:flip_health/views/common/server_error_screen.dart';
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

  Get.put(ConnectivityController(), permanent: true);
  Get.put(GlobalErrorController(), permanent: true);

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
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            Obx(() {
              final cc = Get.find<ConnectivityController>();
              if (!cc.isConnected.value) return const NoConnectionScreen();
              return const SizedBox.shrink();
            }),
            Obx(() {
              final ec = Get.find<GlobalErrorController>();
              if (ec.hasError) return const ServerErrorScreen();
              return const SizedBox.shrink();
            }),
          ],
        );
      },
    );
  }
}
