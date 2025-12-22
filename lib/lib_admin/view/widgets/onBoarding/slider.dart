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
          const SizedBox(height: 40),
          Text(
            onBoardingList[i].title!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColor.darkBackground,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              onBoardingList[i].body!,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                height: 1.6,
                color: AppColor.darkBackground,
                fontWeight: FontWeight.w400,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
