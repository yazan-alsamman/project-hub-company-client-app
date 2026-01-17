import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../data/Models/task_model.dart';
import '../../data/repository/tasks_repository.dart';
import 'tasks_controller.dart';

class RequestDelayController extends GetxController {
  final TasksRepository _tasksRepository = TasksRepository();
  final String taskId;
  final TaskModel task;

  RequestDelayController({
    required this.taskId,
    required this.task,
  });

  final TextEditingController reasonController = TextEditingController();
  DateTime? selectedDate;
  StatusRequest _statusRequest = StatusRequest.none;
  bool _isLoading = false;
  String? _errorMessage;

  StatusRequest get statusRequest => _statusRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColor.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate = picked;
      update();
    }
  }

  Future<void> requestDelay() async {
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a reason for the delay',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        icon: const Icon(
          Icons.error_outline,
          color: AppColor.white,
          size: 28,
        ),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (selectedDate == null) {
      Get.snackbar(
        'Error',
        'Please select a new due date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        icon: const Icon(
          Icons.error_outline,
          color: AppColor.white,
          size: 28,
        ),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    _isLoading = true;
    _statusRequest = StatusRequest.loading;
    _errorMessage = null;
    update();

    try {
      final formattedDate = selectedDate!.toUtc().toIso8601String();

      final result = await _tasksRepository.requestTaskDelay(
        taskId: taskId,
        newDueDate: formattedDate,
        reason: reason,
      );

      result.fold(
        (error) {
          _isLoading = false;
          
          // Extract error message from the error object
          String errorMsg = 'Failed to request task delay';
          StatusRequest errorStatus = StatusRequest.serverFailure;
          
          if (error is Map<String, dynamic>) {
            // If error is a Map, extract the message and status
            errorMsg = error['message']?.toString() ?? 
                      error['error']?.toString() ?? 
                      'Failed to request task delay';
            errorStatus = error['error'] is StatusRequest 
                ? error['error'] as StatusRequest 
                : StatusRequest.serverFailure;
          } else if (error is StatusRequest) {
            // If error is directly a StatusRequest, use default messages
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
          } else {
            // Fallback for other error types
            errorMsg = error.toString();
          }
          
          _statusRequest = errorStatus;
          _errorMessage = errorMsg;
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
          _isLoading = false;
          _statusRequest = StatusRequest.success;
          update();
          Get.snackbar(
            'Success',
            'Task delay requested successfully',
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
          try {
            if (Get.isRegistered<TasksControllerImp>()) {
              Get.find<TasksControllerImp>().refreshTasks();
            }
          } catch (e) {
          }
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.back();
          });
        },
      );
    } catch (e) {
      _isLoading = false;
      _statusRequest = StatusRequest.serverException;
      _errorMessage = 'An unexpected error occurred';
      update();
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
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
    }
  }
}

