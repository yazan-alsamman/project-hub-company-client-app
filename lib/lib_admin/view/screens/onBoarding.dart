import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth/onBoarding_controller.dart';
import '../../core/constant/color.dart';
import '../widgets/onBoarding/custtombuttononboarding.dart';
import '../widgets/onBoarding/dotcontroller.dart';
import '../widgets/onBoarding/slider.dart';
class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(OnBoardingControllerImp());
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(flex: 4, child: CustomSliderOnBoarding()),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  CustomDotControllerOnBoarding(),
                  SizedBox(height: 20),
                  Spacer(flex: 2),
                  CustomButtonOnBoarding(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
