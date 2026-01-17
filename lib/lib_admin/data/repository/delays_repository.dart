import 'package:dartz/dartz.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';

class DelaysRepository {
  final ApiService _apiService = ApiService();

  String _getErrorMessage(StatusRequest error) {
    switch (error) {
      case StatusRequest.serverFailure:
        return 'Server error. Please try again.';
      case StatusRequest.offlineFailure:
        return 'No internet connection. Please check your network.';
      case StatusRequest.timeoutException:
        return 'Request timed out. Please try again.';
      case StatusRequest.serverException:
        return 'An unexpected error occurred.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getDelaySummary() async {
    try {
      final result = await _apiService.get(
        ApiConstant.projectDelaySummary,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              return Right(data);
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

  Future<Either<StatusRequest, Map<String, dynamic>>> getAllProjectsDelayStatus({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final result = await _apiService.get(
        ApiConstant.projectDelay,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              return Right(data);
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

  Future<Either<StatusRequest, Map<String, dynamic>>> getProjectDelayStatus(
    String projectId,
  ) async {
    try {
      final result = await _apiService.get(
        ApiConstant.projectDelayByProject,
        pathParams: {'projectId': projectId},
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              return Right(data);
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

  Future<Either<StatusRequest, Map<String, dynamic>>> getProjectTaskDelays({
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
        ApiConstant.projectTaskDelays,
        pathParams: {'projectId': projectId},
        queryParams: queryParams,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              return Right(data);
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

  Future<Either<dynamic, bool>> acceptDelayRequest({
    required String delayRequestId,
    required String reviewNote,
  }) async {
    try {
      final body = <String, dynamic>{
        'reviewNote': reviewNote,
      };

      final result = await _apiService.post(
        ApiConstant.acceptDelayRequest,
        pathParams: {'delayRequestId': delayRequestId},
        body: body,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to accept delay request';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true) {
              return const Right(true);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to accept delay request';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
          } catch (e, stackTrace) {
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      return Left({
        'error': StatusRequest.serverException,
        'message': 'An unexpected error occurred.',
      });
    }
  }

  Future<Either<dynamic, bool>> rejectDelayRequest({
    required String delayRequestId,
    required String reviewNote,
  }) async {
    try {
      final body = <String, dynamic>{
        'reviewNote': reviewNote,
      };

      final result = await _apiService.post(
        ApiConstant.rejectDelayRequest,
        pathParams: {'delayRequestId': delayRequestId},
        body: body,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to reject delay request';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true) {
              return const Right(true);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to reject delay request';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
          } catch (e, stackTrace) {
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      return Left({
        'error': StatusRequest.serverException,
        'message': 'An unexpected error occurred.',
      });
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getDelayRequests({
    int page = 1,
    int limit = 10,
    String? status,
    String? taskID,
    String? requestedBy,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (taskID != null && taskID.isNotEmpty) {
        queryParams['taskID'] = taskID;
      }
      if (requestedBy != null && requestedBy.isNotEmpty) {
        queryParams['requestedBy'] = requestedBy;
      }

      final result = await _apiService.get(
        ApiConstant.delayRequests,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              return Right(data);
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
}

