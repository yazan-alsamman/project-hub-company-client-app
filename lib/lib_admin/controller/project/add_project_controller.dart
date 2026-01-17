import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/constant/routes.dart';
import '../../core/services/auth_service.dart';
import 'projects_controller.dart';
import '../../data/Models/client_model.dart';
import '../../data/repository/projects_repository.dart';
abstract class AddProjectController extends GetxController {
  void createProject();
  void resetForm();
}
class AddProjectControllerImp extends AddProjectController {
  final ProjectsRepository _projectsRepository = ProjectsRepository();
  final AuthService _authService = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController estimatedEndDateController =
      TextEditingController();
  final TextEditingController safeDelayController = TextEditingController();
  String? selectedClientId;
  String? selectedStatus = 'pending';
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  bool isLoadingClients = false;
  String? errorMessage;
  List<ClientModel> clients = [];
  @override
  void onInit() {
    super.onInit();
    loadClients();
    safeDelayController.text = '7';
  }
  Future<void> loadClients() async {
    isLoadingClients = true;
    update();
    try {
      final result = await _projectsRepository.getClients(page: 1, limit: 10);
      result.fold(
        (error) {
          isLoadingClients = false;
          errorMessage = 'Failed to load clients. Please try again.';
          update();
        },
        (clientsList) {
          clients = clientsList;
          if (clients.isNotEmpty && selectedClientId == null) {
            selectedClientId = clients.first.id;
          }
          isLoadingClients = false;
          update();
        },
      );
    } catch (e, stackTrace) {
      isLoadingClients = false;
      errorMessage =
          'An error occurred while loading clients. Please try again.';
      update();
    }
  }
  @override
  void createProject() async {
    if (!_validateForm()) {
      return;
    }
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    try {
      final finalCompanyId = await _authService.getCompanyId();
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
      final safeDelay = int.tryParse(safeDelayController.text.trim()) ?? 7;
      String formattedStartDate = startDateController.text.trim();
      if (!formattedStartDate.contains('T')) {
        formattedStartDate = '${formattedStartDate}T00:00:00.000Z';
      }
      String formattedEstimatedEndDate = estimatedEndDateController.text.trim();
      if (!formattedEstimatedEndDate.contains('T')) {
        formattedEstimatedEndDate =
            '${formattedEstimatedEndDate}T00:00:00.000Z';
      }
      String backendStatus = _mapStatusToBackend(selectedStatus ?? 'pending');
      final result = await _projectsRepository.createProject(
        companyId: finalCompanyId,
        clientId: selectedClientId ?? '',
        name: nameController.text.trim(),
        code: codeController.text.trim(),
        status: backendStatus,
        startAt: formattedStartDate,
        estimatedEndAt: formattedEstimatedEndDate,
        safeDelay: safeDelay,
      );
      result.fold(
        (error) {
          String errorMsg = 'Failed to create project';
          StatusRequest errorStatus = StatusRequest.serverFailure;
          if (error is Map<String, dynamic>) {
            errorStatus =
                error['error'] as StatusRequest? ?? StatusRequest.serverFailure;
            errorMsg =
                error['message']?.toString() ?? 'Failed to create project';
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
        (project) {
          errorMessage = null;
          isLoading = false;
          statusRequest = StatusRequest.success;
          update();
          try {
            final projectsController = Get.find<ProjectsControllerImp>();
            projectsController.refreshProjects();
          } catch (e) {
          }
          Get.snackbar(
            'Success',
            'Project created successfully',
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
            Get.offNamed(AppRoute.projects);
          });
        },
      );
    } catch (e) {
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
      case 'in progress':
        return 'in_progress';
      case 'on hold':
        return 'on_hold';
      case 'canceled':
        return 'cancelled';
      default:
        return status.toLowerCase();
    }
  }
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Project Name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (codeController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Project Code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (selectedClientId == null || selectedClientId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Client',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (startDateController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Start Date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (estimatedEndDateController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Estimated End Date',
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
  void resetForm() {
    nameController.clear();
    codeController.clear();
    startDateController.clear();
    estimatedEndDateController.clear();
    safeDelayController.text = '7';
    selectedClientId = clients.isNotEmpty ? clients.first.id : null;
    selectedStatus = 'pending';
    statusRequest = StatusRequest.none;
    errorMessage = null;
    update();
  }
  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    startDateController.dispose();
    estimatedEndDateController.dispose();
    safeDelayController.dispose();
    super.onClose();
  }
}
