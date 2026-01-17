import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_admin/core/class/statusrequest.dart';
import 'package:project_hub/lib_admin/core/constant/color.dart';
import 'package:project_hub/lib_admin/core/constant/routes.dart';
import 'package:project_hub/core/services/services.dart';
import 'package:project_hub/lib_admin/data/repository/auth_repository.dart';
import 'package:project_hub/lib_client/controller/auth_controller.dart';
import 'package:project_hub/lib_client/controller/common/analytics_controller.dart';
import 'package:project_hub/lib_client/controller/common/custom_drawer_controller.dart';
import 'package:project_hub/lib_client/controller/project/projects_controller.dart';
import 'package:project_hub/lib_client/controller/common/filter_button_controller.dart';
import 'package:project_hub/core/services/logging_service.dart';

abstract class LoginController extends GetxController {
  login();
}

class LoginControllerImpl extends LoginController {
  final AuthRepository _authRepository = AuthRepository();
  final LoggingService _logger = LoggingService();
  bool isPasswordVisible = false;
  bool rememberMe = false;
  bool isLoading = false;
  StatusRequest statusRequest = StatusRequest.none;
  late TextEditingController usernameController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  @override
  login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.inactiveCardColor,
        colorText: AppColor.darkBackground,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();

    final result = await _authRepository.login(
      username: usernameController.text.trim(),
      password: passwordController.text,
    );

    isLoading = false;

    result.fold(
      (error) {
        String errorMsg = 'Login failed. Please try again.';
        if (error == StatusRequest.serverFailure) {
          errorMsg = 'Invalid username or password.';
        } else if (error == StatusRequest.offlineFailure) {
          errorMsg = 'No internet connection. Please check your network.';
        } else if (error == StatusRequest.timeoutException) {
          errorMsg = 'Request timed out. Please try again.';
        } else if (error == StatusRequest.serverException) {
          errorMsg = 'An unexpected server error occurred.';
        }

        statusRequest = error;
        update();

        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.errorColor,
          colorText: AppColor.white,
          icon: const Icon(
            Icons.error_outline,
            color: AppColor.white,
            size: 28,
          ),
          duration: const Duration(seconds: 5),
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      },
      (response) async {
        statusRequest = StatusRequest.success;
        update();

        final authService = Get.find<Myservices>();
        final userRole = authService.sharedPreferences.getString('user_role');

        if (userRole?.toLowerCase() == 'superadmin' ||
            userRole?.toLowerCase() == 'super admin') {
          await _logger.logAuthEvent(
            event: 'SUPERADMIN_LOGIN_BLOCKED',
            role: userRole,
            success: false,
          );

          statusRequest = StatusRequest.serverFailure;
          update();

          Get.snackbar(
            'Access Denied',
            'Super admin accounts are not allowed to access this application.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.errorColor,
            colorText: AppColor.white,
            icon: const Icon(Icons.block, color: AppColor.white, size: 28),
            duration: const Duration(seconds: 5),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );

          await authService.sharedPreferences.remove('user_role');
          await authService.sharedPreferences.remove('auth_token');
          await authService.sharedPreferences.remove('refresh_token');
          await authService.sharedPreferences.remove('user_id');
          await authService.sharedPreferences.remove('user_email');
          await authService.sharedPreferences.remove('user_username');
          return;
        }

        if (userRole?.toLowerCase() == 'client') {
          await _logger.logInfo('NAV', 'Routing to client app');

          if (!Get.isRegistered<AuthController>()) {
            Get.put(AuthController(), permanent: true);
          }
          if (!Get.isRegistered<AnalyticsControllerImp>()) {
            Get.put(AnalyticsControllerImp());
          }
          if (!Get.isRegistered<CustomDrawerControllerImp>()) {
            Get.put(CustomDrawerControllerImp());
          }
          if (!Get.isRegistered<ProjectsControllerImp>()) {
            Get.put(ProjectsControllerImp(), permanent: true);
          }
          if (!Get.isRegistered<FilterButtonController>()) {
            Get.put(FilterButtonController());
          }

          Get.offAllNamed('/client/tasks-page');
        } else {
          await _logger.logInfo('NAV', 'Routing to admin app');

          // Controllers will be initialized automatically via bindings when entering each page
          // No need to initialize them here

          if (userRole?.toLowerCase() == 'developer') {
            Get.offAllNamed(AppRoute.tasks);
          } else {
            Get.offAllNamed(AppRoute.team);
          }
        }
      },
    );
  }

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    update();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }
}
