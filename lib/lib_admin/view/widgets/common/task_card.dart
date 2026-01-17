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
  final bool showAssignee;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRequestDelay;
  final VoidCallback? onMarkCompleted;
  final List<Map<String, dynamic>>? delayRequests;
  
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
    this.showAssignee = true,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onRequestDelay,
    this.onMarkCompleted,
    this.delayRequests,
  });
  List<Map<String, dynamic>> _parseDelayRequests() {
    if (delayRequests != null && delayRequests!.isNotEmpty) {
      return delayRequests!;
    }
    
    if (subtitle.contains('DELAY REQUESTED') || subtitle.contains('delay requested')) {
      final List<Map<String, dynamic>> delays = [];
      final lines = subtitle.split('\n');
      
      for (var line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;
        
        if (trimmedLine.toUpperCase().contains('DELAY REQUESTED')) {
          if (trimmedLine.contains(' - Reason: ') || trimmedLine.contains(' - reason: ')) {
            final parts = trimmedLine.split(RegExp(r' - [Rr]eason: '));
            if (parts.length == 2) {
              String datePart = parts[0]
                  .replaceAll(RegExp(r'[Dd][Ee][Ll][Aa][Yy]\s+[Rr][Ee][Qq][Uu][Ee][Ss][Tt][Ee][Dd]'), '')
                  .trim();
              final reason = parts[1].trim();
              
              if (datePart.isNotEmpty && reason.isNotEmpty) {
                delays.add({
                  'date': datePart,
                  'reason': reason,
                });
              }
            }
          } else {
            final dateMatch = RegExp(r'\d{4}-\d{2}-\d{2}[Tt]\d{2}:\d{2}:\d{2}').firstMatch(trimmedLine);
            if (dateMatch != null) {
              final datePart = dateMatch.group(0) ?? '';
              final reasonPart = trimmedLine.substring(dateMatch.end).trim();
              final reason = reasonPart.replaceAll(RegExp(r'^[-:\s]+'), '').trim();
              
              if (datePart.isNotEmpty) {
                delays.add({
                  'date': datePart,
                  'reason': reason.isNotEmpty ? reason : 'No reason provided',
                });
              }
            }
          }
        }
      }
      return delays;
    }
    
    return [];
  }

  String _formatDelayDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year} • $hour:$minute';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildCardContent(BuildContext context) {
    final parsedDelays = _parseDelayRequests();
    final hasDelays = parsedDelays.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasDelays ? Colors.orange.withOpacity(0.3) : AppColor.borderColor,
          width: hasDelays ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : isPending
                      ? Colors.orange.shade50
                      : hasDelays
                      ? Colors.orange.shade50
                      : AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasDelays
                      ? Icons.schedule_outlined
                      : isCompleted
                      ? Icons.check_circle
                      : isPending
                      ? Icons.warning_amber_rounded
                      : Icons.access_time,
                  color: hasDelays
                      ? Colors.orange
                      : isCompleted
                      ? Colors.green
                      : isPending
                      ? Colors.orange
                      : AppColor.primaryColor,
                  size: 22,
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
                        height: 1.3,
                        color: isCompleted
                            ? AppColor.textSecondaryColor
                            : AppColor.textColor,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty && !hasDelays) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.textSecondaryColor,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          if (hasDelays) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Delay Requests (${parsedDelays.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...parsedDelays.asMap().entries.map((entry) {
                    final index = entry.key;
                    final delay = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < parsedDelays.length - 1 ? 10 : 0,
                      ),
                      child: _buildDelayRequestItem(
                        context,
                        delay['date']?.toString() ?? '',
                        delay['reason']?.toString() ?? '',
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onRequestDelay != null)
                OutlinedButton.icon(
                  onPressed: onRequestDelay,
                  icon: const Icon(Icons.schedule, size: 14),
                  label: const Text(
                    'Request Delay',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    side: BorderSide(color: AppColor.primaryColor, width: 1.5),
                    foregroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (onMarkCompleted != null)
                ElevatedButton.icon(
                  onPressed: isCompleted ? null : onMarkCompleted,
                  icon: const Icon(Icons.check_circle, size: 14),
                  label: const Text(
                    'Mark as Completed',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    backgroundColor: isCompleted
                        ? AppColor.textSecondaryColor
                        : AppColor.successColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
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
                  borderRadius: BorderRadius.circular(8),
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
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColor.textSecondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        dueDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (showAssignee) ...[
                const SizedBox(width: 8),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: avatarColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: avatarColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          assigneeName.split(' ').first,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (assigneeName.split(' ').length > 1)
                          Text(
                            assigneeName.split(' ').last,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColor.textSecondaryColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDelayRequestItem(BuildContext context, String date, String reason) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _formatDelayDate(date),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.textColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = onTap != null
        ? GestureDetector(onTap: onTap, child: _buildCardContent(context))
        : _buildCardContent(context);

    if (onEdit == null && onDelete == null) {
      return cardContent;
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
      child: cardContent,
    );
  }
}
