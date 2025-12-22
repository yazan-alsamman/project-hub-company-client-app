// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';
import 'package:project_hub/lib_client/core/constant/responsive.dart';
import 'package:project_hub/lib_client/controller/comments_page_controller.dart';
import 'package:project_hub/lib_client/controller/custom_app_bar_controller.dart';
import 'package:project_hub/lib_client/data/Models/task_model.dart';
import 'package:project_hub/lib_client/data/Models/comment_model.dart';
import '../widgets/custom_app_bar.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ClientCustomappbarControllerImp>()) {
      Get.put(ClientCustomappbarControllerImp());
    }
    final taskId = Get.arguments as String?;
    if (!Get.isRegistered<CommentsPageController>()) {
      Get.put(CommentsPageController(taskId: taskId));
    }

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(showBackButton: true, title: ''),
      body: GetBuilder<CommentsPageController>(
        builder: (controller) {
          return Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.primaryColor),
              );
            }

            // Get keyboard height
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

            return Column(
              children: [
                _buildHeaderSection(context, controller),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: Responsive.spacing(context, mobile: 16),
                      right: Responsive.spacing(context, mobile: 16),
                      top: Responsive.spacing(context, mobile: 16),
                      bottom:
                          Responsive.spacing(context, mobile: 16) +
                          keyboardHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, mobile: 24),
                            fontWeight: FontWeight.bold,
                            color: AppColor.textColor,
                          ),
                        ),
                        SizedBox(
                          height: Responsive.spacing(context, mobile: 24),
                        ),
                        _buildAddCommentInput(context, controller),
                        SizedBox(
                          height: Responsive.spacing(context, mobile: 24),
                        ),
                        _buildCommentsList(context, controller),
                      ],
                    ),
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    CommentsPageController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(
                    Responsive.spacing(context, mobile: 8),
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColor.textSecondaryColor,
                    size: Responsive.iconSize(context, mobile: 24),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          Obx(
            () => controller.selectedTask.value != null
                ? _buildTaskSummaryCard(context, controller.selectedTask.value!)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSummaryCard(BuildContext context, TaskModel task) {
    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 12),
        ),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 16),
                    fontWeight: FontWeight.w600,
                    color: AppColor.textColor,
                  ),
                ),
              ),
              if (task.status != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context, mobile: 8),
                    vertical: Responsive.spacing(context, mobile: 4),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      Responsive.borderRadius(context, mobile: 8),
                    ),
                  ),
                  child: Text(
                    task.status!,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 10),
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          // Description
          Text(
            task.description,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 14),
              color: AppColor.textSecondaryColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          Row(
            children: [
              if (task.tag.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context, mobile: 12),
                    vertical: Responsive.spacing(context, mobile: 6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.tagBackgroundColor,
                    borderRadius: BorderRadius.circular(
                      Responsive.borderRadius(context, mobile: 12),
                    ),
                  ),
                  child: Text(
                    task.tag,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 12),
                      color: AppColor.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (task.tag.isNotEmpty)
                SizedBox(width: Responsive.spacing(context, mobile: 8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.spacing(context, mobile: 12),
                  vertical: Responsive.spacing(context, mobile: 6),
                ),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(
                    Responsive.borderRadius(context, mobile: 12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPriorityIcon(task.priority),
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      task.priority,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 12),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (task.date.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColor.textSecondaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      task.date,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 12),
                        color: AppColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              if (task.date.isNotEmpty)
                SizedBox(width: Responsive.spacing(context, mobile: 8)),
              if (task.assignee.isNotEmpty)
                CircleAvatar(
                  radius: Responsive.size(context, mobile: 16),
                  backgroundColor: Color(
                    task.assigneeColor,
                  ).withValues(alpha: 0.2),
                  child: Text(
                    task.assignee.length > 2
                        ? task.assignee.substring(0, 2).toUpperCase()
                        : task.assignee.toUpperCase(),
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 10),
                      color: Color(task.assigneeColor),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('critical') || p.contains('high')) {
      return const Color(0xFFEF4444); // Red
    } else if (p.contains('medium high') || p.contains('medium-high')) {
      return const Color(0xFFF59E0B); // Orange
    } else if (p.contains('medium')) {
      return const Color(0xFFFBBF24); // Yellow
    } else if (p.contains('low medium') || p.contains('low-medium')) {
      return const Color(0xFF84CC16); // Light Green
    } else if (p.contains('low')) {
      return const Color(0xFF10B981); // Green
    }
    return const Color(0xFF6B7280);
  }

  Color _getStatusColor(String? status) {
    if (status == null) return AppColor.textSecondaryColor;
    final s = status.toLowerCase();
    if (s.contains('completed')) {
      return AppColor.completedColor;
    } else if (s.contains('progress')) {
      return AppColor.inProgressColor;
    } else if (s.contains('pending')) {
      return AppColor.pendingColor;
    } else if (s.contains('cancelled')) {
      return AppColor.errorColor;
    }
    return AppColor.textSecondaryColor;
  }

  IconData _getPriorityIcon(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('critical')) {
      return Icons.priority_high;
    } else if (p.contains('high')) {
      return Icons.arrow_upward;
    } else if (p.contains('medium')) {
      return Icons.remove;
    } else if (p.contains('low')) {
      return Icons.arrow_downward;
    }
    return Icons.circle;
  }

  Widget _buildAddCommentInput(
    BuildContext context,
    CommentsPageController controller,
  ) {
    final textController = TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(context, mobile: 16),
        vertical: Responsive.spacing(context, mobile: 12),
      ),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 12),
        ),
        border: Border.all(color: AppColor.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              style: TextStyle(
                color: AppColor.textColor,
                fontSize: Responsive.fontSize(context, mobile: 14),
              ),
              decoration: InputDecoration(
                hintText: 'Add Comment...',
                hintStyle: TextStyle(
                  color: AppColor.textSecondaryColor,
                  fontSize: Responsive.fontSize(context, mobile: 14),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.addComment(value);
                  textController.clear();
                }
              },
            ),
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 8)),
          Icon(
            Icons.attach_file,
            color: AppColor.textSecondaryColor,
            size: Responsive.iconSize(context, mobile: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(
    BuildContext context,
    CommentsPageController controller,
  ) {
    return Column(
      children: controller.comments.asMap().entries.map((entry) {
        final index = entry.key;
        final comment = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: Responsive.spacing(context, mobile: 16),
          ),
          child: _buildCommentItem(context, comment, index, controller),
        );
      }).toList(),
    );
  }

  Widget _buildCommentItem(
    BuildContext context,
    CommentModel comment,
    int index,
    CommentsPageController controller,
  ) {
    return _CommentItemWidget(
      key: ValueKey(comment.id ?? 'comment_$index'),
      comment: comment,
      controller: controller,
    );
  }
}

