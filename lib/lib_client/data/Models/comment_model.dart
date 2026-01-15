class CommentModel {
  final String? id;
  final String text;
  final String date;
  final String author;
  final String? authorId;
  final int authorColor;
  final String? taskId;
  final String? refType;
  final String? refId;
  final String? parentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CommentModel>? replies;

  CommentModel({
    this.id,
    required this.text,
    required this.date,
    required this.author,
    this.authorId,
    required this.authorColor,
    this.taskId,
    this.refType,
    this.refId,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString();
    final text = json['content'] ?? json['text'] ?? '';

    String authorName = '';
    String? authorIdStr;
    if (json['userId'] != null && json['userId'] is Map) {
      authorName = json['userId']['username'] ?? json['userId']['email'] ?? '';
      authorIdStr = json['userId']['_id']?.toString();
    } else {
      authorName = json['author'] ?? '';
      authorIdStr = json['authorId']?.toString();
    }

    String? taskIdStr;
    final refType = json['refType']?.toString();
    final refId = json['refId']?.toString();
    final parentId = json['parentId']?.toString();

    if (refType == 'Task' && refId != null) {
      taskIdStr = refId;
    } else if (refType == 'Project' && refId != null) {
      taskIdStr = refId;
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

    List<CommentModel>? repliesList;
    if (json['replies'] != null && json['replies'] is List) {
      repliesList = (json['replies'] as List)
          .map((item) => CommentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return CommentModel(
      id: id,
      text: text,
      date: dateStr,
      author: authorName,
      authorId: authorIdStr,
      authorColor: json['authorColor'] ?? 0xFF6B46C1,
      taskId: taskIdStr,
      refType: refType ?? 'Task',
      refId: refId ?? taskIdStr,
      parentId: parentId,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      replies: repliesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'content': text,
      'refType': refType ?? 'Task',
      if (refId != null) 'refId': refId,
      if (taskId != null && refId == null) 'refId': taskId,
      if (parentId != null) 'parentId': parentId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? text,
    String? date,
    String? author,
    String? authorId,
    int? authorColor,
    String? taskId,
    String? refType,
    String? refId,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      text: text ?? this.text,
      date: date ?? this.date,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      authorColor: authorColor ?? this.authorColor,
      taskId: taskId ?? this.taskId,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
    );
  }
}
