import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../data/Models/task_model.dart';
import '../../data/Models/project_model.dart';
import '../../data/repository/projects_repository.dart';
import '../../data/repository/tasks_repository.dart';
import '../../core/services/auth_service.dart';

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
  double? generationTime; // Time taken to generate tasks in seconds
  
  // Pagination variables
  int currentPage = 1;
  static const int itemsPerPage = 10;
  bool viewAll = false;

  static const String aiApiUrl = 'https://daliliai.com/api/ai/generate';

  @override
  void onInit() {
    super.onInit();
    numTasksController.text = '10'; // Default value
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

    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();

    try {
      debugPrint('🔵 Generating tasks with AI...');
      debugPrint('Project Description: $projectDescription');
      debugPrint('Number of Tasks: $numTasks');

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

      debugPrint('🟢 AI API Response Status: ${response.statusCode}');
      debugPrint('🟢 AI API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Parse the response - assuming it returns tasks in a 'tasks' or 'data' field
        List<dynamic> tasksList = [];
        if (responseData['tasks'] != null && responseData['tasks'] is List) {
          tasksList = responseData['tasks'] as List<dynamic>;
        } else if (responseData['data'] != null && responseData['data'] is List) {
          tasksList = responseData['data'] as List<dynamic>;
        } else if (responseData is List) {
          tasksList = responseData as List<dynamic>;
        }

        if (tasksList.isEmpty) {
          // If no tasks array, try to parse as single task or different structure
          debugPrint('⚠️ No tasks array found, trying alternative parsing...');
          // You might need to adjust this based on actual API response structure
        }

        generatedTasks = tasksList.asMap().entries.map((entry) {
          final index = entry.key;
          final taskJson = entry.value;
          try {
            // Convert AI response to TaskModel format
            final taskMap = taskJson is Map<String, dynamic>
                ? taskJson
                : <String, dynamic>{};

            // Extract task name
            final taskName = taskMap['task']?.toString() ?? 
                            taskMap['taskName']?.toString() ?? 
                            taskMap['title']?.toString() ?? 
                            'Untitled Task';

            // Extract role
            final role = taskMap['role']?.toString() ?? 'Unassigned';
            
            // Extract priority and convert to code
            final priorityStr = taskMap['priority']?.toString() ?? 'Medium';
            final priorityCode = _convertPriorityToCode(priorityStr);
            final priorityDisplay = _mapPriorityFromAI(priorityCode);

            // Extract time information
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
                // Convert to hours (approximate)
                minEstimatedHour = hours;
                maxEstimatedHour = hours + (minutes > 0 ? 1 : 0);
              }
            }

            // Generate initials from role
            final roleInitials = role.isNotEmpty
                ? role.substring(0, 1).toUpperCase()
                : 'UA';

            // Get avatar color based on role
            final avatarColor = _getAvatarColorFromRole(role);

            // Create a TaskModel from the AI response
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
            debugPrint('🔴 Error parsing task: $e');
            debugPrint('🔴 Task data: $taskJson');
            // Return a default task if parsing fails
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

        // Extract generation time from response
        if (responseData['generation_time'] != null) {
          generationTime = responseData['generation_time'] is double
              ? responseData['generation_time'] as double
              : responseData['generation_time'] is int
                  ? (responseData['generation_time'] as int).toDouble()
                  : responseData['generation_time'] is num
                      ? (responseData['generation_time'] as num).toDouble()
                      : null;
        }

        debugPrint('✅ Successfully generated ${generatedTasks.length} tasks');
        debugPrint('⏱️ Generation time: ${generationTime ?? 'N/A'} seconds');
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
        // Parse error response
        String errorMessage = 'Failed to generate tasks';
        try {
          final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
          
          // Check for detail array (validation errors)
          if (errorResponse['detail'] != null && errorResponse['detail'] is List) {
            final detailList = errorResponse['detail'] as List<dynamic>;
            if (detailList.isNotEmpty) {
              // Extract messages from detail array
              final messages = detailList.map((error) {
                if (error is Map<String, dynamic> && error['msg'] != null) {
                  return error['msg'].toString();
                }
                return null;
              }).where((msg) => msg != null).toList();
              
              if (messages.isNotEmpty) {
                errorMessage = messages.join('\n');
              }
            }
          } 
          // Check for message field
          else if (errorResponse['message'] != null) {
            errorMessage = errorResponse['message'].toString();
          }
          // Check for error field
          else if (errorResponse['error'] != null) {
            errorMessage = errorResponse['error'].toString();
          }
        } catch (e) {
          debugPrint('🔴 Error parsing error response: $e');
          errorMessage = 'Failed to generate tasks';
        }
        
        debugPrint('🔴 AI API Error: $errorMessage');
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
      debugPrint('🔴 Exception generating tasks: $e');
      debugPrint('🔴 Stack trace: $stackTrace');
      statusRequest = StatusRequest.serverException;
      
      String errorMessage = 'Failed to generate tasks';
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup')) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
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
    update();
  }

  // Get tasks for current page
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

  // Get total number of pages
  int get totalPages {
    if (generatedTasks.isEmpty) return 0;
    return (generatedTasks.length / itemsPerPage).ceil();
  }

  // Check if pagination is needed
  bool get needsPagination {
    return generatedTasks.length > itemsPerPage;
  }

  // Navigate to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
      viewAll = false;
      update();
      // Scroll to top of tasks list
    }
  }

  // Go to next page
  void nextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      viewAll = false;
      update();
    }
  }

  // Go to previous page
  void previousPage() {
    if (currentPage > 1) {
      currentPage--;
      viewAll = false;
      update();
    }
  }

  // Toggle view all
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

  Future<void> showProjectSelectionDialog(BuildContext context) async {
    try {
      // Get company ID
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

      // Load projects
      final projectsRepository = ProjectsRepository();
      final result = await projectsRepository.getProjects(
        companyId: companyId,
        page: 1,
        limit: 100, // Get more projects for selection
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

          // Show dialog
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
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Code: ${project.code}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.textSecondaryColor,
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
                                  _acceptTasksForProject(project.id, project.title);
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
      debugPrint('🔴 Error showing project selection dialog: $e');
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

  Future<void> _acceptTasksForProject(String projectId, String projectTitle) async {
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

    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Convert TaskModel to API format
      final tasksForApi = generatedTasks.map((task) {
        // Convert priority from H/M/L to High/Medium/Low
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

        // Get hours and minutes from estimated hours
        int hours = task.minEstimatedHour ?? 0;
        int minutes = 0;
        
        // If there's a range, use the average or max
        if (task.maxEstimatedHour != null && task.maxEstimatedHour! > hours) {
          hours = task.maxEstimatedHour!;
        }

        // Extract role from category or targetRole
        String role = task.category.isNotEmpty 
            ? task.category 
            : (task.targetRole ?? 'Unassigned');

        return {
          'task': task.title,
          'role': role,
          'priority': priority,
          'time': {
            'hours': hours,
            'minutes': minutes,
          },
        };
      }).toList();

      debugPrint('🔵 Sending ${tasksForApi.length} tasks to project: $projectTitle');
      debugPrint('🔵 Project ID: $projectId');

      // Send to API
      final tasksRepository = TasksRepository();
      final result = await tasksRepository.bulkCreateTasks(
        projectId: projectId,
        tasks: tasksForApi,
      );

      Get.back(); // Close loading dialog

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
          final message = response['message']?.toString() ?? 
              'Tasks created successfully';

          debugPrint('✅ Bulk create result:');
          debugPrint('  Total: $total');
          debugPrint('  Success: $successCount');
          debugPrint('  Failed: $failureCount');

          if (failureCount > 0) {
            // Partial success
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
            // Full success
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

          // Clear generated tasks after successful creation
          clearGeneratedTasks();
        },
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      debugPrint('🔴 Exception accepting tasks: $e');
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

    // Check if contains commas or other non-numeric characters (except digits)
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
}

