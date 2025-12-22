import 'package:dartz/dartz.dart';
import 'package:project_hub/lib_client/core/services/api_service.dart';
import 'package:project_hub/lib_client/data/Models/comment_model.dart';

class CommentRepository {
  final ApiService _apiService = ApiService();

  Future<Either<String, List<CommentModel>>> getTaskComments(
    String taskId,
  ) async {
    try {
      final response = await _apiService.get('/comment/task/$taskId');
      final data = _apiService.handleResponse(response);

      if (data['data'] != null) {
        final dataObj = data['data'] as Map<String, dynamic>;
        if (dataObj['comments'] != null && dataObj['comments'] is List) {
          final comments = (dataObj['comments'] as List)
              .map(
                (item) => CommentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          return Right(comments);
        }
        if (dataObj is List) {
          final comments = (dataObj as List)
              .map(
                (item) => CommentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          return Right(comments);
        }
      }

      return Right([]);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, CommentModel>> createComment(
    CommentModel comment,
  ) async {
    try {
      // Determine refType and refId from comment
      String refType = 'Task';
      String? refId = comment.taskId;

      // If taskId is null, try to infer from the comment structure
      if (refId == null || refId.isEmpty) {
        return Left('Task ID or Project ID is required');
      }

      final response = await _apiService.post(
        '/comment',
        body: {'content': comment.text, 'refType': refType, 'refId': refId},
      );

      final data = _apiService.handleResponse(response);

      if (data['data'] != null) {
        final createdComment = CommentModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        return Right(createdComment);
      }

      return Left('Failed to create comment');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, CommentModel>> addTaskComment(
    String taskId,
    String text,
  ) async {
    try {
      final commentData = {'content': text, 'refType': 'Task', 'refId': taskId};

      final response = await _apiService.post('/comment', body: commentData);

      final data = _apiService.handleResponse(response);

      if (data['data'] != null) {
        final createdComment = CommentModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        return Right(createdComment);
      }

      return Left('Failed to create comment');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, CommentModel>> updateComment(
    CommentModel comment,
  ) async {
    try {
      if (comment.id == null) {
        return Left('Comment ID is required for update');
      }

      // The API requires refType and refId for updates
      // Determine refType and refId from the comment
      String refType = comment.refType ?? 'Task';
      String? refId = comment.refId;

      // If refId is not set, try to infer from taskId or other fields
      if (refId == null || refId.isEmpty) {
        refId = comment.taskId;
      }

      // If still no refId, we can't update
      if (refId == null || refId.isEmpty) {
        return Left('Task ID or Project ID is required for update');
      }

      // Build update data with required fields - only send content, refType, and refId
      final updateData = {
        'content': comment.text,
        'refType': refType,
        'refId': refId,
      };

      final response = await _apiService.put(
        '/comment/${comment.id}',
        body: updateData,
      );

      final data = _apiService.handleResponse(response);

      if (data['data'] != null) {
        final updatedComment = CommentModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        return Right(updatedComment);
      }

      return Left('Failed to update comment');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<CommentModel>>> getCommentsByProjectId(
    String projectId,
  ) async {
    try {
      final response = await _apiService.get('/comment/project/$projectId');
      final data = _apiService.handleResponse(response);

      if (data['data'] != null) {
        final dataObj = data['data'] as Map<String, dynamic>;
        if (dataObj['comments'] != null && dataObj['comments'] is List) {
          final comments = (dataObj['comments'] as List)
              .map(
                (item) => CommentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          return Right(comments);
        }
        if (dataObj is List) {
          final comments = (dataObj as List)
              .map(
                (item) => CommentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          return Right(comments);
        }
      }

      return Right([]);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, CommentModel>> addProjectComment(
    String projectId,
    String text,
  ) async {
    try {
      final commentData = {
        'content': text,
        'refType': 'Project',
        'refId': projectId,
      };

      final response = await _apiService.post('/comment', body: commentData);

      final data = _apiService.handleResponse(response);

      if (data['data'] != null) {
        final createdComment = CommentModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        return Right(createdComment);
      }

      return Left('Failed to create comment');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> deleteComment(String id) async {
    try {
      final response = await _apiService.delete('/comment/$id');
      _apiService.handleResponse(response);
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
