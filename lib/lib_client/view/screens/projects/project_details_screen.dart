import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/controller/common/custom_drawer_controller.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';
import 'package:project_hub/lib_client/data/Models/project_model.dart';
import 'package:project_hub/lib_client/data/Models/comment_model.dart';
import 'package:project_hub/lib_client/data/repository/comment_repository.dart';
import 'package:project_hub/lib_client/view/widgets/custom_app_bar.dart';
import 'package:project_hub/lib_client/view/widgets/common/custom_drawer.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = Get.arguments as ProjectModel?;
    
    if (project == null) {
      return Scaffold(
        appBar: const CustomAppBar(showBackButton: true, title: ''),
        body: const Center(child: Text('Project not found')),
      );
    }

    return _ProjectDetailsScreenContent(project: project);
  }
}

class _ProjectDetailsScreenContent extends StatefulWidget {
  final ProjectModel project;
  
  const _ProjectDetailsScreenContent({required this.project});

  @override
  State<_ProjectDetailsScreenContent> createState() => _ProjectDetailsScreenContentState();
}

class _ProjectDetailsScreenContentState extends State<_ProjectDetailsScreenContent> {
  final CommentRepository _commentRepository = CommentRepository();
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoadingComments = false;
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
    });

    try {
      final result = await _commentRepository.getCommentsByProjectId(widget.project.id);
      result.fold(
        (error) {
          Get.snackbar('Error', 'Failed to load comments: $error',
              snackPosition: SnackPosition.BOTTOM);
        },
        (comments) {
          setState(() {
            _comments = comments;
            _isLoadingComments = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
      Get.snackbar('Error', 'Failed to load comments: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAddingComment = true;
    });

    try {
      final result = await _commentRepository.addProjectComment(widget.project.id, text);
      result.fold(
        (error) {
          Get.snackbar('Error', 'Failed to add comment: $error',
              snackPosition: SnackPosition.BOTTOM);
        },
        (comment) {
          setState(() {
            _comments.insert(0, comment);
            _commentController.clear();
          });
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() {
        _isAddingComment = false;
      });
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final result = await _commentRepository.deleteComment(commentId);

      result.fold(
        (error) {
          Get.snackbar('Error', 'Failed to delete comment: $error',
              snackPosition: SnackPosition.BOTTOM);
        },
        (success) {
          if (success) {
            setState(() {
              _comments.removeWhere((c) => c.id == commentId);
            });
          }
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete comment: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Color _getStatusColor() {
    switch (widget.project.status.toLowerCase()) {
      case 'active':
        return const Color(0xFF2196F3);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'planned':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF2196F3);
    }
  }

  Color _getStatusBackgroundColor() {
    switch (widget.project.status.toLowerCase()) {
      case 'active':
        return const Color(0xFFE0F2F7);
      case 'completed':
        return const Color(0xFFE8F5E8);
      case 'planned':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFE0F2F7);
    }
  }

  String _calculateDuration() {
    try {
      final start = DateTime.parse(widget.project.startAt ?? '');
      final end = DateTime.parse(widget.project.estimatedEndAt ?? '');
      final difference = end.difference(start);
      final months = (difference.inDays / 30).round();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getRandomColor(int index) {
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF8A2BE2),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
    ];
    return colors[index % colors.length];
  }

  String _getRandomRole(int index) {
    final roles = [
      'Project Manager',
      'Developer',
      'Designer',
      'QA Engineer',
      'DevOps Engineer',
      'UI/UX Designer',
      'Backend Developer',
      'Frontend Developer',
    ];
    return roles[index % roles.length];
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF666666)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMembersList() {
    return Column(
      children: List.generate(
        widget.project.teamMembers,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getRandomColor(index),
                child: Text(
                  'U${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      _getRandomRole(index),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: const Color(0xFF666666), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CustomDrawerControllerImp customDrawerController =
        Get.find<CustomDrawerControllerImp>();

    return Scaffold(
      drawer: CustomDrawer(
        onItemTap: (item) {
          customDrawerController.onMenuItemTap(item);
        },
      ),
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: AppColor.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.arrow_back_ios),
                                color: AppColor.textColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Project Details',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.textColor,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusBackgroundColor(),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  widget.project.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getStatusColor(),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
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
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8E8FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.folder_outlined,
                                      color: Color(0xFF4285F4),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.project.title,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.project.company,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                widget.project.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF666666),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Project Progress',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Progress',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF666666),
                                              ),
                                            ),
                                            Text(
                                              '${widget.project.progress > 1.0 ? widget.project.progress.round() : (widget.project.progress * 100).round()}%',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF333333),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: const Color(0xFFE0E0E0),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: (widget.project.progress > 1.0 ? widget.project.progress / 100 : widget.project.progress).clamp(0.0, 1.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF4285F4),
                                                    Color(0xFF8A2BE2),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Project Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                Icons.calendar_today_outlined,
                                'Start Date',
                                widget.project.startDate,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.event_outlined,
                                'End Date',
                                widget.project.endDate,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.people_outline,
                                'Team Members',
                                '${widget.project.teamMembers} members',
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.work_outline,
                                'Status',
                                widget.project.status,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.timeline_outlined,
                                'Duration',
                                _calculateDuration(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Team Members',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTeamMembersList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Comments Section
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Comments',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Add Comment Input
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _commentController,
                                      decoration: InputDecoration(
                                        hintText: 'Add a comment...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.all(12),
                                      ),
                                      maxLines: 3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _isAddingComment ? null : _addComment,
                                    icon: _isAddingComment
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.send),
                                    color: AppColor.primaryColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Comments List
                              _isLoadingComments
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : _comments.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Text(
                                            'No comments yet',
                                            style: TextStyle(
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _comments.length,
                                          itemBuilder: (context, index) {
                                            final comment = _comments[index];
                                            return _ProjectCommentItemWidget(
                                              comment: comment,
                                              onDelete: (commentId) async {
                                                await _deleteComment(commentId);
                                              },
                                            );
                                          },
                                        ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20 + keyboardHeight),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProjectCommentItemWidget extends StatefulWidget {
  final CommentModel comment;
  final Future<void> Function(String commentId) onDelete;

  const _ProjectCommentItemWidget({
    required this.comment,
    required this.onDelete,
  });

  @override
  State<_ProjectCommentItemWidget> createState() => _ProjectCommentItemWidgetState();
}

class _ProjectCommentItemWidgetState extends State<_ProjectCommentItemWidget> {
  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (widget.comment.id != null) {
                widget.onDelete(widget.comment.id!);
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColor.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showDeleteConfirmation,
                child: Icon(
                  Icons.delete_outline,
                  color: AppColor.errorColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Color(widget.comment.authorColor).withValues(alpha: 0.2),
                child: Text(
                  widget.comment.author.isNotEmpty
                      ? widget.comment.author.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(widget.comment.authorColor),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.comment.author,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '•',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.comment.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

