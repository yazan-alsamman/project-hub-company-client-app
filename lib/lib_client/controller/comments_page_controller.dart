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

  final RxBool isLoading = false.obs;
  final RxString commentText = ''.obs;

  final Rx<TaskModel?> selectedTask = Rx<TaskModel?>(null);
  final String? taskId;
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxString errorMessage = ''.obs;

  CommentsPageController({this.taskId});

  @override
  void onInit() {
    super.onInit();
    if (taskId != null) {
      loadTaskAndComments();
    } else {
      errorMessage.value = 'No task ID provided';
    }
  }

  Future<void> loadTaskAndComments() async {
    if (taskId == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final taskResult = await _taskRepository.getTaskById(taskId!);
      taskResult.fold(
        (error) {
          errorMessage.value = error;
          selectedTask.value = null;
        },
        (task) {
          selectedTask.value = task;
        },
      );

      await loadComments();
    } catch (e) {
      errorMessage.value = e.toString();
      selectedTask.value = null;
      comments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments() async {
    final currentTaskId = taskId ?? selectedTask.value?.id;
    if (currentTaskId == null) return;

    try {
      final result = await _commentRepository.getTaskComments(currentTaskId);

      result.fold(
        (error) {
          errorMessage.value = error;
          comments.value = [];
        },
        (commentList) {
          comments.value = commentList;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      comments.value = [];
    }
  }

  Future<bool> addComment(String text) async {
    if (text.trim().isEmpty) return false;

    final currentTaskId = taskId ?? selectedTask.value?.id;
    if (currentTaskId == null || currentTaskId.isEmpty) return false;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _commentRepository.addTaskComment(
        currentTaskId,
        text,
      );

      return result.fold(
        (error) {
          errorMessage.value = error;
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
          comments.add(createdComment);
          commentText.value = '';
          return true;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add comment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateComment(String commentId, String newText) async {
    if (newText.trim().isEmpty) return false;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final commentIndex = comments.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) {
        errorMessage.value = 'Comment not found';
        isLoading.value = false;
        return false;
      }

      final existingComment = comments[commentIndex];
      final updatedComment = existingComment.copyWith(
        text: newText,
        updatedAt: DateTime.now(),
        refType: existingComment.refType, // Preserve refType
        refId: existingComment.refId, // Preserve refId
      );

      final result = await _commentRepository.updateComment(updatedComment);

      return result.fold(
        (error) {
          errorMessage.value = error;
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
          comments[commentIndex] = updated;
          return true;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update comment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final isTempComment = commentId.startsWith('temp_');

    try {
      if (isTempComment) {
        comments.removeWhere((comment) => comment.id == commentId);
        isLoading.value = false;
        return true;
      }

      final result = await _commentRepository.deleteComment(commentId);

      return result.fold(
        (error) {
          errorMessage.value = error;
          comments.removeWhere((comment) => comment.id == commentId);
          return false;
        },
        (success) {
          comments.removeWhere((comment) => comment.id == commentId);
          return true;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      comments.removeWhere((comment) => comment.id == commentId);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      if (authController.isClient) {
        errorMessage.value = 'Clients cannot update tasks';
        return false;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _taskRepository.updateTask(task);

      return result.fold(
        (error) {
          errorMessage.value = error;
          return false;
        },
        (updatedTask) {
          selectedTask.value = updatedTask;
          return true;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
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

