import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/project_model.dart';
import '../../data/repository/projects_repository.dart';
import '../../view/widgets/common/sort_dropdown.dart';
abstract class ProjectDashboardController extends GetxController {
  List<ProjectModel> get projects;
  SortOption get selectedSortOption;
  StatusRequest get statusRequest;
  bool get isLoading;
  Map<String, dynamic> get stats;
  bool get isLoadingStats;
  void changeSortOption(SortOption option);
  Future<void> loadProjects({bool refresh = false});
  Future<void> loadStats();
}
class ProjectDashboardControllerImp extends ProjectDashboardController {
  final ProjectsRepository _repository = ProjectsRepository();
  final AuthService _authService = AuthService();
  List<ProjectModel> _projects = [];
  SortOption _selectedSortOption = SortOption.deadline;
  StatusRequest _statusRequest = StatusRequest.none;
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  bool _isLoadingStats = false;
  @override
  List<ProjectModel> get projects => _projects;
  @override
  SortOption get selectedSortOption => _selectedSortOption;
  @override
  StatusRequest get statusRequest => _statusRequest;
  @override
  bool get isLoading => _isLoading;
  @override
  Map<String, dynamic> get stats => _stats;
  @override
  bool get isLoadingStats => _isLoadingStats;
  @override
  void onInit() {
    super.onInit();
    loadProjects();
    // Stats will be calculated from projects data instead of separate API call
  }
  @override
  Future<void> loadProjects({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    _isLoading = true;
    _statusRequest = StatusRequest.loading;
    update();
    try {
      final companyId = await _authService.getCompanyId();
      if (companyId == null || companyId.isEmpty) {
        debugPrint('🔴 CompanyId is required but not found');
        _isLoading = false;
        _statusRequest = StatusRequest.serverFailure;
        update();
        return;
      }
      final result = await _repository.getProjects(
        page: 1,
        limit: 10,
        companyId: companyId,
      );
      _isLoading = false;
      result.fold(
        (error) {
          debugPrint('🔴 Error loading projects: $error');
          _statusRequest = error;
          _projects = [];
        },
        (projectsList) {
          debugPrint('✅ Loaded ${projectsList.length} projects');
          _projects = projectsList;
          _statusRequest = StatusRequest.success;
          _sortProjects();
          // Calculate stats from loaded projects
          _calculateStatsFromProjects();
          _isLoadingStats = false;
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading projects: $e');
      _isLoading = false;
      _statusRequest = StatusRequest.serverException;
      _projects = [];
    }
    update();
  }
  @override
  Future<void> loadStats() async {
    // Calculate stats from projects data instead of calling API
    _isLoadingStats = true;
    update();
    try {
      // Stats will be calculated from _projects list
      _calculateStatsFromProjects();
    } catch (e) {
      debugPrint('🔴 Exception calculating project stats: $e');
      _stats = {};
    }
    _isLoadingStats = false;
    update();
  }
  
  void _calculateStatsFromProjects() {
    // Calculate stats from projects list
    final activeProjects = _projects.where((p) => 
      p.status.toLowerCase() == 'active' || 
      p.status.toLowerCase() == 'in_progress'
    ).length;
    
    // Calculate total tasks from projects
    final totalTasks = _projects.fold<int>(
      0, 
      (sum, project) => sum + (project.totalTasks ?? 0)
    );
    
    // Calculate completion rate
    double totalProgress = 0.0;
    int projectsWithProgress = 0;
    for (var project in _projects) {
      if (project.progressPercentage != null) {
        totalProgress += project.progressPercentage!;
        projectsWithProgress++;
      }
    }
    final avgCompletionRate = projectsWithProgress > 0 
        ? (totalProgress / projectsWithProgress) 
        : 0.0;
    
    _stats = {
      'activeProjects': activeProjects,
      'totalTasks': totalTasks,
      'teamMembers': _projects.fold<int>(0, (sum, p) => sum + (p.teamMembers)),
      'completionRate': avgCompletionRate,
    };
    debugPrint('✅ Calculated stats from projects: $_stats');
  }
  @override
  void changeSortOption(SortOption option) {
    _selectedSortOption = option;
    _sortProjects();
    update();
  }
  void _sortProjects() {
    final sortedProjects = List<ProjectModel>.from(_projects);
    switch (_selectedSortOption) {
      case SortOption.deadline:
        sortedProjects.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      case SortOption.projectStatus:
        sortedProjects.sort((a, b) => a.status.compareTo(b.status));
        break;
    }
    _projects = sortedProjects;
  }
  // Helper methods to get stats values
  int get activeProjectsCount {
    if (_stats.isEmpty) return 0;
    return _stats['activeProjects'] ?? _stats['active'] ?? 0;
  }
  int get totalTasksCount {
    if (_stats.isEmpty) return 0;
    return _stats['totalTasks'] ?? _stats['tasks'] ?? 0;
  }
  int get teamMembersCount {
    if (_stats.isEmpty) return 0;
    return _stats['teamMembers'] ?? _stats['members'] ?? 0;
  }
  double get completionRate {
    if (_stats.isEmpty) return 0.0;
    final rate = _stats['completionRate'] ?? 
                 _stats['completion'] ?? 
                 _stats['progress'] ?? 
                 0.0;
    if (rate is num) return rate.toDouble();
    return 0.0;
  }
}
