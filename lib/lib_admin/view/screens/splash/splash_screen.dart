import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/imageassets.dart';
import '../../../core/constant/routes.dart';
import 'package:project_hub/core/services/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 5), () {
      if (!Get.isRegistered<Myservices>()) {
        Get.put(Myservices());
      }
      final myservices = Get.find<Myservices>();
      final onBoardingStatus = myservices.sharedPreferences.getString("onBoarding");
      
      if (onBoardingStatus == "1") {
        Get.offAllNamed(AppRoute.login);
      } else {
        Get.offAllNamed(AppRoute.onBoarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColor.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppImageAsset.splashLogo,
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.business_center,
                    size: 80,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
