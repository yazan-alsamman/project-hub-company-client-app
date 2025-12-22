import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/constant/routes.dart';
import 'projects_controller.dart';
import '../../data/Models/project_model.dart';
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
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  bool isLoadingProject = false;
  String? errorMessage;
  ProjectModel? project;
  @override
  void onInit() {
    super.onInit();
    loadProjectData();
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
        debugPrint('⚠️ Project not found in list, will fetch from API: $e');
      }
      isLoadingProject = false;
      errorMessage = 'Project not found';
      update();
    } catch (e) {
      debugPrint('🔴 Exception loading project: $e');
      isLoadingProject = false;
      errorMessage = 'An error occurred while loading project data.';
      update();
    }
  }
  @override
  void updateProject() async {
    debugPrint('🔵 Updating project...');
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
      );
      result.fold(
        (error) {
          debugPrint('🔴 Error updating project: $error');
          String errorMsg = 'Failed to update project';
          if (error == StatusRequest.serverFailure) {
            errorMsg = 'Server error. Please try again.';
          } else if (error == StatusRequest.offlineFailure) {
            errorMsg = 'No internet connection. Please check your network.';
          } else if (error == StatusRequest.timeoutException) {
            errorMsg = 'Request timed out. Please try again.';
          } else if (error == StatusRequest.serverException) {
            errorMsg = 'An unexpected server error occurred.';
          }
          errorMessage = errorMsg;
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
        (updatedProject) {
          debugPrint('✅ Project updated successfully: ${updatedProject.title}');
          errorMessage = null;
          isLoading = false;
          statusRequest = StatusRequest.success;
          update();
          try {
            final projectsController = Get.find<ProjectsControllerImp>();
            projectsController.refreshProjects();
            debugPrint('✅ Projects list refresh initiated');
          } catch (e) {
            debugPrint('⚠️ Could not refresh projects: $e');
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
      debugPrint('🔴 Exception updating project: $e');
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
    debugPrint('🔵 Deleting project...');
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
          debugPrint('🔴 Error deleting project: $error');
          String errorMsg = 'Failed to delete project';
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
          debugPrint('✅ Project deleted successfully');
          isLoading = false;
          statusRequest = StatusRequest.success;
          update();
          try {
            final projectsController = Get.find<ProjectsControllerImp>();
            projectsController.refreshProjects();
            debugPrint('✅ Projects list refresh initiated');
          } catch (e) {
            debugPrint('⚠️ Could not refresh projects: $e');
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
      debugPrint('🔴 Exception deleting project: $e');
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
  @override
  void onClose() {
    codeController.dispose();
    safeDelayController.dispose();
    super.onClose();
  }
}
