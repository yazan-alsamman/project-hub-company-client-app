import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../data/Models/task_model.dart';

abstract class AiAssistanceController extends GetxController {
  void generateTasks(String projectDescription, int numTasks);
  void clearGeneratedTasks();
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
        final errorMessage = jsonDecode(response.body)['message']?.toString() ?? 
                            'Failed to generate tasks';
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

