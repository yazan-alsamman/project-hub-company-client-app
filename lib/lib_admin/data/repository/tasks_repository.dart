import 'package:dartz/dartz.dart';
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
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final result = await _apiService.get(
        ApiConstant.tasks,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) => Left(error),
        (response) {
          try {
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              List<dynamic> tasksList;
              if (data is List) {
                tasksList = data;
              } else if (data is Map<String, dynamic>) {
                if (data['tasks'] is List) {
                  tasksList = data['tasks'] as List<dynamic>;
                } else if (data['data'] is List) {
                  tasksList = data['data'] as List<dynamic>;
                } else {
                  return const Left(StatusRequest.serverFailure);
                }
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              final tasks = tasksList.map((item) {
                return TaskModel.fromJson(item as Map<String, dynamic>);
              }).toList();
              return Right(tasks);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
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
      final result = await _apiService.post(
        ApiConstant.createTask,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) => Left(error),
        (response) {
          if (response['success'] == true && response['data'] != null) {
            final taskData = response['data'] as Map<String, dynamic>;
            final task = TaskModel.fromJson(taskData);
            return Right(task);
          } else {
            return const Left(StatusRequest.serverFailure);
          }
        },
      );
    } catch (e) {
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
      final result = await _apiService.put(
        ApiConstant.updateTask,
        pathParams: {'id': taskId},
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
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
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update task';
              return Left(errorMessage);
            }
            if (response['success'] == true && response['data'] != null) {
              final taskData = response['data'] as Map<String, dynamic>;
              final task = TaskModel.fromJson(taskData);
              return Right(task);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update task';
              return Left(errorMessage);
            }
          } catch (e) {
            return const Left(
              'An unexpected error occurred while updating task.',
            );
          }
        },
      );
    } catch (e) {
      return const Left('An unexpected error occurred while updating task.');
    }
  }

  Future<Either<StatusRequest, bool>> deleteTask(String taskId) async {
    try {
      final result = await _apiService.delete(
        ApiConstant.deleteTask,
        pathParams: {'id': taskId},
        requiresAuth: true,
      );
      return result.fold(
        (error) => Left(error),
        (response) {
          try {
            if (response['success'] == true) {
              return const Right(true);
            } else {
              return Left(StatusRequest.serverFailure);
            }
          } catch (e) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, bool>> requestTaskDelay({
    required String taskId,
    required String newDueDate,
    required String reason,
  }) async {
    try {
      final body = <String, dynamic>{
        'newDueDate': newDueDate,
        'reason': reason,
      };
      final result = await _apiService.post(
        ApiConstant.requestTaskDelay,
        pathParams: {'id': taskId},
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) => Left(error),
        (response) {
          try {
            if (response['success'] == true) {
              return const Right(true);
            } else {
              return Left(StatusRequest.serverFailure);
            }
          } catch (e) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, List<TaskModel>>> getTasksByProject({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final result = await _apiService.get(
        ApiConstant.tasksByProject,
        pathParams: {'projectId': projectId},
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) => Left(error),
        (response) {
          try {
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              List<dynamic> tasksList;
              if (data is List) {
                tasksList = data;
              } else if (data is Map<String, dynamic>) {
                if (data['tasks'] is List) {
                  tasksList = data['tasks'] as List<dynamic>;
                } else if (data['data'] is List) {
                  tasksList = data['data'] as List<dynamic>;
                } else {
                  return const Left(StatusRequest.serverFailure);
                }
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              final tasks = tasksList.map((item) {
                return TaskModel.fromJson(item as Map<String, dynamic>);
              }).toList();
              return Right(tasks);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> bulkCreateTasks({
    required String projectId,
    required List<Map<String, dynamic>> tasks,
  }) async {
    try {
      final body = {
        'projectId': projectId,
        'tasks': tasks,
      };
      final result = await _apiService.post(
        ApiConstant.bulkCreateTasks,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) => Left(error),
        (response) {
          if (response['success'] == true) {
            return Right(response);
          } else {
            return const Left(StatusRequest.serverFailure);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }
}
