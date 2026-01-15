import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/data/repository/task_repository.dart';
import 'package:project_hub/lib_client/data/repository/comment_repository.dart';
import 'package:project_hub/lib_client/data/Models/task_model.dart';
import 'package:project_hub/lib_client/data/Models/comment_model.dart';
import 'package:project_hub/lib_client/controller/auth_controller.dart';

class CommentsPageController extends GetxController {
  final TaskRepository _taskRepository = TaskRepository();
  final CommentRepository _commentRepository = CommentRepository();

  final String? taskId;

  List<CommentModel> _comments = [];
  TaskModel? _selectedTask;
  bool _isLoading = false;
  String? _errorMessage;
  String? _replyingToCommentId;
  final TextEditingController commentController = TextEditingController();
  final TextEditingController replyController = TextEditingController();

  List<CommentModel> get comments => _comments;
  TaskModel? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get replyingToCommentId => _replyingToCommentId;

  CommentsPageController({this.taskId});

  @override
  void onInit() {
    super.onInit();
    if (taskId != null) {
      loadTaskAndComments();
    } else {
      _errorMessage = 'No task ID provided';
      update();
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    replyController.dispose();
    super.onClose();
  }

  Future<void> loadTaskAndComments() async {
    if (taskId == null) return;

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      debugPrint('🔵 Loading task and comments');
      final taskResult = await _taskRepository.getTaskById(taskId!);
      taskResult.fold(
        (error) {
          debugPrint('🔴 Error loading task: $error');
          _errorMessage = error;
          _selectedTask = null;
        },
        (task) {
          debugPrint('✅ Task loaded');
          _selectedTask = task;
        },
      );

      await loadComments();
    } catch (e) {
      debugPrint('🔴 Exception loading task and comments: $e');
      _errorMessage = e.toString();
      _selectedTask = null;
      _comments = [];
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> loadComments() async {
    final currentTaskId = taskId ?? _selectedTask?.id;
    if (currentTaskId == null) return;

    _isLoading = true;
    update();

    try {
      debugPrint('🔵 Loading comments for task $currentTaskId');
      final result = await _commentRepository.getTaskComments(currentTaskId);

      result.fold(
        (error) {
          debugPrint('🔴 Error loading comments: $error');
          _errorMessage = error;
          _comments = [];
        },
        (commentList) {
          debugPrint('✅ Loaded ${commentList.length} comments');
          _comments = commentList;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading comments: $e');
      _errorMessage = e.toString();
      _comments = [];
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<bool> addComment(String text) async {
    if (text.trim().isEmpty) return false;

    final currentTaskId = taskId ?? _selectedTask?.id;
    if (currentTaskId == null || currentTaskId.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      debugPrint('🔵 Adding comment');
      final result = await _commentRepository.addTaskComment(
        currentTaskId,
        text,
      );

      return result.fold(
        (error) {
          debugPrint('🔴 Error adding comment: $error');
          _errorMessage = error;
          Get.snackbar(
            'Error',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Colors.white,
          );
          return false;
        },
        (createdComment) {
          debugPrint('✅ Comment added successfully');
          _comments.add(createdComment);
          commentController.clear();
          update();
          return true;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception adding comment: $e');
      _errorMessage = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add comment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<bool> updateComment(String commentId, String newText) async {
    if (newText.trim().isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      debugPrint('🔵 Updating comment $commentId');
      final commentIndex = _comments.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) {
        debugPrint('🔴 Comment not found at index');
        _errorMessage = 'Comment not found';
        update();
        return false;
      }

      final existingComment = _comments[commentIndex];
      debugPrint('🔵 Found comment: ${existingComment.id}');

      final updatedComment = existingComment.copyWith(
        text: newText,
        updatedAt: DateTime.now(),
      );

      debugPrint('🔵 Calling API to update comment');
      final result = await _commentRepository.updateComment(updatedComment);

      final success = result.fold(
        (error) {
          debugPrint('🔴 API Error updating comment: $error');
          _errorMessage = error;
          Get.snackbar(
            'Error',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Colors.white,
          );
          return false;
        },
        (updated) {
          try {
            debugPrint('✅ API returned updated comment');
            // Verify index is still valid
            if (commentIndex >= 0 && commentIndex < _comments.length) {
              _comments[commentIndex] = updated;
              debugPrint('✅ Comment updated in list at index $commentIndex');
            } else {
              debugPrint(
                '⚠️ Index out of bounds after update, searching by ID',
              );
              final idx = _comments.indexWhere((c) => c.id == commentId);
              if (idx >= 0) {
                _comments[idx] = updated;
              }
            }
            return true;
          } catch (e) {
            debugPrint('🔴 Error updating comment in list: $e');
            return false;
          }
        },
      );
      return success;
    } catch (e) {
      debugPrint('🔴 Exception updating comment: $e');
      _errorMessage = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update comment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<bool> deleteComment(String commentId) async {
    _isLoading = true;
    update();

    try {
      debugPrint('🔵 Deleting comment $commentId');
      final result = await _commentRepository.deleteComment(commentId);

      return result.fold(
        (error) {
          debugPrint('🔴 Error deleting comment: $error');
          _errorMessage = error;
          Get.snackbar(
            'Error',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Colors.white,
          );
          return false;
        },
        (success) {
          debugPrint('✅ Comment deleted successfully');
          // Remove from main comments list
          _comments.removeWhere((comment) => comment.id == commentId);
          update();
          Get.snackbar(
            'Success',
            'Comment deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Colors.white,
          );
          return true;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception deleting comment: $e');
      _errorMessage = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete comment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<bool> deleteReply(String parentCommentId, String replyId) async {
    _isLoading = true;
    update();

    try {
      debugPrint('🔵 Deleting reply $replyId from comment $parentCommentId');
      final result = await _commentRepository.deleteComment(replyId);

      return result.fold(
        (error) {
          debugPrint('🔴 Error deleting reply: $error');
          _errorMessage = error;
          Get.snackbar(
            'Error',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Colors.white,
          );
          return false;
        },
        (success) {
          debugPrint('✅ Reply deleted successfully');
          // Find the parent comment and remove the reply from its replies list
          final commentIndex = _comments.indexWhere(
            (c) => c.id == parentCommentId,
          );
          if (commentIndex != -1) {
            final comment = _comments[commentIndex];
            final updatedReplies = (comment.replies ?? [])
                .where((reply) => reply.id != replyId)
                .toList();
            _comments[commentIndex] = comment.copyWith(replies: updatedReplies);
            debugPrint('✅ Reply removed from parent comment');
          }
          update();
          Get.snackbar(
            'Success',
            'Reply deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Colors.white,
          );
          return true;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception deleting reply: $e');
      _errorMessage = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete reply: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  void startReply(String commentId) {
    _replyingToCommentId = commentId;
    replyController.clear();
    update();
  }

  void cancelReply() {
    _replyingToCommentId = null;
    replyController.clear();
    update();
  }

  Future<bool> addReplyToComment(String commentId, String text) async {
    if (text.trim().isEmpty) return false;

    final currentTaskId = taskId ?? _selectedTask?.id;
    if (currentTaskId == null || currentTaskId.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      debugPrint('🔵 Adding reply to comment');
      final result = await _commentRepository.addReplyToComment(
        currentTaskId,
        commentId,
        text,
      );

      return result.fold(
        (error) {
          debugPrint('🔴 Error adding reply: $error');
          _errorMessage = error;
          Get.snackbar(
            'Error',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Colors.white,
          );
          return false;
        },
        (createdReply) {
          debugPrint('✅ Reply added successfully');
          // Find the parent comment and add the reply
          final commentIndex = _comments.indexWhere((c) => c.id == commentId);
          if (commentIndex != -1) {
            final comment = _comments[commentIndex];
            final updatedReplies = <CommentModel>[
              ...(comment.replies ?? []),
              createdReply,
            ];
            _comments[commentIndex] = comment.copyWith(replies: updatedReplies);
          }
          _replyingToCommentId = null;
          replyController.clear();
          update();
          return true;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception adding reply: $e');
      _errorMessage = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add reply: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<List<CommentModel>> loadRepliesForComment(String commentId) async {
    try {
      debugPrint('🔵 Loading replies for comment $commentId');
      final result = await _commentRepository.getCommentReplies(commentId);
      return result.fold(
        (error) {
          debugPrint('🔴 Error loading replies: $error');
          _errorMessage = error;
          update();
          return [];
        },
        (replies) {
          debugPrint('✅ Loaded ${replies.length} replies');
          return replies;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading replie: $e');
      _errorMessage = e.toString();
      update();
      return [];
    }
  }

  bool get canEdit {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      return authController.canEdit;
    }
    return true;
  }

  Future<void> refreshData() async {
    await loadTaskAndComments();
  }
}
