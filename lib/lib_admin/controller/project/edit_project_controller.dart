import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/constant/routes.dart';
import 'projects_controller.dart';
import '../../data/Models/project_model.dart';
import '../../data/Models/client_model.dart';
import '../../data/repository/projects_repository.dart';
abstract class EditProjectController extends GetxController {
  void updateProject();
  void loadProjectData();
  void deleteProject();
}
class EditProjectControllerImp extends EditProjectController {
  final ProjectsRepository _projectsRepository = ProjectsRepository();
  final String projectId;
  EditProjectControllerImp({required this.projectId});
  final TextEditingController codeController = TextEditingController();
  final TextEditingController safeDelayController = TextEditingController();
  String? selectedStatus;
  String? selectedClientId;
  List<ClientModel> clients = [];
  bool isLoadingClients = false;
  StatusRequest clientsStatusRequest = StatusRequest.none;
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  bool isLoadingProject = false;
  String? errorMessage;
  ProjectModel? project;
  @override
  void onInit() {
    super.onInit();
    loadProjectData();
    loadClients();
  }
  @override
  Future<void> loadProjectData() async {
    isLoadingProject = true;
    update();
    try {
      try {
        final projectsController = Get.find<ProjectsControllerImp>();
        final projectInList = projectsController.projects.firstWhere(
          (p) => p.id == projectId,
          orElse: () => throw Exception('Project not found in list'),
        );
        project = projectInList;
        codeController.text = project!.code ?? '';
        safeDelayController.text = project!.safeDelay?.toString() ?? '7';
        // Extract clientId from Map if it exists
        if (project!.clientId != null) {
          final clientIdValue = project!.clientId;
          if (clientIdValue is Map<String, dynamic>) {
            selectedClientId = clientIdValue['_id']?.toString() ?? 
                              clientIdValue['id']?.toString() ?? 
                              null;
          } else if (clientIdValue is String) {
            selectedClientId = clientIdValue;
          }
        }
        final backendStatus = project!.status.toLowerCase();
        switch (backendStatus) {
          case 'pending':
            selectedStatus = 'pending';
            break;
          case 'in_progress':
            selectedStatus = 'in_progress';
            break;
          case 'on_hold':
            selectedStatus = 'on_hold';
            break;
          case 'completed':
            selectedStatus = 'completed';
            break;
          case 'cancelled':
            selectedStatus = 'cancelled';
            break;
          default:
            selectedStatus = 'pending';
        }
        isLoadingProject = false;
        update();
        return;
      } catch (e) {
      }
      isLoadingProject = false;
      errorMessage = 'Project not found';
      update();
    } catch (e) {
      isLoadingProject = false;
      errorMessage = 'An error occurred while loading project data.';
      update();
    }
  }
  @override
  void updateProject() async {
    if (!_validateForm()) {
      return;
    }
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    try {
      final code = codeController.text.trim();
      final safeDelay = int.tryParse(safeDelayController.text.trim());
      if (safeDelay == null) {
        Get.snackbar(
          'Error',
          'Please enter a valid safe delay',
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
        isLoading = false;
        update();
        return;
      }
      String backendStatus = _mapStatusToBackend(selectedStatus!);
      final result = await _projectsRepository.updateProject(
        projectId: projectId,
        status: backendStatus,
        code: code,
        safeDelay: safeDelay,
        clientId: selectedClientId,
      );
      result.fold(
        (error) {
          String errorMsg = 'Failed to update project';
          StatusRequest errorStatus = StatusRequest.serverFailure;
          if (error is Map<String, dynamic>) {
            errorStatus =
                error['error'] as StatusRequest? ?? StatusRequest.serverFailure;
            errorMsg =
                error['message']?.toString() ?? 'Failed to update project';
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
          } else if (error is String) {
            errorMsg = error;
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
        (updatedProject) {
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
            'Project updated successfully',
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
  @override
  void deleteProject() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete ${project?.title ?? 'this project'}? This action cannot be undone.',
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
      final result = await _projectsRepository.deleteProject(projectId);
      result.fold(
        (error) {
          String errorMsg = 'Failed to delete project';
          StatusRequest errorStatus = StatusRequest.serverFailure;
          if (error is Map<String, dynamic>) {
            errorStatus =
                error['error'] as StatusRequest? ?? StatusRequest.serverFailure;
            errorMsg =
                error['message']?.toString() ?? 'Failed to delete project';
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
          } else if (error is String) {
            errorMsg = error;
          }
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
        (success) {
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
            'Project deleted successfully',
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
      case 'in_progress':
        return 'in_progress';
      case 'on_hold':
        return 'on_hold';
      case 'cancelled':
        return 'cancelled';
      case 'completed':
        return 'completed';
      default:
        return 'pending';
    }
  }
  bool _validateForm() {
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
    if (safeDelayController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Safe Delay',
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

  Future<void> loadClients() async {
    isLoadingClients = true;
    clientsStatusRequest = StatusRequest.loading;
    update();
    try {
      List<ClientModel> allClients = [];
      int currentPage = 1;
      const int maxLimit = 100;
      bool hasMore = true;

      while (hasMore) {
        final result = await _projectsRepository.getClients(
          page: currentPage,
          limit: maxLimit,
        );

        result.fold(
          (error) {
            if (allClients.isEmpty) {
              clientsStatusRequest = error;
              isLoadingClients = false;
              hasMore = false;
            } else {
              hasMore = false;
            }
          },
          (clientsList) {
            if (clientsList.isEmpty) {
              hasMore = false;
            } else {
              allClients.addAll(clientsList);
              hasMore = clientsList.length >= maxLimit;
              currentPage++;
            }
          },
        );
      }

      clients = allClients;
      clientsStatusRequest = StatusRequest.success;
      isLoadingClients = false;
      update();
    } catch (e) {
      clientsStatusRequest = StatusRequest.serverException;
      isLoadingClients = false;
      update();
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    safeDelayController.dispose();
    super.onClose();
  }
}
