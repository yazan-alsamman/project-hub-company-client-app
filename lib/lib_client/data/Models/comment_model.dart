class CommentModel {
  final String? id;
  final String text;
  final String date;
  final String author;
  final int authorColor;
  final String? taskId;
  final String? refType;
  final String? refId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommentModel({
    this.id,
    required this.text,
    required this.date,
    required this.author,
    required this.authorColor,
    this.taskId,
    this.refType,
    this.refId,
    this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString();
    final text = json['content'] ?? json['text'] ?? '';
    
    String authorName = '';
    if (json['userId'] != null && json['userId'] is Map) {
      authorName = json['userId']['username'] ?? json['userId']['email'] ?? '';
    } else {
      authorName = json['author'] ?? '';
    }
    
    String? taskIdStr;
    final refType = json['refType']?.toString();
    final refId = json['refId']?.toString();
    
    if (refType == 'Task' && refId != null) {
      taskIdStr = refId;
    } else if (refType == 'Project' && refId != null) {
      taskIdStr = refId; // Store projectId in taskId for backward compatibility
    } else {
      taskIdStr = json['taskId']?.toString();
    }
    
    String dateStr = '';
    if (json['createdAt'] != null) {
      try {
        final createdDate = DateTime.parse(json['createdAt']);
        dateStr = '${createdDate.day}/${createdDate.month}/${createdDate.year}';
      } catch (e) {
        dateStr = json['date'] ?? '';
      }
    } else {
      dateStr = json['date'] ?? '';
    }
    
    return CommentModel(
      id: id,
      text: text,
      date: dateStr,
      author: authorName,
      authorColor: json['authorColor'] ?? 0xFF3B82F6,
      taskId: taskIdStr,
      refType: refType ?? 'Task',
      refId: refId ?? taskIdStr,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'content': text,
      'refType': refType ?? 'Task',
      if (refId != null) 'refId': refId,
      if (taskId != null && refId == null) 'refId': taskId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? text,
    String? date,
    String? author,
    int? authorColor,
    String? taskId,
    String? refType,
    String? refId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      text: text ?? this.text,
      date: date ?? this.date,
      author: author ?? this.author,
      authorColor: authorColor ?? this.authorColor,
      taskId: taskId ?? this.taskId,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

