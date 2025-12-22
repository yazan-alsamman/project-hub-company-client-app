import 'dart:async';
import 'package:flutter/material.dart';
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
      final myservices = Get.find<Myservices>();
      final onBoardingStatus = myservices.sharedPreferences.getString("onBoarding");
      
      if (onBoardingStatus == "1") {
        // User has seen onBoarding before, go to login
        Get.offAllNamed(AppRoute.login);
      } else {
        // First time, go to onBoarding
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
              // Logo Image
              Image.asset(
                AppImageAsset.fullLogo,
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
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
                  );
                },
              ),
              const SizedBox(height: 40),
              // Loading Indicator
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
