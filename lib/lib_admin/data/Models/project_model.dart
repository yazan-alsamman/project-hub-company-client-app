class ProjectModel {
  final String id;
  final String title;
  final String company;
  final String description;
  final double progress;
  final String startDate;
  final String endDate;
  final int teamMembers;
  final String status;
  final String? code;
  final String? projectCode;
  final Map<String, dynamic>? companyId;
  final Map<String, dynamic>? clientId;
  final List<dynamic>? attachments;
  final String? startAt;
  final String? estimatedEndAt;
  final String? endAt;
  final int? safeDelay;
  final int? totalTasks;
  final int? completedTasks;
  final double? progressPercentage;
  ProjectModel({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.progress,
    required this.startDate,
    required this.endDate,
    required this.teamMembers,
    required this.status,
    this.code,
    this.projectCode,
    this.companyId,
    this.clientId,
    this.attachments,
    this.startAt,
    this.estimatedEndAt,
    this.endAt,
    this.safeDelay,
    this.totalTasks,
    this.completedTasks,
    this.progressPercentage,
  });
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final companyIdObj = json['companyId'];
    final companyName = companyIdObj is Map<String, dynamic>
        ? companyIdObj['name']?.toString()
        : null;
    final clientIdObj = json['clientId'];
    final totalTasks = json['totalTasks'] is int
        ? json['totalTasks'] as int
        : json['totalTasks'] is num
        ? (json['totalTasks'] as num).toInt()
        : 0;
    final completedTasks = json['completedTasks'] is int
        ? json['completedTasks'] as int
        : json['completedTasks'] is num
        ? (json['completedTasks'] as num).toInt()
        : 0;
    final progressPercentage = json['progressPercentage'] is num
        ? (json['progressPercentage'] as num).toDouble()
        : (totalTasks > 0 ? (completedTasks / totalTasks) : 0.0);
    final startAtStr = json['startAt']?.toString();
    final startDate = startAtStr != null && startAtStr != 'null'
        ? _formatDate(startAtStr)
        : 'N/A';
    final estimatedEndAtStr = json['estimatedEndAt']?.toString();
    final endDate = estimatedEndAtStr != null && estimatedEndAtStr != 'null'
        ? _formatDate(estimatedEndAtStr)
        : 'N/A';
    final apiStatus = json['status']?.toString() ?? 'pending';
    final status = _mapStatus(apiStatus);
    return ProjectModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['name']?.toString() ?? '',
      company: companyName ?? 'Unknown Company',
      description: json['description']?.toString() ?? '',
      progress: progressPercentage,
      startDate: startDate,
      endDate: endDate,
      teamMembers: totalTasks, // Use totalTasks as teamMembers for now
      status: status,
      code: json['code']?.toString(),
      projectCode: json['code']?.toString(),
      companyId: companyIdObj is Map<String, dynamic> ? companyIdObj : null,
      clientId: clientIdObj is Map<String, dynamic> ? clientIdObj : null,
      attachments: json['attachments'] is List ? json['attachments'] : null,
      startAt: startAtStr,
      estimatedEndAt: estimatedEndAtStr,
      endAt: json['endAt']?.toString(),
      safeDelay: json['safeDelay'] is int
          ? json['safeDelay'] as int
          : json['safeDelay'] is num
          ? (json['safeDelay'] as num).toInt()
          : null,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      progressPercentage: progressPercentage,
    );
  }
  static String _mapStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending':
        return 'planned';
      case 'in_progress':
        return 'active'; // Map API's 'in_progress' to UI's 'active'
      case 'active': // Legacy support if API uses 'active'
        return 'active';
      case 'completed':
      case 'done':
        return 'completed';
      case 'on_hold':
        return 'planned'; // Map on_hold to planned
      case 'cancelled':
        return 'completed'; // Map cancelled to completed (or could be planned)
      default:
        return 'planned';
    }
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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'title': title,
      'name': title,
      'company': company,
      'description': description,
      'progress': progress,
      'startDate': startDate,
      'endDate': endDate,
      'teamMembers': teamMembers,
      'status': status,
      'code': code ?? projectCode,
      'companyId': companyId,
      'clientId': clientId,
      'attachments': attachments,
      'startAt': startAt,
      'estimatedEndAt': estimatedEndAt,
      'endAt': endAt,
      'safeDelay': safeDelay,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'progressPercentage': progressPercentage,
    };
  }
}
