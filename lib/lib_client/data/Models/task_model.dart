class TaskModel {
  final String? id;
  final String title;
  final String description;
  final String tag;
  final String priority; // High, Medium, Low
  final String date;
  final String assignee;
  final int assigneeColor;
  final String? status; // All, In Progress, Completed, Pending
  final String? projectId;
  final String? targetRole; // backend, frontend, etc.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.priority,
    required this.date,
    required this.assignee,
    required this.assigneeColor,
    this.status,
    this.projectId,
    this.targetRole,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString();
    final title = json['taskName'] ?? json['title'] ?? '';
    final description = json['taskDescription'] ?? json['description'] ?? '';
    final status = json['taskStatus'] ?? json['status'];
    final priority = json['taskPriority'] ?? json['priority'] ?? 'Medium';

    String? projectIdStr;
    if (json['projectId'] != null) {
      if (json['projectId'] is Map) {
        projectIdStr = json['projectId']['_id']?.toString();
      } else {
        projectIdStr = json['projectId']?.toString();
      }
    }

    String assigneeName = '';
    int assigneeColor = 0xFF3B82F6;
    if (json['assignments'] != null &&
        json['assignments'] is List &&
        (json['assignments'] as List).isNotEmpty) {
      final assignment = (json['assignments'] as List).first;
      if (assignment['employeeId'] != null &&
          assignment['employeeId']['userId'] != null) {
        assigneeName = assignment['employeeId']['userId']['username'] ?? '';
      }
    }

    String tag = '';
    if (json['projectId'] != null && json['projectId'] is Map) {
      tag = json['projectId']['code'] ?? '';
    }

    String? targetRoleStr;
    if (json['targetRole'] != null) {
      targetRoleStr = json['targetRole'].toString().toLowerCase();
    }

    String dateStr = '';
    if (json['dueDate'] != null) {
      try {
        final dueDate = DateTime.parse(json['dueDate']);
        dateStr = '${dueDate.day}/${dueDate.month}/${dueDate.year}';
      } catch (e) {
        dateStr = '';
      }
    } else if (json['createdAt'] != null) {
      try {
        final createdDate = DateTime.parse(json['createdAt']);
        dateStr = '${createdDate.day}/${createdDate.month}/${createdDate.year}';
      } catch (e) {
        dateStr = '';
      }
    }

    return TaskModel(
      id: id,
      title: title,
      description: description,
      tag: tag.isNotEmpty ? tag : (json['tag'] ?? ''),
      priority: _mapPriority(priority),
      date: dateStr.isNotEmpty ? dateStr : (json['date'] ?? ''),
      assignee: assigneeName.isNotEmpty
          ? assigneeName
          : (json['assignee'] ?? ''),
      assigneeColor: json['assigneeColor'] ?? assigneeColor,
      status: status != null ? _mapStatus(status.toString()) : null,
      projectId: projectIdStr,
      targetRole: targetRoleStr,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  static String _mapPriority(dynamic priority) {
    if (priority == null) return 'Medium';
    final p = priority.toString().toUpperCase();
    switch (p) {
      case 'H':
        return 'High';
      case 'MH':
        return 'Medium High';
      case 'M':
        return 'Medium';
      case 'LM':
        return 'Low Medium';
      case 'L':
        return 'Low';
      case 'C':
        return 'Critical';
      default:
        return priority.toString();
    }
  }

  static String? _mapStatus(String status) {
    final s = status.toLowerCase();
    switch (s) {
      case 'pending':
        return 'Pending';
      case 'inprogress':
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Map<String, dynamic> toJson() {
    final priorityCode = _priorityToCode(priority);
    final statusCode = status != null ? _statusToCode(status!) : null;

    return {
      if (id != null) '_id': id,
      'taskName': title,
      'taskDescription': description,
      if (statusCode != null) 'taskStatus': statusCode,
      'taskPriority': priorityCode,
      if (projectId != null) 'projectId': projectId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  static String _priorityToCode(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('high') && p.contains('critical')) return 'C';
    if (p.contains('high')) return 'H';
    if (p.contains('medium') && p.contains('high')) return 'MH';
    if (p.contains('medium') && p.contains('low')) return 'LM';
    if (p.contains('medium')) return 'M';
    if (p.contains('low')) return 'L';
    return 'M'; // default
  }

  static String _statusToCode(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending')) return 'pending';
    if (s.contains('progress')) return 'inProgress';
    if (s.contains('completed')) return 'completed';
    if (s.contains('cancelled')) return 'cancelled';
    return s;
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? tag,
    String? priority,
    String? date,
    String? assignee,
    int? assigneeColor,
    String? status,
    String? projectId,
    String? targetRole,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      assignee: assignee ?? this.assignee,
      assigneeColor: assigneeColor ?? this.assigneeColor,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      targetRole: targetRole ?? this.targetRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
