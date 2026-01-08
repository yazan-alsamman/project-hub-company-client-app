import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
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
    debugPrint('🔵 TasksControllerImp.onInit() called');
    loadProjects();
    loadTasks();
  }
  @override
  Future<void> loadTasks({bool refresh = false}) async {
    if (_isLoading && !refresh) {
      debugPrint('🟡 Already loading, returning.');
      return;
    }
    _isLoading = true;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _allTasks.clear();
      _statusRequest = StatusRequest.loading;
      debugPrint('🔄 Refreshing tasks...');
    } else if (_allTasks.isEmpty) {
      _statusRequest = StatusRequest.loading;
      debugPrint('⏳ Initial load of tasks...');
    }
    update();
    debugPrint('🔵 Loading tasks...');
    debugPrint('Page: $_currentPage, Limit: $_limit');
    debugPrint('Selected Project ID: $_selectedProjectId');
    
    final result = _selectedProjectId != null && _selectedProjectId!.isNotEmpty
        ? await _loadAllTasksForProject(_selectedProjectId!)
        : await _tasksRepository.getTasks(
            page: _currentPage,
            limit: _limit,
          );
    
    _isLoading = false;
    result.fold(
      (error) async {
        debugPrint('🔴 Error loading tasks: $error');
        _statusRequest = error;
        update();
      },
      (tasks) {
        debugPrint('✅ Loaded ${tasks.length} tasks');
        for (var task in tasks) {
          debugPrint(
            '  - Task: ${task.title}, Status: ${task.status}, Priority: ${task.priority}',
          );
        }
        // If project is selected, show all tasks without pagination
        if (_selectedProjectId != null && _selectedProjectId!.isNotEmpty) {
          _allTasks = tasks; // Replace all tasks (no pagination)
        } else {
          // For all tasks, keep pagination logic
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
        debugPrint('✅ Total tasks: ${_allTasks.length}');
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
    debugPrint('🔵 Loading projects for task filtering...');
    try {
      final authService = AuthService();
      final companyId = await authService.getCompanyId();
      
      if (companyId == null || companyId.isEmpty) {
        debugPrint('🔴 CompanyId not found');
        _projects = [];
        _isLoadingProjects = false;
        update();
        return;
      }

      final result = await _projectsRepository.getProjects(
        companyId: companyId,
        page: 1,
        limit: 100, // Get more projects for dropdown
      );

      result.fold(
        (error) {
          debugPrint('🔴 Failed to load projects: $error');
          _projects = [];
        },
        (loadedProjects) {
          _projects = loadedProjects;
          debugPrint('✅ Loaded ${_projects.length} projects');
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading projects: $e');
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

  // Load all tasks for a project by making multiple requests if needed
  Future<Either<StatusRequest, List<TaskModel>>> _loadAllTasksForProject(
    String projectId,
  ) async {
    List<TaskModel> allProjectTasks = [];
    int currentPage = 1;
    const int maxLimit = 100; // API maximum limit

    while (true) {
      final result = await _tasksRepository.getTasksByProject(
        projectId: projectId,
        page: currentPage,
        limit: maxLimit,
      );

      final shouldContinue = result.fold(
        (error) {
          // If we have some tasks already, return them; otherwise return error
          if (allProjectTasks.isNotEmpty) {
            return false; // Stop and return what we have
          }
          return false; // Stop on error
        },
        (tasks) {
          allProjectTasks.addAll(tasks);
          // If we got less than maxLimit, we've reached the end
          return tasks.length >= maxLimit; // Continue if we got full page
        },
      );

      // Check if we should return early (error or partial success)
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

      // Continue to next page
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
}
