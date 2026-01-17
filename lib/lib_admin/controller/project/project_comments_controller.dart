import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/project_model.dart';
import '../../data/Models/comment_model.dart';
import '../../data/repository/comment_repository.dart';

class ProjectCommentsController extends GetxController {
  final CommentRepository _commentRepository = CommentRepository();
  final AuthService _authService = AuthService();
  final String projectId;
  final ProjectModel project;

  ProjectCommentsController({
    required this.projectId,
    required this.project,
  });

  List<CommentModel> _comments = [];
  StatusRequest _statusRequest = StatusRequest.loading;
  bool _isLoading = false;
  String? _errorMessage;
  String? _replyingToCommentId;
  String? _editingCommentId;
  final TextEditingController commentController = TextEditingController();
  final TextEditingController replyController = TextEditingController();
  final TextEditingController editController = TextEditingController();

  List<CommentModel> get comments => _comments;
  StatusRequest get statusRequest => _statusRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get replyingToCommentId => _replyingToCommentId;
  String? get editingCommentId => _editingCommentId;

  @override
  void onInit() {
    super.onInit();
    loadComments();
  }

  @override
  void onClose() {
    commentController.dispose();
    replyController.dispose();
    editController.dispose();
    super.onClose();
  }

  Future<void> loadComments() async {
    _isLoading = true;
    _statusRequest = StatusRequest.loading;
    _errorMessage = null;
    update();

    try {
      final result = await _commentRepository.getProjectComments(
        projectId,
        page: 1,
        limit: 20,
      );

      result.fold(
        (error) {
          _statusRequest = error;
          _errorMessage = 'Failed to load comments';
          _comments = [];
        },
        (comments) {
          _comments = comments;
          _statusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
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
      final result = await _commentRepository.addProjectComment(
        projectId: projectId,
        content: content,
      );

      result.fold(
        (error) {
          Get.snackbar(
            'Error',
            'Failed to add comment',
            snackPosition: SnackPosition.TOP,
          );
        },
        (comment) {
          _comments.add(comment);
          commentController.clear();
          update();
        },
      );
    } catch (e) {
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
      final result = await _commentRepository.addProjectComment(
        projectId: projectId,
        content: content,
        parentId: parentCommentId,
      );

      result.fold(
        (error) {
          Get.snackbar(
            'Error',
            'Failed to add reply',
            snackPosition: SnackPosition.TOP,
          );
        },
        (reply) {
          final parentIndex = _comments.indexWhere((c) => c.id == parentCommentId);
          if (parentIndex != -1) {
            final parentComment = _comments[parentIndex];
            final updatedReplies = <CommentModel>[
              ...(parentComment.replies ?? []),
              reply,
            ];
            _comments[parentIndex] = parentComment.copyWith(replies: updatedReplies);
          } else {
            _comments.add(reply);
          }
          _replyingToCommentId = null;
          replyController.clear();
          update();
        },
      );
    } catch (e) {
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

  Future<void> updateComment(String commentId, String newContent) async {
    if (newContent.trim().isEmpty) return;

    _isLoading = true;
    update();

    try {
      final result = await _commentRepository.updateComment(
        commentId: commentId,
        content: newContent.trim(),
      );

      result.fold(
        (error) {
          Get.snackbar(
            'Error',
            'Failed to update comment',
            snackPosition: SnackPosition.TOP,
          );
        },
        (updatedComment) {
          final index = _comments.indexWhere((c) => c.id == commentId);
          if (index != -1) {
            _comments[index] = updatedComment;
          } else {
            for (int i = 0; i < _comments.length; i++) {
              if (_comments[i].replies != null) {
                final replyIndex = _comments[i].replies!.indexWhere((r) => r.id == commentId);
                if (replyIndex != -1) {
                  final updatedReplies = List<CommentModel>.from(_comments[i].replies!);
                  updatedReplies[replyIndex] = updatedComment;
                  _comments[i] = _comments[i].copyWith(replies: updatedReplies);
                  break;
                }
              }
            }
          }
          _editingCommentId = null;
          editController.clear();
          update();
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while updating comment',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> deleteComment(String commentId) async {
    _isLoading = true;
    update();

    try {
      final result = await _commentRepository.deleteComment(commentId);

      result.fold(
        (error) {
          Get.snackbar(
            'Error',
            'Failed to delete comment',
            snackPosition: SnackPosition.TOP,
          );
        },
        (_) {
          final index = _comments.indexWhere((c) => c.id == commentId);
          if (index != -1) {
            _comments.removeAt(index);
          } else {
            for (int i = 0; i < _comments.length; i++) {
              if (_comments[i].replies != null) {
                final replyIndex = _comments[i].replies!.indexWhere((r) => r.id == commentId);
                if (replyIndex != -1) {
                  final updatedReplies = List<CommentModel>.from(_comments[i].replies!);
                  updatedReplies.removeAt(replyIndex);
                  _comments[i] = _comments[i].copyWith(replies: updatedReplies);
                  break;
                }
              }
            }
          }
          update();
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while deleting comment',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading = false;
      update();
    }
  }

  void startEdit(String commentId, String currentContent) {
    _editingCommentId = commentId;
    editController.text = currentContent;
    update();
  }

  void cancelEdit() {
    _editingCommentId = null;
    editController.clear();
    update();
  }

  Future<String?> getCurrentUserId() async {
    return await _authService.getUserId();
  }
}

