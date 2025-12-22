import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/onBoarding_controller.dart';
import '../../../core/constant/color.dart';
import '../../../data/static/onBoarding_data.dart';
class CustomSliderOnBoarding extends GetView<OnBoardingControllerImp> {
  const CustomSliderOnBoarding({super.key});
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: (val) {
        controller.onPageChanged(val);
      },
      itemCount: onBoardingList.length,
      itemBuilder: (context, i) => Column(
        children: [
          const SizedBox(height: 80),
          Image.asset(
            onBoardingList[i].image!,
            height: Get.width / 1.3,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20),
          Text(
            onBoardingList[i].title!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColor.gradientStart,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              onBoardingList[i].body!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 2,
                color: AppColor.activeCardColor,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
