import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/common/customDrawer_controller.dart';
import '../../../controller/task/task_detail_controller.dart';
import '../../../core/class/statusrequest.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../../data/Models/task_model.dart';
import '../../../data/Models/comment_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = Get.arguments as TaskModel?;
    if (task == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Task Detail', showBackButton: true),
        body: const Center(
          child: Text('Task not found'),
        ),
      );
    }

    if (!Get.isRegistered<TaskDetailController>()) {
      Get.put(TaskDetailController(taskId: task.id, task: task));
    }

    final CustomDrawerControllerImp customDrawerController =
        Get.find<CustomDrawerControllerImp>();

    return Scaffold(
      drawer: CustomDrawer(
        onItemTap: (item) {
          customDrawerController.onMenuItemTap(item);
        },
      ),
      appBar: const CustomAppBar(title: 'Task Detail', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<TaskDetailController>(
          builder: (controller) {
            if (controller.statusRequest == StatusRequest.loading &&
                controller.comments.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.primaryColor),
              );
            }

            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

            return Column(
              children: [
                _buildTaskHeader(context, task),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: Responsive.spacing(context, mobile: 20),
                      right: Responsive.spacing(context, mobile: 20),
                      top: Responsive.spacing(context, mobile: 20),
                      bottom: Responsive.spacing(context, mobile: 20) +
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
          },
        ),
      ),
    );
  }

  Widget _buildTaskHeader(BuildContext context, TaskModel task) {
    Color priorityColor;
    switch (task.priorityColor) {
      case 'error':
        priorityColor = AppColor.errorColor;
        break;
      case 'orange':
        priorityColor = Colors.orange;
        break;
      case 'green':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = AppColor.errorColor;
    }

    Color statusColor;
    switch (task.status.toLowerCase()) {
      case 'completed':
        statusColor = AppColor.successColor;
        break;
      case 'in progress':
        statusColor = Colors.blue;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = AppColor.textSecondaryColor;
    }

    return Container(
      color: AppColor.backgroundColor,
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      child: Container(
        padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 12),
          ),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
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
                      fontSize: Responsive.fontSize(context, mobile: 18),
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context, mobile: 12),
                    vertical: Responsive.spacing(context, mobile: 6),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      Responsive.borderRadius(context, mobile: 8),
                    ),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 12),
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.spacing(context, mobile: 12),
                vertical: Responsive.spacing(context, mobile: 6),
              ),
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(
                  Responsive.borderRadius(context, mobile: 8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPriorityIcon(task.priority),
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: Responsive.spacing(context, mobile: 6)),
                  Text(
                    task.priority,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 14),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCommentInput(
    BuildContext context,
    TaskDetailController controller,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(context, mobile: 16),
        vertical: Responsive.spacing(context, mobile: 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 12),
        ),
        border: Border.all(color: AppColor.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.commentController,
              textInputAction: TextInputAction.done,
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
              onSubmitted: (_) {
                if (controller.commentController.text.trim().isNotEmpty) {
                  controller.addComment();
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 8)),
          GestureDetector(
            onTap: () {
              if (controller.commentController.text.trim().isNotEmpty) {
                controller.addComment();
                FocusScope.of(context).unfocus();
              }
            },
            child: Icon(
              Icons.send,
              color: AppColor.primaryColor,
              size: Responsive.iconSize(context, mobile: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(
    BuildContext context,
    TaskDetailController controller,
  ) {
    if (controller.comments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.spacing(context, mobile: 40)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.comment_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Text(
                'No comments yet',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 16),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
    TaskDetailController controller,
  ) {
    return _CommentItemWidget(
      key: ValueKey(comment.id ?? 'comment_$index'),
      comment: comment,
      controller: controller,
    );
  }

  IconData _getPriorityIcon(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('critical') || p.contains('high')) {
      return Icons.flag;
    } else if (p.contains('medium')) {
      return Icons.flag_outlined;
    } else if (p.contains('low')) {
      return Icons.flag_outlined;
    }
    return Icons.flag_outlined;
  }
}

class _CommentItemWidget extends StatefulWidget {
  final CommentModel comment;
  final TaskDetailController controller;

  const _CommentItemWidget({
    super.key,
    required this.comment,
    required this.controller,
  });

  @override
  State<_CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<_CommentItemWidget> {
  @override
  Widget build(BuildContext context) {
    final isReplyingToThis =
        widget.controller.replyingToCommentId == widget.comment.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              Responsive.borderRadius(context, mobile: 12),
            ),
            border: Border.all(color: AppColor.borderColor, width: 1),
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
                ],
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 12)),
              Row(
                children: [
                  CircleAvatar(
                    radius: Responsive.size(context, mobile: 14),
                    backgroundColor: Color(widget.comment.authorColor)
                        .withOpacity(0.2),
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
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (widget.controller.replyingToCommentId ==
                          widget.comment.id) {
                        widget.controller.cancelReply();
                      } else {
                        widget.controller.startReply(widget.comment.id!);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(context, mobile: 8),
                        vertical: Responsive.spacing(context, mobile: 4),
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.backgroundColor,
                        borderRadius: BorderRadius.circular(
                          Responsive.borderRadius(context, mobile: 6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reply,
                            size: Responsive.iconSize(context, mobile: 16),
                            color: AppColor.primaryColor,
                          ),
                          SizedBox(
                            width: Responsive.spacing(context, mobile: 4),
                          ),
                          Text(
                            'Reply',
                            style: TextStyle(
                              fontSize:
                                  Responsive.fontSize(context, mobile: 12),
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isReplyingToThis) _buildReplyInput(context, widget.controller),
        if (widget.comment.replies != null &&
            widget.comment.replies!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              left: Responsive.spacing(context, mobile: 32),
              top: Responsive.spacing(context, mobile: 16),
            ),
            child: Column(
              children: widget.comment.replies!.map((reply) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: Responsive.spacing(context, mobile: 12),
                  ),
                  child: _buildReplyItem(context, reply),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildReplyInput(
    BuildContext context,
    TaskDetailController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(
        top: Responsive.spacing(context, mobile: 12),
        left: Responsive.spacing(context, mobile: 32),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(context, mobile: 16),
        vertical: Responsive.spacing(context, mobile: 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 12),
        ),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.replyController,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                color: AppColor.textColor,
                fontSize: Responsive.fontSize(context, mobile: 14),
              ),
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                hintStyle: TextStyle(
                  color: AppColor.textSecondaryColor,
                  fontSize: Responsive.fontSize(context, mobile: 14),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) {
                if (controller.replyController.text.trim().isNotEmpty &&
                    controller.replyingToCommentId != null) {
                  controller.addReply(controller.replyingToCommentId!);
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 8)),
          GestureDetector(
            onTap: () {
              if (controller.replyController.text.trim().isNotEmpty &&
                  controller.replyingToCommentId != null) {
                controller.addReply(controller.replyingToCommentId!);
                FocusScope.of(context).unfocus();
              }
            },
            child: Icon(
              Icons.send,
              color: AppColor.primaryColor,
              size: Responsive.iconSize(context, mobile: 20),
            ),
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 8)),
          GestureDetector(
            onTap: () {
              controller.cancelReply();
            },
            child: Icon(
              Icons.close,
              color: AppColor.textSecondaryColor,
              size: Responsive.iconSize(context, mobile: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(BuildContext context, CommentModel reply) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 12)),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 8),
        ),
        border: Border.all(color: AppColor.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply.text,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 14),
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          Row(
            children: [
              CircleAvatar(
                radius: Responsive.size(context, mobile: 12),
                backgroundColor: Color(reply.authorColor).withOpacity(0.2),
                child: Text(
                  reply.author.isNotEmpty
                      ? reply.author.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 10),
                    color: Color(reply.authorColor),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              Text(
                reply.author,
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
                reply.date,
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
