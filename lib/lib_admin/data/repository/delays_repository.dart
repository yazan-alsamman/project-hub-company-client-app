import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';

class DelaysRepository {
  final ApiService _apiService = ApiService();

  // GET /project-delay/summary
  Future<Either<StatusRequest, Map<String, dynamic>>> getDelaySummary() async {
    debugPrint('🔵 DelaysRepository: Getting delay summary...');
    try {
      final result = await _apiService.get(
        ApiConstant.projectDelaySummary,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          debugPrint('🔴 DelaysRepository error getting delay summary: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 DelaysRepository delay summary response received');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              debugPrint('✅ Delay summary retrieved successfully');
              return Right(data);
            } else {
              debugPrint('🔴 Failed to get delay summary');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 DelaysRepository parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 DelaysRepository exception getting delay summary: $e');
      return const Left(StatusRequest.serverException);
    }
  }

  // GET /project-delay?page=1&limit=10
  Future<Either<StatusRequest, Map<String, dynamic>>> getAllProjectsDelayStatus({
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('🔵 DelaysRepository: Getting all projects delay status...');
    debugPrint('Page: $page, Limit: $limit');
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
          debugPrint('🔴 DelaysRepository error getting all projects delay status: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 DelaysRepository all projects delay status response received');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              debugPrint('✅ All projects delay status retrieved successfully');
              return Right(data);
            } else {
              debugPrint('🔴 Failed to get all projects delay status');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 DelaysRepository parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 DelaysRepository exception getting all projects delay status: $e');
      return const Left(StatusRequest.serverException);
    }
  }

  // GET /project-delay/project/:projectId
  Future<Either<StatusRequest, Map<String, dynamic>>> getProjectDelayStatus(
    String projectId,
  ) async {
    debugPrint('🔵 DelaysRepository: Getting project delay status...');
    debugPrint('ProjectId: $projectId');
    try {
      final result = await _apiService.get(
        ApiConstant.projectDelayByProject,
        pathParams: {'projectId': projectId},
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          debugPrint('🔴 DelaysRepository error getting project delay status: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 DelaysRepository project delay status response received');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              debugPrint('✅ Project delay status retrieved successfully');
              return Right(data);
            } else {
              debugPrint('🔴 Failed to get project delay status');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 DelaysRepository parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 DelaysRepository exception getting project delay status: $e');
      return const Left(StatusRequest.serverException);
    }
  }

  // GET /project-delay/project/:projectId/tasks?page=1&limit=10
  Future<Either<StatusRequest, Map<String, dynamic>>> getProjectTaskDelays({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('🔵 DelaysRepository: Getting project task delays...');
    debugPrint('ProjectId: $projectId, Page: $page, Limit: $limit');
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
          debugPrint('🔴 DelaysRepository error getting project task delays: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 DelaysRepository project task delays response received');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              debugPrint('✅ Project task delays retrieved successfully');
              return Right(data);
            } else {
              debugPrint('🔴 Failed to get project task delays');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 DelaysRepository parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 DelaysRepository exception getting project task delays: $e');
      return const Left(StatusRequest.serverException);
    }
  }
}

