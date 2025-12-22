import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/onBoarding_controller.dart';
import '../../../core/constant/color.dart';
class CustomButtonOnBoarding extends GetView<OnBoardingControllerImp> {
  const CustomButtonOnBoarding({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      height: 40,
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 2),
        onPressed: () {
          controller.next();
        },
        color: AppColor.primaryColor,
        child: Text("8".tr),
      ),
    );
  }
}
