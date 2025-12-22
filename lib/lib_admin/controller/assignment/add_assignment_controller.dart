import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/task_model.dart';
import '../../data/Models/employee_model.dart';
import '../../data/repository/assignments_repository.dart';
import '../../data/repository/tasks_repository.dart';
import '../../data/repository/team_repository.dart';
import 'assignments_controller.dart';
abstract class AddAssignmentController extends GetxController {
  void assignTasks();
  void resetForm();
  void loadTasks();
  void loadEmployees();
}
class AddAssignmentControllerImp extends AddAssignmentController {
  final AssignmentsRepository _assignmentsRepository = AssignmentsRepository();
  final TasksRepository _tasksRepository = TasksRepository();
  final TeamRepository _teamRepository = TeamRepository();
  final AuthService _authService = AuthService();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController estimatedHoursController;
  late TextEditingController notesController;
  List<String> selectedTaskIds = [];
  String? selectedEmployeeId;
  DateTime? startDate;
  DateTime? endDate;
  List<TaskModel> tasks = [];
  List<EmployeeModel> employees = [];
  bool isLoadingTasks = false;
  bool isLoadingEmployees = false;
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  String? errorMessage;
  List<String> errorDetails = [];
  @override
  void onInit() {
    super.onInit();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    estimatedHoursController = TextEditingController();
    notesController = TextEditingController();
    loadTasks();
    loadEmployees();
  }
  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    estimatedHoursController.dispose();
    notesController.dispose();
    super.dispose();
  }
  @override
  Future<void> loadTasks() async {
    isLoadingTasks = true;
    update();
    debugPrint('🔵 Loading tasks for assignment...');
    final result = await _tasksRepository.getTasks(
      page: 1,
      limit: 100, // Get all tasks for dropdown
    );
    isLoadingTasks = false;
    result.fold(
      (error) {
        debugPrint('🔴 Error loading tasks: $error');
      },
      (loadedTasks) {
        debugPrint('✅ Loaded ${loadedTasks.length} tasks');
        tasks = loadedTasks;
        update();
      },
    );
  }
  @override
  Future<void> loadEmployees() async {
    isLoadingEmployees = true;
    update();
    debugPrint('🔵 Loading employees for assignment...');
    final companyId = await _authService.getCompanyId();
    debugPrint('🔵 Using companyId from AuthService: $companyId');
    final result = await _teamRepository.getEmployees(
      page: 1,
      limit: 100, // Get all employees for dropdown
      companyId: companyId,
      status: null, // Get all employees
    );
    isLoadingEmployees = false;
    result.fold(
      (error) {
        debugPrint('🔴 Error loading employees: $error');
      },
      (loadedEmployees) {
        debugPrint('✅ Loaded ${loadedEmployees.length} employees');
        employees = loadedEmployees;
        update();
      },
    );
  }
  void toggleTaskSelection(String taskId) {
    if (selectedTaskIds.contains(taskId)) {
      selectedTaskIds.remove(taskId);
    } else {
      selectedTaskIds.add(taskId);
    }
    update();
  }
  bool isTaskSelected(String taskId) {
    return selectedTaskIds.contains(taskId);
  }
  void selectEmployee(String? employeeId) {
    selectedEmployeeId = employeeId;
    update();
  }
  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      startDate = picked;
      startDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      update();
    }
  }
  Future<void> selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          endDate ?? (startDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      endDate = picked;
      endDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      update();
    }
  }
  @override
  Future<void> assignTasks() async {
    if (!formState.currentState!.validate()) {
      return;
    }
    if (!_validateForm()) {
      return;
    }
    errorMessage = null;
    errorDetails.clear();
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    debugPrint('🔵 Creating assignments...');
    debugPrint('Selected Tasks: ${selectedTaskIds.length}');
    debugPrint('Selected Employee: $selectedEmployeeId');
    final startDateTime = startDate != null
        ? DateTime(
            startDate!.year,
            startDate!.month,
            startDate!.day,
            9, // 9 AM
            0,
            0,
          )
        : DateTime.now();
    final endDateTime = endDate != null
        ? DateTime(
            endDate!.year,
            endDate!.month,
            endDate!.day,
            17, // 5 PM
            0,
            0,
          )
        : DateTime.now().add(const Duration(hours: 8));
    final estimatedHours = int.tryParse(estimatedHoursController.text) ?? 8;
    final notes = notesController.text.trim().isEmpty
        ? null
        : notesController.text.trim();
    if (selectedTaskIds.length > 1) {
      final assignmentsList = selectedTaskIds.map((taskId) {
        return {
          'taskId': taskId,
          'employeeId': selectedEmployeeId!,
          'startDate': startDateTime.toUtc().toIso8601String(),
          'endDate': endDateTime.toUtc().toIso8601String(),
          'estimatedHours': estimatedHours,
          if (notes != null) 'notes': notes,
        };
      }).toList();
      final bulkResult = await _assignmentsRepository.createBulkAssignments(
        assignments: assignmentsList,
      );
      isLoading = false;
      bulkResult.fold(
        (error) {
          if (error is Map<String, dynamic>) {
            final message = error['message'];
            if (message != null) {
              errorMessage = message.toString();
            } else {
              errorMessage = 'Failed to create assignments. Please try again.';
            }
            final errorStatus = error['error'];
            statusRequest = errorStatus is StatusRequest
                ? errorStatus
                : StatusRequest.serverFailure;
          } else if (error is StatusRequest) {
            statusRequest = error;
            errorMessage = 'Failed to create assignments. Please try again.';
          } else {
            statusRequest = StatusRequest.serverFailure;
            errorMessage = 'Failed to create assignments. Please try again.';
          }
          update();
        },
        (response) {
          final successCount = response['successCount'] as int? ?? 0;
          final failureCount = response['failureCount'] as int? ?? 0;
          final results = response['results'] as Map<String, dynamic>? ?? {};
          final failed = results['failed'] as List<dynamic>? ?? [];
          errorDetails.clear();
          for (var failedItem in failed) {
            if (failedItem is Map<String, dynamic>) {
              final taskId = failedItem['taskId']?.toString() ?? 'Unknown';
              final message =
                  failedItem['message']?.toString() ?? 'Unknown error';
              errorDetails.add('Task $taskId: $message');
            }
          }
          if (successCount > 0) {
            statusRequest = StatusRequest.success;
            resetForm();
            Get.back();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (Get.isRegistered<AssignmentsControllerImp>()) {
                Get.find<AssignmentsControllerImp>().refreshAssignments();
              }
              Get.snackbar(
                'Success',
                failureCount > 0
                    ? '$successCount task(s) assigned successfully. $failureCount failed.'
                    : '$successCount task(s) assigned successfully!',
                backgroundColor: AppColor.successColor,
                colorText: AppColor.white,
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
              );
            });
          } else {
            statusRequest = StatusRequest.serverFailure;
            errorMessage = failureCount > 0
                ? 'All assignments failed. Check error details below.'
                : 'Failed to create assignments. Please try again.';
            update();
          }
        },
      );
    } else {
      final result = await _assignmentsRepository.createAssignment(
        taskId: selectedTaskIds.first,
        employeeId: selectedEmployeeId!,
        startDate: startDateTime.toUtc().toIso8601String(),
        endDate: endDateTime.toUtc().toIso8601String(),
        estimatedHours: estimatedHours,
        notes: notes,
      );
      isLoading = false;
      result.fold(
        (error) {
          if (error is Map<String, dynamic>) {
            final message = error['message'];
            if (message != null) {
              errorMessage = message.toString();
            } else {
              errorMessage = 'Failed to assign task. Please try again.';
            }
            final errorStatus = error['error'];
            statusRequest = errorStatus is StatusRequest
                ? errorStatus
                : StatusRequest.serverFailure;
          } else if (error is StatusRequest) {
            statusRequest = error;
            errorMessage = 'Failed to assign task. Please try again.';
          } else {
            statusRequest = StatusRequest.serverFailure;
            errorMessage = 'Failed to assign task. Please try again.';
          }
          update();
        },
        (assignment) {
          statusRequest = StatusRequest.success;
          resetForm();
          Get.back();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.isRegistered<AssignmentsControllerImp>()) {
              Get.find<AssignmentsControllerImp>().refreshAssignments();
            }
            Get.snackbar(
              'Success',
              'Task assigned successfully!',
              backgroundColor: AppColor.successColor,
              colorText: AppColor.white,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
            );
          });
        },
      );
    }
  }
  bool _validateForm() {
    if (selectedTaskIds.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one task',
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (selectedEmployeeId == null || selectedEmployeeId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select an employee',
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (startDate == null) {
      Get.snackbar(
        'Error',
        'Please select a start date',
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (endDate == null) {
      Get.snackbar(
        'Error',
        'Please select an end date',
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (endDate!.isBefore(startDate!)) {
      Get.snackbar(
        'Error',
        'End date must be after start date',
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (estimatedHoursController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter estimated hours',
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }
  @override
  void resetForm() {
    selectedTaskIds.clear();
    selectedEmployeeId = null;
    startDate = null;
    endDate = null;
    startDateController.clear();
    endDateController.clear();
    estimatedHoursController.clear();
    notesController.clear();
    errorMessage = null;
    errorDetails.clear();
    statusRequest = StatusRequest.none;
    update();
  }
  void clearErrors() {
    errorMessage = null;
    errorDetails.clear();
    update();
  }
}
