import 'package:dartz/dartz.dart';
import 'package:project_hub/lib_client/core/services/api_service.dart';
import 'package:project_hub/lib_client/data/Models/task_model.dart';

class TaskRepository {
  final ApiService _apiService = ApiService();

  Future<Either<String, List<TaskModel>>> getAllTasks({
    String? status,
    String? projectId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status != 'All') {
        queryParams['taskStatus'] = status.toLowerCase();
      }
      if (projectId != null) {
        queryParams['projectId'] = projectId;
      }

      final response = await _apiService.get(
        '/task',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        final dataObj = data['data'] as Map<String, dynamic>;
        if (dataObj['tasks'] != null && dataObj['tasks'] is List) {
          final tasks = (dataObj['tasks'] as List)
              .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
              .toList();
          return Right(tasks);
        }
        if (dataObj is List) {
          final tasks = (dataObj as List)
              .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
              .toList();
          return Right(tasks);
        }
      }
      
      return Left('No tasks found');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<TaskModel>>> getTasksByProject(
    String projectId, {
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status != 'All') {
        queryParams['taskStatus'] = status.toLowerCase();
      }

      final response = await _apiService.get(
        '/task/project/$projectId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        final dataObj = data['data'] as Map<String, dynamic>;
        if (dataObj['tasks'] != null && dataObj['tasks'] is List) {
          final tasks = (dataObj['tasks'] as List)
              .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
              .toList();
          return Right(tasks);
        }
      }
      
      return Left('No tasks found for this project');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, TaskModel>> getTaskById(String id) async {
    try {
      final response = await _apiService.get('/task/$id');
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        final task = TaskModel.fromJson(data['data'] as Map<String, dynamic>);
        return Right(task);
      }
      
      return Left('Task not found');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, TaskModel>> createTask(TaskModel task) async {
    try {
      final response = await _apiService.post(
        '/task',
        body: task.toJson(),
      );
      
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        final createdTask = TaskModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        return Right(createdTask);
      }
      
      return Left('Failed to create task');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, TaskModel>> updateTask(TaskModel task) async {
    try {
      if (task.id == null) {
        return Left('Task ID is required for update');
      }

      final response = await _apiService.put(
        '/task/${task.id}',
        body: task.toJson(),
      );
      
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        final updatedTask = TaskModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        return Right(updatedTask);
      }
      
      return Left('Failed to update task');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> deleteTask(String id) async {
    try {
      final response = await _apiService.delete('/task/$id');
      _apiService.handleResponse(response);
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, TaskModel>> updateTaskStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await _apiService.patch(
        '/task/$id/status',
        body: {'taskStatus': status.toLowerCase()},
      );
      
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        final updatedTask = TaskModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        return Right(updatedTask);
      }
      
      return Left('Failed to update task status');
    } catch (e) {
      return Left(e.toString());
    }
  }
}

