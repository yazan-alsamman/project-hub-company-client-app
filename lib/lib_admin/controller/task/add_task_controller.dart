import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/constant/routes.dart';
import '../../data/Models/project_model.dart';
import '../../data/repository/tasks_repository.dart';
import '../../data/repository/projects_repository.dart';
import 'tasks_controller.dart';
import '../project/projects_controller.dart';
abstract class AddTaskController extends GetxController {
  void createTask();
  void resetForm();
  void loadProjects();
}
class AddTaskControllerImp extends AddTaskController {
  final TasksRepository _tasksRepository = TasksRepository();
  final ProjectsRepository _projectsRepository = ProjectsRepository();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController taskNameController;
  late TextEditingController taskDescriptionController;
  late TextEditingController minEstimatedHourController;
  late TextEditingController maxEstimatedHourController;
  late TextEditingController targetRoleController;
  String? selectedProjectId;
  String? selectedPriority;
  String? selectedTaskStatus;
  List<ProjectModel> projects = [];
  bool isLoadingProjects = false;
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
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
    taskNameController = TextEditingController();
    taskDescriptionController = TextEditingController();
    minEstimatedHourController = TextEditingController();
    maxEstimatedHourController = TextEditingController();
    targetRoleController = TextEditingController();
    selectedPriority = 'M'; // Medium
    selectedTaskStatus = 'pending';
    loadProjects();
  }
  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    minEstimatedHourController.dispose();
    maxEstimatedHourController.dispose();
    targetRoleController.dispose();
    super.dispose();
  }
  @override
  Future<void> loadProjects() async {
    isLoadingProjects = true;
    update();
    debugPrint('🔵 Loading projects for task creation...');
    try {
      if (Get.isRegistered<ProjectsControllerImp>()) {
        final projectsController = Get.find<ProjectsControllerImp>();
        if (projectsController.projects.isNotEmpty) {
          projects = projectsController.projects;
          debugPrint(
            '✅ Loaded ${projects.length} projects from ProjectsController',
          );
          isLoadingProjects = false;
          update();
          return;
        }
      }
      final result = await _projectsRepository.getProjects(
        page: 1,
        limit: 100, // Get more projects for dropdown
        companyId: null, // Will use default
      );
      result.fold(
        (error) {
          debugPrint('🔴 Failed to load projects: $error');
          projects = [];
        },
        (loadedProjects) {
          projects = loadedProjects;
          debugPrint('✅ Loaded ${projects.length} projects from API');
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading projects: $e');
      projects = [];
    }
    isLoadingProjects = false;
    update();
  }
  @override
  void resetForm() {
    taskNameController.clear();
    taskDescriptionController.clear();
    minEstimatedHourController.clear();
    maxEstimatedHourController.clear();
    targetRoleController.clear();
    selectedProjectId = null;
    selectedPriority = 'M';
    selectedTaskStatus = 'pending';
    update();
  }
  @override
  void createTask() async {
    if (!_validateForm()) {
      return;
    }
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    debugPrint('🔵 Creating task...');
    debugPrint('Project ID: $selectedProjectId');
    debugPrint('Task Name: ${taskNameController.text}');
    debugPrint('Priority: $selectedPriority');
    debugPrint('Status: $selectedTaskStatus');
    final result = await _tasksRepository.createTask(
      projectId: selectedProjectId!,
      taskName: taskNameController.text.trim(),
      taskDescription: taskDescriptionController.text.trim(),
      taskPriority: selectedPriority ?? 'M',
      taskStatus: selectedTaskStatus ?? 'pending',
      minEstimatedHour: int.tryParse(minEstimatedHourController.text) ?? 0,
      maxEstimatedHour: int.tryParse(maxEstimatedHourController.text) ?? 0,
      targetRole: targetRoleController.text.trim(),
    );
    isLoading = false;
    update();
    result.fold(
      (error) {
        statusRequest = error;
        String errorMessage = 'Failed to create task';
        if (error == StatusRequest.serverFailure) {
          errorMessage = 'Server error. Please try again.';
        } else if (error == StatusRequest.offlineFailure) {
          errorMessage =
              'No internet connection. Please check your connection.';
        }
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: AppColor.primaryColor,
          colorText: AppColor.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      },
      (task) {
        debugPrint('✅ Task created successfully, navigating back...');
        statusRequest = StatusRequest.success;
        resetForm();
        debugPrint('🔵 Navigating back to Tasks page...');
        Get.offNamed(AppRoute.tasks);
        Future.delayed(const Duration(milliseconds: 500), () {
          debugPrint('🔵 Refreshing tasks list...');
          if (Get.isRegistered<TasksControllerImp>()) {
            Get.find<TasksControllerImp>().refreshTasks();
          }
          Get.snackbar(
            'Success',
            'Task created successfully!',
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
    if (selectedProjectId == null || selectedProjectId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a project',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (taskNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter task name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (taskDescriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter task description',
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
        'Please enter minimum estimated hours',
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
        'Please enter maximum estimated hours',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    final minHours = int.tryParse(minEstimatedHourController.text);
    final maxHours = int.tryParse(maxEstimatedHourController.text);
    if (minHours == null || minHours < 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid minimum estimated hours',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (maxHours == null || maxHours < 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid maximum estimated hours',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (maxHours < minHours) {
      Get.snackbar(
        'Error',
        'Maximum hours must be greater than or equal to minimum hours',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (targetRoleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter target role (e.g., backend, frontend, admin)',
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
}
