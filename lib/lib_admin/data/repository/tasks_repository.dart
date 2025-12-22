import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import '../Models/task_model.dart';
class TasksRepository {
  final ApiService _apiService = ApiService();
  Future<Either<StatusRequest, List<TaskModel>>> getTasks({
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('🔵 TasksRepository: Getting tasks...');
    debugPrint('Page: $page, Limit: $limit');
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      debugPrint('Query params: $queryParams');
      final finalUrl =
          '${ApiConstant.baseUrl}${ApiConstant.tasks}?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      debugPrint('🔵 Final API URL: $finalUrl');
      final result = await _apiService.get(
        ApiConstant.tasks,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 TasksRepository error: $error');
          debugPrint('🔴 Error type: ${error.runtimeType}');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 TasksRepository response received');
            debugPrint('🟢 Full response: $response');
            debugPrint('🟢 Response keys: ${response.keys}');
            debugPrint('🟢 Response type: ${response.runtimeType}');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              debugPrint('🟢 Data type: ${data.runtimeType}');
              debugPrint('🟢 Data: $data');
              List<dynamic> tasksList;
              if (data is List) {
                tasksList = data;
                debugPrint(
                  '🟢 Found direct array format with ${tasksList.length} items',
                );
              } else if (data is Map<String, dynamic>) {
                if (data['tasks'] is List) {
                  tasksList = data['tasks'] as List<dynamic>;
                  if (data['pagination'] != null) {
                    final pagination =
                        data['pagination'] as Map<String, dynamic>;
                    debugPrint(
                      '🟢 Pagination: page=${pagination['page']}, limit=${pagination['limit']}, total=${pagination['total']}, totalPages=${pagination['totalPages']}',
                    );
                  }
                } else if (data['data'] is List) {
                  tasksList = data['data'] as List<dynamic>;
                } else {
                  debugPrint('🔴 Unexpected data format: ${data.runtimeType}');
                  return const Left(StatusRequest.serverFailure);
                }
              } else {
                debugPrint('🔴 Unexpected data format: ${data.runtimeType}');
                return const Left(StatusRequest.serverFailure);
              }
              debugPrint('🟢 Found ${tasksList.length} tasks in list');
              final tasks = tasksList.map((item) {
                try {
                  return TaskModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('🔴 Error parsing task: $e');
                  debugPrint('🔴 Task data: $item');
                  rethrow;
                }
              }).toList();
              debugPrint('✅ Successfully parsed ${tasks.length} tasks');
              return Right(tasks);
            } else {
              debugPrint('🔴 Response validation failed:');
              debugPrint('🔴 success: ${response['success']}');
              debugPrint('🔴 message: ${response['message']}');
              debugPrint('🔴 data: ${response['data']}');
              debugPrint('🔴 data is null: ${response['data'] == null}');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Task parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TasksRepository exception: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, TaskModel>> createTask({
    required String projectId,
    required String taskName,
    required String taskDescription,
    required String taskPriority,
    required String taskStatus,
    required int minEstimatedHour,
    required int maxEstimatedHour,
    required String targetRole,
    List<String>? attachments,
  }) async {
    debugPrint('🔵 TasksRepository: Creating task...');
    try {
      final body = {
        'projectId': projectId,
        'taskName': taskName,
        'taskDescription': taskDescription,
        'taskPriority': taskPriority,
        'taskStatus': taskStatus,
        'minEstimatedHour': minEstimatedHour,
        'maxEstimatedHour': maxEstimatedHour,
        'targetRole': targetRole,
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments,
      };
      debugPrint('Request body: $body');
      final result = await _apiService.post(
        ApiConstant.createTask,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 TasksRepository createTask error: $error');
          return Left(error);
        },
        (response) {
          debugPrint(
            '🟢 TasksRepository createTask response received: $response',
          );
          if (response['success'] == true && response['data'] != null) {
            final taskData = response['data'] as Map<String, dynamic>;
            final task = TaskModel.fromJson(taskData);
            debugPrint('✅ Successfully created task: ${task.title}');
            return Right(task);
          } else {
            debugPrint('🔴 Create task failed: ${response['message']}');
            return const Left(StatusRequest.serverFailure);
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 TasksRepository createTask exception: $e');
      debugPrint('Stack trace: $stackTrace');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<String, TaskModel>> updateTask({
    required String taskId,
    required String taskStatus,
    String? taskName,
    String? taskPriority,
    int? minEstimatedHour,
    int? maxEstimatedHour,
    String? targetRole,
    List<String>? existingAttachments,
    List<String>? attachments,
  }) async {
    debugPrint('🔵 TasksRepository: Updating task...');
    debugPrint('🔵 TaskId: $taskId');
    debugPrint('🔵 TaskStatus: $taskStatus');
    try {
      final body = <String, dynamic>{'taskStatus': taskStatus};
      if (taskName != null && taskName.isNotEmpty) {
        body['taskName'] = taskName;
      }
      if (taskPriority != null && taskPriority.isNotEmpty) {
        body['taskPriority'] = taskPriority;
      }
      if (minEstimatedHour != null) {
        body['minEstimatedHour'] = minEstimatedHour;
      }
      if (maxEstimatedHour != null) {
        body['maxEstimatedHour'] = maxEstimatedHour;
      }
      if (targetRole != null && targetRole.isNotEmpty) {
        body['targetRole'] = targetRole;
      }
      if (existingAttachments != null) {
        body['existingAttachments'] = existingAttachments;
      }
      if (attachments != null && attachments.isNotEmpty) {
        body['attachments'] = attachments;
      }
      debugPrint('🔵 Request body: $body');
      final result = await _apiService.put(
        ApiConstant.updateTask,
        pathParams: {'id': taskId},
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 TasksRepository error updating task: $error');
          String errorMsg = 'Failed to update task';
          if (error == StatusRequest.serverFailure) {
            errorMsg = 'Server error. Please try again.';
          } else if (error == StatusRequest.offlineFailure) {
            errorMsg = 'No internet connection. Please check your network.';
          } else if (error == StatusRequest.timeoutException) {
            errorMsg = 'Request timed out. Please try again.';
          } else if (error == StatusRequest.serverException) {
            errorMsg = 'An unexpected server error occurred.';
          }
          return Left(errorMsg);
        },
        (response) {
          try {
            debugPrint('🟢 TasksRepository update task response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == false || response['success'] == null) {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update task';
              debugPrint('🔴 API returned success: false or null');
              debugPrint('🔴 Error message: $errorMessage');
              return Left(errorMessage);
            }
            if (response['success'] == true && response['data'] != null) {
              final taskData = response['data'] as Map<String, dynamic>;
              final task = TaskModel.fromJson(taskData);
              debugPrint('✅ Successfully updated task: ${task.title}');
              return Right(task);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update task';
              debugPrint('🔴 Failed to update task');
              debugPrint(
                '🔴 Response structure: success=${response['success']}, data=${response['data']}',
              );
              debugPrint('🔴 Error message: $errorMessage');
              return Left(errorMessage);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Task update parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(
              'An unexpected error occurred while updating task.',
            );
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TasksRepository exception updating task: $e');
      return const Left('An unexpected error occurred while updating task.');
    }
  }
  Future<Either<StatusRequest, bool>> deleteTask(String taskId) async {
    debugPrint('🔵 TasksRepository: Deleting task...');
    debugPrint('🔵 TaskId: $taskId');
    try {
      final result = await _apiService.delete(
        ApiConstant.deleteTask,
        pathParams: {'id': taskId},
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 TasksRepository error deleting task: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 TasksRepository delete task response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == true) {
              debugPrint('✅ Successfully deleted task');
              return const Right(true);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete task';
              debugPrint('🔴 Failed to delete task');
              debugPrint('🔴 Error message: $errorMessage');
              return Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Task delete parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TasksRepository exception deleting task: $e');
      return const Left(StatusRequest.serverException);
    }
  }
}