class _CommentItemWidget extends StatefulWidget {
  final CommentModel comment;
  final CommentsPageController controller;

  const _CommentItemWidget({
    super.key,
    required this.comment,
    required this.controller,
  });

  @override
  State<_CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<_CommentItemWidget> {
  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              if (widget.comment.id != null) {
                widget.controller.deleteComment(widget.comment.id!);
              }
            },
            child: Text('Delete', style: TextStyle(color: AppColor.errorColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.comment.text,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    color: AppColor.textColor,
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              GestureDetector(
                onTap: _showDeleteConfirmation,
                child: Icon(
                  Icons.delete_outline,
                  color: AppColor.errorColor,
                  size: Responsive.iconSize(context, mobile: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          Row(
            children: [
              CircleAvatar(
                radius: Responsive.size(context, mobile: 12),
                backgroundColor: Color(
                  widget.comment.authorColor,
                ).withValues(alpha: 0.2),
                child: Text(
                  widget.comment.author.isNotEmpty
                      ? widget.comment.author.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 10),
                    color: Color(widget.comment.authorColor),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              Text(
                widget.comment.author,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 12),
                  color: AppColor.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              Text(
                '•',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 12),
                  color: AppColor.textSecondaryColor,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              Text(
                widget.comment.date,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 12),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
