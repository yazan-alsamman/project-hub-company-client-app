import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_admin/core/class/statusrequest.dart';
import 'package:project_hub/lib_admin/core/constant/color.dart';
import 'package:project_hub/lib_admin/core/constant/routes.dart';
import 'package:project_hub/lib_admin/core/services/controllers_initializer.dart';
import 'package:project_hub/core/services/services.dart';
import 'package:project_hub/lib_admin/data/repository/auth_repository.dart';
import 'package:project_hub/lib_client/controller/auth_controller.dart';
import 'package:project_hub/lib_client/controller/common/analytics_controller.dart';
import 'package:project_hub/lib_client/controller/common/settings_controller.dart';
import 'package:project_hub/lib_client/controller/common/custom_drawer_controller.dart';
import 'package:project_hub/lib_client/controller/project/projects_controller.dart';
import 'package:project_hub/lib_client/controller/common/filter_button_controller.dart';

abstract class LoginController extends GetxController {
  login();
}

class LoginControllerImpl extends LoginController {
  final AuthRepository _authRepository = AuthRepository();
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
    print('🔵 ====== LOGIN FUNCTION CALLED ======');
    debugPrint('🔵 Login started');
    print('🔵 Login started - PRINT VERSION');
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
    print('🔵 Calling repository login...');
    debugPrint('Username: ${usernameController.text}');
    debugPrint('Password length: ${passwordController.text.length}');
    final result = await _authRepository.login(
      username: usernameController.text.trim(),
      password: passwordController.text,
    );
    isLoading = false;
    result.fold(
      (error) {
        print('🔴 Login error: $error');
        debugPrint('🔴 Login error: $error');
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
        print('✅ Login successful');
        debugPrint('✅ Login successful');
        debugPrint('Response: $response');
        statusRequest = StatusRequest.success;
        update();

        // Get user role from auth service
        final authService = Get.find<Myservices>();
        final userRole = await authService.sharedPreferences.getString(
          'user_role',
        );
        debugPrint('🔵 User role: $userRole');

        // Route based on user role
        if (userRole?.toLowerCase() == 'client') {
          // Route to client app
          debugPrint('🔵 Routing to client app');
          // Initialize client controllers
          if (!Get.isRegistered<AuthController>()) {
            Get.put(AuthController(), permanent: true);
          }
          if (!Get.isRegistered<AnalyticsControllerImp>()) {
            Get.put(AnalyticsControllerImp());
          }
          if (!Get.isRegistered<SettingsControllerImp>()) {
            Get.put(SettingsControllerImp());
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
          // Route to admin app (dev, admin, superAdmin, pm)
          debugPrint('🔵 Routing to admin app');
          // Initialize all controllers after successful login
          debugPrint('🔄 Initializing all controllers after login...');
          ControllersInitializer.initializeControllers();
          debugPrint('✅ All controllers initialized');
          Get.offAllNamed(AppRoute.team);
        }
      },
    );
  }

  @override
  void toggleRememberMe() {
    rememberMe = !rememberMe;
    update();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }
}
