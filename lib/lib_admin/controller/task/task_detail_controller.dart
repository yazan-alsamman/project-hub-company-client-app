import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../data/Models/task_model.dart';
import '../../data/Models/comment_model.dart';
import '../../data/repository/comment_repository.dart';

class TaskDetailController extends GetxController {
  final CommentRepository _commentRepository = CommentRepository();
  final String taskId;
  final TaskModel task;

  TaskDetailController({
    required this.taskId,
    required this.task,
  });

  List<CommentModel> _comments = [];
  StatusRequest _statusRequest = StatusRequest.loading;
  bool _isLoading = false;
  String? _errorMessage;
  String? _replyingToCommentId;
  final TextEditingController commentController = TextEditingController();
  final TextEditingController replyController = TextEditingController();

  List<CommentModel> get comments => _comments;
  StatusRequest get statusRequest => _statusRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get replyingToCommentId => _replyingToCommentId;

  @override
  void onInit() {
    super.onInit();
    loadComments();
  }

  @override
  void onClose() {
    commentController.dispose();
    replyController.dispose();
    super.onClose();
  }

  Future<void> loadComments() async {
    _isLoading = true;
    _statusRequest = StatusRequest.loading;
    _errorMessage = null;
    update();

    try {
      final result = await _commentRepository.getTaskComments(
        taskId,
        page: 1,
        limit: 20,
      );

      result.fold(
        (error) {
          debugPrint('🔴 Error loading comments: $error');
          _statusRequest = error;
          _errorMessage = 'Failed to load comments';
          _comments = [];
        },
        (comments) {
          debugPrint('✅ Loaded ${comments.length} comments');
          _comments = comments;
          _statusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading comments: $e');
      _statusRequest = StatusRequest.serverException;
      _errorMessage = 'An error occurred while loading comments';
      _comments = [];
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> addComment() async {
    final content = commentController.text.trim();
    if (content.isEmpty) return;

    _isLoading = true;
    update();

    try {
      final result = await _commentRepository.addComment(
        taskId: taskId,
        content: content,
      );

      result.fold(
        (error) {
          debugPrint('🔴 Error adding comment: $error');
          Get.snackbar(
            'Error',
            'Failed to add comment',
            snackPosition: SnackPosition.TOP,
          );
        },
        (comment) {
          debugPrint('✅ Comment added successfully');
          _comments.add(comment);
          commentController.clear();
          update();
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception adding comment: $e');
          Get.snackbar(
            'Error',
            'An error occurred while adding comment',
            snackPosition: SnackPosition.TOP,
          );
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

  Future<void> addReply(String parentCommentId) async {
    final content = replyController.text.trim();
    if (content.isEmpty) return;

    _isLoading = true;
    update();

    try {
      final result = await _commentRepository.addComment(
        taskId: taskId,
        content: content,
        parentId: parentCommentId,
      );

      result.fold(
        (error) {
          debugPrint('🔴 Error adding reply: $error');
          Get.snackbar(
            'Error',
            'Failed to add reply',
            snackPosition: SnackPosition.TOP,
          );
        },
        (reply) {
          debugPrint('✅ Reply added successfully');
          // Find the parent comment and add the reply
          final parentIndex = _comments.indexWhere((c) => c.id == parentCommentId);
          if (parentIndex != -1) {
          final parentComment = _comments[parentIndex];
          final updatedReplies = <CommentModel>[
            ...(parentComment.replies ?? []),
            reply,
          ];
          _comments[parentIndex] = parentComment.copyWith(replies: updatedReplies);
          } else {
            // If parent not found, add as top-level comment (shouldn't happen)
            _comments.add(reply);
          }
          _replyingToCommentId = null;
          replyController.clear();
          update();
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception adding reply: $e');
      Get.snackbar(
        'Error',
        'An error occurred while adding reply',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading = false;
      update();
    }
  }
}
