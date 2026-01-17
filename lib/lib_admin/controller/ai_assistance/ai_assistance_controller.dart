import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../data/Models/task_model.dart';
import '../../data/repository/projects_repository.dart';
import '../../data/repository/tasks_repository.dart';
import '../../data/repository/assignments_repository.dart';
import '../../core/services/auth_service.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import '../../core/services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:project_hub/core/config/app_config.dart';
import '../../core/functions/checkinternet.dart';

abstract class AiAssistanceController extends GetxController {
  void generateTasks(String projectDescription, int numTasks);
  void clearGeneratedTasks();
  Future<void> showProjectSelectionDialog(BuildContext context);
}

class AiAssistanceControllerImp extends AiAssistanceController {
  final TextEditingController projectDescriptionController =
      TextEditingController();
  final TextEditingController numTasksController = TextEditingController();
  final GlobalKey<FormState> formState = GlobalKey<FormState>();

  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  List<TaskModel> generatedTasks = [];
  double? generationTime;

  int currentPage = 1;
  static const int itemsPerPage = 10;
  bool viewAll = false;

  Map<String, dynamic>? acceptedTasksResponse;
  bool showAssignTasksButton = false;
  bool isAssigningTasks = false;

  bool showPdfButton = false;
  bool isGeneratingPdf = false;
  List<Map<String, dynamic>> successfulAssignments = [];

  String? assignmentStatusMessage;
  String? assignmentStatusTitle;
  Color? assignmentStatusColor;
  bool showAssignmentStatus = false;

  List<Map<String, dynamic>> aiAssignments = [];
  bool showAiAssignments = false;

  Map<String, dynamic>? aiAssignmentsResponse; // Store the AI response for approval
  bool showApproveButton = false;
  bool isApprovingAssignments = false;

  static const String aiApiUrl = AppConfig.aiApiUrl;
  static const String assignTasksApiUrl = AppConfig.aiAssignTasksApiUrl;

  final ApiService _apiService = ApiService();
  final AssignmentsRepository _assignmentsRepository = AssignmentsRepository();

  @override
  void onInit() {
    super.onInit();
    numTasksController.text = '10';
  }

  @override
  void onClose() {
    projectDescriptionController.dispose();
    numTasksController.dispose();
    super.onClose();
  }

