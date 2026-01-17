import 'package:dartz/dartz.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/api_service.dart';
import '../Models/comment_model.dart';

class CommentRepository {
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
            if (response['success'] == false || response['success'] == null) {
              return const Right([]);
            }
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
            if (response['success'] == false || response['success'] == null) {
              return const Right([]);
            }
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

  Future<Either<dynamic, CommentModel>> addComment({
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
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to add comment';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true && response['data'] != null) {
              final comment = CommentModel.fromJson(
                response['data'] as Map<String, dynamic>,
              );
              return Right(comment);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to add comment';
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

  Future<Either<dynamic, CommentModel>> addProjectComment({
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
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to add comment';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true && response['data'] != null) {
              final comment = CommentModel.fromJson(
                response['data'] as Map<String, dynamic>,
              );
              return Right(comment);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to add comment';
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

  Future<Either<dynamic, CommentModel>> updateComment({
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
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update comment';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true && response['data'] != null) {
              final comment = CommentModel.fromJson(
                response['data'] as Map<String, dynamic>,
              );
              return Right(comment);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update comment';
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

  Future<Either<dynamic, void>> deleteComment(String commentId) async {
    try {

      final result = await _apiService.delete(
        '/comment/$commentId',
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
                  'Failed to delete comment';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true) {
              return const Right(null);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete comment';
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
}
