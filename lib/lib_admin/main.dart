import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constant/routes.dart';
import 'package:project_hub/core/services/services.dart';
import 'routes.dart';
import 'controller/auth/login_controller.dart';
import 'controller/auth/onBoarding_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();
  Get.put(LoginControllerImpl(), permanent: true);
  Get.put(OnBoardingControllerImp(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.splash,
      getPages: routes,
    );
  }
}
