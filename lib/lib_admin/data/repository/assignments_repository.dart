import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint(
      '🔵 AssignmentsRepository: Getting assignments for employee $employeeId...',
    );
    debugPrint('Page: $page, Limit: $limit');
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      debugPrint('Query params: $queryParams');
      final result = await _apiService.get(
        ApiConstant.taskAssignmentsByEmployee,
        pathParams: {'employeeId': employeeId},
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 AssignmentsRepository error: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 AssignmentsRepository response received');
            debugPrint('🟢 Full response: $response');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              debugPrint('🟢 Data type: ${data.runtimeType}');
              debugPrint('🟢 Data: $data');
              List<dynamic> assignmentsList;
              if (data is List) {
                assignmentsList = data;
                debugPrint(
                  '🟢 Found direct array format with ${assignmentsList.length} items',
                );
              } else if (data is Map<String, dynamic>) {
                if (data['assignments'] is List) {
                  assignmentsList = data['assignments'] as List<dynamic>;
                  if (data['pagination'] != null) {
                    final pagination =
                        data['pagination'] as Map<String, dynamic>;
                    debugPrint(
                      '🟢 Pagination: page=${pagination['page']}, limit=${pagination['limit']}, total=${pagination['total']}, totalPages=${pagination['totalPages']}',
                    );
                  }
                } else if (data['data'] is List) {
                  assignmentsList = data['data'] as List<dynamic>;
                } else {
                  debugPrint('🔴 Unexpected data format: ${data.runtimeType}');
                  return const Left(StatusRequest.serverFailure);
                }
              } else {
                debugPrint('🔴 Unexpected data format: ${data.runtimeType}');
                return const Left(StatusRequest.serverFailure);
              }
              debugPrint(
                '🟢 Found ${assignmentsList.length} assignments in list',
              );
              final assignments = assignmentsList.map((item) {
                try {
                  return AssignmentModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('🔴 Error parsing assignment: $e');
                  debugPrint('🔴 Assignment data: $item');
                  rethrow;
                }
              }).toList();
              debugPrint(
                '✅ Successfully parsed ${assignments.length} assignments',
              );
              return Right(assignments);
            } else {
              debugPrint('🔴 Response validation failed:');
              debugPrint('🔴 success: ${response['success']}');
              debugPrint('🔴 message: ${response['message']}');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Assignment parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 AssignmentsRepository exception: $e');
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
    debugPrint('🔵 AssignmentsRepository: Creating assignment...');
    try {
      final body = {
        'taskId': taskId,
        'employeeId': employeeId,
        'startDate': startDate,
        'endDate': endDate,
        'estimatedHours': estimatedHours,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      debugPrint('Request body: $body');
      final result = await _apiService.post(
        ApiConstant.createTaskAssignment,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 AssignmentsRepository createAssignment error: $error');
          return Left({'error': error, 'message': null});
        },
        (response) {
          debugPrint(
            '🟢 AssignmentsRepository createAssignment response received: $response',
          );
          if (response['success'] == true && response['data'] != null) {
            final assignmentData = response['data'] as Map<String, dynamic>;
            final assignment = AssignmentModel.fromJson(assignmentData);
            debugPrint(
              '✅ Successfully created assignment: ${assignment.taskName}',
            );
            return Right(assignment);
          } else {
            final errorMsg =
                response['message']?.toString() ??
                'Failed to create assignment';
            debugPrint('🔴 Create assignment failed: $errorMsg');
            return Left({
              'error': StatusRequest.serverFailure,
              'message': errorMsg,
            });
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 AssignmentsRepository createAssignment exception: $e');
      debugPrint('Stack trace: $stackTrace');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<dynamic, Map<String, dynamic>>> createBulkAssignments({
    required List<Map<String, dynamic>> assignments,
  }) async {
    debugPrint('🔵 AssignmentsRepository: Creating bulk assignments...');
    debugPrint('Number of assignments: ${assignments.length}');
    try {
      final body = {'assignments': assignments};
      debugPrint('Request body: $body');
      final result = await _apiService.post(
        ApiConstant.bulkCreateTaskAssignment,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint(
            '🔴 AssignmentsRepository createBulkAssignments error: $error',
          );
          return Left({'error': error, 'message': null});
        },
        (response) {
          debugPrint(
            '🟢 AssignmentsRepository createBulkAssignments response received: $response',
          );
          if (response['success'] == true && response['data'] != null) {
            final data = response['data'] as Map<String, dynamic>;
            debugPrint('✅ Successfully processed bulk assignments');
            return Right(data);
          } else {
            final errorMsg =
                response['message']?.toString() ??
                'Failed to create bulk assignments';
            debugPrint('🔴 Create bulk assignments failed: $errorMsg');
            return Left({
              'error': StatusRequest.serverFailure,
              'message': errorMsg,
            });
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 AssignmentsRepository createBulkAssignments exception: $e',
      );
      debugPrint('Stack trace: $stackTrace');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, Map<String, dynamic>>> getEmployeeSchedule({
    required String employeeId,
    required String startDate,
    required String endDate,
  }) async {
    debugPrint('🔵 AssignmentsRepository: Getting employee schedule...');
    debugPrint('EmployeeId: $employeeId');
    debugPrint('StartDate: $startDate, EndDate: $endDate');
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
          debugPrint(
            '🔴 AssignmentsRepository getEmployeeSchedule error: $error',
          );
          return Left(error);
        },
        (response) {
          debugPrint(
            '🟢 AssignmentsRepository getEmployeeSchedule response received',
          );
          if (response['success'] == true && response['data'] != null) {
            return Right(response['data'] as Map<String, dynamic>);
          } else {
            debugPrint(
              '🔴 Get employee schedule failed: ${response['message']}',
            );
            return const Left(StatusRequest.serverFailure);
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 AssignmentsRepository getEmployeeSchedule exception: $e');
      debugPrint('Stack trace: $stackTrace');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, Map<String, dynamic>>> getAssignmentsByTask({
    required String taskId,
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint(
      '🔵 AssignmentsRepository: Getting assignments for task $taskId...',
    );
    debugPrint('Page: $page, Limit: $limit');
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
          debugPrint(
            '🔴 AssignmentsRepository getAssignmentsByTask error: $error',
          );
          return Left(error);
        },
        (response) {
          debugPrint(
            '🟢 AssignmentsRepository getAssignmentsByTask response received',
          );
          if (response['success'] == true && response['data'] != null) {
            return Right(response['data'] as Map<String, dynamic>);
          } else {
            debugPrint(
              '🔴 Get assignments by task failed: ${response['message']}',
            );
            return const Left(StatusRequest.serverFailure);
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 AssignmentsRepository getAssignmentsByTask exception: $e');
      debugPrint('Stack trace: $stackTrace');
      return const Left(StatusRequest.serverException);
    }
  }
}
