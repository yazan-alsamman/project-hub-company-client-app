import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/onBoarding_controller.dart';
import '../../../core/constant/color.dart';
import '../../../data/static/onBoarding_data.dart';
class CustomDotControllerOnBoarding extends StatelessWidget {
  const CustomDotControllerOnBoarding({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardingControllerImp>(
      builder: (controller) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(
            onBoardingList.length,
            (index) => AnimatedContainer(
              margin: const EdgeInsets.only(right: 5),
              duration: const Duration(microseconds: 900),
              width: controller.currentPage == index ? 20 : 5,
              height: 6,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
