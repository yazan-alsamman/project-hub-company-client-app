import 'package:dartz/dartz.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import '../Models/assignment_model.dart';
class AssignmentsRepository {
  final ApiService _apiService = ApiService();
  Future<Either<StatusRequest, List<AssignmentModel>>>
  getAssignmentsByEmployee({
    required String employeeId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final result = await _apiService.get(
        ApiConstant.taskAssignmentsByEmployee,
        pathParams: {'employeeId': employeeId},
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              List<dynamic> assignmentsList;
              if (data is List) {
                assignmentsList = data;
              } else if (data is Map<String, dynamic>) {
                if (data['assignments'] is List) {
                  assignmentsList = data['assignments'] as List<dynamic>;
                } else if (data['data'] is List) {
                  assignmentsList = data['data'] as List<dynamic>;
                } else {
                  return const Left(StatusRequest.serverFailure);
                }
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              final assignments = assignmentsList.map((item) {
                try {
                  return AssignmentModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  rethrow;
                }
              }).toList();
              return Right(assignments);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<dynamic, AssignmentModel>> createAssignment({
    required String taskId,
    required String employeeId,
    required String startDate,
    required String endDate,
    required int estimatedHours,
    String? notes,
  }) async {
    try {
      final body = {
        'taskId': taskId,
        'employeeId': employeeId,
        'startDate': startDate,
        'endDate': endDate,
        'estimatedHours': estimatedHours,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      final result = await _apiService.post(
        ApiConstant.createTaskAssignment,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({'error': error, 'message': null});
        },
        (response) {
          if (response['success'] == true && response['data'] != null) {
            final assignmentData = response['data'] as Map<String, dynamic>;
            final assignment = AssignmentModel.fromJson(assignmentData);
            return Right(assignment);
          } else {
            final errorMsg =
                response['message']?.toString() ??
                'Failed to create assignment';
            return Left({
              'error': StatusRequest.serverFailure,
              'message': errorMsg,
            });
          }
        },
      );
    } catch (e, stackTrace) {
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<dynamic, Map<String, dynamic>>> createBulkAssignments({
    required List<Map<String, dynamic>> assignments,
  }) async {
    try {
      final body = {'assignments': assignments};
      final result = await _apiService.post(
        ApiConstant.bulkCreateTaskAssignment,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({'error': error, 'message': null});
        },
        (response) {
          if (response['success'] == true && response['data'] != null) {
            final data = response['data'] as Map<String, dynamic>;
            return Right(data);
          } else {
            final errorMsg =
                response['message']?.toString() ??
                'Failed to create bulk assignments';
            return Left({
              'error': StatusRequest.serverFailure,
              'message': errorMsg,
            });
          }
        },
      );
    } catch (e, stackTrace) {
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, Map<String, dynamic>>> getEmployeeSchedule({
    required String employeeId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'startDate': startDate,
        'endDate': endDate,
      };
      final result = await _apiService.get(
        ApiConstant.employeeSchedule,
        pathParams: {'employeeId': employeeId},
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          if (response['success'] == true && response['data'] != null) {
            return Right(response['data'] as Map<String, dynamic>);
          } else {
            return const Left(StatusRequest.serverFailure);
          }
        },
      );
    } catch (e, stackTrace) {
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, Map<String, dynamic>>> getAssignmentsByTask({
    required String taskId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final result = await _apiService.get(
        ApiConstant.taskAssignmentsByTask,
        pathParams: {'taskId': taskId},
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          if (response['success'] == true && response['data'] != null) {
            return Right(response['data'] as Map<String, dynamic>);
          } else {
            return const Left(StatusRequest.serverFailure);
          }
        },
      );
    } catch (e, stackTrace) {
      return const Left(StatusRequest.serverException);
    }
  }
}
