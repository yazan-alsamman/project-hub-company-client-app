import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/services/auth_service.dart';
import '../common/filter_button_controller.dart';
import '../../data/Models/task_model.dart';
import '../../data/Models/project_model.dart';
import '../../data/repository/tasks_repository.dart';
import '../../data/repository/projects_repository.dart';
abstract class TasksController extends GetxController {
  List<TaskModel> get allTasks;
  StatusRequest get statusRequest;
  bool get isLoading;
  String? get selectedProjectId;
  List<ProjectModel> get projects;
  bool get isLoadingProjects;
  Future<void> loadTasks({bool refresh = false});
  Future<void> refreshTasks();
  Future<void> loadProjects();
  void selectProject(String? projectId);
  void viewAllTasks();
  List<TaskModel> get filteredTasks;
}
class TasksControllerImp extends TasksController {
  final TasksRepository _tasksRepository = TasksRepository();
  final ProjectsRepository _projectsRepository = ProjectsRepository();
  List<TaskModel> _allTasks = [];
  StatusRequest _statusRequest = StatusRequest.none;
  bool _isLoading = false;
  String? _selectedProjectId;
  List<ProjectModel> _projects = [];
  bool _isLoadingProjects = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;
  @override
  List<TaskModel> get allTasks => _allTasks;
  @override
  StatusRequest get statusRequest => _statusRequest;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get selectedProjectId => _selectedProjectId;
  @override
  List<ProjectModel> get projects => _projects;
  @override
  bool get isLoadingProjects => _isLoadingProjects;
  @override
  void onInit() {
    super.onInit();
    loadProjects();
    loadTasks();
  }
  @override
  Future<void> loadTasks({bool refresh = false}) async {
    if (_isLoading && !refresh) {
      return;
    }
    _isLoading = true;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _allTasks.clear();
      _statusRequest = StatusRequest.loading;
    } else if (_allTasks.isEmpty) {
      _statusRequest = StatusRequest.loading;
    }
    update();

    final result = _selectedProjectId != null && _selectedProjectId!.isNotEmpty
        ? await _loadAllTasksForProject(_selectedProjectId!)
        : await _tasksRepository.getTasks(
            page: _currentPage,
            limit: _limit,
          );

    _isLoading = false;
    result.fold(
      (error) async {
        _statusRequest = error;
        update();
      },
      (tasks) {
        if (_selectedProjectId != null && _selectedProjectId!.isNotEmpty) {
          _allTasks = tasks;
        } else {
          if (refresh) {
            _allTasks = tasks;
          } else {
            _allTasks.addAll(tasks);
          }
          _hasMore = tasks.length >= _limit;
          if (_hasMore) {
            _currentPage++;
          }
        }
        _statusRequest = StatusRequest.success;
        update();
      },
    );
  }
  @override
  Future<void> refreshTasks() async {
    await loadTasks(refresh: true);
  }

  @override
  Future<void> loadProjects() async {
    _isLoadingProjects = true;
    update();
    try {
      final authService = AuthService();
      final companyId = await authService.getCompanyId();

      if (companyId == null || companyId.isEmpty) {
        _projects = [];
        _isLoadingProjects = false;
        update();
        return;
      }

      final result = await _projectsRepository.getProjects(
        companyId: companyId,
        page: 1,
        limit: 100,
      );

      result.fold(
        (error) {
          _projects = [];
        },
        (loadedProjects) {
          _projects = loadedProjects;
        },
      );
    } catch (e) {
      _projects = [];
    }
    _isLoadingProjects = false;
    update();
  }

  @override
  void selectProject(String? projectId) {
    _selectedProjectId = projectId;
    _currentPage = 1;
    _hasMore = true;
    _allTasks.clear();
    update();
    loadTasks(refresh: true);
  }

  @override
  void viewAllTasks() {
    _selectedProjectId = null;
    _currentPage = 1;
    _hasMore = true;
    _allTasks.clear();
    update();
    loadTasks(refresh: true);
  }

  Future<Either<StatusRequest, List<TaskModel>>> _loadAllTasksForProject(
    String projectId,
  ) async {
    List<TaskModel> allProjectTasks = [];
    int currentPage = 1;
    const int maxLimit = 100;

    while (true) {
      final result = await _tasksRepository.getTasksByProject(
        projectId: projectId,
        page: currentPage,
        limit: maxLimit,
      );

      final shouldContinue = result.fold(
        (error) {
          if (allProjectTasks.isNotEmpty) {
            return false;
          }
          return false;
        },
        (tasks) {
          allProjectTasks.addAll(tasks);
          return tasks.length >= maxLimit;
        },
      );

      if (!shouldContinue) {
        return result.fold(
          (error) {
            if (allProjectTasks.isNotEmpty) {
              return Right<StatusRequest, List<TaskModel>>(allProjectTasks);
            }
            return Left<StatusRequest, List<TaskModel>>(error);
          },
          (tasks) => Right<StatusRequest, List<TaskModel>>(allProjectTasks),
        );
      }

      currentPage++;
    }
  }

  @override
  List<TaskModel> get filteredTasks {
    final filterController = Get.find<FilterButtonController>();
    if (filterController.selectedFilter == 'All') {
      return _allTasks;
    }
    return _allTasks
        .where((task) => task.status == filterController.selectedFilter)
        .toList();
  }

  Future<bool> markTaskAsCompleted(String taskId) async {
    final result = await _tasksRepository.markTaskAsCompleted(taskId);
    return result.fold(
      (error) {
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.errorColor,
          colorText: AppColor.white,
          icon: const Icon(Icons.error_outline, color: AppColor.white, size: 28),
          duration: const Duration(seconds: 5),
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        return false;
      },
      (success) {
        Get.snackbar(
          'Success',
          'Task marked as completed successfully',
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
        // Refresh tasks after marking as completed
        refreshTasks();
        return true;
      },
    );
  }
}
