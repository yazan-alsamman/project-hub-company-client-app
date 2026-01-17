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
  String? selectedTaskId;
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
    final result = await _tasksRepository.getTasks(page: 1, limit: 100);
    isLoadingTasks = false;
    result.fold((error) {}, (loadedTasks) {
      tasks = loadedTasks;
      update();
    });
  }

  @override
  Future<void> loadEmployees() async {
    isLoadingEmployees = true;
    update();
    final companyId = await _authService.getCompanyId();
    final result = await _teamRepository.getEmployees(
      page: 1,
      limit: 100,
      companyId: companyId,
      status: null,
    );
    isLoadingEmployees = false;
    result.fold((error) {}, (loadedEmployees) {
      employees = loadedEmployees;
      update();
    });
  }

  void selectTask(String? taskId) {
    selectedTaskId = taskId;
    update();
  }

  bool isTaskSelected(String taskId) {
    return selectedTaskId == taskId;
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
    final firstDateValue = startDate ?? DateTime.now();
    final lastDateValue = DateTime.now().add(const Duration(days: 365));
    final initialDateValue =
        endDate ??
        (firstDateValue.isAfter(DateTime.now())
            ? firstDateValue
            : DateTime.now().add(const Duration(days: 1)));

    // Ensure initialDate is not before firstDate
    final safeInitialDate = initialDateValue.isBefore(firstDateValue)
        ? firstDateValue
        : (initialDateValue.isAfter(lastDateValue)
              ? lastDateValue
              : initialDateValue);

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: firstDateValue,
      lastDate: lastDateValue,
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
    final startDateTime = startDate != null
        ? DateTime(startDate!.year, startDate!.month, startDate!.day, 9, 0, 0)
        : DateTime.now();
    final endDateTime = endDate != null
        ? DateTime(endDate!.year, endDate!.month, endDate!.day, 17, 0, 0)
        : DateTime.now().add(const Duration(hours: 8));
    final estimatedHours = int.tryParse(estimatedHoursController.text) ?? 8;
    final notes = notesController.text.trim().isEmpty
        ? null
        : notesController.text.trim();
    final result = await _assignmentsRepository.createAssignment(
      taskId: selectedTaskId!,
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

  bool _validateForm() {
    if (selectedTaskId == null || selectedTaskId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a task',
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
    selectedTaskId = null;
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
