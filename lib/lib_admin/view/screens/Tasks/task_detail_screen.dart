import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/common/customDrawer_controller.dart';
import '../../../controller/task/task_detail_controller.dart';
import '../../../core/class/statusrequest.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/Models/task_model.dart';
import '../../../data/Models/comment_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  Future<String?> _getUserRole() async {
    final authService = AuthService();
    return await authService.getUserRole();
  }

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

    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
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
          init: Get.isRegistered<TaskDetailController>()
              ? Get.find<TaskDetailController>()
              : Get.put(TaskDetailController(taskId: task.id, task: task)),
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
                        FutureBuilder<String?>(
                          future: _getUserRole(),
                          builder: (context, snapshot) {
                            final userRole = snapshot.data?.toLowerCase() ?? '';
                            final isAdmin = userRole == 'admin';
                            
                            if (!isAdmin) {
                              return Column(
                                children: [
                                  _buildAddCommentInput(context, controller),
                                  SizedBox(
                                    height: Responsive.spacing(context, mobile: 24),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
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
  final AuthService _authService = AuthService();
  bool _isOwner = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userId = await _authService.getUserId();
    final userRole = await _authService.getUserRole();
    setState(() {
      _isOwner = widget.comment.userId != null && 
                  widget.comment.userId == userId;
      _isAdmin = userRole?.toLowerCase() == 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReplyingToThis =
        widget.controller.replyingToCommentId == widget.comment.id;
    final isEditingThis =
        widget.controller.editingCommentId == widget.comment.id;

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
              if (isEditingThis)
                _buildEditInput(context, widget.controller)
              else
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
                    if ((_isOwner && !_isAdmin) || _isAdmin)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isOwner && !_isAdmin)
                            GestureDetector(
                              onTap: () {
                                widget.controller.startEdit(
                                  widget.comment.id!,
                                  widget.comment.text,
                                );
                              },
                              child: Icon(
                                Icons.edit,
                                size: Responsive.iconSize(context, mobile: 18),
                                color: AppColor.primaryColor,
                              ),
                            ),
                          if (_isOwner && !_isAdmin)
                            SizedBox(width: Responsive.spacing(context, mobile: 12)),
                          if (_isAdmin || _isOwner)
                            GestureDetector(
                              onTap: () {
                                _showDeleteConfirmation(context, widget.comment.id!);
                              },
                              child: Icon(
                                Icons.delete,
                                size: Responsive.iconSize(context, mobile: 18),
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              SizedBox(height: Responsive.spacing(context, mobile: 12)),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 350;
                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: Responsive.spacing(context, mobile: 4),
                                children: [
                                  Text(
                                    widget.comment.author,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, mobile: 12),
                                      color: AppColor.textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, mobile: 12),
                                      color: AppColor.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    widget.comment.date,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, mobile: 12),
                                      color: AppColor.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!isEditingThis && !_isAdmin) ...[
                          SizedBox(height: Responsive.spacing(context, mobile: 8)),
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
                      ],
                    );
                  }
                  return Row(
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
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: Responsive.spacing(context, mobile: 4),
                          children: [
                            Text(
                              widget.comment.author,
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, mobile: 12),
                                color: AppColor.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, mobile: 12),
                                color: AppColor.textSecondaryColor,
                              ),
                            ),
                            Text(
                              widget.comment.date,
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, mobile: 12),
                                color: AppColor.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isEditingThis && !_isAdmin)
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
                  );
                },
              ),
            ],
          ),
        ),
        if (isReplyingToThis && !_isAdmin) _buildReplyInput(context, widget.controller),
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
                  child: _ReplyItemWidget(
                    reply: reply,
                    controller: widget.controller,
                    parentCommentId: widget.comment.id!,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildEditInput(
    BuildContext context,
    TaskDetailController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 12)),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 8),
        ),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.editController,
            maxLines: 3,
            style: TextStyle(
              color: AppColor.textColor,
              fontSize: Responsive.fontSize(context, mobile: 14),
            ),
            decoration: InputDecoration(
              hintText: 'Edit your comment...',
              hintStyle: TextStyle(
                color: AppColor.textSecondaryColor,
                fontSize: Responsive.fontSize(context, mobile: 14),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  controller.cancelEdit();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              ElevatedButton(
                onPressed: () {
                  if (controller.editController.text.trim().isNotEmpty &&
                      widget.comment.id != null) {
                    controller.updateComment(
                      widget.comment.id!,
                      controller.editController.text,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context, mobile: 16),
                    vertical: Responsive.spacing(context, mobile: 8),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Comment',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this comment? This action cannot be undone.',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.controller.deleteComment(commentId);
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
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

}

class _ReplyItemWidget extends StatefulWidget {
  final CommentModel reply;
  final TaskDetailController controller;
  final String parentCommentId;

  const _ReplyItemWidget({
    required this.reply,
    required this.controller,
    required this.parentCommentId,
  });

  @override
  State<_ReplyItemWidget> createState() => _ReplyItemWidgetState();
}

class _ReplyItemWidgetState extends State<_ReplyItemWidget> {
  final AuthService _authService = AuthService();
  bool _isOwner = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userId = await _authService.getUserId();
    final userRole = await _authService.getUserRole();
    setState(() {
      _isOwner = widget.reply.userId != null && 
                  widget.reply.userId == userId;
      _isAdmin = userRole?.toLowerCase() == 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditingThis =
        widget.controller.editingCommentId == widget.reply.id;

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
          if (isEditingThis)
            _buildEditInput(context, widget.controller)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.reply.text,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 14),
                      color: AppColor.textColor,
                    ),
                  ),
                ),
                if ((_isOwner && !_isAdmin) || _isAdmin)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isOwner && !_isAdmin)
                        GestureDetector(
                          onTap: () {
                            widget.controller.startEdit(
                              widget.reply.id!,
                              widget.reply.text,
                            );
                          },
                          child: Icon(
                            Icons.edit,
                            size: Responsive.iconSize(context, mobile: 16),
                            color: AppColor.primaryColor,
                          ),
                        ),
                      if (_isOwner && !_isAdmin)
                        SizedBox(width: Responsive.spacing(context, mobile: 8)),
                      if (_isAdmin || _isOwner)
                        GestureDetector(
                          onTap: () {
                            _showDeleteConfirmation(context, widget.reply.id!);
                          },
                          child: Icon(
                            Icons.delete,
                            size: Responsive.iconSize(context, mobile: 16),
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          Row(
            children: [
              CircleAvatar(
                radius: Responsive.size(context, mobile: 12),
                backgroundColor: Color(widget.reply.authorColor).withOpacity(0.2),
                child: Text(
                  widget.reply.author.isNotEmpty
                      ? widget.reply.author.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 10),
                    color: Color(widget.reply.authorColor),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              Text(
                widget.reply.author,
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
                widget.reply.date,
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

  Widget _buildEditInput(
    BuildContext context,
    TaskDetailController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 6),
        ),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.editController,
            maxLines: 2,
            style: TextStyle(
              color: AppColor.textColor,
              fontSize: Responsive.fontSize(context, mobile: 14),
            ),
            decoration: InputDecoration(
              hintText: 'Edit your reply...',
              hintStyle: TextStyle(
                color: AppColor.textSecondaryColor,
                fontSize: Responsive.fontSize(context, mobile: 14),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  controller.cancelEdit();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 6)),
              ElevatedButton(
                onPressed: () {
                  if (controller.editController.text.trim().isNotEmpty &&
                      widget.reply.id != null) {
                    controller.updateComment(
                      widget.reply.id!,
                      controller.editController.text,
                    );
                    _refreshParentComment();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context, mobile: 12),
                    vertical: Responsive.spacing(context, mobile: 6),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String replyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Reply',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this reply? This action cannot be undone.',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.controller.deleteComment(replyId);
                _refreshParentComment();
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _refreshParentComment() {
    widget.controller.loadComments();
  }
}
