class TaskModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String priority;
  final String dueDate;
  final String assigneeName;
  final String assigneeInitials;
  final String status; // 'All', 'In Progress', 'Completed', 'Pending'
  final String priorityColor;
  final String avatarColor;
  final String? projectId;
  final String? projectCode;
  final String? projectStatus;
  final String? taskDescription;
  final String? taskPriority; // H, M, L
  final String? taskStatus; // pending, in_progress, completed
  final String? targetRole;
  final int? minEstimatedHour;
  final int? maxEstimatedHour;
  final String? completedAt;
  final List<dynamic>? assignments;
  final bool? isDelayed;
  final int? delayDays;
  TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.assigneeName,
    required this.assigneeInitials,
    required this.status,
    required this.priorityColor,
    required this.avatarColor,
    this.projectId,
    this.projectCode,
    this.projectStatus,
    this.taskDescription,
    this.taskPriority,
    this.taskStatus,
    this.targetRole,
    this.minEstimatedHour,
    this.maxEstimatedHour,
    this.completedAt,
    this.assignments,
    this.isDelayed,
    this.delayDays,
  });
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final projectIdObj = json['projectId'];
    final projectCode = projectIdObj is Map<String, dynamic>
        ? projectIdObj['code']?.toString()
        : null;
    final projectStatus = projectIdObj is Map<String, dynamic>
        ? projectIdObj['status']?.toString()
        : null;
    String assigneeName = 'Unassigned';
    String assigneeInitials = 'UA';
    if (json['assignments'] != null &&
        json['assignments'] is List &&
        (json['assignments'] as List).isNotEmpty) {
      final assignment = json['assignments'][0];
      if (assignment is Map<String, dynamic>) {
        final employeeId = assignment['employeeId'];
        if (employeeId is Map<String, dynamic>) {
          final userId = employeeId['userId'];
          if (userId is Map<String, dynamic>) {
            final username = userId['username']?.toString() ?? '';
            assigneeName = username;
            assigneeInitials = username.isNotEmpty
                ? username.substring(0, 1).toUpperCase()
                : 'UA';
          }
        }
      }
    }
    final taskStatus = json['taskStatus']?.toString() ?? 'pending';
    final uiStatus = _mapTaskStatusToUI(taskStatus);
    final taskPriority = json['taskPriority']?.toString() ?? 'M';
    final priority = _mapPriority(taskPriority);
    final priorityColor = _getPriorityColor(taskPriority);
    final dueDateStr = json['dueDate']?.toString();
    final dueDate = dueDateStr != null && dueDateStr != 'null'
        ? _formatDate(dueDateStr)
        : 'No due date';
    final avatarColor = _getAvatarColor(assigneeName);
    return TaskModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['taskName']?.toString() ?? '',
      subtitle: json['taskDescription']?.toString() ?? '',
      category: projectCode ?? 'Uncategorized',
      priority: priority,
      dueDate: dueDate,
      assigneeName: assigneeName,
      assigneeInitials: assigneeInitials,
      status: uiStatus,
      priorityColor: priorityColor,
      avatarColor: avatarColor,
      projectId: projectIdObj is Map<String, dynamic>
          ? projectIdObj['_id']?.toString()
          : null,
      projectCode: projectCode,
      projectStatus: projectStatus,
      taskDescription: json['taskDescription']?.toString(),
      taskPriority: taskPriority,
      taskStatus: taskStatus,
      targetRole: json['targetRole']?.toString(),
      minEstimatedHour: json['minEstimatedHour'] is int
          ? json['minEstimatedHour'] as int
          : json['minEstimatedHour'] is num
          ? (json['minEstimatedHour'] as num).toInt()
          : null,
      maxEstimatedHour: json['maxEstimatedHour'] is int
          ? json['maxEstimatedHour'] as int
          : json['maxEstimatedHour'] is num
          ? (json['maxEstimatedHour'] as num).toInt()
          : null,
      completedAt: json['completedAt']?.toString(),
      assignments: json['assignments'] is List ? json['assignments'] : null,
      isDelayed: json['isDelayed'] as bool? ?? false,
      delayDays: json['delayDays'] is int
          ? json['delayDays'] as int
          : json['delayDays'] is num
          ? (json['delayDays'] as num).toInt()
          : 0,
    );
  }
  static String _mapTaskStatusToUI(String taskStatus) {
    switch (taskStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
      case 'inprogress':
        return 'In Progress';
      case 'completed':
      case 'done':
        return 'Completed';
      default:
        return 'Pending';
    }
  }
  static String _mapPriority(String priority) {
    switch (priority.toUpperCase()) {
      case 'H':
        return 'High';
      case 'M':
        return 'Medium';
      case 'L':
        return 'Low';
      default:
        return 'Medium';
    }
  }
  static String _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'H':
        return 'error';
      case 'M':
        return 'orange';
      case 'L':
        return 'green';
      default:
        return 'orange';
    }
  }
  static String _getAvatarColor(String assigneeName) {
    final colors = ['primary', 'purple', 'blue'];
    final index = assigneeName.hashCode.abs() % colors.length;
    return colors[index];
  }
  static String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
