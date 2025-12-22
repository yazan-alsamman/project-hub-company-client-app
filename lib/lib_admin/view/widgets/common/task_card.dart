import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/constant/color.dart';
class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;
  final String priority;
  final String dueDate;
  final String assigneeName;
  final String assigneeInitials;
  final Color priorityColor;
  final Color avatarColor;
  final bool isCompleted;
  final bool isPending;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.assigneeName,
    required this.assigneeInitials,
    this.priorityColor = AppColor.errorColor,
    this.avatarColor = AppColor.primaryColor,
    this.isCompleted = false,
    this.isPending = false,
    this.onEdit,
    this.onDelete,
  });
  Widget _buildCardContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : isPending
                      ? Colors.yellow.shade50
                      : AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : isPending
                      ? Icons.warning_amber_rounded
                      : Icons.access_time,
                  color: isCompleted
                      ? Colors.green
                      : isPending
                      ? Colors.orange
                      : AppColor.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? AppColor.textSecondaryColor
                            : AppColor.textColor,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 12,
                color: AppColor.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      priority,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dueDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        assigneeInitials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assigneeName.split(' ').first,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        assigneeName.split(' ').length > 1
                            ? assigneeName.split(' ').last
                            : '',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) {
      return _buildCardContent(context);
    }
    return Slidable(
      key: ValueKey(title),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.3,
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: AppColor.errorColor,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
        ],
      ),
      child: _buildCardContent(context),
    );
  }
}
