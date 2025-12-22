import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'team_controller.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/constant/routes.dart';
import '../../data/Models/employee_model.dart';
import '../../data/Models/position_model.dart';
import '../../data/Models/department_model.dart';
import '../../data/repository/team_repository.dart';
abstract class EditEmployeeController extends GetxController {
  void updateEmployee();
  void loadEmployeeData();
  void deleteEmployee();
}
class EditEmployeeControllerImp extends EditEmployeeController {
  final TeamRepository _teamRepository = TeamRepository();
  final String employeeId;
  EditEmployeeControllerImp({required this.employeeId});
  final TextEditingController salaryController = TextEditingController();
  String? selectedPositionId;
  String? selectedStatus;
  String? selectedDepartmentId;
  String? departmentId; // Store original department ID
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  bool isLoadingEmployee = false;
  bool isLoadingPositions = false;
  bool isLoadingDepartments = false;
  String? errorMessage;
  EmployeeModel? employee;
  List<PositionModel> positions = [];
  List<DepartmentModel> departments = [];
  @override
  void onInit() {
    super.onInit();
    loadEmployeeData();
    loadPositions();
    loadDepartments();
  }
  @override
  Future<void> loadEmployeeData() async {
    isLoadingEmployee = true;
    update();
    try {
      final result = await _teamRepository.getEmployeeById(employeeId);
      result.fold(
        (error) {
          debugPrint('🔴 Error loading employee: $error');
          isLoadingEmployee = false;
          errorMessage = 'Failed to load employee data. Please try again.';
          update();
        },
        (employeeData) {
          debugPrint('✅ Loaded employee: ${employeeData.username}');
          employee = employeeData;
          salaryController.text = employeeData.salary?.toString() ?? '';
          if (employeeData.positionObj != null) {
            selectedPositionId = employeeData.positionObj!['_id']?.toString();
          } else if (employeeData.position != null) {
            final position = positions.firstWhere(
              (p) => p.name == employeeData.position,
              orElse: () => positions.isNotEmpty
                  ? positions.first
                  : PositionModel(
                      id: '',
                      name: '',
                      description: '',
                      isActive: true,
                    ),
            );
            selectedPositionId = position.id;
          }
          if (employeeData.departmentObj != null) {
            selectedDepartmentId = employeeData.departmentObj!['_id']
                ?.toString();
            departmentId = selectedDepartmentId;
            debugPrint('✅ Set department ID from departmentObj: $departmentId');
          } else if (employeeData.department != null) {
            debugPrint(
              '⚠️ Department ID not found, will try to match by name: ${employeeData.department}',
            );
          }
          final backendStatus = employeeData.status?.toLowerCase() ?? 'active';
          switch (backendStatus) {
            case 'active':
              selectedStatus = 'active';
              break;
            case 'on_leave':
            case 'on leave':
              selectedStatus = 'on_leave';
              break;
            case 'terminated':
              selectedStatus = 'terminated';
              break;
            default:
              selectedStatus = 'active';
          }
          isLoadingEmployee = false;
          update();
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading employee: $e');
      isLoadingEmployee = false;
      errorMessage = 'An error occurred while loading employee data.';
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
          if (employee != null && selectedPositionId == null) {
            if (employee!.positionObj != null) {
              selectedPositionId = employee!.positionObj!['_id']?.toString();
            }
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
          if (employee != null &&
              (selectedDepartmentId == null || departmentId == null)) {
            if (employee!.departmentObj != null) {
              selectedDepartmentId = employee!.departmentObj!['_id']
                  ?.toString();
              departmentId = selectedDepartmentId;
              debugPrint(
                '✅ Set department ID after loading departments: $departmentId',
              );
            } else if (employee!.department != null && departments.isNotEmpty) {
              try {
                final department = departments.firstWhere(
                  (d) =>
                      d.name.toLowerCase() ==
                      employee!.department!.toLowerCase(),
                );
                selectedDepartmentId = department.id;
                departmentId = department.id;
                debugPrint(
                  '✅ Matched department by name: ${department.name} (ID: $departmentId)',
                );
              } catch (e) {
                debugPrint(
                  '⚠️ Could not match department by name: ${employee!.department}',
                );
                if (departments.isNotEmpty) {
                  departmentId = departments.first.id;
                  debugPrint(
                    '⚠️ Using first department as fallback: $departmentId',
                  );
                }
              }
            }
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
  void updateEmployee() async {
    debugPrint('🔵 Updating employee...');
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
        isLoading = false;
        update();
        return;
      }
      final positionId = selectedPositionId ?? positions.first.id;
      final finalDepartmentId =
          selectedDepartmentId ?? departmentId ?? departments.first.id;
      String backendStatus = _mapStatusToBackend(selectedStatus ?? 'active');
      final currentEmployee = employee;
      if (currentEmployee == null) {
        Get.snackbar(
          'Error',
          'Employee data not loaded',
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
      final subRoleValue = currentEmployee.subRole;
      if (subRoleValue == null || subRoleValue.isEmpty) {
        Get.snackbar(
          'Error',
          'Sub Role is required but not found in employee data',
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
      final subRole = subRoleValue;
      final result = await _teamRepository.updateEmployee(
        employeeId: employeeId,
        position: positionId,
        salary: salary,
        status: backendStatus,
        subRole: subRole,
        department: finalDepartmentId,
      );
      result.fold(
        (error) {
          debugPrint('🔴 Error updating employee: $error');
          String errorMsg = 'Failed to update employee';
          StatusRequest errorStatus = StatusRequest.serverFailure;
          if (error is Map<String, dynamic>) {
            errorStatus =
                error['error'] as StatusRequest? ?? StatusRequest.serverFailure;
            errorMsg =
                error['message']?.toString() ?? 'Failed to update employee';
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
            duration: const Duration(seconds: 5),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
        },
        (updatedEmployee) {
          debugPrint(
            '✅ Employee updated successfully: ${updatedEmployee.username}',
          );
          errorMessage = null;
          isLoading = false;
          statusRequest = StatusRequest.success;
          update();
          try {
            final teamController = Get.find<TeamControllerImp>();
            teamController.refreshTeamMembers();
            debugPrint('✅ Team members list refresh initiated');
          } catch (e) {
            debugPrint('⚠️ Could not refresh team members: $e');
          }
          Get.snackbar(
            'Success',
            'Employee updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.successColor,
            colorText: AppColor.white,
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColor.white,
              size: 28,
            ),
            duration: const Duration(seconds: 2),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.offNamed(AppRoute.team);
          });
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception updating employee: $e');
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
        duration: const Duration(seconds: 5),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }
  @override
  void deleteEmployee() async {
    debugPrint('🔵 Deleting employee...');
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${employee?.username ?? 'this employee'}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColor.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColor.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) {
      return;
    }
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    try {
      final result = await _teamRepository.deleteEmployee(employeeId);
      result.fold(
        (error) {
          debugPrint('🔴 Error deleting employee: $error');
          String errorMsg = 'Failed to delete employee';
          if (error == StatusRequest.serverFailure) {
            errorMsg = 'Server error. Please try again.';
          } else if (error == StatusRequest.offlineFailure) {
            errorMsg = 'No internet connection. Please check your network.';
          } else if (error == StatusRequest.timeoutException) {
            errorMsg = 'Request timed out. Please try again.';
          } else if (error == StatusRequest.serverException) {
            errorMsg = 'An unexpected server error occurred.';
          }
          isLoading = false;
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
        (success) {
          debugPrint('✅ Employee deleted successfully');
          isLoading = false;
          statusRequest = StatusRequest.success;
          update();
          try {
            final teamController = Get.find<TeamControllerImp>();
            teamController.refreshTeamMembers();
            debugPrint('✅ Team members list refresh initiated');
          } catch (e) {
            debugPrint('⚠️ Could not refresh team members: $e');
          }
          Get.snackbar(
            'Success',
            'Employee deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.successColor,
            colorText: AppColor.white,
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColor.white,
              size: 28,
            ),
            duration: const Duration(seconds: 2),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.offNamed(AppRoute.team);
          });
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception deleting employee: $e');
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
        duration: const Duration(seconds: 5),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }
  String _mapStatusToBackend(String status) {
    switch (status.toLowerCase()) {
      case 'on_leave':
      case 'on leave':
        return 'on_leave';
      case 'terminated':
        return 'terminated';
      default:
        return 'active';
    }
  }
  bool _validateForm() {
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
    if (selectedStatus == null || selectedStatus!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Status',
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
  void onClose() {
    salaryController.dispose();
    super.onClose();
  }
}
