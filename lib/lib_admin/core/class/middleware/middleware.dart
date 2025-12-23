import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/routes.dart';
import 'package:project_hub/core/services/services.dart';
class MyMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;
  Myservices myservices = Get.find();
  @override
  RouteSettings? redirect(String? route) {
    // Allow splash screen to load without redirect
    if (route == AppRoute.splash) {
      return null;
    }
    if (route == AppRoute.projectDashboard ||
        route == AppRoute.analytics ||
        route == AppRoute.projects ||
        route == AppRoute.team ||
        route == AppRoute.tasks ||
        route == AppRoute.addEmployee ||
        route == AppRoute.addTask ||
        route == AppRoute.addProject ||
        route == AppRoute.memberDetail ||
        route == AppRoute.profile ||
        route == AppRoute.projectDetails ||
        route == AppRoute.assignments ||
        route == AppRoute.addAssignment ||
        route == AppRoute.addClient ||
        route == AppRoute.aiAssistance) {
      return null;
    }
    String? onBoardingStatus = myservices.sharedPreferences.getString(
      "onBoarding",
    );
    if (onBoardingStatus == "1") {
      return const RouteSettings(name: AppRoute.login);
    }
    return null;
  }
}
