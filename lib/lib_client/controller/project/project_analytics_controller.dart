import 'package:get/get.dart';
import 'package:project_hub/lib_client/data/repository/task_repository.dart';
import 'package:project_hub/lib_client/data/Models/task_model.dart';
import 'package:project_hub/lib_client/data/Models/project_model.dart';

class ProjectAnalyticsController extends GetxController {
  final TaskRepository _taskRepository = TaskRepository();

  final RxBool isLoading = false.obs;
  final Rx<ProjectModel?> selectedProject = Rx<ProjectModel?>(null);

  // Overview metrics
  final RxDouble overallProgress = 0.0.obs;
  final RxInt daysRemaining = 0.obs;
  final RxString projectStatus = 'planned'.obs;

  // Task breakdown
  final RxDouble completedPercent = 0.0.obs;
  final RxDouble inProgressPercent = 0.0.obs;
  final RxDouble pendingPercent = 0.0.obs;

  // Priority distribution
  final RxMap<String, int> priorityDistribution = <String, int>{}.obs;
  final RxInt totalTasks = 0.obs;

  // Role distribution
  final RxInt backendTasks = 0.obs;
  final RxInt frontendTasks = 0.obs;

  // Timeline metrics
  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;
  final RxInt safeDelay = 0.obs;

  // Team workload
  final RxList<AssigneeData> assignees = <AssigneeData>[].obs;

  final RxString errorMessage = ''.obs;
  final RxList<TaskModel> projectTasks = <TaskModel>[].obs;

  void setProject(ProjectModel project) {
    selectedProject.value = project;
    loadProjectAnalytics(project.id);
  }

  Future<void> loadProjectAnalytics(String projectId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final tasksResult = await _taskRepository.getTasksByProject(
        projectId,
        status: null,
      );

      tasksResult.fold(
        (error) {
          errorMessage.value = error;
          projectTasks.value = [];
        },
        (tasks) {
          projectTasks.value = tasks;
          _calculateMetrics(tasks);
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      projectTasks.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateMetrics(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      _resetMetrics();
      return;
    }

    final project = selectedProject.value;
    if (project == null) return;

    totalTasks.value = tasks.length;

    // Overview metrics
    overallProgress.value = project.progressPercentage ?? 0.0;
    projectStatus.value = project.status;

    // Calculate days remaining
    if (project.estimatedEndAt != null && project.estimatedEndAt!.isNotEmpty) {
      try {
        final endDate = DateTime.parse(project.estimatedEndAt!);
        final today = DateTime.now();
        final remaining = endDate.difference(today).inDays;
        daysRemaining.value = remaining > 0 ? remaining : 0;
      } catch (e) {
        daysRemaining.value = 0;
      }
    }

    // Store timeline info
    startDate.value = project.startDate;
    endDate.value = project.endDate;
    safeDelay.value = project.safeDelay ?? 0;

    // Task status breakdown
    final completedCount = tasks
        .where(
          (t) =>
              t.status != null && t.status!.toLowerCase().contains('completed'),
        )
        .length;
    final inProgressCount = tasks
        .where(
          (t) =>
              t.status != null && t.status!.toLowerCase().contains('progress'),
        )
        .length;
    final pendingCount = tasks
        .where(
          (t) =>
              t.status != null && t.status!.toLowerCase().contains('pending'),
        )
        .length;

    completedPercent.value = totalTasks.value > 0
        ? completedCount / totalTasks.value
        : 0.0;
    inProgressPercent.value = totalTasks.value > 0
        ? inProgressCount / totalTasks.value
        : 0.0;
    pendingPercent.value = totalTasks.value > 0
        ? pendingCount / totalTasks.value
        : 0.0;

    // Priority distribution
    final priorityMap = <String, int>{};
    for (final task in tasks) {
      final priority = task.priority;
      priorityMap[priority] = (priorityMap[priority] ?? 0) + 1;
    }
    priorityDistribution.value = priorityMap;

    // Role distribution
    final backend = tasks
        .where(
          (t) =>
              t.targetRole != null &&
              t.targetRole!.toLowerCase().contains('backend'),
        )
        .length;
    final frontend = tasks
        .where(
          (t) =>
              t.targetRole != null &&
              t.targetRole!.toLowerCase().contains('frontend'),
        )
        .length;

    backendTasks.value = backend;
    frontendTasks.value = frontend;

    // Assignee workload
    final assigneeMap = <String, int>{};
    for (final task in tasks) {
      if (task.assignee.isNotEmpty) {
        assigneeMap[task.assignee] = (assigneeMap[task.assignee] ?? 0) + 1;
      }
    }

    assignees.value =
        assigneeMap.entries
            .map(
              (e) => AssigneeData(
                name: e.key,
                taskCount: e.value,
                percentage: (e.value / totalTasks.value) * 100,
              ),
            )
            .toList()
          ..sort(
            (a, b) => b.taskCount.compareTo(a.taskCount),
          ); // Sort by count descending
  }

  void _resetMetrics() {
    overallProgress.value = 0.0;
    daysRemaining.value = 0;
    projectStatus.value = 'planned';
    completedPercent.value = 0.0;
    inProgressPercent.value = 0.0;
    pendingPercent.value = 0.0;
    priorityDistribution.value = {};
    totalTasks.value = 0;
    backendTasks.value = 0;
    frontendTasks.value = 0;
    startDate.value = '';
    endDate.value = '';
    safeDelay.value = 0;
    assignees.value = [];
  }
}

class AssigneeData {
  final String name;
  final int taskCount;
  final double percentage;

  AssigneeData({
    required this.name,
    required this.taskCount,
    required this.percentage,
  });
}
