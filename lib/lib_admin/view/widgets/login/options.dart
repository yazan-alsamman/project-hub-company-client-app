import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/routes.dart';
import '../../../controller/auth/login_controller.dart';
class Options extends StatelessWidget {
  const Options({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return GetBuilder<LoginControllerImpl>(
      builder: (controller) => Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: controller.rememberMe,
                onChanged: (value) {
                  controller.toggleRememberMe();
                },
                activeColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                'Remember me',
                style: TextStyle(
                  color: AppColor.textColor,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Get.toNamed(AppRoute.forgetPassword);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 8,
                  vertical: isTablet ? 8 : 6,
                ),
              ),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: AppColor.secondaryColor,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
