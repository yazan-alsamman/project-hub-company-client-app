import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/assignment_model.dart';
import '../../data/Models/employee_model.dart';
import '../../data/Models/task_model.dart';
import '../../data/repository/assignments_repository.dart';
import '../../data/repository/team_repository.dart';
import '../../data/repository/tasks_repository.dart';
class EmployeeScheduleController extends GetxController {
  final AssignmentsRepository _assignmentsRepository = AssignmentsRepository();
  final TeamRepository _teamRepository = TeamRepository();
  final AuthService _authService = AuthService();
  List<EmployeeModel> employees = [];
  String? selectedEmployeeId;
  DateTime? startDate;
  DateTime? endDate;
  List<AssignmentModel> scheduleAssignments = [];
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  bool isLoadingEmployees = false;
  @override
  void onInit() {
    super.onInit();
    loadEmployees();
  }
  Future<void> loadEmployees() async {
    isLoadingEmployees = true;
    update();
    final companyId = await _authService.getCompanyId();
    debugPrint('🔵 Using companyId from AuthService: $companyId');
    final result = await _teamRepository.getEmployees(
      page: 1,
      limit: 100,
      companyId: companyId,
      status: null,
    );
    isLoadingEmployees = false;
    result.fold(
      (error) {
        debugPrint('🔴 Error loading employees: $error');
      },
      (employeeList) {
        employees = employeeList;
        debugPrint('✅ Loaded ${employees.length} employees.');
      },
    );
    update();
  }
  void selectEmployee(String? employeeId) {
    selectedEmployeeId = employeeId;
    update();
  }
  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      startDate = picked;
      update();
    }
  }
  Future<void> selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          endDate ?? (startDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      endDate = picked;
      update();
    }
  }
  Future<void> loadEmployeeSchedule() async {
    if (selectedEmployeeId == null || startDate == null || endDate == null) {
      return;
    }
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    final startDateStr =
        '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
    final endDateStr =
        '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
    final result = await _assignmentsRepository.getEmployeeSchedule(
      employeeId: selectedEmployeeId!,
      startDate: startDateStr,
      endDate: endDateStr,
    );
    isLoading = false;
    result.fold(
      (error) {
        statusRequest = error;
        scheduleAssignments = [];
      },
      (data) {
        statusRequest = StatusRequest.success;
        final assignmentsList = data['assignments'] as List<dynamic>? ?? [];
        scheduleAssignments = assignmentsList.map((item) {
          return AssignmentModel.fromJson(item as Map<String, dynamic>);
        }).toList();
      },
    );
    update();
  }
}
class TaskAssignmentsController extends GetxController {
  final AssignmentsRepository _assignmentsRepository = AssignmentsRepository();
  final TasksRepository _tasksRepository = TasksRepository();
  List<TaskModel> tasks = [];
  String? selectedTaskId;
  List<AssignmentModel> taskAssignments = [];
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  bool isLoadingTasks = false;
  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }
  Future<void> loadTasks() async {
    isLoadingTasks = true;
    update();
    final result = await _tasksRepository.getTasks(page: 1, limit: 100);
    isLoadingTasks = false;
    result.fold(
      (error) {
        debugPrint('🔴 Error loading tasks: $error');
      },
      (taskList) {
        tasks = taskList;
        debugPrint('✅ Loaded ${tasks.length} tasks.');
      },
    );
    update();
  }
  void selectTask(String? taskId) {
    selectedTaskId = taskId;
    taskAssignments = [];
    statusRequest = StatusRequest.none;
    update();
  }
  Future<void> loadTaskAssignments() async {
    if (selectedTaskId == null) {
      return;
    }
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    final result = await _assignmentsRepository.getAssignmentsByTask(
      taskId: selectedTaskId!,
      page: 1,
      limit: 10,
    );
    isLoading = false;
    result.fold(
      (error) {
        statusRequest = error;
        taskAssignments = [];
      },
      (data) {
        statusRequest = StatusRequest.success;
        final assignmentsList = data['assignments'] as List<dynamic>? ?? [];
        String? selectedTaskName;
        String? selectedTaskDescription;
        if (tasks.isNotEmpty && selectedTaskId != null) {
          try {
            final selectedTask = tasks.firstWhere(
              (task) => task.id == selectedTaskId,
            );
            selectedTaskName = selectedTask.title;
            selectedTaskDescription = selectedTask.taskDescription;
          } catch (e) {
            debugPrint('🔴 Task not found in list: $selectedTaskId');
          }
        }
        taskAssignments = assignmentsList.map((item) {
          final assignment = AssignmentModel.fromJson(
            item as Map<String, dynamic>,
          );
          if (assignment.taskName == 'Unknown Task' &&
              selectedTaskName != null &&
              selectedTaskName.isNotEmpty) {
            return AssignmentModel(
              id: assignment.id,
              taskId: assignment.taskId,
              taskName: selectedTaskName, // Use selected task name
              taskDescription:
                  assignment.taskDescription ?? selectedTaskDescription,
              employeeId: assignment.employeeId,
              employeeName: assignment.employeeName,
              employeeEmail: assignment.employeeEmail,
              assignedBy: assignment.assignedBy,
              assignedByName: assignment.assignedByName,
              startDate: assignment.startDate,
              endDate: assignment.endDate,
              estimatedHours: assignment.estimatedHours,
              actualHours: assignment.actualHours,
              status: assignment.status,
              notes: assignment.notes,
              completedAt: assignment.completedAt,
              createdAt: assignment.createdAt,
              updatedAt: assignment.updatedAt,
              projectId: assignment.projectId,
              projectName: assignment.projectName,
              projectCode: assignment.projectCode,
            );
          }
          return assignment;
        }).toList();
      },
    );
    update();
  }
}