  @override
  void generateTasks(String projectDescription, int numTasks) async {
    if (projectDescription.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a project description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Check internet connectivity first
    final hasInternet = await checkInternet();
    if (!hasInternet) {
      Get.snackbar(
        'Error',
        'No internet connection. Please check your network and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();

    try {
      final body = {
        'project_description': projectDescription,
        'num_tasks': numTasks,
      };

      final response = await http
          .post(
            Uri.parse(aiApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        List<dynamic> tasksList = [];
        if (responseData['tasks'] != null && responseData['tasks'] is List) {
          tasksList = responseData['tasks'] as List<dynamic>;
        } else if (responseData['data'] != null &&
            responseData['data'] is List) {
          tasksList = responseData['data'] as List<dynamic>;
        } else if (responseData is List) {
          tasksList = responseData as List<dynamic>;
        }

        if (tasksList.isEmpty) {}

        generatedTasks = tasksList.asMap().entries.map((entry) {
          final index = entry.key;
          final taskJson = entry.value;
          try {
            final taskMap = taskJson is Map<String, dynamic>
                ? taskJson
                : <String, dynamic>{};

            final taskName =
                taskMap['task']?.toString() ??
                taskMap['taskName']?.toString() ??
                taskMap['title']?.toString() ??
                'Untitled Task';

            final role = taskMap['role']?.toString() ?? 'Unassigned';

            final priorityStr = taskMap['priority']?.toString() ?? 'Medium';
            final priorityCode = _convertPriorityToCode(priorityStr);
            final priorityDisplay = _mapPriorityFromAI(priorityCode);

            final timeObj = taskMap['time'];
            String timeDisplay = 'No time estimate';
            int? minEstimatedHour;
            int? maxEstimatedHour;

            if (timeObj is Map<String, dynamic>) {
              final hours = timeObj['hours'] is int
                  ? timeObj['hours'] as int
                  : timeObj['hours'] is num
                  ? (timeObj['hours'] as num).toInt()
                  : 0;
              final minutes = timeObj['minutes'] is int
                  ? timeObj['minutes'] as int
                  : timeObj['minutes'] is num
                  ? (timeObj['minutes'] as num).toInt()
                  : 0;

              if (hours > 0 || minutes > 0) {
                if (minutes > 0) {
                  timeDisplay = '${hours}h ${minutes}m';
                } else {
                  timeDisplay = '${hours}h';
                }
                minEstimatedHour = hours;
                maxEstimatedHour = hours + (minutes > 0 ? 1 : 0);
              }
            }

            final roleInitials = role.isNotEmpty
                ? role.substring(0, 1).toUpperCase()
                : 'UA';

            final avatarColor = _getAvatarColorFromRole(role);

            return TaskModel(
              id: 'ai_task_${DateTime.now().millisecondsSinceEpoch}_$index',
              title: taskName,
              subtitle: 'Estimated time: $timeDisplay',
              category: role,
              priority: priorityDisplay,
              dueDate: timeDisplay,
              assigneeName: role,
              assigneeInitials: roleInitials,
              status: 'Pending',
              priorityColor: _getPriorityColorFromCode(priorityCode),
              avatarColor: avatarColor,
              taskDescription: taskName,
              taskPriority: priorityCode,
              taskStatus: 'pending',
              targetRole: role,
              minEstimatedHour: minEstimatedHour,
              maxEstimatedHour: maxEstimatedHour,
            );
          } catch (e) {
            return TaskModel(
              id: 'ai_task_error_${DateTime.now().millisecondsSinceEpoch}_$index',
              title: 'Parsing Error',
              subtitle: 'Failed to parse task data',
              category: 'Error',
              priority: 'Medium',
              dueDate: 'No time estimate',
              assigneeName: 'Unassigned',
              assigneeInitials: 'UA',
              status: 'Pending',
              priorityColor: 'orange',
              avatarColor: 'primary',
            );
          }
        }).toList();

        if (responseData['generation_time'] != null) {
          generationTime = responseData['generation_time'] is double
              ? responseData['generation_time'] as double
              : responseData['generation_time'] is int
              ? (responseData['generation_time'] as int).toDouble()
              : responseData['generation_time'] is num
              ? (responseData['generation_time'] as num).toDouble()
              : null;
        }

        statusRequest = StatusRequest.success;

        Get.snackbar(
          'Success',
          'Generated ${generatedTasks.length} tasks successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.successColor,
          colorText: AppColor.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      } else {
        String errorMessage = 'Failed to generate tasks';
        try {
          final errorResponse =
              jsonDecode(response.body) as Map<String, dynamic>;

          if (errorResponse['detail'] != null &&
              errorResponse['detail'] is List) {
            final detailList = errorResponse['detail'] as List<dynamic>;
            if (detailList.isNotEmpty) {
              final messages = detailList
                  .map((error) {
                    if (error is Map<String, dynamic> && error['msg'] != null) {
                      return error['msg'].toString();
                    }
                    return null;
                  })
                  .where((msg) => msg != null)
                  .toList();

              if (messages.isNotEmpty) {
                errorMessage = messages.join('\n');
              }
            }
          } else if (errorResponse['message'] != null) {
            errorMessage = errorResponse['message'].toString();
          } else if (errorResponse['error'] != null) {
            errorMessage = errorResponse['error'].toString();
          }
        } catch (e) {
          errorMessage = 'Failed to generate tasks';
        }

        statusRequest = StatusRequest.serverFailure;

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.errorColor,
          colorText: AppColor.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e, stackTrace) {
      statusRequest = StatusRequest.serverException;

      String errorMessage = 'Failed to generate tasks';
      if (e.toString().contains('timeout') ||
          e.toString().contains('Timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        // Re-check connectivity to be more accurate
        final hasInternetNow = await checkInternet();
        if (!hasInternetNow) {
          errorMessage =
              'No internet connection. Please check your network and try again.';
        } else {
          // Internet is available but connection failed - likely server issue
          errorMessage =
              'Unable to connect to server. Please check your connection or try again later.';
        }
      } else {
        errorMessage =
            'An error occurred while generating tasks. Please try again.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void clearGeneratedTasks() {
    generatedTasks.clear();
    generationTime = null;
    currentPage = 1;
    viewAll = false;
    acceptedTasksResponse = null;
    showAssignTasksButton = false;
    update();
  }

  List<TaskModel> get displayedTasks {
    if (viewAll) {
      return generatedTasks;
    }
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (startIndex >= generatedTasks.length) {
      return [];
    }
    return generatedTasks.sublist(
      startIndex,
      endIndex > generatedTasks.length ? generatedTasks.length : endIndex,
    );
  }

  int get totalPages {
    if (generatedTasks.isEmpty) return 0;
    return (generatedTasks.length / itemsPerPage).ceil();
  }

  bool get needsPagination {
    return generatedTasks.length > itemsPerPage;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
      viewAll = false;
      update();
    }
  }

  void nextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      viewAll = false;
      update();
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      currentPage--;
      viewAll = false;
      update();
    }
  }

  void toggleViewAll() {
    viewAll = !viewAll;
    if (!viewAll) {
      currentPage = 1;
    }
    update();
  }

  String _mapPriorityFromAI(String priority) {
    switch (priority.toUpperCase()) {
      case 'H':
      case 'HIGH':
        return 'High';
      case 'M':
      case 'MEDIUM':
        return 'Medium';
      case 'L':
      case 'LOW':
        return 'Low';
      case 'C':
      case 'CRITICAL':
        return 'Critical';
      default:
        return 'Medium';
    }
  }

  String _getPriorityColorFromCode(String priority) {
    switch (priority.toUpperCase()) {
      case 'H':
      case 'HIGH':
      case 'C':
      case 'CRITICAL':
        return 'error';
      case 'M':
      case 'MEDIUM':
        return 'orange';
      case 'L':
      case 'LOW':
        return 'green';
      default:
        return 'orange';
    }
  }

  String _convertPriorityToCode(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return 'H';
      case 'MEDIUM':
        return 'M';
      case 'LOW':
        return 'L';
      case 'CRITICAL':
        return 'C';
      case 'H':
      case 'M':
      case 'L':
      case 'C':
        return priority.toUpperCase();
      default:
        return 'M';
    }
  }

  String _getAvatarColorFromRole(String role) {
    final roleLower = role.toLowerCase();
    if (roleLower.contains('designer') || roleLower.contains('design')) {
      return 'purple';
    } else if (roleLower.contains('developer') || roleLower.contains('dev')) {
      return 'blue';
    } else if (roleLower.contains('qa') || roleLower.contains('test')) {
      return 'green';
    } else if (roleLower.contains('devops') || roleLower.contains('ops')) {
      return 'orange';
    } else if (roleLower.contains('manager') || roleLower.contains('pm')) {
      return 'primary';
    } else {
      return 'primary';
    }
  }

  @override
  Future<void> showProjectSelectionDialog(BuildContext context) async {
    try {
      final authService = AuthService();
      final companyId = await authService.getCompanyId();

      if (companyId == null || companyId.isEmpty) {
        Get.snackbar(
          'Error',
          'Company ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.errorColor,
          colorText: AppColor.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      final projectsRepository = ProjectsRepository();
      final result = await projectsRepository.getProjects(
        companyId: companyId,
        page: 1,
        limit: 100,
      );

      result.fold(
        (error) {
          Get.snackbar(
            'Error',
            'Failed to load projects',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.errorColor,
            colorText: AppColor.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
        },
        (projects) {
          if (projects.isEmpty) {
            Get.snackbar(
              'Info',
              'No projects available',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColor.warningColor,
              colorText: AppColor.white,
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
            );
            return;
          }

          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Text(
                  'Choose Project',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: projects.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No projects available'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: projects.length,
                            itemBuilder: (context, index) {
                              final project = projects[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColor.borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    project.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textColor,
                                    ),
                                  ),
                                  subtitle: project.code != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            'Code: ${project.code}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  AppColor.textSecondaryColor,
                                            ),
                                          ),
                                        )
                                      : null,
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: AppColor.textSecondaryColor,
                                  ),
                                  onTap: () {
                                    Navigator.of(dialogContext).pop();
                                    _acceptTasksForProject(
                                      project.id,
                                      project.title,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.textSecondaryColor,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while loading projects',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _acceptTasksForProject(
    String projectId,
    String projectTitle,
  ) async {
    if (generatedTasks.isEmpty) {
      Get.snackbar(
        'Error',
        'No tasks to accept',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final tasksForApi = generatedTasks.map((task) {
        String priority = 'Medium';
        if (task.taskPriority != null) {
          switch (task.taskPriority!.toUpperCase()) {
            case 'H':
            case 'HIGH':
              priority = 'High';
              break;
            case 'M':
            case 'MEDIUM':
              priority = 'Medium';
              break;
            case 'L':
            case 'LOW':
              priority = 'Low';
              break;
          }
        }

        int hours = task.minEstimatedHour ?? 0;
        int minutes = 0;

        if (task.maxEstimatedHour != null && task.maxEstimatedHour! > hours) {
          hours = task.maxEstimatedHour!;
        }

        String role = task.category.isNotEmpty
            ? task.category
            : (task.targetRole ?? 'Unassigned');

        return {
          'task': task.title,
          'role': role,
          'priority': priority,
          'time': {'hours': hours, 'minutes': minutes},
        };
      }).toList();

      final tasksRepository = TasksRepository();
      final result = await tasksRepository.bulkCreateTasks(
        projectId: projectId,
        tasks: tasksForApi,
      );

      Get.back();

      result.fold(
        (error) {
          String errorMsg = 'Failed to create tasks';
          if (error == StatusRequest.serverFailure) {
            errorMsg = 'Server error. Please try again.';
          } else if (error == StatusRequest.offlineFailure) {
            errorMsg = 'No internet connection. Please check your network.';
          } else if (error == StatusRequest.timeoutException) {
            errorMsg = 'Request timed out. Please try again.';
          } else if (error == StatusRequest.serverException) {
            errorMsg = 'An unexpected server error occurred.';
          }

          Get.snackbar(
            'Error',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.errorColor,
            colorText: AppColor.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          );
        },
        (response) {
          final data = response['data'] as Map<String, dynamic>?;
          final total = data?['total'] ?? 0;
          final successCount = data?['successCount'] ?? 0;
          final failureCount = data?['failureCount'] ?? 0;
          final message =
              response['message']?.toString() ?? 'Tasks created successfully';

          if (failureCount > 0) {
            Get.snackbar(
              'Partial Success',
              '$message\nSuccess: $successCount, Failed: $failureCount',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColor.warningColor,
              colorText: AppColor.white,
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            );
          } else {
            Get.snackbar(
              'Success',
              '$message\nAll $successCount tasks created successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColor.successColor,
              colorText: AppColor.white,
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            );
          }

          acceptedTasksResponse = response;
          showAssignTasksButton = true;

          generatedTasks.clear();
          generationTime = null;
          currentPage = 1;
          viewAll = false;
          update();
        },
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    }
  }

  String? validateNumTasks(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter number of tasks';
    }

    if (value.contains(',') || value.contains('.')) {
      return 'Number should not contain commas or decimals';
    }

    final numTasks = int.tryParse(value);
    if (numTasks == null) {
      return 'Please enter a valid number';
    }

    if (numTasks < 10) {
      return 'Number of tasks must be at least 10';
    }

    if (numTasks > 200) {
      return 'Number of tasks must not exceed 200';
    }

    if (numTasks < 0) {
      return 'Number of tasks cannot be negative';
    }

    return null;
  }

  Future<void> assignTasksByAI() async {
    if (acceptedTasksResponse == null) {
      assignmentStatusTitle = 'Error';
      assignmentStatusMessage = 'No accepted tasks found';
      assignmentStatusColor = AppColor.errorColor;
      showAssignmentStatus = true;
      update();
      return;
    }

    showAssignmentStatus = false;
    assignmentStatusMessage = null;
    assignmentStatusTitle = null;
    assignmentStatusColor = null;

    isAssigningTasks = true;
    update();

    try {
      final employeesEndpoint = '/employee/roles';

      final employeesResult = await _apiService.get(
        employeesEndpoint,
        requiresAuth: true,
      );

      final employeesData = employeesResult.fold((error) {
        String errorMsg = 'Failed to fetch employees';
        if (error == StatusRequest.serverFailure) {
          errorMsg = 'Server error. Please try again.';
        } else if (error == StatusRequest.offlineFailure) {
          errorMsg = 'No internet connection. Please check your network.';
        } else if (error == StatusRequest.timeoutException) {
          errorMsg = 'Request timed out. Please try again.';
        } else if (error == StatusRequest.serverException) {
          errorMsg = 'Authentication failed. Please login again.';
        }
        throw Exception(errorMsg);
      }, (response) => response);

      List<dynamic> employeesList = [];
      if (employeesData['data'] != null && employeesData['data'] is List) {
        employeesList = employeesData['data'] as List<dynamic>;
      } else if (employeesData['employees'] != null &&
          employeesData['employees'] is List) {
        employeesList = employeesData['employees'] as List<dynamic>;
      } else {
        employeesData.forEach((key, value) {
          if (value is List && value.isNotEmpty && employeesList.isEmpty) {
            employeesList = value;
          }
        });
      }

      if (employeesList.isEmpty) {
        throw Exception('No employees found in response');
      }

      final allowedRoles = [
        'backend',
        'frontend',
        'fullstack',
        'qa',
        'tester',
        'devops',
        'developer',
        'dev',
        'software engineer',
        'test engineer',
      ].map((r) => r.toLowerCase()).toSet();

      final List<Map<String, dynamic>> employeesForAI = [];
      int filteredCount = 0;

      for (var emp in employeesList) {
        try {
          final empMap = emp as Map<String, dynamic>;
          final employeeId = empMap['employeeId']?.toString() ?? '';
          final role = empMap['role']?.toString() ?? '';
          final employeeName = empMap['employeeName']?.toString() ?? '';

          if (employeeId.isEmpty) {
            continue;
          }

          final roleLower = role.toLowerCase();
          if (!allowedRoles.contains(roleLower)) {
            filteredCount++;
            continue;
          }

          employeesForAI.add({
            'employeeId': employeeId,
            'role': role,
            'employeeName': employeeName,
          });
        } catch (e) {
          continue;
        }
      }

      if (employeesForAI.isEmpty) {
        throw Exception(
          'No valid employees found after filtering. All employees have non-development roles (ui_ux, data, etc.). Only employees with development-related roles can be assigned tasks.',
        );
      }

      final responseData = acceptedTasksResponse!;

      Map<String, dynamic>? tasksDataForAI;

      if (responseData['data'] != null && responseData['data'] is Map) {
        final dataField = responseData['data'] as Map<String, dynamic>;

        if (dataField['results'] != null && dataField['results'] is Map) {
          final results = dataField['results'] as Map<String, dynamic>;
          if (results['successful'] != null && results['successful'] is List) {
            tasksDataForAI = {
              'data': {
                'results': {'successful': results['successful']},
              },
            };
          }
        }
      }

      if (tasksDataForAI == null) {
        throw Exception(
          'No tasks found in expected structure. Please try accepting tasks again.',
        );
      }

      final tasksForAI = tasksDataForAI;

      final tasksCount =
          (tasksForAI['data']?['results']?['successful'] as List?)?.length ?? 0;

      final authService = AuthService();
      final token = await authService.getToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final assignBody = {'employees': employeesForAI, 'tasks': tasksForAI};

      final assignResponse = await http
          .post(
            Uri.parse(assignTasksApiUrl),
            headers: headers,
            body: jsonEncode(assignBody),
          )
          .timeout(const Duration(seconds: 60));

      if (assignResponse.statusCode != 200 &&
          assignResponse.statusCode != 201) {
        throw Exception('AI assignment failed: ${assignResponse.statusCode}');
      }

      final assignResponseData =
          jsonDecode(assignResponse.body) as Map<String, dynamic>;

      if (assignResponseData['success'] != true ||
          assignResponseData['data'] == null) {
        throw Exception(
          assignResponseData['message']?.toString() ?? 'AI assignment failed',
        );
      }

      final assignmentsData =
          assignResponseData['data'] as Map<String, dynamic>;
      final assignments = assignmentsData['assignments'] as List<dynamic>?;

      if (assignments == null || assignments.isEmpty) {
        throw Exception('No assignments generated');
      }

      // Store the response for approval
      aiAssignmentsResponse = assignResponseData;

      final totalTasksSent = tasksCount;
      final assignmentsGenerated = assignments.length;
      final unassignedTasks =
          assignmentsData['unassigned_tasks'] as List<dynamic>? ?? [];
      final unassignedCount = unassignedTasks.length;

      final summary = assignmentsData['summary'] as Map<String, dynamic>?;

      final taskIdToNameMap = <String, String>{};
      final taskIdToRoleMap = <String, String>{};
      if (responseData['data'] != null && responseData['data'] is Map) {
        final dataField = responseData['data'] as Map<String, dynamic>;
        if (dataField['results'] != null && dataField['results'] is Map) {
          final results = dataField['results'] as Map<String, dynamic>;
          if (results['successful'] != null && results['successful'] is List) {
            final successfulTasksList = results['successful'] as List<dynamic>;
            for (var taskItem in successfulTasksList) {
              if (taskItem is Map<String, dynamic>) {
                var taskData = taskItem['data'] as Map<String, dynamic>?;
                if (taskData == null && taskItem['taskName'] != null) {
                  taskData = taskItem;
                }
                if (taskData != null) {
                  final taskId = taskData['_id']?.toString() ?? '';
                  final taskName = taskData['taskName']?.toString() ?? '';
                  final taskRole = taskData['targetRole']?.toString() ?? '';
                  if (taskId.isNotEmpty && taskName.isNotEmpty) {
                    taskIdToNameMap[taskId] = taskName;
                  }
                  if (taskId.isNotEmpty && taskRole.isNotEmpty) {
                    taskIdToRoleMap[taskId] = taskRole;
                  }
                }
              }
            }
          }
        }
      }

      final employeeIdToNameMap = <String, Map<String, String>>{};
      for (var empMap in employeesList) {
        if (empMap is Map<String, dynamic>) {
          final employeeId = empMap['employeeId']?.toString() ?? '';
          final employeeName = empMap['employeeName']?.toString() ?? '';
          final employeeRole = empMap['role']?.toString() ?? '';
          if (employeeId.isNotEmpty && employeeName.isNotEmpty) {
            employeeIdToNameMap[employeeId] = {
              'name': employeeName,
              'role': employeeRole,
            };
          }
        }
      }

      aiAssignments = [];
      for (var assignment in assignments) {
        final assignMap = assignment as Map<String, dynamic>;
        final taskId = assignMap['taskId']?.toString() ?? '';
        final employeeId = assignMap['employeeId']?.toString() ?? '';

        final taskName = taskIdToNameMap[taskId] ?? 'Unknown Task';
        final taskRole = taskIdToRoleMap[taskId] ?? '';

        final employeeInfo = employeeIdToNameMap[employeeId];
        final employeeName = employeeInfo?['name'] ?? 'Unknown Employee';
        final employeeRole = employeeInfo?['role'] ?? '';

        String formattedStartDate = 'N/A';
        String formattedEndDate = 'N/A';
        try {
          final startDateStr = assignMap['startDate']?.toString();
          final endDateStr = assignMap['endDate']?.toString();
          if (startDateStr != null && startDateStr.isNotEmpty) {
            final startDate = DateTime.tryParse(startDateStr);
            if (startDate != null) {
              formattedStartDate =
                  '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
            }
          }
          if (endDateStr != null && endDateStr.isNotEmpty) {
            final endDate = DateTime.tryParse(endDateStr);
            if (endDate != null) {
              formattedEndDate =
                  '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
            }
          }
        } catch (e) {}

        final estimatedHours = assignMap['estimatedHours'] is int
            ? assignMap['estimatedHours'] as int
            : assignMap['estimatedHours'] is num
            ? (assignMap['estimatedHours'] as num).toInt()
            : 0;

        final notes = assignMap['notes']?.toString() ?? '';

        aiAssignments.add({
          'taskId': taskId,
          'taskName': taskName,
          'taskRole': taskRole,
          'employeeId': employeeId,
          'employeeName': employeeName,
          'employeeRole': employeeRole,
          'startDate': formattedStartDate,
          'endDate': formattedEndDate,
          'estimatedHours': estimatedHours,
          'notes': notes,
        });
      }

      successfulAssignments = aiAssignments.map((assign) {
        return {
          'taskName': assign['taskName'],
          'taskRole': assign['taskRole'],
          'employeeName': assign['employeeName'],
          'startDate': assign['startDate'],
          'endDate': assign['endDate'],
          'estimatedHours': assign['estimatedHours'],
        };
      }).toList();

      isAssigningTasks = false;
      showAiAssignments = true;

      String successMessage =
          '${assignments.length} assignment(s) generated successfully!';
      if (unassignedCount > 0) {
        successMessage +=
            '\n\nNote: $unassignedCount task(s) were not assigned by AI';
      } else if (totalTasksSent > assignmentsGenerated) {
        final missingCount = totalTasksSent - assignmentsGenerated;
        successMessage += '\n\nNote: $missingCount task(s) were not assigned';
      } else if (totalTasksSent == assignmentsGenerated) {
        successMessage += '\n\nAll $totalTasksSent task(s) have been assigned!';
      }

      assignmentStatusTitle = 'Success';
      assignmentStatusMessage = successMessage;
      assignmentStatusColor = AppColor.successColor;
      showAssignmentStatus = true;

      acceptedTasksResponse = null;
      showAssignTasksButton = false;

      if (successfulAssignments.isNotEmpty) {
        showPdfButton = true;
        showApproveButton = true; // Show approve button after successful AI assignment
      }

      update();
    } catch (e, stackTrace) {
      isAssigningTasks = false;
      update();

      String errorMessage = 'Failed to assign tasks';
      if (e.toString().contains('timeout') ||
          e.toString().contains('Timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      assignmentStatusTitle = 'Error';
      assignmentStatusMessage = errorMessage;
      assignmentStatusColor = AppColor.errorColor;
      showAssignmentStatus = true;

      acceptedTasksResponse = null;
      showAssignTasksButton = false;
      showPdfButton = false;
      successfulAssignments = [];
      update();
    }
  }

  Future<void> downloadAssignmentsPDF() async {
    if (successfulAssignments.isEmpty) {
      Get.snackbar(
        'Error',
        'No assignments available to generate PDF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isGeneratingPdf = true;
    update();

    try {
      final file = await PDFService.generateAssignmentsPDF(
        successfulAssignments,
      );

      if (file != null && await file.exists()) {
        final fileSize = await file.length();

        try {
          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'application/pdf')],
            text: 'Task Assignments Report',
            subject:
                'Task Assignments - ${DateTime.now().toString().split(' ')[0]}',
          );
        } catch (shareError) {
          try {
            final result = await OpenFile.open(file.path);
            if (result.type == ResultType.done) {
              Get.snackbar(
                'PDF Opened',
                'PDF opened successfully in default app',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColor.successColor,
                colorText: AppColor.white,
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
              );
            } else {
              throw Exception('Failed to open file: ${result.message}');
            }
          } catch (openError) {
            Get.snackbar(
              'PDF Generated Successfully!',
              'PDF saved at: ${file.path}\n\nTap to copy path',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColor.successColor,
              colorText: AppColor.white,
              duration: const Duration(seconds: 8),
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
              onTap: (snack) {
                Clipboard.setData(ClipboardData(text: file.path));
                Get.snackbar(
                  'Path Copied',
                  'File path copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColor.primaryColor,
                  colorText: AppColor.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                );
              },
            );
          }
        }

        Get.snackbar(
          'Success',
          'PDF generated and saved successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.successColor,
          colorText: AppColor.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } else {
        throw Exception('PDF file was not created successfully');
      }
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to generate PDF';
      if (e.toString().contains('permission')) {
        errorMessage =
            'Storage permission denied. Please grant permission to save PDF.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'PDF generation timed out. Please try again.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isGeneratingPdf = false;
      update();
    }
  }

  Future<void> approveAssignments() async {
    if (aiAssignmentsResponse == null) {
      Get.snackbar(
        'Error',
        'No assignments to approve',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isApprovingAssignments = true;
    update();

    try {
      final assignmentsData =
          aiAssignmentsResponse!['data'] as Map<String, dynamic>;
      final assignments = assignmentsData['assignments'] as List<dynamic>?;

      if (assignments == null || assignments.isEmpty) {
        throw Exception('No assignments found in response');
      }

      // Convert assignments to the format required by the API
      final List<Map<String, dynamic>> assignmentsToSend = [];
      for (var assignment in assignments) {
        final assignMap = assignment as Map<String, dynamic>;
        assignmentsToSend.add({
          'taskId': assignMap['taskId']?.toString() ?? '',
          'employeeId': assignMap['employeeId']?.toString() ?? '',
          'startDate': assignMap['startDate']?.toString() ?? '',
          'endDate': assignMap['endDate']?.toString() ?? '',
          'estimatedHours': assignMap['estimatedHours'] is int
              ? assignMap['estimatedHours'] as int
              : assignMap['estimatedHours'] is num
                  ? (assignMap['estimatedHours'] as num).toInt()
                  : 0,
          'notes': assignMap['notes']?.toString() ?? '',
        });
      }

      final result = await _assignmentsRepository.createBulkAssignments(
        assignments: assignmentsToSend,
      );

      isApprovingAssignments = false;
      result.fold(
        (error) {
          String errorMsg = error['message']?.toString() ??
              'Failed to approve assignments';
          Get.snackbar(
            'Error',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.errorColor,
            colorText: AppColor.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          );
          update();
        },
        (response) {
          showApproveButton = false;
          aiAssignmentsResponse = null;
          Get.snackbar(
            'Success',
            'Assignments approved and created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.successColor,
            colorText: AppColor.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
          update();
        },
      );
    } catch (e) {
      isApprovingAssignments = false;
      String errorMessage = 'Failed to approve assignments';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      update();
    }
  }
}
