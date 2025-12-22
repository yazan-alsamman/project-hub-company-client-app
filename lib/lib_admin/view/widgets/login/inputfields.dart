import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/color.dart';
import '../../../controller/auth/login_controller.dart';
class InputFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String hintText;
  const InputFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.hintText,
  });
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return GetBuilder<LoginControllerImpl>(
      builder: (controller) => Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.text,
              style: TextStyle(fontSize: isTablet ? 16 : 14),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColor.textSecondaryColor,
                  fontSize: isTablet ? 16 : 14,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppColor.textSecondaryColor,
                  size: isTablet ? 24 : 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 20 : 16,
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Container(
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: passwordController,
              obscureText: !controller.isPasswordVisible,
              style: TextStyle(fontSize: isTablet ? 16 : 14),
              decoration: InputDecoration(
                hintText: 'Your password',
                hintStyle: TextStyle(
                  color: AppColor.textSecondaryColor,
                  fontSize: isTablet ? 16 : 14,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppColor.textSecondaryColor,
                  size: isTablet ? 24 : 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColor.textSecondaryColor,
                    size: isTablet ? 24 : 20,
                  ),
                  onPressed: () => controller.togglePasswordVisibility(),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 20 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
