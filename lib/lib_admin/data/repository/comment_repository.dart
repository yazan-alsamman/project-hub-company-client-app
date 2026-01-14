import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/api_service.dart';
import '../Models/comment_model.dart';

class CommentRepository {
  final ApiService _apiService = ApiService();

  Future<Either<StatusRequest, List<CommentModel>>> getTaskComments(
    String taskId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('🔵 CommentRepository: Getting comments for task $taskId');
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      final result = await _apiService.get(
        '/comment/task/$taskId',
        queryParams: queryParams,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          debugPrint('🔴 CommentRepository error: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 CommentRepository response received');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              List<CommentModel> comments = [];
              
              if (data is Map<String, dynamic>) {
                if (data['comments'] != null && data['comments'] is List) {
                  comments = (data['comments'] as List)
                      .map((item) => CommentModel.fromJson(item as Map<String, dynamic>))
                      .toList();
                }
              } else if (data is List) {
                comments = data
                    .map((item) => CommentModel.fromJson(item as Map<String, dynamic>))
                    .toList();
              }
              
              debugPrint('✅ Found ${comments.length} comments');
              return Right(comments);
            } else {
              debugPrint('⚠️ No comments found');
              return const Right([]);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 CommentRepository parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 CommentRepository exception: $e');
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, CommentModel>> addComment({
    required String taskId,
    required String content,
    String? parentId,
  }) async {
    try {
      debugPrint('🔵 CommentRepository: Adding comment');
      final body = <String, dynamic>{
        'content': content,
        'refType': 'Task',
        'refId': taskId,
      };
      
      if (parentId != null && parentId.isNotEmpty) {
        body['parentId'] = parentId;
      }

      final result = await _apiService.post(
        '/comment',
        body: body,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          debugPrint('🔴 CommentRepository error adding comment: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 CommentRepository add comment response received');
            if (response['success'] == true && response['data'] != null) {
              final comment = CommentModel.fromJson(
                response['data'] as Map<String, dynamic>,
              );
              debugPrint('✅ Comment added successfully');
              return Right(comment);
            } else {
              final errorMessage = response['message']?.toString() ?? 'Failed to add comment';
              debugPrint('🔴 Failed to add comment: $errorMessage');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 CommentRepository parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 CommentRepository exception adding comment: $e');
      return const Left(StatusRequest.serverException);
    }
  }
}
