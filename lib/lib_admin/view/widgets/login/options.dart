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
        ],
      ),
    );
  }
}
