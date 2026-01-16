import 'package:dartz/dartz.dart';
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
          return Left(error);
        },
        (response) {
          try {
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

              return Right(comments);
            } else {
              return const Right([]);
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

  Future<Either<StatusRequest, List<CommentModel>>> getProjectComments(
    String projectId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final result = await _apiService.get(
        '/comment/project/$projectId',
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

              return Right(comments);
            } else {
              return const Right([]);
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

  Future<Either<StatusRequest, CommentModel>> addComment({
    required String taskId,
    required String content,
    String? parentId,
  }) async {
    try {
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
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true && response['data'] != null) {
              final comment = CommentModel.fromJson(
                response['data'] as Map<String, dynamic>,
              );
              return Right(comment);
            } else {
              final errorMessage = response['message']?.toString() ?? 'Failed to add comment';
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

  Future<Either<StatusRequest, CommentModel>> addProjectComment({
    required String projectId,
    required String content,
    String? parentId,
  }) async {
    try {
      final body = <String, dynamic>{
        'content': content,
        'refType': 'Project',
        'refId': projectId,
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
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true && response['data'] != null) {
              final comment = CommentModel.fromJson(
                response['data'] as Map<String, dynamic>,
              );
              return Right(comment);
            } else {
              final errorMessage = response['message']?.toString() ?? 'Failed to add comment';
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

  Future<Either<StatusRequest, CommentModel>> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final body = <String, dynamic>{
        'content': content,
      };

      final result = await _apiService.put(
        '/comment/$commentId',
        body: body,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true && response['data'] != null) {
              final comment = CommentModel.fromJson(
                response['data'] as Map<String, dynamic>,
              );
              return Right(comment);
            } else {
              final errorMessage = response['message']?.toString() ?? 'Failed to update comment';
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

  Future<Either<StatusRequest, void>> deleteComment(String commentId) async {
    try {

      final result = await _apiService.delete(
        '/comment/$commentId',
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true) {
              return const Right(null);
            } else {
              final errorMessage = response['message']?.toString() ?? 'Failed to delete comment';
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
