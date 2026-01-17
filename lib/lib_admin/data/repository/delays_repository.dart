import 'package:dartz/dartz.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';

class DelaysRepository {
  final ApiService _apiService = ApiService();

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

  Future<Either<StatusRequest, bool>> acceptDelayRequest({
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
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true) {
              return const Right(true);
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

  Future<Either<StatusRequest, bool>> rejectDelayRequest({
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
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true) {
              return const Right(true);
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

