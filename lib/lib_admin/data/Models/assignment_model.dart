import 'package:flutter/material.dart';
class AssignmentModel {
  final String id;
  final String taskId;
  final String taskName;
  final String? taskDescription;
  final String employeeId;
  final String employeeName;
  final String? employeeEmail;
  final String assignedBy;
  final String? assignedByName;
  final String startDate;
  final String endDate;
  final int estimatedHours;
  final int? actualHours;
  final String status; // active, completed, pending
  final String? notes;
  final String? completedAt;
  final String createdAt;
  final String updatedAt;
  final String? projectId;
  final String? projectName;
  final String? projectCode;
  AssignmentModel({
    required this.id,
    required this.taskId,
    required this.taskName,
    this.taskDescription,
    required this.employeeId,
    required this.employeeName,
    this.employeeEmail,
    required this.assignedBy,
    this.assignedByName,
    required this.startDate,
    required this.endDate,
    required this.estimatedHours,
    this.actualHours,
    required this.status,
    this.notes,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.projectId,
    this.projectName,
    this.projectCode,
  });
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    final employeeIdObj = json['employeeId'];
    String employeeIdStr = '';
    String employeeName = 'Unknown';
    String? employeeEmail;
    if (employeeIdObj is Map<String, dynamic>) {
      employeeIdStr = employeeIdObj['_id']?.toString() ?? '';
      if (employeeIdObj['userId'] is Map<String, dynamic>) {
        final userId = employeeIdObj['userId'] as Map<String, dynamic>;
        employeeName = userId['username']?.toString() ?? 'Unknown';
        employeeEmail = userId['email']?.toString();
      }
    } else if (employeeIdObj is String) {
      employeeIdStr = employeeIdObj;
    }
    final taskIdObj = json['taskId'];
    String taskIdStr = '';
    String taskName = 'Unknown Task';
    String? projectId;
    String? projectCode;
    if (taskIdObj is Map<String, dynamic>) {
      taskIdStr = taskIdObj['_id']?.toString() ?? '';
      taskName = taskIdObj['taskName']?.toString() ?? 'Unknown Task';
      if (taskIdObj['projectId'] != null) {
        if (taskIdObj['projectId'] is Map<String, dynamic>) {
          final projectObj = taskIdObj['projectId'] as Map<String, dynamic>;
          projectId = projectObj['_id']?.toString();
          projectCode = projectObj['code']?.toString();
        } else if (taskIdObj['projectId'] is String) {
          projectId = taskIdObj['projectId'] as String;
        }
      }
    } else if (taskIdObj is String) {
      taskIdStr = taskIdObj;
    }
    final assignedByObj = json['assignedBy'];
    String assignedByStr = '';
    String? assignedByName;
    if (assignedByObj is Map<String, dynamic>) {
      assignedByStr = assignedByObj['_id']?.toString() ?? '';
      assignedByName = assignedByObj['username']?.toString();
    } else if (assignedByObj is String) {
      assignedByStr = assignedByObj;
    }
    String? projectName;
    if (projectId == null && json['projectId'] != null) {
      if (json['projectId'] is Map<String, dynamic>) {
        final projectObj = json['projectId'] as Map<String, dynamic>;
        projectId = projectObj['_id']?.toString();
        projectName = projectObj['name']?.toString();
        projectCode = projectObj['code']?.toString();
      } else if (json['projectId'] is String) {
        projectId = json['projectId'] as String;
      }
    }
    return AssignmentModel(
      id: json['_id']?.toString() ?? '',
      taskId: taskIdStr,
      taskName: taskName,
      taskDescription: json['taskDescription']?.toString(),
      employeeId: employeeIdStr,
      employeeName: employeeName,
      employeeEmail: employeeEmail,
      assignedBy: assignedByStr,
      assignedByName: assignedByName,
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      estimatedHours: json['estimatedHours'] is int
          ? json['estimatedHours'] as int
          : json['estimatedHours'] is num
          ? (json['estimatedHours'] as num).toInt()
          : 0,
      actualHours: json['actualHours'] is int
          ? json['actualHours'] as int
          : json['actualHours'] is num
          ? (json['actualHours'] as num).toInt()
          : null,
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
      completedAt: json['completedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      projectId: projectId,
      projectName: projectName,
      projectCode: projectCode,
    );
  }
  String get formattedStartDate {
    if (startDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(startDate);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return startDate;
    }
  }
  String get formattedEndDate {
    if (endDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(endDate);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return endDate;
    }
  }
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
