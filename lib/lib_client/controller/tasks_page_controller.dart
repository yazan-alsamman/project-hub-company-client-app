import 'package:get/get.dart';
import 'package:project_hub/lib_client/data/repository/task_repository.dart';
import 'package:project_hub/lib_client/data/repository/project_repository.dart';
import 'package:project_hub/lib_client/data/Models/task_model.dart';
import 'package:project_hub/lib_client/data/Models/project_model.dart';
import 'package:project_hub/lib_client/controller/auth_controller.dart';

class TasksPageController extends GetxController {
  final TaskRepository _taskRepository = TaskRepository();
  final ProjectRepository _projectRepository = ProjectRepository();

  final RxBool isLoading = false.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxList<String> statusFilters = [
    'All',
    'In Progress',
    'Completed',
    'Pending',
  ].obs;

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxList<TaskModel> allTasks =
      <TaskModel>[].obs; // Store all tasks for progress/chart
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final Rx<String?> selectedProjectId = Rx<String?>(null);

  // Progress metrics for selected project
  final RxDouble projectCompletionPercent = 0.0.obs; // 0.0 - 1.0

  // Chart metrics - status breakdown for selected project
  final RxDouble completedPercent = 0.0.obs;
  final RxDouble inProgressPercent = 0.0.obs;
  final RxDouble pendingPercent = 0.0.obs;

  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedProjectId.value = 'All'; // Default to 'All Projects'
    _loadProjects();
    loadTasks();
  }

  Future<void> _loadProjects() async {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        if (authController.isClient && authController.userId != null) {
          final result = await _projectRepository.getProjectsByClientId(
            authController.userId!,
          );
          result.fold(
            (error) {
              // Projects loading failed, but continue with tasks
            },
            (projectList) {
              projects.value = projectList;
            },
          );
        }
      }
    } catch (e) {
      // Ignore errors, projects are optional
    }
  }

  void selectProject(String? projectId) {
    selectedProjectId.value = projectId;
    _applyFilters();
    _calculateProgress();
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();

        if (authController.isClient) {
          if (authController.userId != null) {
            await _loadClientTasks(authController.userId!);
          } else {
            errorMessage.value = 'User ID not available. Please login again.';
            tasks.value = [];
          }
        } else {
          await _loadAllTasks();
        }
      } else {
        await _loadAllTasks();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      tasks.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllTasks() async {
    // Load all tasks without status filter for progress/chart
    final allTasksResult = await _taskRepository.getAllTasks(status: null);

    allTasksResult.fold(
      (error) {
        errorMessage.value = error;
        allTasks.value = [];
      },
      (taskList) {
        allTasks.value = taskList;
        _calculateProgress();
        _applyFilters(); // Apply filters after loading
      },
    );
  }

  Future<void> _loadClientTasks(String clientId) async {
    // If projects list is empty, load it first
    if (projects.isEmpty) {
      await _loadProjects();
    }

    // Load tasks from all projects (without filters) for progress/chart
    final projectsResult = await _projectRepository.getProjectsByClientId(
      clientId,
    );

    await projectsResult.fold(
      (error) async {
        errorMessage.value = 'Failed to load projects: $error';
        allTasks.value = [];
        tasks.value = [];
      },
      (projectsList) async {
        if (projectsList.isEmpty) {
          errorMessage.value = 'No projects found for this client';
          allTasks.value = [];
          tasks.value = [];
          return;
        }

        // Update projects list
        projects.value = projectsList;

        final allTasksList = <TaskModel>[];

        // Load all tasks without status filter for progress/chart
        for (final project in projectsList) {
          final projectId = project.id;

          if (projectId.isNotEmpty) {
            final tasksResult = await _taskRepository.getTasksByProject(
              projectId,
              status: null, // Load all tasks regardless of status
            );

            tasksResult.fold(
              (error) {
                // Continue with other projects
              },
              (projectTasks) {
                allTasksList.addAll(projectTasks);
              },
            );
          }
        }

        allTasks.value = allTasksList;
        _calculateProgress();
        _applyFilters(); // Apply filters after loading

        if (allTasksList.isEmpty) {
          errorMessage.value = 'No tasks found for your projects';
        }
      },
    );
  }

  Future<bool> createTask(TaskModel task) async {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      if (authController.isClient) {
        errorMessage.value = 'Clients cannot create tasks';
        return false;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _taskRepository.createTask(task);

      return result.fold(
        (error) {
          errorMessage.value = error;
          return false;
        },
        (createdTask) {
          allTasks.add(createdTask);
          _calculateProgress();
          _applyFilters();
          return true;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      if (authController.isClient) {
        errorMessage.value = 'Clients cannot update tasks';
        return false;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _taskRepository.updateTask(task);

      return result.fold(
        (error) {
          errorMessage.value = error;
          return false;
        },
        (updatedTask) {
          final allIndex = allTasks.indexWhere((t) => t.id == updatedTask.id);
          if (allIndex != -1) {
            allTasks[allIndex] = updatedTask;
          }
          _calculateProgress();
          _applyFilters();
          return true;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      if (authController.isClient) {
        errorMessage.value = 'Clients cannot delete tasks';
        return false;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _taskRepository.deleteTask(taskId);

      return result.fold(
        (error) {
          errorMessage.value = error;
          return false;
        },
        (success) {
          allTasks.removeWhere((task) => task.id == taskId);
          _calculateProgress();
          _applyFilters();
          return true;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTaskStatus(String taskId, String status) async {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      if (authController.isClient) {
        errorMessage.value = 'Clients cannot update task status';
        return false;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _taskRepository.updateTaskStatus(taskId, status);

      return result.fold(
        (error) {
          errorMessage.value = error;
          return false;
        },
        (updatedTask) {
          final allIndex = allTasks.indexWhere((t) => t.id == updatedTask.id);
          if (allIndex != -1) {
            allTasks[allIndex] = updatedTask;
          }
          _calculateProgress();
          _applyFilters();
          return true;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool get canEdit {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      return authController.canEdit;
    }
    return true;
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void _applyFilters() {
    // Start with all tasks
    List<TaskModel> filtered = List.from(allTasks);

    // Apply project filter
    final currentProjectId = selectedProjectId.value;
    if (currentProjectId != null &&
        currentProjectId.isNotEmpty &&
        currentProjectId != 'All') {
      filtered = filtered.where((task) {
        // Check if task belongs to the selected project
        return task.projectId != null && task.projectId == currentProjectId;
      }).toList();
    }

    // Apply status filter
    if (selectedStatus.value != 'All') {
      filtered = filtered.where((task) {
        final taskStatus = task.status?.toLowerCase() ?? '';
        final filterStatus = selectedStatus.value.toLowerCase();

        // Handle status matching (e.g., "In Progress" vs "in progress")
        if (filterStatus == 'in progress') {
          return taskStatus.contains('progress') ||
              taskStatus.contains('in progress');
        }
        return taskStatus == filterStatus;
      }).toList();
    }

    tasks.value = filtered;
  }

  Future<void> refreshData() async {
    await loadTasks();
  }

  void _calculateProgress() {
    // Get relevant tasks based on project selection
    final currentProjectId = selectedProjectId.value;
    List<TaskModel> relevantTasks = List.from(allTasks);

    if (currentProjectId != null &&
        currentProjectId != 'All' &&
        currentProjectId!.isNotEmpty) {
      relevantTasks = allTasks
          .where((task) => task.projectId == currentProjectId)
          .toList();
    }

    if (relevantTasks.isEmpty) {
      projectCompletionPercent.value = 0.0;
      completedPercent.value = 0.0;
      inProgressPercent.value = 0.0;
      pendingPercent.value = 0.0;
      return;
    }

    final total = relevantTasks.length;

    // Calculate completion percentage (completed tasks / total tasks)
    final completedCount = relevantTasks
        .where(
          (t) =>
              t.status != null && t.status!.toLowerCase().contains('completed'),
        )
        .length;
    projectCompletionPercent.value = total > 0 ? completedCount / total : 0.0;

    // Calculate status breakdown percentages
    final inProgressCount = relevantTasks
        .where(
          (t) =>
              t.status != null && t.status!.toLowerCase().contains('progress'),
        )
        .length;
    final pendingCount = relevantTasks
        .where(
          (t) =>
              t.status != null && t.status!.toLowerCase().contains('pending'),
        )
        .length;

    completedPercent.value = total > 0 ? completedCount / total : 0.0;
    inProgressPercent.value = total > 0 ? inProgressCount / total : 0.0;
    pendingPercent.value = total > 0 ? pendingCount / total : 0.0;
  }
}
