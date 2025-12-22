import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/constant/routes.dart';
import '../../core/services/auth_service.dart';
import 'team_controller.dart';
import '../../data/Models/role_model.dart';
import '../../data/Models/position_model.dart';
import '../../data/Models/department_model.dart';
import '../../data/repository/team_repository.dart';
abstract class AddEmployeeController extends GetxController {
  void createEmployee();
  void resetForm();
}
class AddEmployeeControllerImp extends AddEmployeeController {
  final TeamRepository _teamRepository = TeamRepository();
  AuthService? _authService;
  AuthService get authService {
    _authService ??= AuthService();
    return _authService!;
  }
  final TextEditingController employeeCodeController = TextEditingController();
  final TextEditingController hireDateController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController subRoleController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedStatus = 'active';
  String? selectedCompanyId;
  String? selectedRoleId; // Selected role ID
  String? selectedPositionId; // Selected position ID
  String? selectedDepartmentId; // Selected department ID
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  bool isLoadingRoles = false;
  bool isLoadingPositions = false;
  bool isLoadingDepartments = false;
  String? errorMessage; // Store error message from backend
  List<RoleModel> roles = []; // List of available roles
  List<PositionModel> positions = []; // List of available positions
  List<DepartmentModel> departments = []; // List of available departments
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadRoles();
    loadPositions();
    loadDepartments();
  }
  Future<void> loadUserData() async {
    selectedCompanyId = await authService.getCompanyId();
    debugPrint('✅ Loaded companyId from AuthService: $selectedCompanyId');
    update();
  }
  Future<void> loadRoles() async {
    isLoadingRoles = true;
    update();
    try {
      final result = await _teamRepository.getRoles();
      result.fold(
        (error) {
          debugPrint('🔴 Error loading roles: $error');
          isLoadingRoles = false;
          update();
        },
        (rolesList) {
          debugPrint('✅ Loaded ${rolesList.length} roles');
          // Filter out "client" role (case-insensitive)
          roles = rolesList.where((role) {
            final roleNameLower = role.name.toLowerCase();
            return roleNameLower != 'client';
          }).toList();
          debugPrint('✅ Filtered roles: ${roles.length} roles (excluding client)');
          if (roles.isNotEmpty && selectedRoleId == null) {
            selectedRoleId = roles.first.id;
          }
          isLoadingRoles = false;
          update();
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading roles: $e');
      isLoadingRoles = false;
      update();
    }
  }
  Future<void> loadPositions() async {
    isLoadingPositions = true;
    update();
    try {
      final result = await _teamRepository.getPositions(page: 1, limit: 10);
      result.fold(
        (error) {
          debugPrint('🔴 Error loading positions: $error');
          isLoadingPositions = false;
          update();
        },
        (positionsList) {
          debugPrint('✅ Loaded ${positionsList.length} positions');
          positions = positionsList;
          if (positions.isNotEmpty && selectedPositionId == null) {
            selectedPositionId = positions.first.id;
          }
          isLoadingPositions = false;
          update();
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading positions: $e');
      isLoadingPositions = false;
      update();
    }
  }
  Future<void> loadDepartments() async {
    isLoadingDepartments = true;
    update();
    try {
      final result = await _teamRepository.getDepartments(page: 1, limit: 10);
      result.fold(
        (error) {
          debugPrint('🔴 Error loading departments: $error');
          isLoadingDepartments = false;
          update();
        },
        (departmentsList) {
          debugPrint('✅ Loaded ${departmentsList.length} departments');
          departments = departmentsList;
          if (departments.isNotEmpty && selectedDepartmentId == null) {
            selectedDepartmentId = departments.first.id;
          }
          isLoadingDepartments = false;
          update();
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading departments: $e');
      isLoadingDepartments = false;
      update();
    }
  }
  @override
  void createEmployee() async {
    debugPrint('🔵 Creating employee with user...');
    if (!_validateForm()) {
      return;
    }
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    try {
      final salary = int.tryParse(salaryController.text.trim());
      if (salary == null) {
        Get.snackbar(
          'Error',
          'Please enter a valid salary',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.primaryColor,
          colorText: AppColor.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        isLoading = false;
        update();
        return;
      }
      if (positions.isEmpty) {
        Get.snackbar(
          'Error',
          'Positions not loaded. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.errorColor,
          colorText: AppColor.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        isLoading = false;
        update();
        return;
      }
      if (departments.isEmpty) {
        Get.snackbar(
          'Error',
          'Departments not loaded. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.errorColor,
          colorText: AppColor.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        isLoading = false;
        update();
        return;
      }
      final positionId = selectedPositionId ?? positions.first.id;
      final departmentId = selectedDepartmentId ?? departments.first.id;
      // جلب companyId من AuthService في كل مرة قبل الإرسال
      String? finalCompanyId = await authService.getCompanyId();
      debugPrint('🔵 Got companyId from AuthService: $finalCompanyId');
      // التأكد من وجود companyId قبل الإرسال
      if (finalCompanyId == null || finalCompanyId.isEmpty) {
        Get.snackbar(
          'Error',
          'Company ID not found. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.errorColor,
          colorText: AppColor.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        isLoading = false;
        statusRequest = StatusRequest.serverFailure;
        update();
        return;
      }
      debugPrint('✅ Sending companyId with request: $finalCompanyId');
      final result = await _teamRepository.createEmployeeWithUser(
        companyId: finalCompanyId,
        employeeCode: employeeCodeController.text.trim(),
        position: positionId, // Use position ID
        department: departmentId, // Use department ID
        hireDate: hireDateController.text.trim(),
        salary: salary,
        status: selectedStatus ?? 'active',
        subRole: subRoleController.text.trim().isNotEmpty
            ? subRoleController.text.trim()
            : null,
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        roleId: selectedRoleId ?? '',
        isActive: true,
      );
      result.fold(
        (error) {
          debugPrint('🔴 Error creating employee: $error');
          String errorMsg = 'Failed to create employee';
          StatusRequest errorStatus = StatusRequest.serverFailure;
          if (error is Map<String, dynamic>) {
            errorStatus =
                error['error'] as StatusRequest? ?? StatusRequest.serverFailure;
            errorMsg =
                error['message']?.toString() ?? 'Failed to create employee';
            debugPrint('🔴 Error message from backend: $errorMsg');
          } else if (error is StatusRequest) {
            errorStatus = error;
            if (error == StatusRequest.serverFailure) {
              errorMsg = 'Server error. Please try again.';
            } else if (error == StatusRequest.offlineFailure) {
              errorMsg = 'No internet connection. Please check your network.';
            } else if (error == StatusRequest.timeoutException) {
              errorMsg = 'Request timed out. Please try again.';
            } else if (error == StatusRequest.serverException) {
              errorMsg = 'An unexpected server error occurred.';
            }
          }
          errorMessage = errorMsg;
          isLoading = false;
          statusRequest = errorStatus;
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
            shouldIconPulse: false,
            duration: const Duration(seconds: 5),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            boxShadows: [
              BoxShadow(
                color: AppColor.errorColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            forwardAnimationCurve: Curves.easeOutBack,
            reverseAnimationCurve: Curves.easeInBack,
          );
        },
        (employee) {
          debugPrint('✅ Employee created successfully: ${employee.username}');
          errorMessage = null;
          isLoading = false;
          statusRequest = StatusRequest.success;
          update();
          try {
            final teamController = Get.find<TeamControllerImp>();
            authService.getCompanyId().then((refreshCompanyId) {
              teamController.refreshTeamMembers(
                companyId: refreshCompanyId,
                status: null,
              );
              debugPrint('✅ Team members list refresh initiated');
            });
          } catch (e) {
            debugPrint('⚠️ Could not refresh team members: $e');
          }
          Get.snackbar(
            'Success',
            'Employee created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.successColor,
            colorText: AppColor.white,
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColor.white,
              size: 28,
            ),
            shouldIconPulse: false,
            duration: const Duration(seconds: 2),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            boxShadows: [
              BoxShadow(
                color: AppColor.successColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            forwardAnimationCurve: Curves.easeOutBack,
            reverseAnimationCurve: Curves.easeInBack,
          );
          Future.delayed(const Duration(milliseconds: 300), () {
            try {
              Get.offNamed(AppRoute.team);
              debugPrint('✅ Navigated to team screen using Get.offNamed()');
            } catch (e) {
              debugPrint('🔴 Error navigating to team screen: $e');
              try {
                Get.back();
                debugPrint('✅ Navigated back using Get.back() as fallback');
              } catch (e2) {
                debugPrint('🔴 All navigation attempts failed: $e2');
                try {
                  Get.until((route) => route.settings.name == AppRoute.team);
                  debugPrint('✅ Navigated using Get.until()');
                } catch (e3) {
                  debugPrint('🔴 Final navigation attempt failed: $e3');
                }
              }
            }
          });
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception creating employee: $e');
      isLoading = false;
      statusRequest = StatusRequest.serverException;
      update();
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        icon: const Icon(Icons.error_outline, color: AppColor.white, size: 28),
        shouldIconPulse: false,
        duration: const Duration(seconds: 5),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        boxShadows: [
          BoxShadow(
            color: AppColor.errorColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
      );
    }
  }
  bool _validateForm() {
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Username',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (!emailController.text.trim().contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (selectedRoleId == null || selectedRoleId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Role',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (employeeCodeController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Employee Code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (selectedPositionId == null || selectedPositionId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Position',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (selectedDepartmentId == null || selectedDepartmentId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Department',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (hireDateController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Hire Date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (salaryController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Salary',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }
  @override
  void resetForm() {
    employeeCodeController.clear();
    hireDateController.clear();
    salaryController.clear();
    subRoleController.clear();
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    selectedRoleId = roles.isNotEmpty
        ? roles.first.id
        : null; // Reset to first role
    selectedPositionId = positions.isNotEmpty
        ? positions.first.id
        : null; // Reset to first position
    selectedDepartmentId = departments.isNotEmpty
        ? departments.first.id
        : null; // Reset to first department
    selectedStatus = 'active';
    authService.getCompanyId().then((companyId) {
      selectedCompanyId = companyId;
      update();
    });
    statusRequest = StatusRequest.none;
    errorMessage = null; // Clear error message
    update();
  }
  @override
  void onClose() {
    employeeCodeController.dispose();
    hireDateController.dispose();
    salaryController.dispose();
    subRoleController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
