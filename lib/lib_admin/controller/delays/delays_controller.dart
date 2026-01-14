import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/project_model.dart';
import '../../data/repository/delays_repository.dart';
import '../../data/repository/projects_repository.dart';

class DelaysController extends GetxController {
  final DelaysRepository _delaysRepository = DelaysRepository();
  final ProjectsRepository _projectsRepository = ProjectsRepository();
  final AuthService _authService = AuthService();

  // Delay Summary
  Map<String, dynamic>? _delaySummary;
  StatusRequest _summaryStatusRequest = StatusRequest.none;
  bool _isLoadingSummary = false;

  // All Projects Delay Status
  List<dynamic> _allProjectsDelayStatus = [];
  StatusRequest _allProjectsStatusRequest = StatusRequest.none;
  bool _isLoadingAllProjects = false;

  // Project Delay Status (Single Project)
  Map<String, dynamic>? _projectDelayStatus;
  StatusRequest _projectDelayStatusRequest = StatusRequest.none;
  bool _isLoadingProjectDelay = false;

  // Project Task Delays
  List<dynamic> _projectTaskDelays = [];
  StatusRequest _projectTaskDelaysStatusRequest = StatusRequest.none;
  bool _isLoadingProjectTaskDelays = false;

  // Projects list for dropdowns
  List<ProjectModel> _projects = [];
  String? _selectedProjectId;
  bool _isLoadingProjects = false;

  // Getters
  Map<String, dynamic>? get delaySummary => _delaySummary;
  StatusRequest get summaryStatusRequest => _summaryStatusRequest;
  bool get isLoadingSummary => _isLoadingSummary;

  List<dynamic> get allProjectsDelayStatus => _allProjectsDelayStatus;
  StatusRequest get allProjectsStatusRequest => _allProjectsStatusRequest;
  bool get isLoadingAllProjects => _isLoadingAllProjects;

  Map<String, dynamic>? get projectDelayStatus => _projectDelayStatus;
  StatusRequest get projectDelayStatusRequest => _projectDelayStatusRequest;
  bool get isLoadingProjectDelay => _isLoadingProjectDelay;

  List<dynamic> get projectTaskDelays => _projectTaskDelays;
  StatusRequest get projectTaskDelaysStatusRequest => _projectTaskDelaysStatusRequest;
  bool get isLoadingProjectTaskDelays => _isLoadingProjectTaskDelays;

  List<ProjectModel> get projects => _projects;
  String? get selectedProjectId => _selectedProjectId;
  bool get isLoadingProjects => _isLoadingProjects;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  // Load projects for dropdowns
  Future<void> loadProjects() async {
    _isLoadingProjects = true;
    update();

    try {
      final companyId = await _authService.getCompanyId();
      final result = await _projectsRepository.getProjects(
        page: 1,
        limit: 100,
        companyId: companyId,
      );

      result.fold(
        (error) {
          debugPrint('🔴 Error loading projects: $error');
          _projects = [];
        },
        (projectsList) {
          debugPrint('✅ Loaded ${projectsList.length} projects for dropdown');
          _projects = projectsList;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading projects: $e');
      _projects = [];
    } finally {
      _isLoadingProjects = false;
      update();
    }
  }

  // Select project for dropdowns
  void selectProject(String? projectId) {
    _selectedProjectId = projectId;
    // Clear related data when project changes
    _projectDelayStatus = null;
    _projectTaskDelays = [];
    _projectDelayStatusRequest = StatusRequest.none;
    _projectTaskDelaysStatusRequest = StatusRequest.none;
    update();
  }

  // Load Delay Summary
  Future<void> loadDelaySummary() async {
    _isLoadingSummary = true;
    _summaryStatusRequest = StatusRequest.loading;
    update();

    try {
      final result = await _delaysRepository.getDelaySummary();

      result.fold(
        (error) {
          debugPrint('🔴 Error loading delay summary: $error');
          _summaryStatusRequest = error;
          _delaySummary = null;
        },
        (summary) {
          debugPrint('✅ Delay summary loaded successfully');
          _delaySummary = summary;
          _summaryStatusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading delay summary: $e');
      _summaryStatusRequest = StatusRequest.serverException;
      _delaySummary = null;
    } finally {
      _isLoadingSummary = false;
      update();
    }
  }

  // Load All Projects Delay Status
  Future<void> loadAllProjectsDelayStatus({int page = 1, int limit = 10}) async {
    _isLoadingAllProjects = true;
    _allProjectsStatusRequest = StatusRequest.loading;
    update();

    try {
      final result = await _delaysRepository.getAllProjectsDelayStatus(
        page: page,
        limit: limit,
      );

      result.fold(
        (error) {
          debugPrint('🔴 Error loading all projects delay status: $error');
          _allProjectsStatusRequest = error;
          _allProjectsDelayStatus = [];
        },
        (data) {
          debugPrint('✅ All projects delay status loaded successfully');
          // Extract projects list from response
          if (data['projects'] != null && data['projects'] is List) {
            _allProjectsDelayStatus = data['projects'] as List<dynamic>;
          } else {
            _allProjectsDelayStatus = [];
          }
          _allProjectsStatusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading all projects delay status: $e');
      _allProjectsStatusRequest = StatusRequest.serverException;
      _allProjectsDelayStatus = [];
    } finally {
      _isLoadingAllProjects = false;
      update();
    }
  }

  // Load Project Delay Status (Single Project)
  Future<void> loadProjectDelayStatus() async {
    if (_selectedProjectId == null || _selectedProjectId!.isEmpty) {
      debugPrint('⚠️ No project selected');
      return;
    }

    _isLoadingProjectDelay = true;
    _projectDelayStatusRequest = StatusRequest.loading;
    update();

    try {
      final result = await _delaysRepository.getProjectDelayStatus(_selectedProjectId!);

      result.fold(
        (error) {
          debugPrint('🔴 Error loading project delay status: $error');
          _projectDelayStatusRequest = error;
          _projectDelayStatus = null;
        },
        (status) {
          debugPrint('✅ Project delay status loaded successfully');
          _projectDelayStatus = status;
          _projectDelayStatusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading project delay status: $e');
      _projectDelayStatusRequest = StatusRequest.serverException;
      _projectDelayStatus = null;
    } finally {
      _isLoadingProjectDelay = false;
      update();
    }
  }

  // Load Project Task Delays
  Future<void> loadProjectTaskDelays({int page = 1, int limit = 10}) async {
    if (_selectedProjectId == null || _selectedProjectId!.isEmpty) {
      debugPrint('⚠️ No project selected');
      return;
    }

    _isLoadingProjectTaskDelays = true;
    _projectTaskDelaysStatusRequest = StatusRequest.loading;
    update();

    try {
      final result = await _delaysRepository.getProjectTaskDelays(
        projectId: _selectedProjectId!,
        page: page,
        limit: limit,
      );

      result.fold(
        (error) {
          debugPrint('🔴 Error loading project task delays: $error');
          _projectTaskDelaysStatusRequest = error;
          _projectTaskDelays = [];
        },
        (data) {
          debugPrint('✅ Project task delays loaded successfully');
          // Extract tasks list from response
          if (data['tasks'] != null && data['tasks'] is List) {
            _projectTaskDelays = data['tasks'] as List<dynamic>;
          } else {
            _projectTaskDelays = [];
          }
          _projectTaskDelaysStatusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading project task delays: $e');
      _projectTaskDelaysStatusRequest = StatusRequest.serverException;
      _projectTaskDelays = [];
    } finally {
      _isLoadingProjectTaskDelays = false;
      update();
    }
  }
}

