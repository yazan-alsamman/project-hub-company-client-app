import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/routes.dart';
import 'package:project_hub/core/services/services.dart';
class MyMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;
  Myservices myservices = Get.find();
  @override
  RouteSettings? redirect(String? route) {
    if (myservices.sharedPreferences.getString("onBoarding") == "1") {
      return const RouteSettings(name: AppRoute.login);
    }
    return null;
  }
}
