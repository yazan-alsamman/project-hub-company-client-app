import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/login_controller.dart';
import '../../../core/constant/color.dart';

import '../../widgets/common/main_button.dart';
import '../../widgets/login/build_header.dart';
import '../../widgets/login/inputfields.dart';
import '../../widgets/login/options.dart';

class Login extends StatelessWidget {
  const Login({super.key});
  @override
  Widget build(BuildContext context) {
    LoginControllerImpl controller = Get.find<LoginControllerImpl>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.gradientStart,
              AppColor.gradientMiddle, // #8B5CF6
              AppColor.gradientEnd, // #6B46C1
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width > 600
                      ? 500
                      : MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width > 600 ? 40.0 : 24.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BuildHeader(
                        title: "Welcome Back",
                        subtitle: "Sign in to continue to ProjectHub",
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      InputFields(
                        emailController: controller.usernameController,
                        passwordController: controller.passwordController,
                        hintText: "username",
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      const Options(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      _buildSignInButton(context),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      _buildSignUpLink(context),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      width: double.infinity,
      height: isTablet ? 56 : 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.primaryColor, AppColor.gradientStart],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GetBuilder<LoginControllerImpl>(
        builder: (controller) => MainButton(
          icon: Icons.arrow_forward_outlined,
          onPressed: controller.isLoading
              ? null
              : () {
                  print('🔵 ====== SIGN IN BUTTON PRESSED ======');
                  debugPrint('🔵 Sign in button pressed');
                  debugPrint('🔵 Controller: ${controller.runtimeType}');
                  debugPrint(
                    '🔵 Username: ${controller.usernameController.text}',
                  );
                  debugPrint(
                    '🔵 Password length: ${controller.passwordController.text.length}',
                  );
                  controller.login();
                },
          text: controller.isLoading ? "Signing in..." : "Sign in",
        ),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: AppColor.textSecondaryColor,
            fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }
}
