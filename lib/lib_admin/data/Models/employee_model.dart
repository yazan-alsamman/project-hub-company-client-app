import 'package:flutter/material.dart';
import '../../core/constant/color.dart';
import '../static/team_members_data.dart';
class EmployeeModel {
  final String id;
  final String username;
  final String email;
  final String? name;
  final String? phone;
  final String? position;
  final String? department;
  final Map<String, dynamic>? positionObj; // Position object from API
  final Map<String, dynamic>? departmentObj; // Department object from API
  final String? status;
  final Map<String, dynamic>? role;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? employeeCode;
  final String? hireDate;
  final int? salary;
  final String? subRole;
  final Map<String, dynamic>? userId;
  final Map<String, dynamic>? companyId;
  EmployeeModel({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.phone,
    this.position,
    this.department,
    this.positionObj,
    this.departmentObj,
    this.status,
    this.role,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.employeeCode,
    this.hireDate,
    this.salary,
    this.subRole,
    this.userId,
    this.companyId,
  });
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? userIdObj;
    if (json['userId'] != null) {
      if (json['userId'] is Map<String, dynamic>) {
        userIdObj = json['userId'] as Map<String, dynamic>;
      }
    }
    Map<String, dynamic>? companyIdObj;
    if (json['companyId'] != null) {
      if (json['companyId'] is Map<String, dynamic>) {
        companyIdObj = json['companyId'] as Map<String, dynamic>;
      }
    }
    final username =
        userIdObj?['username']?.toString() ??
        json['username']?.toString() ??
        '';
    final email =
        userIdObj?['email']?.toString() ?? json['email']?.toString() ?? '';
    return EmployeeModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      username: username,
      email: email,
      name: userIdObj?['name']?.toString() ?? json['name']?.toString(),
      phone: json['phone']?.toString(),
      position: json['position'] is Map<String, dynamic>
          ? ((json['position'] as Map<String, dynamic>)['name']?.toString() ??
                (json['position'] as Map<String, dynamic>)['_id']?.toString())
          : json['position']?.toString(),
      department: json['department'] is Map<String, dynamic>
          ? ((json['department'] as Map<String, dynamic>)['name']?.toString() ??
                (json['department'] as Map<String, dynamic>)['_id']?.toString())
          : json['department']?.toString(),
      positionObj: json['position'] is Map<String, dynamic>
          ? json['position'] as Map<String, dynamic>
          : null,
      departmentObj: json['department'] is Map<String, dynamic>
          ? json['department'] as Map<String, dynamic>
          : null,
      status: json['status']?.toString() ?? 'active',
      role: json['role'] is Map<String, dynamic>
          ? json['role'] as Map<String, dynamic>
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      employeeCode: json['employeeCode']?.toString(),
      hireDate: json['hireDate']?.toString(),
      salary: json['salary'] is int
          ? json['salary'] as int
          : json['salary'] is num
          ? (json['salary'] as num).toInt()
          : null,
      subRole: json['subRole']?.toString(),
      userId: userIdObj,
      companyId: companyIdObj,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'phone': phone,
      'position': position,
      'department': department,
      'positionObj': positionObj,
      'departmentObj': departmentObj,
      'status': status,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'employeeCode': employeeCode,
      'hireDate': hireDate,
      'salary': salary,
      'subRole': subRole,
      'userId': userId,
      'companyId': companyId,
    };
  }
  TeamMember toTeamMember() {
    final displayName = userId?['name']?.toString() ?? name ?? username;
    return TeamMember(
      id: id,
      name: displayName,
      position:
          position ?? subRole ?? (role?['name']?.toString() ?? 'Employee'),
      status: _getStatusDisplay(status ?? 'active'),
      statusColor: _getStatusColor(status ?? 'active'),
      icon: _getIconForPosition(
        position ?? subRole ?? role?['name']?.toString(),
      ),
      email: email,
      phone: phone,
      department: department ?? companyId?['name']?.toString(),
      joinDate: hireDate != null ? _formatDate(hireDate!) : null,
    );
  }
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
  String _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Away';
      case 'busy':
        return 'Busy';
      case 'on_leave':
      case 'on leave':
        return 'Away'; // Map on_leave to 'Away' to match UI expectations
      case 'terminated':
        return 'Terminated';
      default:
        return 'Active';
    }
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColor.successColor;
      case 'inactive':
        return AppColor.textSecondaryColor;
      case 'busy':
        return AppColor.warningColor;
      case 'on_leave':
      case 'on leave':
        return AppColor.textSecondaryColor;
      case 'terminated':
        return AppColor.errorColor;
      default:
        return AppColor.successColor;
    }
  }
  IconData _getIconForPosition(String? position) {
    if (position == null) return Icons.person;
    final pos = position.toLowerCase();
    if (pos.contains('manager') || pos.contains('lead')) {
      return Icons.manage_accounts;
    } else if (pos.contains('designer') ||
        pos.contains('ui') ||
        pos.contains('ux')) {
      return Icons.design_services;
    } else if (pos.contains('developer') || pos.contains('engineer')) {
      return Icons.code;
    } else if (pos.contains('tester') || pos.contains('qa')) {
      return Icons.bug_report;
    } else if (pos.contains('analyst')) {
      return Icons.analytics;
    } else if (pos.contains('owner') || pos.contains('product')) {
      return Icons.business;
    } else {
      return Icons.person;
    }
  }
}
