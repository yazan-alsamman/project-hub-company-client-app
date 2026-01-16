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
      final taskResult = await _taskRepository.getTaskById(taskId!);
      taskResult.fold(
        (error) {
          _errorMessage = error;
          _selectedTask = null;
        },
        (task) {
          _selectedTask = task;
        },
      );

      await loadComments();
    } catch (e) {
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
      final result = await _commentRepository.getTaskComments(currentTaskId);

      result.fold(
        (error) {
          _errorMessage = error;
          _comments = [];
        },
        (commentList) {
          _comments = commentList;
        },
      );
    } catch (e) {
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
      final result = await _commentRepository.addTaskComment(
        currentTaskId,
        text,
      );

      return result.fold(
        (error) {
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
          _comments.add(createdComment);
          commentController.clear();
          update();
          return true;
        },
      );
    } catch (e) {
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
      final commentIndex = _comments.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) {
        _errorMessage = 'Comment not found';
        update();
        return false;
      }

      final existingComment = _comments[commentIndex];

      final updatedComment = existingComment.copyWith(
        text: newText,
        updatedAt: DateTime.now(),
      );

      final result = await _commentRepository.updateComment(updatedComment);

      final success = result.fold(
        (error) {
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
            // Verify index is still valid
            if (commentIndex >= 0 && commentIndex < _comments.length) {
              _comments[commentIndex] = updated;
            } else {
              final idx = _comments.indexWhere((c) => c.id == commentId);
              if (idx >= 0) {
                _comments[idx] = updated;
              }
            }
            return true;
          } catch (e) {
            return false;
          }
        },
      );
      return success;
    } catch (e) {
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
      final result = await _commentRepository.deleteComment(commentId);

      return result.fold(
        (error) {
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
      final result = await _commentRepository.deleteComment(replyId);

      return result.fold(
        (error) {
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
      final result = await _commentRepository.addReplyToComment(
        currentTaskId,
        commentId,
        text,
      );

      return result.fold(
        (error) {
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
      final result = await _commentRepository.getCommentReplies(commentId);
      return result.fold(
        (error) {
          _errorMessage = error;
          update();
          return [];
        },
        (replies) {
          return replies;
        },
      );
    } catch (e) {
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
