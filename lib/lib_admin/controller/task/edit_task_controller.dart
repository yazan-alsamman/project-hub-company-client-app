import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/constant/routes.dart';
import 'tasks_controller.dart';
import '../../data/Models/task_model.dart';
import '../../data/repository/tasks_repository.dart';
abstract class EditTaskController extends GetxController {
  void updateTask();
  void loadTaskData();
  void deleteTask();
}
class EditTaskControllerImp extends EditTaskController {
  final TasksRepository _tasksRepository = TasksRepository();
  final String taskId;
  EditTaskControllerImp({required this.taskId});
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final TextEditingController minEstimatedHourController =
      TextEditingController();
  final TextEditingController maxEstimatedHourController =
      TextEditingController();
  final TextEditingController targetRoleController = TextEditingController();
  String? selectedTaskStatus;
  String? selectedPriority;
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  bool isLoadingTask = false;
  String? errorMessage;
  TaskModel? task;
  static const List<Map<String, String>> priorityOptions = [
    {'value': 'C', 'label': 'Critical'},
    {'value': 'H', 'label': 'High'},
    {'value': 'MH', 'label': 'Medium-High'},
    {'value': 'M', 'label': 'Medium'},
    {'value': 'LM', 'label': 'Low-Medium'},
    {'value': 'L', 'label': 'Low'},
  ];
  static const List<Map<String, String>> taskStatusOptions = [
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'pending', 'label': 'Pending'},
  ];
  @override
  void onInit() {
    super.onInit();
    loadTaskData();
  }
  @override
  Future<void> loadTaskData() async {
    isLoadingTask = true;
    update();
    try {
      try {
        final tasksController = Get.find<TasksControllerImp>();
        final taskInList = tasksController.allTasks.firstWhere(
          (t) => t.id == taskId,
          orElse: () => throw Exception('Task not found in list'),
        );
        task = taskInList;
        taskNameController.text = task!.title;
        taskDescriptionController.text = task!.taskDescription ?? '';
        minEstimatedHourController.text =
            task!.minEstimatedHour?.toString() ?? '';
        maxEstimatedHourController.text =
            task!.maxEstimatedHour?.toString() ?? '';
        targetRoleController.text = task!.targetRole ?? '';
        final backendStatus = task!.taskStatus?.toLowerCase() ?? 'pending';
        switch (backendStatus) {
          case 'pending':
            selectedTaskStatus = 'pending';
            break;
          case 'in_progress':
            selectedTaskStatus = 'in_progress';
            break;
          case 'completed':
            selectedTaskStatus = 'completed';
            break;
          default:
            selectedTaskStatus = 'pending';
        }
        final backendPriority = task!.taskPriority?.toUpperCase() ?? 'M';
        selectedPriority = backendPriority;
        isLoadingTask = false;
        update();
        return;
      } catch (e) {
        debugPrint('⚠️ Task not found in list, will fetch from API: $e');
      }
      isLoadingTask = false;
      errorMessage = 'Task not found';
      update();
    } catch (e) {
      debugPrint('🔴 Exception loading task: $e');
      isLoadingTask = false;
      errorMessage = 'An error occurred while loading task data.';
      update();
    }
  }
  @override
  void updateTask() async {
    debugPrint('🔵 Updating task...');
    if (!_validateForm()) {
      return;
    }
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    try {
      final taskName = taskNameController.text.trim();
      final minEstimatedHour = int.tryParse(
        minEstimatedHourController.text.trim(),
      );
      final maxEstimatedHour = int.tryParse(
        maxEstimatedHourController.text.trim(),
      );
      final targetRole = targetRoleController.text.trim();
      if (minEstimatedHour == null) {
        Get.snackbar(
          'Error',
          'Please enter a valid minimum estimated hour',
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
      if (maxEstimatedHour == null) {
        Get.snackbar(
          'Error',
          'Please enter a valid maximum estimated hour',
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
      if (selectedTaskStatus == null || selectedTaskStatus!.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select a Task Status',
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
      if (selectedPriority == null || selectedPriority!.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select a Priority',
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
      final result = await _tasksRepository.updateTask(
        taskId: taskId,
        taskStatus: selectedTaskStatus!,
        taskName: taskName.isNotEmpty ? taskName : null,
        taskPriority: selectedPriority,
        minEstimatedHour: minEstimatedHour,
        maxEstimatedHour: maxEstimatedHour,
        targetRole: targetRole.isNotEmpty ? targetRole : null,
      );
      result.fold(
        (errorMsg) {
          debugPrint('🔴 Error updating task: $errorMsg');
          errorMessage = errorMsg;
          isLoading = false;
          statusRequest = StatusRequest.serverFailure;
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
        (updatedTask) {
          debugPrint('✅ Task updated successfully: ${updatedTask.title}');
          errorMessage = null;
          isLoading = false;
          statusRequest = StatusRequest.success;
          update();
          try {
            final tasksController = Get.find<TasksControllerImp>();
            tasksController.refreshTasks();
            debugPrint('✅ Tasks list refresh initiated');
          } catch (e) {
            debugPrint('⚠️ Could not refresh tasks: $e');
          }
          Get.snackbar(
            'Success',
            'Task updated successfully',
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
            Get.offNamed(AppRoute.tasks);
          });
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception updating task: $e');
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
  void deleteTask() async {
    debugPrint('🔵 Deleting task...');
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete ${task?.title ?? 'this task'}? This action cannot be undone.',
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
      final result = await _tasksRepository.deleteTask(taskId);
      result.fold(
        (error) {
          debugPrint('🔴 Error deleting task: $error');
          String errorMsg = 'Failed to delete task';
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
          debugPrint('✅ Task deleted successfully');
          isLoading = false;
          statusRequest = StatusRequest.success;
          update();
          try {
            final tasksController = Get.find<TasksControllerImp>();
            tasksController.refreshTasks();
            debugPrint('✅ Tasks list refresh initiated');
          } catch (e) {
            debugPrint('⚠️ Could not refresh tasks: $e');
          }
          Get.snackbar(
            'Success',
            'Task deleted successfully',
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
            Get.offNamed(AppRoute.tasks);
          });
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception deleting task: $e');
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
  bool _validateForm() {
    if (taskNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Task Name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (minEstimatedHourController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Minimum Estimated Hour',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (maxEstimatedHourController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Maximum Estimated Hour',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (selectedTaskStatus == null || selectedTaskStatus!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Task Status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (selectedPriority == null || selectedPriority!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Priority',
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
    taskNameController.dispose();
    taskDescriptionController.dispose();
    minEstimatedHourController.dispose();
    maxEstimatedHourController.dispose();
    targetRoleController.dispose();
    super.onClose();
  }
}
