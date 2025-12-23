import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/controller/auth_controller.dart';
import 'package:project_hub/lib_client/data/Models/project_model.dart';
import 'package:project_hub/lib_client/data/Models/task_model.dart';
import 'package:project_hub/lib_client/data/repository/project_repository.dart';
import 'package:project_hub/lib_client/data/repository/task_repository.dart';

abstract class AnalyticsController extends GetxController {}

class AnalyticsControllerImp extends AnalyticsController {
  late ProjectRepository projectRepository;
  late TaskRepository taskRepository;
  late AuthController authController;

  final projects = RxList<ProjectModel>([]);
  final selectedProjectId = RxString('all');
  final projectAnalytics = Rx<Map<String, dynamic>?>(null);

  // Dashboard metrics
  final overallCompletion = RxDouble(0.0);
  final averageProjectCompletion = RxDouble(0.0);
  final totalProjects = RxInt(0);
  final projectStatuses = RxList<ProjectStatusModel>([]);
  final isLoading = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    try {
      projectRepository = Get.find<ProjectRepository>();
    } catch (e) {
      projectRepository = ProjectRepository();
      Get.put(projectRepository);
    }
    try {
      taskRepository = Get.find<TaskRepository>();
    } catch (e) {
      taskRepository = TaskRepository();
      Get.put(taskRepository);
    }
    try {
      authController = Get.find<AuthController>();
    } catch (e) {
      print('AuthController not found: $e');
    }
    loadProjects();
  }

  void loadProjects() async {
    try {
      isLoading.value = true;
      final userId = authController.user['_id'] ?? '';
      final result = await projectRepository.getProjectsByClientId(userId);

      result.fold(
        (error) {
          print('Error loading projects: $error');
        },
        (data) {
          projects.value = data;
          totalProjects.value = data.length;
          _calculateDashboardMetrics();
        },
      );
    } catch (e) {
      print('Exception in loadProjects: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectProject(String projectId) async {
    selectedProjectId.value = projectId;
    if (projectId == 'all') {
      projectAnalytics.value = null;
    } else {
      await _loadProjectAnalytics(projectId);
    }
    update();
  }

  void _calculateDashboardMetrics() {
    if (projects.isEmpty) return;

    try {
      double totalCompletion = 0;
      int completedProjects = 0;
      int inProgressProjects = 0;
      int plannedProjects = 0;

      for (var project in projects) {
        final totalTasks = project.totalTasks ?? 0;
        final completedTasks = project.completedTasks ?? 0;

        if (totalTasks > 0) {
          totalCompletion += completedTasks / totalTasks;
        }

        final status = project.status;
        switch (status.toLowerCase()) {
          case 'completed':
            completedProjects++;
            break;
          case 'active':
            inProgressProjects++;
            break;
          default:
            plannedProjects++;
        }
      }

      averageProjectCompletion.value = projects.isNotEmpty
          ? totalCompletion / projects.length
          : 0.0;

      overallCompletion.value = averageProjectCompletion.value;

      projectStatuses.value = [
        ProjectStatusModel(
          label: 'Completed',
          count: completedProjects,
          percentage: (completedProjects / projects.length) * 100,
          color: const Color(0xFF4CAF50),
        ),
        ProjectStatusModel(
          label: 'In Progress',
          count: inProgressProjects,
          percentage: (inProgressProjects / projects.length) * 100,
          color: const Color(0xFF2196F3),
        ),
        ProjectStatusModel(
          label: 'Planned',
          count: plannedProjects,
          percentage: (plannedProjects / projects.length) * 100,
          color: const Color(0xFF9E9E9E),
        ),
      ];
    } catch (e) {
      print('Error calculating dashboard metrics: $e');
    }
  }

  Future<void> _loadProjectAnalytics(String projectId) async {
    try {
      isLoading.value = true;
      final result = await taskRepository.getTasksByProject(projectId);

      result.fold(
        (error) {
          print('Error loading project tasks: $error');
        },
        (tasks) {
          _calculateProjectAnalytics(tasks);
        },
      );
    } catch (e) {
      print('Exception in _loadProjectAnalytics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateProjectAnalytics(List<TaskModel> tasks) {
    try {
      final project = projects.firstWhere(
        (p) => p.id == selectedProjectId.value,
        orElse: () => ProjectModel(
          id: '',
          title: '',
          description: '',
          company: '',
          progress: 0.0,
          startDate: '',
          endDate: '',
          teamMembers: 0,
          status: 'planned',
        ),
      );

      int completedCount = 0;
      int inProgressCount = 0;
      int pendingCount = 0;
      Map<String, int> priorityMap = {};
      int backendCount = 0;
      int frontendCount = 0;
      Map<String, int> assigneeMap = {};

      for (var task in tasks) {
        final status = task.status?.toLowerCase();
        switch (status) {
          case 'completed':
            completedCount++;
            break;
          case 'in-progress':
          case 'in progress':
            inProgressCount++;
            break;
          default:
            pendingCount++;
        }

        // Priority distribution
        final priority = task.priority;
        priorityMap[priority] = (priorityMap[priority] ?? 0) + 1;

        // Role distribution
        final role = task.targetRole?.toLowerCase() ?? '';
        if (role.contains('backend')) {
          backendCount++;
        } else if (role.contains('frontend')) {
          frontendCount++;
        }

        // Assignee workload
        final assignee = task.assignee;
        assigneeMap[assignee] = (assigneeMap[assignee] ?? 0) + 1;
      }

      final total = tasks.length > 0 ? tasks.length : 1;
      final completedPercent = completedCount / total;
      final inProgressPercent = inProgressCount / total;
      final pendingPercent = pendingCount / total;

      List<Map<String, dynamic>> assigneesList =
          assigneeMap.entries
              .map(
                (e) => {
                  'name': e.key,
                  'taskCount': e.value,
                  'percentage': (e.value / total) * 100,
                },
              )
              .toList()
            ..sort(
              (a, b) =>
                  (b['taskCount'] as int).compareTo(a['taskCount'] as int),
            );

      projectAnalytics.value = {
        'title': project.title,
        'progress': tasks.isNotEmpty ? completedCount / tasks.length : 0.0,
        'completed': completedPercent,
        'inProgress': inProgressPercent,
        'pending': pendingPercent,
        'daysRemaining': _calculateDaysRemaining(project),
        'status': project.status,
        'startDate': _formatDate(project.startDate),
        'endDate': _formatDate(project.endDate),
        'priorityDistribution': priorityMap,
        'backendTasks': backendCount,
        'frontendTasks': frontendCount,
        'totalTasks': tasks.length,
        'assignees': assigneesList,
      };
    } catch (e) {
      print('Error calculating project analytics: $e');
    }
  }

  int _calculateDaysRemaining(ProjectModel project) {
    final endDate = project.endDate;
    if (endDate.isEmpty) return 0;
    final parsedDate = DateTime.tryParse(endDate);
    if (parsedDate == null) return 0;
    return parsedDate.difference(DateTime.now()).inDays;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.tryParse(dateStr);
      if (date == null) return dateStr;
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

class ProjectStatusModel {
  final String label;
  final int count;
  final double percentage;
  final Color color;

  ProjectStatusModel({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });
}
