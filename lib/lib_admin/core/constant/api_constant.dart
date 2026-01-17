import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:project_hub/core/services/services.dart';
import 'package:project_hub/core/config/app_config.dart';

class ApiConstant {
  static const String _customBaseUrl = AppConfig.productionApiUrl;
  static const String _baseUrlKey = 'api_base_url';
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    try {
      final Myservices services = Get.find();
      final customUrl = services.sharedPreferences.getString(_baseUrlKey);
      if (customUrl != null && customUrl.isNotEmpty) {
        return customUrl;
      }
    } catch (e) {}
    if (Platform.isAndroid) {
      return AppConfig.androidEmulatorApiUrl;
    }
    return AppConfig.localhostApiUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    try {
      final Myservices services = Get.find();
      await services.sharedPreferences.setString(_baseUrlKey, url);
      debugPrint('✅ Base URL set to: $url');
    } catch (e) {
      debugPrint('❌ Failed to save base URL: $e');
    }
  }

  static String? getCustomBaseUrl() {
    try {
      final Myservices services = Get.find();
      return services.sharedPreferences.getString(_baseUrlKey);
    } catch (e) {
      return null;
    }
  }

  static const Duration connectTimeout = AppConfig.connectTimeout;
  static const Duration receiveTimeout = AppConfig.receiveTimeout;
  static const String contentType = AppConfig.contentTypeJson;
  static const String accept = AppConfig.acceptJson;
  static const String login = '/user/login';
  static const String register = '/auth/register';
  static const String logout = '/user/logout';
  static const String refreshToken = '/user/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  static const String roles = '/role';
  static const String positions = '/position';
  static const String departments = '/department';
  static const String projects = '/project';
  static const String projectDetails = '/projects/{id}';
  static const String createProject = '/project';
  static const String updateProject = '/project/{id}';
  static const String deleteProject = '/project/{id}';
  static const String projectStats = '/projects/stats';
  static const String clients = '/user/clients';
  static const String tasks = '/task';
  static const String taskDetails = '/tasks/{id}';
  static const String createTask = '/task';
  static const String updateTask = '/task/{id}';
  static const String deleteTask = '/task/{id}';
  static const String requestTaskDelay = '/task/{id}/request-delay';
  static const String delayRequests = '/task/delay-requests';
  static const String acceptDelayRequest = '/task/delay-requests/{delayRequestId}/accept';
  static const String rejectDelayRequest = '/task/delay-requests/{delayRequestId}/reject';
  static const String taskByProject = '/projects/{projectId}/tasks';
  static const String tasksByProject = '/task/project/{projectId}';
  static const String bulkCreateTasks = '/task/bulk/create';
  static const String taskAssignments = '/task-assignment';
  static const String taskAssignmentsByEmployee =
      '/task-assignment/employee/{employeeId}';
  static const String employeeSchedule =
      '/task-assignment/employee/{employeeId}/schedule';
  static const String taskAssignmentsByTask = '/task-assignment/task/{taskId}';
  static const String createTaskAssignment = '/task-assignment';
  static const String bulkCreateTaskAssignment = '/task-assignment/bulk/create';
  static const String markTaskAsCompleted = '/task-assignment/task/{taskId}/complete';
  static const String reassignTaskAssignment = '/task-assignment/{assignmentId}/reassign';
  static const String employees = '/employee';
  static const String employeeDetails = '/employee/{id}';
  static const String updateEmployee = '/employee/{id}';
  static const String deleteEmployee = '/employee/{id}';
  static const String createEmployeeWithUser = '/employee/with-user/create';
  static const String teamMembers = '/team/members';
  static const String teamMemberDetails = '/team/members/{id}';
  static const String addTeamMember = '/team/members';
  static const String updateTeamMember = '/team/members/{id}';
  static const String removeTeamMember = '/team/members/{id}';
  static const String teamByProject = '/projects/{projectId}/team';
  static const String analytics = '/analytics';
  static const String analyticsDashboard = '/analytics/dashboard';
  static const String analyticsProjects = '/analytics/projects';
  static const String analyticsTasks = '/analytics/tasks';
  static const String settings = '/settings';
  static const String updateSettings = '/settings';
  static const String notifications = '/settings/notifications';
  static const String uploadFile = '/upload';
  static const String uploadAvatar = '/upload/avatar';
  static const String createClient = '/user';
  static const String deleteClient = '/user/{id}';
  static const String projectDelaySummary = '/project-delay/summary';
  static const String projectDelay = '/project-delay';
  static const String projectDelayByProject = '/project-delay/project/{projectId}';
  static const String projectTaskDelays = '/project-delay/project/{projectId}/tasks';
  static String replacePathParams(String path, Map<String, String> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static String buildUrlWithParams(
    String endpoint,
    Map<String, String> params,
  ) {
    final path = replacePathParams(endpoint, params);
    return buildUrl(path);
  }
}
